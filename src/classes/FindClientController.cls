public with sharing class FindClientController 
{
	private secure_settings__c settings;
    public List<IdentifiableClient> results{get;set;} // search results
    public string searchFirstNameString{get;set;} // search keywords
    public string searchLastNameString{get;set;} // search keywords
    public List<String> clientRefs{get;set;} 
    public Map<String, IdentifiableClient> clientMap;
    
    public FindClientController() 
    {
        settings = secure_settings__c.getOrgDefaults();
        clientRefs = new List<String>();
    }
 
    // performs the keyword search
    public PageReference search() 
    {
        runSearch();
        if (results.size() == 0)
        {
	    	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'No Clients Found');
	        ApexPages.addMessage(myMsg);
        }
        else if (results.size() == 1) 
        {
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'One Client Found');
	        ApexPages.addMessage(myMsg);
        	
        }
        else if (results.size() == 100) 
        {
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Showing maximum of ' + results.size() + ' Clients Found');
	        ApexPages.addMessage(myMsg);
        	
        }
        else
        {
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, results.size() + ' Clients Found');
	        ApexPages.addMessage(myMsg);
        	
        }
        return null;
    }
 
    // prepare the query and issue the search command
    private void runSearch() 
    {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch();               
    } 
 
    // run the search and return the records found.
    public List<IdentifiableClient> performSearch() 
    {
    	clientMap = new Map<String, IdentifiableClient>();
    	
        results = new List<IdentifiableClient>();
        
	    List<IdentifiableClient> onePage = null;
        Integer pageNumber = 1;
        do {
        } while (getOnePage (pageNumber++) > 0 && pageNumber<=5);
        
	    List <Contact> clientContacts = [select ID, LastName, Birthdate, Owner.Name from Contact where LastName in :clientMap.keySet() limit 500];
        for (Contact oneContact: clientContacts)
        {
            IdentifiableClient oneClient = clientMap.get (oneContact.LastName);
            if (oneClient != null) 
            {
                oneClient.details = oneContact;
                oneClient.Owner = oneContact.Owner.Name;
                results.add (oneClient);
            }
        }
        return results;
    }
	
	public Integer getOnePage (Integer pageNo)
	{ 
        String url = settings.baseURL__c + 'api/client/?User=' + settings.Username__c + '&key=' + settings.Key__c + '&secret=' + settings.Secret__c + '&page=' + pageNo;
        url += '&ordering=firstName';
        if (searchFirstNameString != null && searchFirstNameString.length() > 0) url += '&firstName=' + system.Encodingutil.urlEncode(searchFirstNameString,'UTF-8');
        if (searchLastNameString != null && searchLastNameString.length() > 0) url += '&lastName=' + system.Encodingutil.urlEncode(searchLastNameString,'UTF-8');
 		system.debug ('URL: ' + url);
        String result = RestHelpers.getContent (url);
        List<Object> clientsFound = null;
        try
        {
            Map<String, Object> m= (Map<String, Object>)JSON.deserializeUntyped(result);
            clientsFound = (List<Object>)m.get('objects');
            for (Object oneClient: clientsFound)
            {
                Map<String, Object> workingClient = (Map<String, Object>)oneClient;
                IdentifiableClient newClient = new IdentifiableClient ();
                try
                {
	                newClient.FirstName = (String)workingClient.get('firstName');
		            newClient.LastName = (String)workingClient.get('lastName');
                	newClient.Ref = (String)workingClient.get('ID');
                }
                catch (Exception e)
                {
  		        	system.debug ('In getOnePage: ' + e.getMessage());
                	continue; // no point in trying to continue
                }
                
                clientMap.put (newClient.Ref, newClient);
            }
        }
        catch (Exception e)
        {
            system.debug ('In getOnePage Overall: ' + e.getMessage());
        	system.debug ('In getOnePage result: ' + result);
            return 1; // see if it moves on to the next page
        }
		return clientsFound.size();
	}
}