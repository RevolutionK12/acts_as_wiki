module ActsAsWiki
	class MigrationGenerator < Rails::Generators::Base
		def manifest 
	    record do |m| 
	      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "acts_as_wiki_migration"
	    end
	  end
	end
end