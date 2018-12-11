require 'redcarpet'

class Question
  include Mongoid::Document

  belongs_to :quiz, :inverse_of => :questions
  field :order, type: Integer, default: 0
  field :type, type: String
  field :title, type: String
  field :content, type: String
  embeds_many :options

  accepts_nested_attributes_for :options, :allow_destroy => true

  validates_presence_of :type, :title, :content
  validates_length_of :type, :title, maximum: 255
  validates_inclusion_of :type, in: %w(radio checkbox input code)

  def type_enum
    %w(radio checkbox input code)
  end

  rails_admin do
    list do
      sort_by 'quiz ASC, order ASC'
      field :id
      field :quiz
      field :order
      field :type
      field :title
      field :content
      field :options do
        label do
          'Options count'
        end
        pretty_value do
          bindings[:object].options.count
        end
      end
    end

    configure :content do
      help 'Markdown is allowed.'

      # used in list view columns and show views, defaults to formatted_value for non-association fields
      pretty_value do
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, highlight: true, strikethrough: true)
        markdown.render(value).html_safe
      end
    end
  end

  # calculate question weight on the fly
  def weight
    options.reduce(0) { |memo, option| option.weight > 0 ? memo + option.weight : memo }
  end
end
