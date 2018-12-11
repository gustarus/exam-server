class Form
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :session, :inverse_of => :forms, touch: true
  field :token, type: String, default: lambda { ApplicationController.helpers.get_token }
  field :identity, type: String
  field :score, type: Integer, default: 0
  embeds_many :answers

  accepts_nested_attributes_for :answers, :allow_destroy => true

  validates_presence_of :identity

  rails_admin do
    list do
      field :id
      field :session
      field :token
      field :identity
      field :answers do
        label do
          'Answers count'
        end
        pretty_value do
          bindings[:object].answers.count
        end
      end
      field :score do
        label do
          'Answers score'
        end
      end
    end

    edit do
      configure :score do
        hide
      end
      configure :token do
        hide
      end
    end
  end

  def title
    "##{id.to_s}"
  end

  def self.find_by_token(token)
    self.find_by({ token: token })
  end

  def recalculate
    self.score = calculate_score
  end

  private

  def calculate_score
    answers.reduce(0) { |memo, answer| memo + answer.score }
  end
end


