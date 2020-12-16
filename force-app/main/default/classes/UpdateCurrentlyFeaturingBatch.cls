public class UpdateCurrentlyFeaturingBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public List<Playlist__c> start(Database.BatchableContext bc) {
        // Selects and returns all Playlist__c records 
        List<Playlist__c> playlistsToReturn = [SELECT Id, Spotify_Token__c, Currently_Featuring_a_Released_Track__c FROM Playlist__c];
        return playlistsToReturn;
    }

    public void execute(Database.BatchableContext bc, List<Playlist__c> playlistList) {
        // Instantiates the classes used to call Spotify's API and parse the JSON data
        // that is returned from the call
        SpotifyAPIRequest requestedPL = new SpotifyAPIRequest();
        PlaylistMapHandler mapHandler = new PlaylistMapHandler();
        
        // This SOQLs all Released Track records and puts their names into a list of strings that
        // are used to check 
        List<Released_Track__c> rtRecordList = [SELECT Name FROM Released_Track__c];
        List<String> trackNameList = new List<String>();
        for (Released_Track__c iter : rtRecordList) {
            trackNameList.add(iter.Name);
        }

        for (Playlist__c iter : playlistList) {
            Map<String,Object> playlistMap = requestedPL.getPlaylist(iter.Spotify_Token__c);
            Boolean trackBool = mapHandler.isReleasedTrackInPlaylist(playlistMap,trackNameList);
            system.debug('NAME = ' + string.valueOf(playlistMap.get('name')) + ' '+ 'Bool = ' + trackBool);
            iter.Currently_Featuring_a_Released_Track__c = trackBool;
        }

        update playlistList;
        
    }   

    public void finish(Database.BatchableContext bc){
    
    }

}
