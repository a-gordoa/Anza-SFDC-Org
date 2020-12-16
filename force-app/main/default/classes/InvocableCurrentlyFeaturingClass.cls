public class InvocableCurrentlyFeaturingClass {
    public InvocableCurrentlyFeaturingClass() {

    }

    @invocablemethod
    public static void CallUpdateForTrackInPlaylist() {
        
        // Instantiates and calls new Apex Batch Job class. Uses batch size of 5 at a time
        // becuase at higher numbers there is a CPU Timeout error that occurs. 
        UpdateCurrentlyFeaturingBatch newBatch = new UpdateCurrentlyFeaturingBatch();
        Id batchID = Database.executeBatch(newBatch, 5);
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID = :batchId];
        system.debug(job);
    }
}