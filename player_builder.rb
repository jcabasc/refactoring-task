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
    }.merge!(about_text.to_h).merge!(about_link.to_h).merge!(aspect_ratio.to_h).merge!(height.to_h)
  end

  private

  def image
    { image: options[:image] } unless options[:image].nil?
  end

  def tracks
    { tracks: options[:tracks] } unless options[:tracks].nil?
  end

  def about_text
    { abouttext: options[:abouttext] } unless options[:abouttext].nil?
  end

  def about_link
    { aboutlink: options[:aboutlink] } unless options[:aboutlink].nil?
  end

  def aspect_ratio
    { aspectratio: options[:aspectratio] } unless options[:aspectratio].nil?
  end

  def height
    { height: options[:height] } unless options[:height].nil?
  end

end
