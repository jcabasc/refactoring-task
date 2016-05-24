require 'aes_crypt'

class Player::ZypeLiveAudio < Player::ZypeLive
  include PlayerMixin
  field :on_air_required, type: :boolean, default: true
  field :audio_required, type: :boolean, default: true

  class Renderer < BaseRenderer
    include Player::Manifest

    def manifest_params
      super.merge(audio: true)
    end

    def render
      # build out base player with media information,
      # core settings including width, height, aspect ratio
      # auto start, skin
      @options[:sources] = [{file: manifest_url}]
      @options[:height] = 30
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

  end
end
