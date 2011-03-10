module ActsAsWiki
	class CustomWikiGenerator < Rails::Generators::Base
		
		def self.source_root
			File.join(File.dirname(__FILE__), 'templates')
		end
		
		def manifest
			template 'custom_redcloth.rb', 'lib/red_cloth_custom.rb', :collision => :skip
		end
		
	end
end