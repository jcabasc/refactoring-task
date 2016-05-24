module BaseRenderer
  def initialize(data_source, options={})
    @data_source = data_source
    @options = options
    @referer_https = detect_referer_https
  end
end
