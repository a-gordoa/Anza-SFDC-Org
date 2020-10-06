trigger PlaylistTrigger on Playlist__c (after insert) {
	/*	
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
    */
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            System.debug('XXX Made it to After Insert Loop');
            //Creates the list of playlists that will be passed to the API call method
            List<Playlist__c> playlistList = new List<Playlist__c>();

            //Instantiates playlistInfoFiller which calle the API and updates records
            playlistInfoFiller PL_API_Call = new playlistInfoFiller();

            // Iters thru all new playlists being udpated. 
            // (Will eventually need to be set up to handle 50 api call limit potentially)
            for(Playlist__c playlistRecordIter : Trigger.new) {
                System.debug('XXX Made it to PlaylistItterLoop');
            	playlistList.add(playlistRecordIter);
            }

            PL_API_Call.setPlaylistInfo(playlistList);

        }
    } 
    	
}