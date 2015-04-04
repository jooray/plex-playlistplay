plex-playlistplay
=================

If you use [Plex](http://www.plex.tv/), this tool allows you to play a selected playlist from Plex server to a given (named) Plex client. 

I use this to automatically play some nice morning music when I wake up.

Not debugged very well and I had to reverse engineer the Plex protocol (I would call it an API, but there's no documentation).

Installation
============

Just running 

      bundle install
      
should be enough to get you started.

Usage
=====

To show playlists:

    plex-playlistplay.rb plex_server_hostname plex_server_port

To play playlist by name or number:

    plex-playlistplay.rb plex_server_hostname plex_server_port client_hostname playlist_name
    plex-playlistplay.rb plex_server_hostname plex_server_port client_hostname playlist_number

Examples
--------

Show a list of playlists:

    plex-playlistplay.rb 192.168.1.1 32400 # shows list of playlist

Play a playlist called ``Awesome Playlist`` residing on server ``192.168.1.1:32400`` on client called ``plexht-player``:
    
    
    plex-playlistplay.rb 192.168.1.1 32400 plexht-player "Awesome dancing"
    
Play playlist number 4 on the same Plex server and client:
    
    plex-playlistplay.rb 192.168.1.1 32400 plexht-player 4      
      
	  
License
=======

Released under ``Apache License Version 2.0, January 2004``, see file ``LICENSE``

Author: [Juraj Bednár](http://juraj.bednar.sk/) ([Github](https://github.com/jooray))
 