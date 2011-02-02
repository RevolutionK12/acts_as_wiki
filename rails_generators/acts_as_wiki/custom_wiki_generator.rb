module ActsAsWiki
	class CustomWikiGenerator < Rails::Generators::Base
		def manifest
			record do |m|
				m.template 'custom_redcloth.rb', 'lib/RedClothCustom.rb', :collision => :skip
			end
		end
	end
end