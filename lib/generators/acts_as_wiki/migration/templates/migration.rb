class ActsAsWikiMigration < ActiveRecord::Migration
  def self.up
		create_table :wiki_markups do |t|
			t.integer :markable_id
			t.string  :markable_type
			t.text    :markup
			t.string    :column
		end
		add_index :wiki_markups, [:markable_id, :markable_type]
  end

  def self.down
    drop_table :wiki_markups
  end
end
