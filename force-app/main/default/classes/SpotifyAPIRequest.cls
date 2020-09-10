public class SpotifyAPIRequest {
//This is a test
//This is another test for the gitz
//This is test 3

    private String parseTokenRequestJSON (HttpResponse response) {
		Map<String,Object> authResponseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
		String token = string.valueOf(authResponseMap.get('access_token'));
        return token;
    }
    
    
    public String returnAuthToken() {
		//Temp auth token from Spotify to be sent to Get methods to Spotify 
        String returnedTokenfromJSON;
        
        //Perminent tokens for my account to be used to get a temp auth token
        String secretID = 'c4ee607462d64ea58752b32d30f1cc72';
        String clientID = 'a9646708a8f04fe88cd0c50c1e3c4f82';
        
        //Formats the payload that is sent in the temp auth token API request
        String payload = 'grant_type=client_credentials&client_id=' + clientID + '&client_secret=' + secretID;
        
        
		//Contructs API request that's sent to Spotify to get temp auth token 
		HttpRequest request = new HttpRequest();
        request.setMethod('POST');
		request.setEndpoint('https://accounts.spotify.com/api/token');
		request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setHeader('Content-Length',String.valueOf(payload.length()));
        request.setBody(payload);
        
        //Sends the above info to Spotify and gets back an HTTP Response
        Http binding = new Http();
        HttpResponse tokenResponse = binding.send(request);



		// Checks if tokenResponse worked properly
        if(tokenResponse.getStatusCode()==200) {
			// Parses returned HTTPrequest to an 
			// auth token using written class method and returns 
			// a single string 
        	returnedTokenfromJSON = parseTokenRequestJSON(tokenResponse);
            return returnedTokenfromJSON;
        } 
        // Returns string for debugging if http tokenResponse didn't work
        else {
			String r = 'This did not work, returned other than 200';
            system.debug(r);
            return r;
        }

    }     
    
    
    public Map<String,Object> getPlaylist(String token) {
        
        // Formats authToken to be sent in HttpRequest
        String authToken = 'Bearer'+' '+  returnAuthToken();
        
        // Formatted to get the following from Spotify
        // Name, External_URL (playlist url), Owners Name, Owners URL 
        // Owner Id, Follower Count, Playlist Description 
        String fieldsToRetrieve = '?fields=name%2Cexternal_urls%2Cowner(display_name%2Cexternal_url%2Cid)%2Cfollowers(total)%2Cdescription';
        
        // Binds required info for the call to the HttpRequest
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.spotify.com/v1/playlists/' + token + fieldsToRetrieve);
        request.setHeader('Authorization', authToken);
        request.setMethod('GET');
        
		// Sends HttpRequest to Spotify and gets back a JSON with playlist info 
		Http binding = new Http();
		HttpResponse playlistResponse = binding.send(request);
        
        
        
        //system.debug(playlistResponse.getBody());
        if (playlistResponse.getStatusCode() == 200) {
           
			// Takes the HTTPRequest response and turns it into a Map whos values are going to be called by other methods
            Map<String,Object> playlistResponseMap = (Map<String,Object>)JSON.deserializeUntyped(playlistResponse.getBody());
            return playlistResponseMap;
            
        } else {
            
            // Error that is sent out becuase the HttpRespnse didn't work
            Map<String,Object> errorMap = new Map<String,Object>();
            errorMap.put('error', 'Hard coded error - getStatusCode didn\'nt return 200 success code');
            system.debug(errorMap);
            return errorMap;
        }
        
    }
    
    

    /* The following methods get specific values from the Playlist info Map*/
    public String getPlaylistName(Map<String,Object> playlist) {
   		String name = string.valueOf(playlist.get('name'));
        system.debug(name);
        return name;
    }
    
    public String getPlaylistDescription(Map<String,Object> playlist) {
   		String description = string.valueOf(playlist.get('description'));
        system.debug(description);
        return description;
    }
    
    public String playlsterName(Map<String,Object> playlist) {
        String name = innerObjectFieldRetriver ('owner', 'display_name', playlist);
        system.debug(name);
        return name;
    }
    
	public String playlisterSpotifyId(Map<String,Object> playlist) {
        String id = innerObjectFieldRetriver ('owner', 'id', playlist);
        system.debug(id);
        return id;
	}
    
    public String playlistURL(Map<String,Object> playlist) {
		String url = innerObjectFieldRetriver ('external_urls', 'spotify', playlist);
		system.debug(url);
        return url;
	}
    
    public Integer playlistFollowerCount(Map<String,Object> playlist) {
        String numString = innerObjectFieldRetriver ('followers', 'total', playlist);
        Integer followers = Integer.valueOf(numString);
        return followers;
    }
    
    private String innerObjectFieldRetriver (String upperKey, String lowerKey, Map<String,Object> playlist) {
        //used the following to get the inner object key/value 
        //https://gist.github.com/TehNrd/4559623
        String returnValue;
        String jsonPlaylist = '[' + JSON.serialize(playlist.get(upperKey))+']';
        List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(jsonPlaylist);

        for (Object fld : fieldList) {
            Map<String,Object> data = (Map<String,Object>)fld;
            returnValue = String.valueOf(data.get(lowerKey));
        }
        
        return returnValue;
    }
    
    
}