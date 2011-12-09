module ActsAsWiki
	class WikiMarkup < ::ActiveRecord::Base
		
		belongs_to :markable, :polymorphic => true
		
		after_save :touch_markup
		
		def text
			"#{::RedCloth.new(self.markup || '').tap{|r| r.extend RedClothCustom}.to_html}"
		end
		
		protected
		
		def touch_markup
			logger.info("hi")
			self.markable.send("#{self.column}=", self.text)
			self.markable.save
		end
		
	end
end