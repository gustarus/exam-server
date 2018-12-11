require 'digest/md5'

module ValidationHelper

  def validate_javascript(original, validator)
    path_original = ensure_content(original, :original)
    path_validator = ensure_content(validator, :validator)
    result = system ("mocha #{path_validator} --target=#{path_original}")
    logger.info "[validator] The result of validating #{path_original} with #{path_validator} is #{result.to_s}."
    result
  end

  private

  def ensure_content(content, symbol)
    hash = Digest::SHA1.hexdigest(content)
    folder = Rails.root.join('tmp', 'tests', symbol.to_s)
    path = File.join(folder, hash)

    FileUtils.mkdir_p(folder) unless File.directory?(folder)
    unless File.file?(path)
      File.open(path, 'w+') { |f| f.write(content) }
    end

    path
  end
end
