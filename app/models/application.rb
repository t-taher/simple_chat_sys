class Application < ApplicationRecord
  before_create :generate_token

  protected
  def generate_token
    retries = 0
    begin
      self.token = SecureRandom.urlsafe_base64
      retries += 1
    rescue ActiveRecord::RecordNotUnique => e
      raise if retries > 5
      puts retries

      Rails.logger.warn("Collision occurred creating application token #{retries}")
      retry
    end
  end
end
