require 'httparty'
require 'digest/md5'

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

def build_data(time_window, site, auth_token)
  api_url = 'http://api.sl.se/api2/realtimedeparturesV4.json?key=%&siteid=%&timewindow=%'
  api_url = api_url % [auth_token, site, time_window]
  api_response =  HTTParty.get(api_url, :headers => { "Accept" => "application/json" } )
  api_json = JSON.parse(api_response.body)
  return {} if api_json.empty?

  latest_build = api_json.select{ |build| build['status'] != 'queued' }.first
  email_hash = Digest::MD5.hexdigest(latest_build['committer_email'])
  build_id = "#{latest_build['branch']}, build ##{latest_build['build_num']}"

  data = {
    build_id: build_id,
    repo: "#{project[:repo]}",
    branch: "#{latest_build['branch']}",
    time: "#{calculate_time(latest_build['stop_time'])}",
    state: "#{latest_build['status'].capitalize}",
    widget_class: "#{translate_status_to_class(latest_build['status'])}",
    committer_name: latest_build['committer_name'],
    commit_body: "\"#{latest_build['body']}\"",
    avatar_url: "http://www.gravatar.com/avatar/#{email_hash}"
  }
  return data
end
