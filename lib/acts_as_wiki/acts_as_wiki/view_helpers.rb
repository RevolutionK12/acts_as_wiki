module ActsAsWiki::Markable
	module FormTagHelper
		def wiki_text_field_tag(name, value = nil, options = {})
			text_field_tag(name, value, options)
		end
		
		def wiki_text_area(name, value = nil, options = {})
			text_field_tag(name, value, options)
		end
	end
	
	module FormBuilder
		def wiki_text_field(method, options = {})
			@template.send(
				"wiki_text_field",
				@object_name,
				method,
				objectify_options(options)
			)
		end
		def wiki_text_area(method, options = {})
			@template.send(
				"wiki_text_area",
				@object_name,
				method,
				objectify_options(options)
			)
		end
	end
	
	module FormHelper
		
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
		
		def wiki_text_area(object_name, method, options = {})
			if @object.responds_to?(:has_markup?)
				if @object.has_markup?
					fields_for :wiki_markup do |w_markup|
						w_markup.text_area :markup, options
					end
				else
					text_area object_name, method, options
				end
			else
				text_area object_name, method, options
			end
		end
	end
end