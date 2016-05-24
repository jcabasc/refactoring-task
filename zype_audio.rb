require 'aes_crypt'

class Player::ZypeAudio < Player
  include PlayerMixin
  field :audio_required, type: :boolean, default: true

  class Renderer
    include BaseRenderer
    include RendererMixin
    include Player::Manifest

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

  end
end
