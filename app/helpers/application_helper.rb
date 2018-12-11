require 'digest/md5'

module ApplicationHelper
  def get_token
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def get_id_token(id)
    Digest::SHA1.hexdigest([id, Time.now, rand].join)
  end
end
