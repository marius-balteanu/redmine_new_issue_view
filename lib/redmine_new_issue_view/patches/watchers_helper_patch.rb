module NewIssueView
  module Patches
    module WatchersHelperPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          unloadable
          alias_method_chain :watcher_link, :span
        end
      end

      module InstanceMethods
        def watcher_link_with_span(objects, user)
          return '' unless user && user.logged?
          objects = Array.wrap(objects)
          return '' unless objects.any?

          watched = Watcher.any_watched?(objects, user)
          css = [watcher_css(objects), watched ? 'icon icon-del' : 'icon icon-fav-off'].join(' ')
          text = watched ? l(:button_unwatch) : l(:button_watch)
          url = watch_path(
            :object_type => objects.first.class.to_s.underscore,
            :object_id => (objects.size == 1 ? objects.first.id : objects.map(&:id).sort)
          )
          method = watched ? 'delete' : 'post'

          link_to content_tag('span', text), url, :remote => true, :method => method, :class => css
        end
      end
    end
  end
end

base = WatchersHelper
new_module = NewIssueView::Patches::WatchersHelperPatch
base.send :include, new_module unless base.included_modules.include? new_module
