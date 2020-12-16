public class PlaylistMapHandler {
    

    public Boolean isReleasedTrackInPlaylist(Map<String,Object> playlist, List<String> userTracks) {
        List<String> trackList = new List<String>();
        system.System.debug('Made it to top of isReleasedTrackInPlaylist');

        // Thw following several lines are there to get the individual track info into a Map that can
        // be referenced. Since Spotify returns nested Objects in it's data structure, we have to  
        // keep turning it into a JSON and converting it to objects each time we get down a layer in the 
        // data structure becuase there is no way to reference the key/values using the standard 
        // salesforce Object (as oppsed to sObject). 
        //
        // Takes the playlist map passed in and gets the "tracks" value (not to be confused with "track")
        // This is the top level of the playlist object and the value of the key is a set of objects
		Object topLevelTrackObject = playlist.get('tracks');
		system.debug('topLevelTrackObject =' + topLevelTrackObject);

        // Turns all of the value of the key "tracks:" into a json
		String jsonStringForList = JSON.serialize(topLevelTrackObject); 
		system.debug('jsonStringForList =' + jsonStringForList);	
        
        // Turns the keys and values within "tracks" into a Map
		Map<String,Object> tracksObjMap = (Map<String,Object>)JSON.deserializeUntyped(jsonStringForList);
		system.debug('tracksObjMap =' + tracksObjMap);
        
        // Get the "items:" value and stores it in an object. The object is a collection of the 
        // info for each song in the playlist. Since the object is an object-of-objects 
        // we use the JSON.serialize it's contents so that they can be converted into a List of objects
        // which can be iterated through to get needed info from then. 
		Object itemObj = tracksObjMap.get('items');
		String jsonStringForTrack = JSON.serialize(itemObj);
		system.debug('jsonStringForTrack =' + jsonStringForTrack);

        // The itemList is a list of Objects, each of which contain the songs info in an object.
        // The object can't be used to retreive info since we can't use the .get() method,
        // so each of the objects will have to be converted to a JSON, then a Map to access
        // the info
		List<Object> itemList = (List<Object>)JSON.deserializeUntyped(jsonStringForTrack);
		system.debug('itemList = ' + itemList);

	    // Iterates through the List of individual songs in the Item level that have been turned into objects
        for (Object iterObj : itemList ) {

            // Takes the individual song from the "items" object and turns it into a JSON that can be used to 
            // turn it into a Map with accessable info
            String jsonForItemObj = JSON.serialize(iterObj);

            // Takes JSON and turns into a Map with access to teh individual data pieces for the track
            Map<String,Object> songMap = (Map<String,Object>)JSON.deserializeUntyped(jsonForItemObj);
            //system.debug('Song Map = ' + songMap);
            
            // Doesn the same as above, but one level deeper to get to the actual track info, as oppsed to
            // album/user/date added info for the song in the playlst. 
            String jsonForInnerTrack = JSON.serialize(songMap.get('track'));
            Map<String,Object> trackDataMap = (Map<String,Object>)JSON.deserializeUntyped(jsonForInnerTrack);

            // Converts the value of the name from an Object to a String
            String trackName = string.valueOf(trackDataMap.get('name'));
            
            // Adds track name to a trackList (List<>), which will be a complete list of all tracks in playlist
            trackList.add(trackName);
            }

        // Iterates thru the list of user tracks passed in
        for (String iter : userTracks ) {
            system.debug('made it here!');

            // if the playlist trackList contains the users track, return true
            if (trackList.contains(iter)) {
                return true;
            }
        }

        // If no user tracks were found, return false
        return false;
    }
}
