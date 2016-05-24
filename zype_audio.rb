require 'aes_crypt'

class Player::ZypeAudio < Player
  field :audio_required, type: :boolean, default: true

  def player_source
    File.read("#{Rails.root}/public/jwplayer/6.11/jwplayer.js")
  end

  def build_player(data_source,options={})
    Player::ZypeAudio::Renderer.new(data_source,options).render
  end

  def render(data_source,options={})
    <<-EOS
#{player_source}

/** Write container **/
if(!document.getElementById('zype_#{data_source.video.id}')) {
  if(document.getElementById('zype_player')) {
    document.getElementById('zype_player').innerHTML = "<div id='zype_#{data_source.video.id}'></div>";
  } else {
    console.log('could not find zype container');
  }
}

jwplayer.key="#{APP_CONFIG[:jwplayer_key]}";
jwplayer("zype_#{data_source.video.id}").setup(#{build_player(data_source,options)});
EOS
  end

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
      player = {
        playlist: [{
          sources: audio_files,
          title: @data_source.video.title,
          mediaid: @data_source.video.id.to_s
        }],
        plugins: {},
        androidhls: true,
        autostart: @options[:autoplay] ? true : false,
        flashplayer: content_url('/jwplayer/6.11/jwplayer.flash.swf'),
        height: '30px',
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
