# frozen_string_literal: true
require 'rake_helper'
include RakeHelper
require 'auth_utilities'

namespace :tagteam do
  desc 'Parse out image URLs from all feed items'
  task set_image_urls: :environment do |_t|
    bar = ProgressBar.new(FeedItem.count)
    FeedItem.find_each do |fi|
      fi.method('set_image_url').call
      fi.save! if fi.changed?
      bar.increment!
    end
  end

  desc 'Remove taggings that should not exist'
  task destroy_spurious_taggings: :environment do
    puts 'Destroying by SQL'
    # Destroy the easy ones first to save time.
    ActsAsTaggableOn::Tagging.find_by_sql("select taggings.* from taggings join
    tag_filters on taggings.tagger_id = tag_filters.id where
    taggings.tagger_type = 'TagFilter' and tag_filters.scope_type = 'FeedItem'
    and tag_filters.scope_id != taggings.taggable_id;").map(&:destroy)

    puts 'Destroying by ruby'
    bar = ProgressBar.new(ActsAsTaggableOn::Tagging.where(tagger_type: 'TagFilter').count)
    ActsAsTaggableOn::Tagging.where(tagger_type: 'TagFilter').find_each do |tagging|
      unless tagging.tagger.items_in_scope.pluck(:id).include? tagging.taggable_id
        tagging.destroy
      end
      bar.increment!
    end
  end

  desc 'Reapply all filters in a hub'
  task :reapply_filters, [:hub_id] => :environment do |_t, args|
    if args[:hub_id]
      RecalcAllItems.new.perform(args[:hub_id])
    else
      Hub.order(:id).each do |hub|
        RecalcAllItems.new.perform(hub.id)
      end
    end
  end

  desc 'auto import feeds from json'
  task :auto_import_from_json, [:json_url, :hub_title, :owner_email] => :environment do |_t, args|
    include FeedUtilities

    response = fetch(args[:json_url])
    feeds = ActiveSupport::JSON.decode(response.body)

    add_example_feeds(args[:hub_title], feeds, args[:owner_email])
  end

  desc 'dump documentation'
  task dump_documentation: :environment do
    f = File.open("#{Rails.root}/db/documentation.yml", 'w')
    f.write(Documentation.all.to_yaml)
    f.close
  end

  desc 'expire file cache'
  task expire_file_cache: :environment do
    ExpireFileCache.new.perform
  end

  desc 'update feeds'
  task update_feeds: :environment do
    UpdateFeeds.new.perform
  end

  desc 'Transmogrifies feed titles from email@example.com\'s bookmarks to username\'s bookmarks'
  task cleanup_titles: :environment do
    Feed.where(bookmarking_feed: true).each do |f|
      u = User.where(["roles.authorizable_id = ? and roles.authorizable_type = 'Feed' and roles.name ='creator'", f.id]).joins(:roles).first
      if u && f.title.include?(u.email)
        puts "feed #{f.id}: #{f.title} => '#{u.username}\'s boookmarks'"
        f.update_attribute(:title, "#{u.username}'s bookmarks")
      end
    end
  end

  desc 'clean up orphaned items'
  task clean_orphan_items: :environment do
    original_sunspot_session = Sunspot.session
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(original_sunspot_session)

    conn = ActiveRecord::Base.connection

    results = conn.execute('select id from feeds where id not in(select feed_id from hub_feeds group by feed_id)')
    puts "Destroying Feeds #{results.collect { |r| r['id'] }.join(',')}"
    Feed.destroy(results.collect { |r| r['id'] })

    results = conn.execute('select id from feed_items except (select distinct feed_item_id from feed_items_feeds)')
    puts "Destroying #{results.count} FeedItems #{results.first(4).collect { |r| r['id'] }.join(',')}"
    results.each { |r| FeedItem.destroy(r['id']) }

    Role.includes(:authorizable).where('authorizable_id is not null').all.each do |r|
      if r.authorizable.blank?
        puts "Destroying Role #{r.id}"
        Role.destroy(r.id)
      end
    end

    Sunspot.session = original_sunspot_session
  end

  desc 'Fix tag names with commas in them'
  task fix_tag_names_with_commas: :environment do
    affected_tags = ActsAsTaggableOn::Tag.where('name LIKE \'%,%\'')

    affected_tags.each do |tag|
      tag_name = tag.name
      name_tags = tag_name.split(',') - ['', nil]
      is_multiple = name_tags.length > 1
      filters_with_tag = TagFilter.where(tag: tag)
      filter_with_new_as_tag = TagFilter.where(new_tag: tag)

      if is_multiple
        taggings = tag.taggings

        name_tags.each do |name_tag|
          name_tag = name_tag.strip

          existing_tag = ActsAsTaggableOn::Tag
                         .where('name=?', name_tag).first

          tag_to_tag = if existing_tag.nil?
                         ActsAsTaggableOn::Tag.create(
                           name: name_tag
                         )
                       else
                         existing_tag
                       end

          taggings.each do |tagging|
            new_tagging = tagging.dup

            new_tagging.tag_id = tag_to_tag.id

            new_tagging.save!

            tagging.destroy
          end

          unless filters_with_tag.empty?
            filters_with_tag.each do |filter_with_tag|
              new_filter = filter_with_tag.dup

              new_filter.tag = tag_to_tag

              new_filter.save(validate: false)
            end
          end

          unless filter_with_new_as_tag.empty?
            filter_with_new_as_tag.each do |filter_with_tag|
              new_filter = filter_with_tag.dup

              new_filter.new_tag = tag_to_tag

              new_filter.save(validate: false)
            end
          end
        end

        tag.destroy
        filters_with_tag.destroy_all
        filter_with_new_as_tag.destroy_all
      else
        tag.name = tag.name.gsub(',', '').strip
        tag.save!
      end
    end
  end
end
