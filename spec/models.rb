class MarkableModel < ActiveRecord::Base
	acts_as_wiki

  after_save :make_markup

  attr_accessor :no_markup

  def make_markup
    unless no_markup
      allow_markup!
    end
  end
end

class OtherMarkableModel < ActiveRecord::Base
	acts_as_wiki :column => 'other_column_text'
end

class MarkableModelSubClass < MarkableModel
  disable_acts_as_wiki
end
