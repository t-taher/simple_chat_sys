class Application < ApplicationRecord

  def save
    if new_record?
      retries = 0
      begin
        self.token = SecureRandom.urlsafe_base64
        retries += 1
        super
      rescue ActiveRecord::RecordNotUnique => e
        raise if retries > 5
        Rails.logger.warn("Collision occurred creating application token #{retries}")
        retry
        end
    else
      super
    end
  end
end
