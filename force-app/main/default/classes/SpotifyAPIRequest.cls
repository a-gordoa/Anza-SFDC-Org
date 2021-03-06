public class SpotifyAPIRequest {

    // This is a datetime var that is used to store a static datetime 
    static datetime lastTokenDT;
    static String staticAuthToken;

    private String parseTokenRequestJSON (HttpResponse response) {
		Map<String,Object> authResponseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
		String token = string.valueOf(authResponseMap.get('access_token'));
        return token;
    }
    
    
    
    public String returnAuthToken() {


        if (staticAuthToken == NULL || lastTokenDT > lastTokenDT.addMinutes(59) ) {

        
            // This updates the static timestamp with the current time when the  
            // method is called. This is used elsewhere to determine if a new auth
            // token is neccesary, since they expire an hour after being generated
            lastTokenDT = datetime.now();

            // Auth token var that will be used to return  
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
        } else {
            return staticAuthToken;
        }

    }     
    
    
    public Map<String,Object> getPlaylist(String token) {
        
        // Formats authToken to be sent in HttpRequest
        String authToken = 'Bearer'+' '+  returnAuthToken();
        
        // Formatted to get the following from Spotify
        // Name, External_URL (playlist url), Owners Name, Owners URL 
        // Owner Id, Follower Count, Playlist Description 
        // Query below is what was used in Spotify Dev Consol 
        // name,external_urls,owner(display_name,external_urls,id),followers(total),description,images
        String fieldsToRetrieve = '?fields=name%2Cexternal_urls%2Cowner(display_name%2Cexternal_urls%2Cid)%2Cfollowers(total)%2Cdescription%2Cimages%2Ctracks';
                             
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
    
    

    
    
}
