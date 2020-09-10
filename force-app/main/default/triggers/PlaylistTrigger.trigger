trigger PlaylistTrigger on Playlist__c (before insert, after insert) {
		
    if (Trigger.isBefore) {
        List<Playlist__c> beforeInsertPlaylists;
        
        //Before Insert
        if(Trigger.isInsert) {
            for (Playlist__c playlistRecordIter : Trigger.new) {
            	
                // Instantiates playlistFiller which gets info from
                // Spotify API and places it in the Playlist record
				playlistInfoFiller fill = new playlistInfoFiller();
                fill.setPlaylistInfoFromSpotify(playlistRecordIter);
                beforeInsertPlaylists.add(playlistRecordIter);

            }
        }
        
        
        
        
    }
    
    if (Trigger.isAfter) {
        if(Trigger.isInsert) {
            for (Playlist__c playlistRecordIter : Trigger.new) {
            	
                // Instantiates playlistFiller which gets info from
                // Spotify API and places it in the Playlist record
				playlistInfoFiller fill = new playlistInfoFiller();
                fill.setPlaylistInfoFromSpotify(playlistRecordIter);
            }
            system.debug('Update Reached');
            update Trigger.new;
        }
    } 
    	
}