require 'httparty'

auth = '8c77399c4a1b475b92665e325a8d5e63'
dataM = Array.new
dataB = Array.new

def build_data(time_window, site, auth_token, count)
  api_url = 'http://api.sl.se/api2/realtimedeparturesV4.json?key=#{auth_token}&siteid=#{site}&timewindow=#{time_window}'
  api_response =  HTTParty.get(api_url, :headers => { "Accept" => "application/json" } )
  api_json = JSON.parse(api_response.body)
  return {} if api_json.empty?

  for (x = 0; x < count; x++)
    if !api_json.ResponseData.Metros[]
      time_left = api_json.ResponseData.Metros[x].DisplayTime
      line = api_json.ResponseData.Metros[x].GroupOfLine
      dest = api_json.ResponseData.Metros[x].Destination
      dataM.push = [{'label': x, 'value':{
        'time_left' => time_left,
        'line' => line,
        'dest' => dest,
      }}
    end
    if !api_json.ResponseData.Buses[]
      time_left = api_json.ResponseData.Buses[x].DisplayTime
      line = api_json.ResponseData.Buses[x].GroupOfLine
      dest = api_json.ResponseData.Buses[x].Destination
      dataB.push = [{'label': x, 'value':{
        'time_left' => time_left,
        'line' => line,
        'dest' => dest,
      }}
    end
  end
  return dataM, dataB
end

SCHEDULER.every '10s', :first_in => 0  do
   dataM, dataB = build_data(60, 9192, auth, 5)
   send_event('slM', {'items': dataM}) unless dataM.empty?
   send_event('slB', {'items': dataB}) unless dataB.empty?
   dataM2, dataB2 = build_data(60, 9192, auth, 5)
   send_event('slM2', {'items': dataM2}) unless dataM.empty?
   send_event('slB2', {'items': dataB2}) unless dataB.empty?
end
