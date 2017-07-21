require 'httparty'

auth = '8c77399c4a1b475b92665e325a8d5e63'
data = Hash.new

def build_data(time_window, site, auth_token, count)
  api_url = 'http://api.sl.se/api2/realtimedeparturesV4.json?key=#{auth_token}&siteid=#{site}&timewindow=#{time_window}'
  api_response =  HTTParty.get(api_url, :headers => { "Accept" => "application/json" } )
  api_json = JSON.parse(api_response.body)
  return {} if api_json.empty?

  for (x = 0; x < count; x++)
    time_left = api_json.ResponseData.Metros[x].DisplayTime
    line = api_json.ResponseData.Metros[x].GroupOfLine
    dest = api_json.ResponseData.Metros[x].Destination
    data[:x] = {
      'time_left' => time_left,
      'line' => line,
      'dest' => dest,
    }
  end
  return data
end

SCHEDULER.every '10s', :first_in => 0  do
   data = build_data(60, 9192, auth, 5)
   send_event('sl', data) unless data.empty?
end
