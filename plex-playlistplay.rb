#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'

require 'net/http'
require 'nokogiri'
require 'addressable/uri'

require 'openssl'


if ARGV.empty?
  $stderr.puts <<-EOF
plex-playlistplay.rb shows playlists on a server or plays a chosen playlist
(c) 2015 Juraj Bednar, more info at https://github.com/jooray/plex-playlistplay


Usage (to show playlists):

  plex-playlistplay.rb plex_server_hostname plex_server_port

Usage (to play playlist by name or number):

  plex-playlistplay.rb [-s] plex_server_hostname plex_server_port client_hostname playlist_name
  plex-playlistplay.rb [-s] plex_server_hostname plex_server_port client_hostname playlist_number

  When -s is specified, shuffle the playlist before playing

Examples:
  plex-playlistplay.rb 192.168.1.1 32400
  plex-playlistplay.rb 192.168.1.1 32400 plexht-player \"Awesome dancing\"
  plex-playlistplay.rb -s 192.168.1.1 32400 plexht-player 4
EOF
	exit 1

end

shuffle = ARGV.delete('-s') ? 1 : 0
plex_server_host = ARGV.shift
plex_server_port = ARGV.shift
client_name = ARGV.shift
playlist_name = ARGV.shift

client_id = "12345678-abab-4bc3-86a6-809c4901fb87"

# helper functions

def add_client_id(request, client_id)
	request.add_field('X-Plex-Client-Identifier', client_id)
	request
end

def uri_escape(string)
	Addressable::URI.encode_component(string, Addressable::URI::CharacterClasses::QUERY)
end


# main code

plex_server = Net::HTTP.new(plex_server_host, plex_server_port)
plex_server.use_ssl = true
plex_server.verify_mode = OpenSSL::SSL::VERIFY_NONE

# get list of playlists
request = Net::HTTP::Get.new("/playlists/all?type=15&X-Plex-Container-Start=0&X-Plex-Container-Size=300")
add_client_id(request, client_id)
response = plex_server.request(request)
playlists = Nokogiri::XML(response.body)

if not playlist_name
	# we don't have playlist, just list all the playlists including their numbers
	n=1
  playlists.xpath("//Playlist").each do |p|
		puts "\##{n} : #{p.attributes["title"]}\n"
    n=n+1
	end
else
  # we have playlist name or number, let's play it

  number_match = playlist_name.match("^([0-9]+)$")
  playlist = nil
  if number_match
  	playlist = playlists.xpath("//Playlist")[number_match[1].to_i - 1]
  else
  	playlist = playlists.xpath("//Playlist[@title=\"#{playlist_name}\"]").first
  end

  # plex server machine identifier
  request = Net::HTTP::Get.new("/")
  add_client_id(request, client_id)
  response = plex_server.request(request)
  plex_server_machine_id = Nokogiri::XML(response.body).xpath("//MediaContainer").first.attributes["machineIdentifier"].value
  
  # get information about clients
  request = Net::HTTP::Get.new("/clients")
  add_client_id(request, client_id)
  response = plex_server.request(request)
  clients = Nokogiri::XML(response.body)
  
  # find the client we want
  client = (clients.xpath("//Server[@name=\"#{client_name}\"]")+clients.xpath("//Server[@host=\"#{client_name}\"]")+clients.xpath("//Server[@address=\"#{client_name}\"]")).first
  plex_client = Net::HTTP.new(client.attributes["host"].value, client.attributes["port"].value)
  plex_client_machine_identifier = client.attributes["machineIdentifier"].value
    
  # create play queue
  request = Net::HTTP::Post.new("/playQueues?playlistID=#{uri_escape(playlist.attributes['ratingKey'].value)}&shuffle=#{shuffle}&type=audio&uri=#{uri_escape('library:///item/' + uri_escape(playlist.attributes['key'].value))}&continuous=0")
  add_client_id(request, client_id)
  request.set_form_data({})
  response = plex_server.request(request)
  playqueue = Nokogiri::XML(response.body)
  playqueue_id = playqueue.xpath("//MediaContainer").first.attributes["playQueueID"].value
  playqueue_media_key = playqueue.xpath("//MediaContainer/Track").first.attributes["key"].value
  
  # play media
  request = Net::HTTP::Get.new("/player/playback/playMedia?protocol=http&address=#{uri_escape(plex_server_host)}&key=#{uri_escape(playqueue_media_key)}&offset=0&commandID=1&port=#{uri_escape(plex_server_port)}&containerKey=#{uri_escape("/playQueues/#{uri_escape(playqueue_id)}?own=1&window=200")}&type=music&machineIdentifier=#{uri_escape(plex_server_machine_id)}")
  add_client_id(request, client_id)
  request.add_field('X-Plex-Target-Client-Identifier', plex_client_machine_identifier)
  response = plex_client.request(request)
end
