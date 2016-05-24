require 'aes_crypt'

class Player::Zype < Player
  include PlayerMixin

  field :ad_tag_required, type: :boolean, default: true
  class Renderer
    include BaseRenderer
    include Player::Manifest

    def render
      # build out base player with media information,
      # core settings including width, height, aspect ratio
      # a uto start, skin
      @options[:sources] = [{file: manifest_url}]
      @options[:image] = default_thumbnail_url
      @options[:tracks] = subtitles
      @options[:aspectratio] = "16:9"
      @options[:abouttext] = @data_source.site.title
      @options[:aboutlink] = @data_source.site.player_logo_link
      player = PlayerBuilder.build(@data_source, @options)

      # if player logo is present merge in the plugin
      if logo_present?
        player.merge!(logo_plugin)
      end

      # if age gate is required merge in the plugin
      if age_gate_required?
        player[:plugins].merge!(age_gate_plugin)
        # disable autostart when age gate enabled
        player[:autostart] = false
      end
      # if google analytics is required merge in the plugin
      if google_analytics_required?
        player.merge!(ga_plugin)
      end

      if player_sharing_enabled?
        player.merge!(sharing: {})
      end

      if ad_tag = @options[:ad_tag]
        ad_tag.web_render(player,@data_source,@options)
      end

      player.to_json
    end

    def logo_present?
      @data_source.site.player_logo.present?
    end

    def age_gate_required?
      @data_source.video.age_gate_required?
    end

    def google_analytics_required?
      @data_source.site.ga_enabled?
    end

    def player_sharing_enabled?
      @data_source.site.player_sharing_enabled?
    end

    def content_url(path)
      options = {
        host: APP_CONFIG[:content_host],
        port: (referer_https? ? APP_CONFIG[:https_port] : APP_CONFIG[:http_port]),
        path: path
      }

      (referer_https? ? URI::HTTPS : URI::HTTP).build(options).to_s
    end

    def logo_plugin
      {
        logo: {
          file: @data_source.site.player_logo.url(:thumb),
          link: @data_source.site.player_logo_link,
          margin: @data_source.site.player_logo_margin,
          position: @data_source.site.player_logo_position,
          hide: @data_source.site.player_logo_hide
        }
      }
    end

    def subtitles
      @data_source.video.subtitles.active.order(language: :asc).collect do |s|
        { file: s.file.url,
          label: s.language_name,
          kind: 'captions' }
      end
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

    def age_gate_plugin
      {
        content_url("/jwplayer/agegate.js") => {
          cookielife: 60,
          minage: @data_source.video.site.age_gate_min_age
        }
      }
    end

    def default_thumbnail_url
      if t = @data_source.thumbnails.max_by(&:height)
        t.url
      end
    end
  end
end
