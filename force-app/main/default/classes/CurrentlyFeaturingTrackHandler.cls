public with sharing class CurrentlyFeaturingTrackHandler {
    // This class is used to host a method to be calle by flow/process builder.
    // The class updates the "is track featured" checkbox on a Playlist record
    
    public CurrentlyFeaturingTrackHandler() {

    }

    @InvocableMethod
    public static void updateReleasedTrackCheckbox(List<Playlist__c> playlistRecordInput) {
        List<String> releasedTrackInput = new List<String>();
        
        // Get's the Names for all released tracks and stores them in a List, which is to be 
        // passed into PlaylistTracks class
        for (Released_Track__c iter : [SELECT Name FROM Released_Track__c]) {
            releasedTrackInput.add(iter.Name);
        }
        
        // Iterates through List of playlist records and calls the PlaylistTracks queable class
        // on each one, to update it's "is track featured" checkbox. 
        for (Playlist__c iter : playlistRecordInput) {
            Id jobID = System.enqueueJob(new PlaylistTracks(playlistRecordInput,releasedTrackInput));
        }

    }

}