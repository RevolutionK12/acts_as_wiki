module ActsAsWiki
	module Markable

		##
		# This will add the ability to markup a given column of this model
		#
		# @param [Hash] opts A hash of options, the only one right now is which column to make wikiable
		#
		# Example:
		#   class Passage < ActiveRecord::Base
		#      acts_as_wiki :column => 'text' or [:text, :other_col]
		#   end
		def acts_as_wiki(opts = {})
			options = {
				:column => ['text']
			}.merge(opts)
			
      class_attribute :wiki_columns
      self.wiki_columns = [options[:column]].flatten.map{ |c| c.to_s }

			unless (is_acts_as_wiki? rescue false)
        class_attribute :acts_as_wiki_options
        self.acts_as_wiki_options = options

        class_attribute :is_acts_as_wiki
        self.is_acts_as_wiki = true

				class_eval do
					include ActsAsWiki::Markable::Core
				end
			end
		end
		
	end
end
