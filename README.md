plex-playlistplay
-----------------

If you use [Plex](http://www.plex.tv/), this tool allows you to play a selected playlist from Plex server to a given (named) Plex client. 

I use this to automatically play some nice morning music when I wake up.

Not debugged very well and I had to reverse engineer the Plex protocol (I would call it an API, but there's no documentation).

Installation
------------

Just running 

      bundle install
      
should be enough to get you started.

Usage
-----

Syntax:
      
      plex-playlistplay.rb plex_server_hostname plex_server_port client_hostname playlist_name
      
For example to play playlist called ``Awesome Playlist`` residing on server ``192.168.1.1:32400`` on client called ``plexht-player``:

	  plex-playlistplay.rb 192.168.1.1 32400 plexht-player "Awesome dancing"
	  
License
-------

Released under ``Apache License Version 2.0, January 2004``, see file ``LICENSE``

Author: [Juraj Bednár](http://juraj.bednar.sk/) ([Github](https://github.com/jooray))
 