class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActionView::Helpers::TextHelper

  embedded_in :form, touch: true
  belongs_to :question, :inverse_of => :answers
  field :values, type: Array, default: Array.new
  field :score, type: Integer, default: 0

  rails_admin do
    edit do
      configure :score do
        hide
      end
    end
  end

  def title
    "#{question.title} (#{pluralize(score, 'point')})"
  end

  def recalculate
    self.score = calculate_score
  end

  private

  def validate
    if values.kind_of?(Array) && values.count > 0
      values.reduce(true) { |memo, a| a.kind_of?(String) ? memo : false }
    else
      false
    end
  end

  def calculate_score
    if validate
      if question.type === 'radio' || question.type ==='checkbox'
        reduce_options(values, method(:include_id?))
      elsif question.type === 'input'
        reduce_options(values, method(:include_string?))
      elsif question.type ==='code'
        reduce_options(values, method(:test_passed?))
      end
    else
      0
    end
  end

  def include_id?(values, option)
    values.include?(option[:id].to_s)
  end

  def include_string?(values, option)
    values.include?(option[:validator])
  end

  def test_passed?(values, option)
    ApplicationController.helpers.validate_javascript(values.first, option[:validator])
  end

  def reduce_options(values, comparator)
    question.options.reduce(0) do |memo, option|
      comparator.call(values, option) ? memo + option.weight : memo
    end
  end
end
