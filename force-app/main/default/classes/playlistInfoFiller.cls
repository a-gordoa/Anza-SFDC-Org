public class playlistInfoFiller implements Queueable, Database.AllowsCallouts {
    
    private String playlistToken;
    private Playlist__c playlistRecord = new Playlist__c();
    private Account account;

    
    public playlistInfoFiller(String pT) {
        this.playlistToken = pT;
        System.debug('This shit worked');
    }

    private Account createAccountRecord(Map<String,Object> plMap) {
        Account newAcct = new Account();

        newAcct.Name =  playlsterName(plMap);
        newAcct.Spotify_User_ID__c = playlisterSpotifyId(plMap);

        return newAcct;
    }

    /* The following methods get specific values from the Playlist info Map*/
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
 


    public void execute(QueueableContext context) {
    	System.debug('Made it to playlistInfoFiller');  
        
        // Requests info from Spotify via the Playlust Token and
        // stores info in a Map to be passed into the methods below
		SpotifyAPIRequest requestedPL = new SpotifyAPIRequest();
        Map<String,Object> playlistMap = requestedPL.getPlaylist(this.playlistToken);
        system.System.debug(playlistMap);


        
        List<Account> acctFinder = [SELECT Id, Name FROM Account WHERE Name =:playlsterName(playlistMap) LIMIT 1];

        

        // This happens if there is no matching account found
        // new account is created and playlist is associated with it
        if (acctFinder.isEmpty()) {
             // This creates a new account using this instance method and
            // assigns it the variable acct
            System.System.debug('Made it No Account found Loop');
            Account acct = createAccountRecord(playlistMap);
            insert acct;
            system.System.debug('This acount was created: ' + acct.Name);

            // Assigns playlist properties 
            this.playlistRecord.Name = playlistName(playlistMap);
            this.playlistRecord.Playlist_URL__c = playlistURL(playlistMap);
            this.playlistRecord.Followers__c = playlistFollowerCount(playlistMap);
            this.playlistRecord.Description__c = playlistDescription(playlistMap);
            this.playlistRecord.Spotify_Token__c = this.playlistToken;
            this.playlistRecord.Parent_Spotify_ID__c = playlisterSpotifyId(playlistMap);
            this.playlistRecord.DSP__c = 'Spotify';  
            this.playlistRecord.Account__c = acct.Id;
            system.System.debug('This playlist will be inserted ' + this.playlistRecord.Name);  
            
            insert this.playlistRecord;


       } 

        else {
        account = acctFinder.get(0);
        system.System.debug(account);
        // Sets info from Spotify into the record passed into the method
         System.System.debug('Made it Account found Loop');
         this.playlistRecord.Name = playlistName(playlistMap);
         this.playlistRecord.Playlist_URL__c = playlistURL(playlistMap);
         this.playlistRecord.Followers__c = playlistFollowerCount(playlistMap);
         this.playlistRecord.Description__c = playlistDescription(playlistMap);
         this.playlistRecord.Spotify_Token__c = this.playlistToken;
         this.playlistRecord.Parent_Spotify_ID__c = playlisterSpotifyId(playlistMap);
         this.playlistRecord.DSP__c = 'Spotify';  
         this.playlistRecord.Account__c = account.Id; 

         system.System.debug('This playlist will be inserted ' + this.playlistRecord.Name);
         insert this.playlistRecord;
            
       }

        
 
        
    }



}