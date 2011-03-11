module ActsAsWiki::Markable
	module WikiFormBuilder
		
		def self.included(base)
			base.class_eval do
				alias_method_chain :text_field, :wiki
				alias_method_chain :text_area, :wiki
			end
		end
		
		def text_field_with_wiki(method, options = {})
			output = nil
			if @object.respond_to?(:has_markup?) && @object.has_markup? && (method.to_s == @object.class.acts_as_wiki_options[:column])
				output = fields_for(:wiki_markup) { |w_markup|
					w_markup.text_field_without_wiki :markup, options
				}
			else
				output = text_field_without_wiki method, options
			end
			output
		end
		
		def text_area_with_wiki(method, options = {})
			output = nil
			if @object.respond_to?(:has_markup?) && @object.has_markup? && (method.to_s == @object.class.acts_as_wiki_options[:column])
				output = fields_for(:wiki_markup){ |w_markup|
					w_markup.text_area_without_wiki :markup, options
				}
			else
				output = text_area_without_wiki method, options
			end
			output
		end
	end
end