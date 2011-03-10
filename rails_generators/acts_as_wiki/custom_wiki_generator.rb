module ActsAsWiki
	class CustomWikiGenerator < Rails::Generators::Base
		def manifest
			record do |m|
				m.template 'custom_redcloth.rb', 'lib/red_cloth_custom.rb', :collision => :skip
			end
		end
	end
end