require 'aes_crypt'

class Player::ZypeLiveAudio < Player::ZypeLive
  field :on_air_required, type: :boolean, default: true
  field :audio_required, type: :boolean, default: true

  def build_player(data_source,options={})
    Player::ZypeLiveAudio::Renderer.new(data_source,options).render
  end

  class Renderer < Player::ZypeLive::Renderer
    include Player::Manifest

    def manifest_params
      super.merge(audio: true)
    end

    def render
      # build out base player with media information,
      # core settings including width, height, aspect ratio
      # auto start, skin
      player = {
        playlist: [{
          sources: [{file: manifest_url}],
          title: @data_source.video.title,
          mediaid: @data_source.video.id.to_s
        }],
        plugins: {},
        androidhls: true,
        autostart: @options[:autoplay] ? true : false,
        flashplayer: content_url('/jwplayer/6.11/jwplayer.flash.swf'),
        height: 30,
        html5player: content_url('/jwplayer/6.11/jwplayer.html5.js'),
        primary: APP_CONFIG[:player_default_mode],
        skin: APP_CONFIG[:player_default_skin],
        width: "100%"
      }

      # if google analytics is required merge in the plugin
      if @data_source.site.ga_enabled?
        player.merge!(ga_plugin)
      end

      player.to_json
    end
  end
end
