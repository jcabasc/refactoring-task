require 'active_support/inflector'

module PlayerMixin
  def player_source
    File.read("#{Rails.root}/public/jwplayer/6.11/jwplayer.js")
  end

  def build_player(data_source,options={})
    "#{self.class}::Renderer".constantize.new(data_source,options).render
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

end
