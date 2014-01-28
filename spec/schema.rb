ActiveRecord::Schema.define :version => 0 do
	create_table :wiki_markups, :force => true do |t|
		t.integer :markable_id
		t.string  :markable_type
		t.text    :markup
    t.string  :column
	end
	
	add_index :wiki_markups, [:markable_id, :markable_type]
	
	create_table :markable_models, :force => true do |t|
		t.text :text
	end
	
	create_table :other_markable_models, :force => true do |t|
		t.text :other_column_text
	end
	
	create_table :associated_markables, :force => true do |t|
    t.integer :markable_model_id
		t.text :text
	end
	
end
