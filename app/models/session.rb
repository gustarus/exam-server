class Session
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :quiz, :inverse_of => :sessions
  field :token, type: String, default: lambda { ApplicationController.helpers.get_token }
  field :active, type: Boolean, default: false
  field :finished, type: Boolean, default: false
  has_many :forms, :dependent => :destroy, :inverse_of => :session
  embeds_many :timestamps, class_name: 'SessionTimestamp'

  accepts_nested_attributes_for :forms, :allow_destroy => true
  accepts_nested_attributes_for :timestamps, :allow_destroy => true

  rails_admin do
    list do
      field :id
      field :quiz
      field :token
      field :active
      field :finished
      field :forms do
        label do
          'Forms count'
        end
        pretty_value do
          bindings[:object].forms.count
        end
      end
    end

    edit do
      configure :token do
        hide
      end
      configure :forms do
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

  def joinable?
    !finished
  end

  def writable?
    active && !finished
  end

  # calculate score on the fly
  def score
    forms.reduce(0) { |memo, form| memo + form.score }
  end

  def start
    update(active: true)
  end

  def pause
    update(active: false)
  end

  def finish
    update(active: false, finished: true)
  end

  def tick_start
    timestamps.create!(closed: false)
  end

  def tick_stop
    timestamps.where(closed: false).update(closed: true, updated_at: Time.now.to_s)
  end
end
