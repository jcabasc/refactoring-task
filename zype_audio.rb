require 'aes_crypt'

class Player::ZypeAudio < Player
  include PlayerMixin
  field :audio_required, type: :boolean, default: true

  class Renderer
    include Player::Manifest

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

    def audio_outputs
      @data_source.outputs.in(preset_id: @data_source.site.audio_preset_ids)
    end

    def audio_files
      audio_outputs.collect{|o| {file: o.download_url,label: o.bitrate}}
    end

    def render
      # build out base player with media information,
      # core settings including width, height, aspect ratio
      # auto start, skin
      @options[:sources] = audio_files
      @options[:height] = "30px"
      player = PlayerBuilder.build(@data_source, @options)

      # if google analytics is required merge in the plugin
      if google_analytics_required?
        player.merge!(ga_plugin)
      end

      player.to_json
    end

    def google_analytics_required?
      @data_source.site.ga_enabled?
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
  end
end
