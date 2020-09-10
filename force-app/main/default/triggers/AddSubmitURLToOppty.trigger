trigger AddSubmitURLToOppty on Opportunity (after insert, after update) {

    //Puts all updated opptys in a list. This will be udpated at the end 
    List<Opportunity> opptysToUpdate = [SELECT Id, AccountId,Submission_Link__c  FROM Opportunity WHERE Id IN :Trigger.New];
    
    // Gets all the AccountID's assocaite with opptys. 
    // Uses Set becuase we don't want duplicates (for efficentcy), and don't need to reference
    // specific values via index. This will just be used to call check ID's against as a whole
    Set<ID> accountIds = new Set<ID>();
    for (Opportunity opt : opptysToUpdate) {
        accountIds.add(opt.AccountId);
    }
    
    // Gets a list of accounts that have an oppty that just update into a list
    // Then put the list into a Map for reference in the for loop, where AccountID is the Key
    List<Account> accountsWithOpptysList = [SELECT Id, Submission_Link__c FROM Account WHERE Id in :accountIds];
    Map<ID,Account> accountsWithOpptysMap = new Map<ID, Account>(accountsWithOpptysList);
 
    
    // Goes thru each opportunity and adds the accounts Submissin Link to the 
    // oppty Submission link field automaticlly. 
    for (Opportunity oppty : opptysToUpdate) {
        oppty.Submission_Link__c = accountsWithOpptysMap.get(oppty.AccountId).Submission_Link__c;
    }
    
    //Updates the opptys back to the server
    update opptysToUpdate;
    
}