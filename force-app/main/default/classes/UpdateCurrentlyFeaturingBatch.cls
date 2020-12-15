public class UpdateCurrentlyFeaturingBatch implements Database.Batchable<sObject> {

    public List<Playlist__c> start(Database.BatchableContext bc) {
        // Selects and returns all Playlist__c records 
        List<Playlist__c> playlistsToReturn = [SELECT Id, Currently_Featuring_a_Released_Track__c FROM Playlist__c];
        return playlistsToReturn;
    }

    public void execute(Database.BatchableContext bc, List<Playlist__c> playlistList) {
        for (Playlist__c iter : playlistList) {
            List<Playlist__c> PL = new List<Playlist__c>();
            PL.add(iter);
            CurrentlyFeaturingTrackHandler.updateReleasedTrackCheckbox(PL);
        }
        
    }   

    public void finish(Database.BatchableContext bc){
    
    }

}
