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
					accepts_nested_attributes_for :wiki_markups, :reject_if => :all_blank
				end
			end
			
		end
		
		module InstanceMethods
			
			def allow_markup!
				if self.wiki_markups.present?
          self.wiki_markups.each do |wm|
            val = self.send(wm.column).to_s
            wm.destroy if val.blank? # Note: model must be reloaded to detect destroyed associations
          end
				else
          self.wiki_markups = wiki_columns.collect do |c|
            val = self.send(c).to_s
            ActsAsWiki::WikiMarkup.create!(:markup => val, :column => c.to_s) if val.present?
          end.compact
				end
        self.wiki_markups
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
					self.wiki_markups.select { |wm| wm.column == column }.first
				else
					column.nil? ? self.wiki_markups.first : self.wiki_markups.where(:column => column.to_s).first
				end
			end
			
			def cache_wiki_html
				if has_markup?
					wiki_columns.each do |col|
						if self.wiki_markup(col).nil?
              val = self.send(col)
              if val.present?
                wm = ActsAsWiki::WikiMarkup.create(:markup => val, :column => col.to_s)
                self.wiki_markups << wm
                self.send "#{col}=", wm.text
              end
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
