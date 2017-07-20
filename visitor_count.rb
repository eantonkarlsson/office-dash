require 'google/api_client'
require 'date'

# Update these to match your own apps credentials
service_account_email = 'dashing-widget2@office-dashboard-widget.iam.gserviceaccount.com' # Email of service account
key_file = 'assets/office-dashboard-widget-ad5666511874.p12' # File containing your private key
key_secret = 'notasecret'
# Array of profile names and corresponding Analytics profile id
# profileID = '142644153'
profiles = [{name: 'brighter.se', id: '95280038'},
	    {name: 'actiste.com', id: '142644153'}]

# Get the Google API client
client = Google::APIClient.new(:application_name => 'office-dashboard-widget', 
  :application_version => '0.01')

# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => service_account_email,
  :signing_key => key)

# Start the scheduler
SCHEDULER.every '30m', :first_in => 0 do

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  # Start and end dates
  startDate = (Date.today - 30).strftime("%Y-%m-%d") # first day of current month
  endDate = Time.now.strftime("%Y-%m-%d")  # now


  visitors = Array.new
  visitsum = 0

  profiles.each do |profile|
    # Execute the query
    visitCount = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
      'ids' => "ga:" + profile[:id],
      'start-date' => startDate,
      'end-date' => endDate,
      # 'dimensions' => "ga:month",
      'metrics' => "ga:visits",
      # 'sort' => "ga:month" 
    })
    
    if visitCount.data.rows[0] and visitCount.data.rows[0][0] # deals with no visits
      visits = visitCount.data.rows[0][0]
    else
      visits = 0
    end
    visitsum += Integer(visits)
    
    visitors.push({label: profile[:name], value: visits})
end
  visitors.push({label: "Total", value: visitsum})

  # Update the dashboard
  send_event('visitor_count', {items: visitors})
end