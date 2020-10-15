public class PlaylistRecordCreator {
   
    public PlaylistRecordCreator() {
    
    }

    // Method used in UI Flow which takes a token and send it to
    // playlistInfoFiller() to create the playlist (and account record if needed)
    @InvocableMethod
    public static void createPlaylistRecord(List<String> token) {
        for (String iter : token) {
            Id jobID = System.enqueueJob(new playlistInfoFiller(iter));
        }
    }
}