module ActsAsWiki
	module Markable

		##
		# This will add the ability to markup a given column of this model
		#
		# @param [Hash] opts A hash of options, the only one right now is which column to make wikiable
		#
		# Example:
		#   class Passage < ActiveRecord::Base
		#      acts_as_wiki :column => 'text'
		#   end
		def acts_as_wiki(opts = {})
			
			options = {
				:column => 'text'
			}.merge(opts)
			
			write_inheritable_attribute :acts_as_wiki_options, options
			class_inheritable_reader    :acts_as_wiki_options
			
			class_eval do 
				include ActsAsWiki::Markable::Core
			end
			
		end
		
	end
end
