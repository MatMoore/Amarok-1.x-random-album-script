#!/usr/bin/env ruby

#Amarok script to randomly pick an album and add it to the playlist
#A new album is added when the album is nearly finished or if the playlist is cleared.

def addalbum()
  gotalbum = false;
  until(gotalbum == true)
    #query the database for a random album id
    id = `dcop amarok collection query "select id from album order by rand() limit 1"`

    #get tracks
    tracks = `dcop amarok collection query "select url from tags where album=#{id} order by discnumber"`
    device = `dcop amarok collection query "select deviceid from tags where album=#{id} order by discnumber"`
    tracksarr = tracks.split("\n");
    devicearr = device.split("\n");
    gotalbum = true if tracksarr.length > 2 #don't use it if theres only 1 or 2 tracks
  end

  #get the mountpoint, use it to replace the './' at the beginning of the filename
  #then add the url to trackslist
  trackslist = " "
  for i in 0...tracksarr.length
    mountpoint = `dcop amarok collection query "select lastmountpoint from devices where id=#{devicearr[i]}"`
    trackslist = trackslist + "\"#{mountpoint.chomp() + (tracksarr[i].reverse().chomp('.').reverse())}\" "
  end

  #add tracks to playlist
  `dcop amarok playlist addMediaList [#{trackslist}]`
end

#trap( "SIGTERM" ) { cleanup() } #signal sent by amarok on exit

addalbum()

#listen for notifications from amarok
loop do
    message = gets().chomp() #Read message from stdin
    command = /[A-Za-z]*/.match( message ).to_s()

    case command
        when "configure" #configuration dialog
            msg  = "This script does not have configuration options."
            `dcop amarok playlist popupMessage "#{msg}"`

        when "playlistChange"
            #empty playlist?
            args = message.split()
            state = args[1]
            if state == "cleared"
              addalbum()
            end

        when "trackChange"
            #check to see if the playlist will end soon
            n = `dcop amarok playlist getTotalTrackCount`
            i = `dcop amarok playlist getActiveIndex`
            if i.to_i+1>=n.to_i-1 #final or penultimate track in the playlist
              addalbum()
            end
    end
end 
