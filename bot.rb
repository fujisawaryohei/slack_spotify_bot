require 'http'
require 'json'
require 'faye/websocket' #websocketをrubyでできるモジュール
require 'eventmachine' #同時並列処理を行えるモジュール
require 'rspotify'

RSpotify.authenticate(ENV['SPOTIFY_CLIENT_ID'],ENV['SPOTIFY_CLIENT_SECRET'])

response = HTTP.post("https://slack.com/api/rtm.start", params: {
    token: ENV['SLACK_API_TOKEN']})
    rc = JSON.parse(response.body)
    url = rc['url']

    EM.run do
      websocket = Faye::WebSocket::Client.new(url)
#ws.onでFaye/websocketで双方向通信を立ち上げる
       websocket.on :open do
        p [:open]
    end


#slackサーバーからメッセージイベントを受け取る
  websocket.on :message do |event|
    data = JSON.parse(event.data)
#nextはtrueでスキップする falseは終了
    next  if data['text'].nil?
    msg=data['text']
#consoleに出力
    p [:message,data]

    if msg=='こんにちは'
      ws.send({
        type: 'message',
        text: "こんにちは <@#{data['user']}> さん",
        channel: data['channel']
        }.to_json)
    end
#find(ids)
if msg.match(/^bgm/)
  text = "No result"
  if matched_msg = msg.match(/^bgm song (.*)/)
    track = RSpotify::Track.search(matched_msg[1]).first
    text = track.external_urls['spotify'] unless track.nil?
  elsif matched_msg = msg.match(/^bgm artist (.*)/)
    artist = RSpotify::Artist.search(matched_msg[1]).first
    text = artist.external_urls['spotify'] unless artist.nil?
  elsif matched_msg = msg.match(/^bgm album (.*)/)
    album = RSpotify::Album.search(matched_msg[1]).first
    text = album.external_urls['spotify'] unless album.nil?
  elsif matched_msg = msg.match(/^bgm playlist (.*)/)
    playlist = RSpotify::Playlist.search(matched_msg[1]).first
    text = playlist.external_urls['spotify'] unless playlist.nil?
  elsif matched_msg = msg.match(/^bgm recommend (.*)/)
    result = RSpotify::Recommendations.generate(seed_genres: [matched_msg[1]]).tracks.sample
    text = result.external_urls['spotify'] unless result.nil?
  end
end
  
 websocket.send({
	    type: 'message',
            text: text,
	    channel: data['channel']
	    }.to_json)
    end
   end


  websocket.on :close do
    p [:close, event.code]
    ws = nil
    EM.stop
  end
 
