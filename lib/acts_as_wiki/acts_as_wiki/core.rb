module ActsAsWiki::Markable
	module Core
		def self.included(base)
			require 'redcloth'
			require 'red_cloth_custom'
			
			base.send :include, ActsAsWiki::Markable::Core::InstanceMethods
			base.extend ActsAsWiki::Markable::Core::ClassMethods
			
			base.class_eval do 
				before_save :cache_wiki_html
			end
			
			base.initialize_acts_as_wiki_core
		end
		
		module ClassMethods
			
			def initialize_acts_as_wiki_core
				class_eval do 
					has_many :wiki_markups, :as => :markable, :class_name => "ActsAsWiki::WikiMarkup", :dependent => :destroy
					accepts_nested_attributes_for :wiki_markups
				end
			end
			
		end
		
		module InstanceMethods
			
			def allow_markup!
				if self.wiki_markups && !self.wiki_markups.empty?
					return self.wiki_markups
				else
					self.wiki_markups = wiki_columns.collect{|c| ActsAsWiki::WikiMarkup.create(:markup => self.send(c), :column => c)}
					self.save
					self.wiki_markups
				end
			end
			
			def dissallow_markup!
				if !self.wiki_markups.empty?
					self.wiki_markup.each(&:destroy)
					self.wiki_markups = []
				end
			end
			
			def has_markup?
				!self.wiki_markups.empty?
			end
			
			def preview_text(column=nil)
				if self.has_markup? 
					column.nil? ? self.wiki_markups.first.markup : self.wiki_markup(column)
				else
					column.nil? ? self.send(wiki_columns.first) : self.send(column)
				end
			end
			
			def preview_markup(column=nil)
				self.has_markup? ? (column.nil? ? self.wiki_markups.first.text : self.wiki_markup(column).text) : self.text
			end
			
			def wiki_markup(column) 
				self.wiki_markups.where(:column => column).first
			end
						
			protected

			def cache_wiki_html
				if has_markup?
					wiki_columns.each do |col|
						self.send "#{col}=", self.wiki_markup(col).text
					end
				end
				return true
			end
			
		end
	end
end