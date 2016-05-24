class BaseRenderer
  def initialize(data_source, options={})
    @data_source = data_source
    @options = options
    @referer_https = detect_referer_https
  end

  def detect_referer_https
    begin
      return APP_CONFIG[:player_https] if @options[:iframe]

      uri = URI.parse(@options[:referer])
      uri.scheme == 'https'
    rescue StandardError => e
      Rails.logger.warn("Could not determine scheme from referer: #{@options[:referer]}, defaulting to #{APP_CONFIG[:player_https]}")
      APP_CONFIG[:player_https]
    end
  end

  def referer_https?
    @referer_https == true
  end

end
