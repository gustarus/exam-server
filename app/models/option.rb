class Option
  include Mongoid::Document
  include ActionView::Helpers::TextHelper

  embedded_in :question
  field :weight, type: Integer, default: 0
  field :content, type: String
  field :validator, type: String

  validates_presence_of :weight

  rails_admin do
    configure :content do
      help 'Used as label for radio and checkbox fields and as editor default content.'
    end

    configure :validator do
      help 'Used as backend validation helper for input and code questions.'
    end
  end

  def title
    "#{content}#{" (#{pluralize(weight, 'point')})" if weight > 0}"
  end
end
