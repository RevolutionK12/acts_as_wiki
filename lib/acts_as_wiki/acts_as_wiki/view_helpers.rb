module ActsAsWiki::Markable
	module ViewHelpers
		def wiki_text_field_tag(name, value = nil, options = {})
			text_field_tag(name, value, options)
		end
	end
	
	module FormTagHelpers
		def wiki_text_field(object_name, method, options = {})
			if @object.responds_to?(:has_markup?)
				if @object.has_markup?
					fields_for :wiki_markup do |w_markup|
						w_markup.text_field :markup, options
					end
				else
					text_field object_name, method, options
				end
			else
				text_field object_name, method, options
			end
		end
	end
end