require "active_record"
require "active_support"
require "action_view"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'acts_as_wiki/acts_as_wiki'
require 'acts_as_wiki/wiki_markup'
require 'acts_as_wiki/acts_as_wiki/core'
require 'acts_as_wiki/acts_as_wiki/view_helpers'

$LOAD_PATH.shift

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend ActsAsWiki::Markable
  ActiveRecord::Base.send :include, ActsAsWiki::Markable
end

if defined?(ActionView::Helpers::FormHelper)
	ActionView::Helpers::FormHelper.send :include, ActsAsWiki::Markable::FormHelper
end

if defined?(ActionView::Helpers::FormBuilder) 
	ActionView::Helpers::FormBuilder.send :include, ActsAsWiki::Markable::FormBuilder
end

if defined?(ActionView::Helpers::FormTagHelper)
	ActionView::Helpers::FormTagHelper.send :include, ActsAsWiki::Markable::FormTagHelper
end