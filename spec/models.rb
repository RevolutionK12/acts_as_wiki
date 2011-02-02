class MarkableModel < ActiveRecord::Base
	acts_as_wiki
end

class OtherMarkableModel < ActiveRecord::Base
	acts_as_wiki :column => 'other_column_text'
end