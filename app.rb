require 'sinatra'
require 'api-ai-ruby'
require 'json'

class ProcessPayLoad

  def setLocation(item,location)
    itemFile = JSON.parse(File.read('./items.json'))
    itemFile[item] = location
    puts "Setting #{item} to #{location}"
    File.open('./items.json', 'w') do | f |
      f.write(itemFile.to_json)
    end
  end

  def replyToAPI(item,location,action)
    prng = Random.new
    reply_text = prng.rand(1..3)
#    if location == ""
#      speech = "Sorry I couldn't find #{item}. Are you sure you told me where it was?"
#      reply_hash = {:speech => speech, :displayText => speech, :source => "Findr"}
#      return reply_hash
#    end
    case action
    when "set"
      case reply_text
      when 1
        speech = "I have made a note that your #{item} is in your #{location}"
      when 2
        speech = "I will remember your #{item} is in your #{location}"
      when 3
        speech = "I have saved the location of your #{item} to #{location}"
      end
      reply_hash = {:speech => speech, :displayText => speech, :source => "Findr" }
      return reply_hash
    when "get"
      case reply_text
      when 1
        speech = "I found your #{item} at #{location}"
      when 2
        speech = "You left your #{item} in the #{location}"
      when 3
        speech = "Your #{item} is in the #{location}"
      end
      reply_hash = {:speech => speech, :displayText => speech, :source => "Findr"}
      return reply_hash
    else
      puts "Not a valid action"
    end
  end

  def findLocation(item)
  itemFile = JSON.parse(File.read('./items.json'))
  return itemFile[item]
  end

end

class FindMy < Sinatra::Base

#  get '/.well-known/acme-challenge/Wqv7ViO-HNk6JxVVHM-0E6TjfzNUGMdaVtEDCiAovw8' do
#    "Wqv7ViO-HNk6JxVVHM-0E6TjfzNUGMdaVtEDCiAovw8.bYitzFzvdbYcokOkfsilS57neWbc6jilrsVziLG6X-8"
#  end

#  get '/.well-known/acme-challenge/yU2DfKEH4wW9ddRiOz1SCtmwF9q1VaSO2H4GeG2FdDk' do
#    "yU2DfKEH4wW9ddRiOz1SCtmwF9q1VaSO2H4GeG2FdDk.bYitzFzvdbYcokOkfsilS57neWbc6jilrsVziLG6X-8"
#  end
  get '/' do
     puts 'You landed on the main page'
  end

  post '/find' do
    payload = JSON.parse(request.body.read)
    case  payload["result"]["metadata"]["intentName"]
      when "Findr.SetLocation.Intent"
        item = payload["result"]["parameters"]["items"]
        location = payload["result"]["parameters"]["locations"]
        reply = ProcessPayLoad.new()
        reply.setLocation(item,location)
        reply = reply.replyToAPI(item,location,"set")
      when "Findr.GetLocation.Intent"
        item = payload["result"]["parameters"]["items"]
        reply = ProcessPayLoad.new()
        location = reply.findLocation(item)
        reply = reply.replyToAPI(item,location,"get")
      else
        puts "Invalid info"
    end
    puts reply
    content_type :json
    reply.to_json
  end
end
