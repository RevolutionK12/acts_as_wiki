module ActsAsWiki
  class WikiMarkup < ::ActiveRecord::Base
    # attr_accessible :markable_id, :markable_type, :markup, :column

    validates :markable_id, :markable_type, :column, :presence => true

    belongs_to :markable, :polymorphic => true

    after_save :cache_wiki_html

    def text
      "#{::RedCloth.new(self.markup || '').tap{|r| r.extend RedClothCustom}.to_html}"
    end

    protected

    def cache_wiki_html
      markable.__send__("#{column}=", text)
      markable.save!
    end

  end
end
