$LOAD_PATH << "." unless $LOAD_PATH.include?(".")

require 'rspec'
require 'bundler'
require 'logger'
require File.expand_path('../../lib/acts_as_wiki', __FILE__)
require 'red_cloth_custom'

Bundler.setup

require 'RedCloth'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ENV['DB'] ||= 'mysql'

database_yml = File.expand_path('../database.yml', __FILE__)
if File.exists?(database_yml) 
	active_record_configuration = YAML.load_file(database_yml)[ENV['DB']]
	ActiveRecord::Base.establish_connection(active_record_configuration)
	ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))
	ActiveRecord::Base.silence do
    ActiveRecord::Migration.verbose = false
    load(File.dirname(__FILE__) + '/schema.rb')
    load(File.dirname(__FILE__) + '/models.rb')
  end
else
  raise "Please create #{database_yml} first to configure your database"
end

def clean_database!
	models = [ActsAsWiki::WikiMarkup, MarkableModel, OtherMarkableModel]
	models.each do |model|
		begin
			ActiveRecord::Base.connection.execute "DELETE from #{model.table_name}"
		rescue
			puts 'table might not exist'
		end
	end
end

clean_database!

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
