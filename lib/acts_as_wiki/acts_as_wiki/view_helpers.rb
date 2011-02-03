module ActsAsWiki::Markable
	module WikiFormBuilder
		
		def self.included(base)
			base.class_eval do
				alias_method_chain :text_field, :wiki
				alias_method_chain :text_area, :wiki
			end
		end
		
		def text_field_with_wiki(method, options = {})
			if @object.respond_to?(:has_markup?) && @object.has_markup? && (method.to_s == @object.class.acts_as_wiki_options[:column])
				self.fields_for :wiki_markup do |w_markup|
					w_markup.text_field :markup, options
				end
			else
				text_field_without_wiki method, options
			end
		end
		
		def text_area_with_wiki(method, options = {})
			if @object.respond_to?(:has_markup?) && @object.has_markup? && (method.to_s == @object.class.acts_as_wiki_options[:column])
				self.fields_for :wiki_markup do |w_markup|
					w_markup.text_area :markup, options
				end
			else
				text_area_without_wiki method, options
			end
		end
	end
end