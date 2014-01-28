class MarkableModel < ActiveRecord::Base
	acts_as_wiki

  has_many :associated_markables
  accepts_nested_attributes_for :associated_markables, :reject_if => :all_blank

  after_create :make_markup

  attr_accessor :no_markup

  def make_markup
    unless no_markup
      allow_markup!
    end
  end
end

class OtherMarkableModel < ActiveRecord::Base
	acts_as_wiki :column => 'other_column_text'

  after_create :make_markup

  attr_accessor :no_markup

  def make_markup
    unless no_markup
      allow_markup!
    end
  end
end

class MarkableModelSubClass < MarkableModel
  disable_acts_as_wiki
end

class AssociatedMarkable < ActiveRecord::Base
  acts_as_wiki

  belongs_to :markable_model

  after_create :make_markup

  attr_accessor :no_markup

  def make_markup
    unless no_markup
      allow_markup!
    end
  end
end
