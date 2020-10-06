public class playlistInfoFiller {
    
    private List<Playlist__c> DML_Playlist_List = new List<Playlist__c>();
    
    public void setPlaylistInfo (List<Playlist__c> PL_List) {
        
        for (Playlist__c PL : PL_List) {
            spotifyAPICallAndRecordSet(PL);
        }

        update DML_Playlist_List;
    }

    @future(callout = true)
    public static void spotifyAPICallAndRecordSet(Playlist__c playlistRecord) {
    	system.debug('Made it to playlistInfoFiller');
        
        // Requests info from Spotify via the Playlust Token and
        // stores info in a Map to be passed into the methods below
		SpotifyAPIRequest requestedPL = new SpotifyAPIRequest();
	    Map<String,Object> playlistMap = requestedPL.getPlaylist(playlistRecord.Id);
        
        // Sets info from Spotify into the record passed into the method
        playlistRecord.Name = requestedPL.playlistName(playlistMap);
        playlistRecord.Playlist_URL__c = requestedPL.playlistURL(playlistMap);
        playlistRecord.Followers__c = requestedPL.playlistFollowerCount(playlistMap);
        playlistRecord.Description__c = requestedPL.playlistDescription(playlistMap);
		playlistRecord.Spotify_Token__c = requestedPL.playlisterSpotifyId(playlistMap);
        playlistRecord.DSP__c = 'Spotify';
        
        DML_Playlist_List.add(playlistRecord);
        
    }
}