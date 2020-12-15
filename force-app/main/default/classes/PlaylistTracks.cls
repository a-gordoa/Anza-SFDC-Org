public class PlaylistTracks implements Queueable, Database.AllowsCallouts {
    // Consider renaming class "ReleasedTrackChecker"

    // This class has a single method that takes in a single playlist record 
    // (via a List since it's the only way to pass in arguments in a queable calss)
    // and a List of released track names. The playlist then has it's tracks searched
    // for any of the released tracks and has it's checkbox updated accordingly. 

    List<String> releasedTracks = new List<String>();
    Playlist__c playlistRecord;

    // Constructor
    public PlaylistTracks(List<Playlist__c> playlistRecordInput, List<String> releasedTrackInput) {
        this.releasedTracks = releasedTrackInput;
        this.playlistRecord = playlistRecordInput.get(0);
    }
    
    public void execute(QueueableContext context) {
    
        // Instantiates the Class used to handle the API call
        SpotifyAPIRequest requestedPL = new SpotifyAPIRequest();
        System.debug(requestedPL);

        // Gets token from playlist that was passed into the class when called/instanted elsewhere.
        String playlistToken = playlistRecord.Spotify_Token__c;
        
        // Places playlist recieved from Spotify into a Map<String,Object>
        Map<String,Object> playlistMap = requestedPL.getPlaylist(playlistToken);

        // Calls PlaylistMapHandler which converts the tracks in the playlist data
        // from nested objects to a map that is accessable. The isReleasedTrackInPlaylist 
        // method iterates thru all of the tracks within that map and determines if 
        // any of the tracks stored in the "releasedTracks" variable are found in the
        // playlist returned from Spotify. 
        PlaylistMapHandler PMH = new PlaylistMapHandler();
        Boolean trackInPlaylistBool = PMH.isReleasedTrackInPlaylist(playlistMap,this.releasedTracks);
        // If one of the tracks in the "releasedTracks" list is found in the playlist
        // then isReleasedTrackInPlaylist returns True, if not then False is returned. 
        // Then the checkbox on the record is set accordingly here. 
        this.playlistRecord.Currently_Featuring_a_Released_Track__c = trackInPlaylistBool;
        system.debug('In Class, Value on Record ' + this.playlistRecord.Currently_Featuring_a_Released_Track__c);
        system.debug('In Class, Bool used to Assign ' + trackInPlaylistBool);

        update this.playlistRecord;

    }
}
