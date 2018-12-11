class SessionTimestamp
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :session
  field :closed, type: Boolean, default: false

  def duration
    closed ? updated_at - created_at : Time.now - created_at
  end
end
