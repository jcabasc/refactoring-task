module RendereMixin
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

  def content_url(path)
    options = {
      host: APP_CONFIG[:content_host],
      port: (referer_https? ? APP_CONFIG[:https_port] : APP_CONFIG[:http_port]),
      path: path
    }

    (referer_https? ? URI::HTTPS : URI::HTTP).build(options).to_s
  end

  def ga_plugin
    {
      ga: {
        idstring: "title",
        trackingobject: @data_source.video.site.ga_object,
        label: "title"
      }
    }
  end

  def google_analytics_required?
    @data_source.site.ga_enabled?
  end

end
