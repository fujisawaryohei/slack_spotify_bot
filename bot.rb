require 'http'
require 'json'
require 'faye/websocket' #websocketをrubyでできるモジュール
require 'eventmachine' #同時並列処理を行えるモジュール

response = HTTP.post("https://slack.com/api/rtm.start", params: {
    token: ENV['SLACK_API_TOKEN']})
    rc = JSON.parse(response.body)
    url = rc['url']

    EM.run do
	    ws = Faye::WebSocket::Client.new(url)

	    ws.on :open do
		    p [:open]
	    end

	    ws.on :message do |event|
        data = JSON.parse(event.data)
		    p [:message,data]

		    if data['text'] == "こんにちは"
		    ws.send({
                 type: 'message',
                 text: "こんにちは <@#{data['user']}> さん",                channel: data['channel']
                 }.to_json)
		    end
	    end

	    ws.on :close do
		    p [:close,event.code]
		    ws = nil
		    EM.stop
	    end
    end
