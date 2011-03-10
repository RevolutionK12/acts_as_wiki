module ActsAsWiki
	class MigrationGenerator < Rails::Generators::Base
		include Rails::Generators::Migration

		def self.source_root
			File.join(File.dirname(__FILE__), "templates")
		end

		def manifest 
			migration_template 'migration.rb', 'db/migrate/acts_as_wiki_migration'
		end
	end
end