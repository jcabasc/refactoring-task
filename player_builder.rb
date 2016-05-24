class PlayerBuilder
  attr_reader :options, :data_source

  def self.build(data_source, options)
    new(data_source, options).build
  end
  def initialize(data_source, options)
    @options = options
    @data_source = data_source
  end

  def playlist_default_attrs
    {
      sources: options[:sources],
      title: data_source.video.title,
      mediaid: data_source.video.id.to_s,

    }.merge!(image.to_h).merge!(tracks.to_h)
  end


  def build
    {
      playlist: [
        playlist_default_attrs
      ],
      plugins: {},
      androidhls: true,
      autostart: options[:autoplay] ? true : false,
      flashplayer: content_url('/jwplayer/6.11/jwplayer.flash.swf'),
      html5player: content_url('/jwplayer/6.11/jwplayer.html5.js'),
      primary: APP_CONFIG[:player_default_mode],
      skin: APP_CONFIG[:player_default_skin],
      width: "100%"
    }.merge!(abouttext.to_h).merge!(aboutlink.to_h).merge!(aspectratio.to_h).merge!(height.to_h)
  end

  private

  ["image", "tracks", "abouttext", "aboutlink", "aspectratio", "height"].each do |attr|
    define_method("#{attr}") do
      attr_sym = attr.to_sym
      { attr_sym => options[attr_sym] } unless options[attr_sym].nil?
    end
  end

end
