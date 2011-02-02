module ActsAsWiki
	class WikiMarkup < ::ActiveRecord::Base
		
		belongs_to :markable, :polymorphic => true
		
		def text
			"#{::RedCloth.new(self.markup || '').tap{|r| r.extend RedClothCustom}.to_html}"
		end
		
	end
end