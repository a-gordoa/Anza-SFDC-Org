public class playlistInfoFiller implements Queueable, Database.AllowsCallouts {
    
    private String playlistToken;
    private Playlist__c playlistRecord = new Playlist__c();
    private Account account;

    // Constructor 
    public playlistInfoFiller(String pT) {
        this.playlistToken = pT;
    }

    // Used to create a new Account record in the event that the playlist owner
    // does not have an account record in the org yet. It uses info from the 
    // Map of info pulled from the API 
    private Account createAccountRecord(Map<String,Object> plMap) {
        Account newAcct = new Account();

        newAcct.Name =  playlsterName(plMap);
        newAcct.Spotify_User_ID__c = playlisterSpotifyId(plMap);

        return newAcct;
    }

    //---------------------------------------------------------------------
    // The following methods get specific values from the Playlist info Map
    //---------------------------------------------------------------------
    private String playlistName(Map<String,Object> playlist) {
        String name = string.valueOf(playlist.get('name'));
        System.debug(name);
        return name;
    }
    
    private String playlistDescription(Map<String,Object> playlist) {
        String description = string.valueOf(playlist.get('description'));
        System.debug(description);
        return description;
    }
    
    private String playlsterName(Map<String,Object> playlist) {
        String name = innerObjectFieldRetriver('owner', 'display_name', playlist);
        System.debug(name);
        return name;
    }
    
    private String playlisterSpotifyId(Map<String,Object> playlist) {
        String id = innerObjectFieldRetriver('owner', 'id', playlist);
        System.debug('Spotifyers NAme Is' + id);
        return id;
    }
    
    private String playlistURL(Map<String,Object> playlist) {
        String url = innerObjectFieldRetriver ('external_urls', 'spotify', playlist);
        System.debug(url);
        return url;
    }
    
    private Integer playlistFollowerCount(Map<String,Object> playlist) {
        String numString = innerObjectFieldRetriver ('followers', 'total', playlist);
        Integer followers = Integer.valueOf(numString);
        return followers;
 }
    
    // This is used to get the inner object key/value from objects in the playlst info map returned 
    // from Spotify, since there are key/value objects (maps) stored as values within the top layer of the Map. 
    // I used the below code from a github user to get this solution:
    // https://gist.github.com/TehNrd/4559623
    private String innerObjectFieldRetriver (String upperKey, String lowerKey, Map<String,Object> playlist) {
        String returnValue;
        String jsonPlaylist = '[' + JSON.serialize(playlist.get(upperKey))+']';
        List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(jsonPlaylist);

        for (Object fld : fieldList) {
            Map<String,Object> data = (Map<String,Object>)fld;
            returnValue = String.valueOf(data.get(lowerKey));
        }
        
        return returnValue;
 }
 


    public void execute(QueueableContext context) {
        
        // Instantiates the Class used to handle the API call
        SpotifyAPIRequest requestedPL = new SpotifyAPIRequest();
        
        // Uses the playlist token that was passed in from the user and sends it to Spotify
        // via the API handler class that was instantated above and stores the returned info as a
        // map that will be used parsed by class methods 
        Map<String,Object> playlistMap = requestedPL.getPlaylist(this.playlistToken);
        system.System.debug(playlistMap);


        // This list is used to query the current SFDC org to see if an account already exists for the playlist
        // owner. The reason for List<Account> rater than Account is becuase if an SOQL query comes back with 
        // no results it will throw an error, rather than just store null. 
        List<Account> acctFinder = [SELECT Id, Name FROM Account WHERE Name =:playlsterName(playlistMap) LIMIT 1];

        

        // This tests the acctFinder List to see if it's empty, and if that returns TRUE, then
        // there are no accounts that currently match the playlists owner, which means a new Account
        // needs to be created as well, since Playlist is the detail in a Master-Detail relationshp
        // with the Account object
        if (acctFinder.isEmpty()) {
             // This creates a new account using this instance method and
            // assigns it the variable acct, and inserts it to the org
            Account acct = createAccountRecord(playlistMap);
            insert acct;
            system.System.debug('This acount was created: ' + acct.Name);

            // Assigns playlist properties using the parser methods defined in this class
            this.playlistRecord.Name = playlistName(playlistMap);
            this.playlistRecord.Playlist_URL__c = playlistURL(playlistMap);
            this.playlistRecord.Followers__c = playlistFollowerCount(playlistMap);
            this.playlistRecord.Description__c = playlistDescription(playlistMap);
            this.playlistRecord.Spotify_Token__c = this.playlistToken;
            this.playlistRecord.Parent_Spotify_ID__c = playlisterSpotifyId(playlistMap);
            this.playlistRecord.DSP__c = 'Spotify';  
            this.playlistRecord.Account__c = acct.Id;
            system.System.debug('This playlist will be inserted ' + this.playlistRecord.Name);  
            
            // inserts the Playlist__c record that was instantiated as a class variable when the 
            // class was instantiated
            insert this.playlistRecord;


       } 
        // If the SOQL query returned an account to acctFinder, then this set code will run 
        // and 
        else {
            // The account variable is a class variable 
            account = acctFinder.get(0);
            system.System.debug(account);
            // Assigns playlist properties using the parser methods defined in this class
            this.playlistRecord.Name = playlistName(playlistMap);
            this.playlistRecord.Playlist_URL__c = playlistURL(playlistMap);
            this.playlistRecord.Followers__c = playlistFollowerCount(playlistMap);
            this.playlistRecord.Description__c = playlistDescription(playlistMap);
            this.playlistRecord.Spotify_Token__c = this.playlistToken;
            this.playlistRecord.Parent_Spotify_ID__c = playlisterSpotifyId(playlistMap);
            this.playlistRecord.DSP__c = 'Spotify';  
            // Assigns Master-detail link with the Account__c and account.Id from the SOQL'd account
            this.playlistRecord.Account__c = account.Id; 

            system.System.debug('This playlist will be inserted ' + this.playlistRecord.Name);
            // Inserted playlist
            insert this.playlistRecord;
                
       }

        
 
        
    }



}