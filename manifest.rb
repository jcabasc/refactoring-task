module Player::Manifest
  def manifest_params
    { video_id: @data_source.video.id, expires_at: manifest_expiration }
  end

  def manifest_token
    ManifestToken.new(manifest_params).encrypt(@data_source.video.signing_key)
  end

  def manifest_expiration
    @data_source.video.site.player_expiration.seconds.since.to_i
  end

  def manifest_url
    options = {
      host: APP_CONFIG[:manifest_host], 
      port: (APP_CONFIG[:manifest_https] ? APP_CONFIG[:https_port] : APP_CONFIG[:http_port]),
      path: "/manifest/#{@data_source.video.id}.m3u8",
      query: Rack::Utils.build_query(player_key: @data_source.video.player_key, token: manifest_token)
    }

    (APP_CONFIG[:manifest_https] ? URI::HTTPS : URI::HTTP).build(options).to_s
  end
end