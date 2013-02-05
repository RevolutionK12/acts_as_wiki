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
          #require 'pry'; binding.pry
				if self.wiki_markups && !self.wiki_markups.empty?
					return self.wiki_markups
				else
					self.wiki_markups = wiki_columns.collect{|c| ActsAsWiki::WikiMarkup.create(:markup => self.send(c.to_s), :column => c.to_s)}
					self.wiki_markups
				end
			end
			
			def dissallow_markup!
				if !self.wiki_markups.empty?
					self.wiki_markups.each(&:destroy)
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
				self.has_markup? ? (self.wiki_markup(column || 'text').text rescue self.send("#{column || 'text'}")) : self.send("#{column || 'text'}")
			end

			def wiki_markup(column=nil)
				if self.wiki_markups.all?(&:new_record?)
					self.wiki_markups.collect{|wm| wm if wm.column == column.to_s}.first
				else
					column.nil? ? self.wiki_markups.first : self.wiki_markups.where(:column => column.to_s).first
				end
			end
			
			def cache_wiki_html
				if has_markup?
					wiki_columns.each do |col|
						if self.wiki_markup(col).nil?
							wm = ActsAsWiki::WikiMarkup.create(:markup => self.send(col), :column => col.to_s)
							self.wiki_markups << wm
							self.send "#{col}=", wm.text
						else
							self.send "#{col}=", self.wiki_markup(col).text
						end
					end
				end
				return true
			end
						
		end
	end
end
