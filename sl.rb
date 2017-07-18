require 'httparty'

auth = 8c77399c4a1b475b92665e325a8d5e63

def duration(time)
  secs  = time.to_int
  mins  = secs / 60
  hours = mins / 60
  days  = hours / 24

  if days > 0
    "in #{days}d #{hours % 24}h"
  elsif hours > 0
    "in #{hours}h #{mins % 60}m"
  elsif mins > 0
    "#in {mins}m #{secs % 60}s"
  elsif secs >= 0
    "in #{secs}s"
  end
end

def build_data(time_window, site, auth_token, count)
  api_url = 'http://api.sl.se/api2/realtimedeparturesV4.json?key=%&siteid=%&timewindow=%'
  api_url = api_url % [auth_token, site, time_window]
  api_response =  HTTParty.get(api_url, :headers => { "Accept" => "application/json" } )
  api_json = JSON.parse(api_response.body)
  return {} if api_json.empty?

  for (x = 1; x < count; x++)
    time_left = api_json.ResponseData.Metros[x].DisplayTime
    line = api_json.ResponseData.Metros[x].GroupOfLine
    dest = api_json.ResponseData.Metros[x].Destination
    data[x] = {
      time_left: time_left,
      line: line,
      dest: dest,
    }
  return data
end

  SCHEDULER.every '10s', :first_in => 0  do
   data = build_data(60, 9192, auth, 5)
   send_event(data) unless data.empty?
end
