#!/usr/bin/env ruby
require 'net/http'
require 'openssl'
require 'json'

# This job can track some metrics of a single youtube video by accessing the
# public available api of youtube.

# Config
# ------
youtube_api_key =  ENV['YOUTUBE_API_KEY'] || 'AIzaSyBU2CiVCH3xrURnl32UZA2H7jJwRQqAXng'
youtube_playlist_id = ENV['YOUTUBE_PLAYLIST_ID'] || 'PLKLUEY-PeRwtpik0FOjYCCa4w5rX9Dx8W'
max_results = 50
# order the list by the numbers
ordered = true
max_length = 8

SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new("www.googleapis.com", Net::HTTP.https_default_port())
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check
  response = http.request(Net::HTTP::Get.new("/youtube/v3/playlistItems?part=snippet&playlistId=#{youtube_playlist_id}&maxResults=#{max_results}&key=#{youtube_api_key}"))

  if response.code != "200"
    puts "youtube api error (status-code: #{response.code})\n#{response.body}"
  else
    data = JSON.parse(response.body, :symbolize_names => true)

    youtube_videos = Array.new

    data[:items].each do |video|
      youtube_videos.push({
        label: video[:snippet][:title],
        value: video[:snippet][:resourceId][:videoId]
      })
    end

    youtube_stats = Array.new

    for each in youtube_videos do
      http = Net::HTTP.new("www.googleapis.com", Net::HTTP.https_default_port())
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check
      response = http.request(Net::HTTP::Get.new("/youtube/v3/videos?part=statistics&id=#{each[:value]}&key=#{youtube_api_key}"))
      data = JSON.parse(response.body, :symbolize_names => true)

      data[:items].each do |video|
        youtube_stats.push({
          label: each[:label],
          value: video[:statistics][:viewCount].to_i
        })
      end
    end

    if ordered
      youtube_stats = youtube_stats.sort_by { |obj| -obj[:value] }
    end

    if defined?(send_event)
      send_event('youtube_video_views', { items: youtube_stats.slice(0, max_length) })
    else
      puts youtube_stats
    end
  end
end
