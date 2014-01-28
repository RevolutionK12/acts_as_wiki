module ActsAsWiki::Markable
  module Core
    def self.included(base)
      require 'redcloth'
      require 'red_cloth_custom'

      base.send :include, ActsAsWiki::Markable::Core::InstanceMethods
      base.extend ActsAsWiki::Markable::Core::ClassMethods

      base.initialize_acts_as_wiki_core
    end

    module ClassMethods

      def initialize_acts_as_wiki_core
        unless acts_as_wiki_disabled?
          class_eval do
            has_many :wiki_markups, :as => :markable, :class_name => "ActsAsWiki::WikiMarkup", :dependent => :destroy
            accepts_nested_attributes_for :wiki_markups, :reject_if => :all_blank
          end
        end
      end

      def disable_acts_as_wiki
        class_eval do
          @acts_as_wiki_disabled = true
        end
      end

      def acts_as_wiki_disabled?
         @acts_as_wiki_disabled == true
      end

    end

    module InstanceMethods

      def allow_markup!
        return if self.class.acts_as_wiki_disabled?

        wiki_columns.each do |column|
          value = self.__send__(column)
          if value.present?
            create_wiki_markup(value, column)
          end
        end
        reload
      end

      def create_wiki_markup(val, col)
        self.wiki_markups.create!(:markup => val, :column => col.to_s)
      end

      def clone_markups(cloned_markable)
        self.wiki_markups.each do |wm|
          cloned_wiki_markup = cloned_markable.wiki_markups.select {|cwm| cwm.column == wm.column}.first
          cloned_wiki_markup = cloned_wiki_markup || cloned_markable.wiki_markups.build(:markup => wm.markup, :column => wm.column)
          cloned_wiki_markup.markup = wm.markup
          cloned_wiki_markup.save!
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
          self.wiki_markups.select { |wm| wm.column == column }.first
        else
          column.nil? ? self.wiki_markups.first : self.wiki_markups.where(:column => column.to_s).first
        end
      end

    end
  end
end
