class Quiz
  include Mongoid::Document

  field :token, type: String, default: lambda { ApplicationController.helpers.get_token }
  field :title, type: String
  has_many :questions, :dependent => :destroy, :inverse_of => :quiz
  has_many :sessions, :dependent => :destroy, :inverse_of => :quiz

  accepts_nested_attributes_for :questions, :allow_destroy => true
  accepts_nested_attributes_for :sessions, :allow_destroy => true

  validates_presence_of :title
  validates_length_of :title, maximum: 255

  rails_admin do
    list do
      field :id
      field :token
      field :title
      field :questions do
        label do
          'Questions count'
        end
        pretty_value do
          bindings[:object].questions.count
        end
      end
    end

    edit do
      configure :token do
        hide
      end
      configure :questions do
        hide
      end
      configure :sessions do
        hide
      end
    end
  end

  def self.find_by_token(token)
    self.find_by({ token: token })
  end

  # calculate quiz weight on the fly
  def weight
    questions.reduce(0) { |memo, question| question.weight > 0 ? memo + question.weight : memo }
  end
end
