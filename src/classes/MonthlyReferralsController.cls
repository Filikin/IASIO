public with sharing class MonthlyReferralsController 
{
	private secure_settings__c settings;
	public List<IdentifiableClient> clients {get;set;}
	private List<IdentifiableClient> allClients;
	
	public Date startDate {get;set;}
	public Date endDate {get;set;}
	
	public MonthlyReferralsController ()
	{
    	settings = secure_settings__c.getOrgDefaults();
		Initialise ();
	}

	private void Initialise ()
	{
		calculateReportDate ();
		
		Map<ID,Client_Outcome__c> outcomes = new Map<ID,Client_Outcome__c>([select ID, Placement_Date__c, Referral__c from Client_Outcome__c where Placement_Date__c >= :startDate and Placement_Date__c < :endDate and Referral__r.Programme__c LIKE 'Linkage%']);
		Set <ID> referralSet = new Set<ID>();
		for (Client_Outcome__c oneOutcome: outcomes.Values())
			referralSet.add (oneOutcome.Referral__c);
		
		
		Map<ID, Client_Referral__c> referrals = new Map<ID, Client_Referral__c>([select ID, Name, Client__c, Referral_ID__c, Referral_Type__c, Referred_From__c, First_Status_Outcome_Date__c, Referred_By__c, OwnerID, (select ID, Placement_Date__c, Status__c, Outcome_Types__c, Reason_for_Discontinued__c  from Client_Placements__r order by Placement_Date__c DESC) from Client_Referral__c where ID in :referralSet]);
		Set <ID> clientSet = new Set<ID>();
		Set <ID> referralOwnersSet = new Set<ID>();
		for (Client_Referral__c oneReferral: referrals.Values())
		{
			clientSet.add (oneReferral.Client__c);
			referralOwnersSet.add (oneReferral.OwnerId);
		}
			
		Map<ID,User> referralOwners = new Map<ID,User>([select ID, Name from User where ID in :referralOwnersSet]); 
		List<Contact> clientContacts = [select ID, LastName, Client_Ref__c, Birthdate, Gender__c, Client_Nationality__c, (select ID, First_Status_Outcome_Date__c , ReferralDate__c from Client_Referrals__r order by ReferralDate__c ASC) from Contact where ID in :clientSet];
		
		clients = getClients (clientContacts);
		
		// now we have the clients, fill in the details needed for the report
		for (IdentifiableClient oneClient: clients)
		{
			oneClient.FirstReferralDate = null; 
			for (Client_Referral__c oneReferral: oneClient.details.Client_Referrals__r)
			{
				if (referralSet.contains (oneReferral.id)) // is this a referral I am interested in
				{
					if (oneClient.FirstReferralDate == null) 
					{
						oneClient.FirstReferralDate = oneReferral.ReferralDate__c; // this is the first referral date on the client during the time period of the report (date of referral in the report)
						oneClient.StartDateFirstMeeting = oneReferral.First_Status_Outcome_Date__c; // this is the oldest status and outcome date linked to the first referral
					}
					Client_Referral__c thisClientsReferral = referrals.get (oneReferral.Id);
					oneClient.ProbationOfficer = thisClientsReferral.Referred_By__c;
					oneClient.Owner = referralOwners.get(thisClientsReferral.OwnerId).Name;
					oneClient.referralID = thisClientsReferral.Name; // Adele asked for the Name of the referral rather than the referral ID EK 29/4/2014
					oneClient.referredFrom = thisClientsReferral.Referred_From__c;
					oneClient.referredFor = thisClientsReferral.Referral_Type__c;
					if (thisClientsReferral != null && thisClientsReferral.Client_Placements__r != null && thisClientsReferral.Client_Placements__r.size() > 0)
					{
						for (Client_Outcome__c oneOutcome: thisClientsReferral.Client_Placements__r)
						{
							if (outcomes.keySet().contains (oneOutcome.id))
							{
								oneClient.OutcomeDate = oneOutcome.Placement_Date__c;
								oneClient.OutcomeStatus = oneOutcome.Outcome_Types__c;
								oneClient.Status = oneOutcome.Status__c;
								if (oneClient.Status == 'Engaged but Discontinued') oneClient.DateDiscontinued = oneClient.OutcomeDate;
								if (oneClient.Status == 'Placed') oneClient.DateCompleted = oneClient.OutcomeDate;
								oneClient.ReasonDiscontinued = oneOutcome.Reason_for_Discontinued__c;
								
								oneClient.lineYear = oneOutcome.Placement_Date__c.year();
								DateTime d = date.newInstance(oneClient.lineYear, oneOutcome.Placement_Date__c.month(), 1);
								oneClient.lineMonth = d.format('MMMMM');
								break; // out of the for loop as only one outcome is counted
							}
						}
					}
					break; // out of the for loop
				}
			}
			
		}
	}	
	
	private void calculateReportDate ()
	{
		if (!test.isRunningTest())
		{
			startDate = Date.parse(ApexPages.currentPage().getParameters().get('start'));
			endDate = Date.parse(ApexPages.currentPage().getParameters().get('end')).addDays (1);
		}
		else 
		{
			startDate = date.newInstance(system.today().year(), system.today().month() - 1, 1);
			endDate = date.newInstance(system.today().year(), system.today().month() + 1, 1) - 1;
		}
	}
	
	// run the search and match against the contacts.
  	public List<IdentifiableClient> getClients(List<Contact> reportContacts) 
  	{
  		List<IdentifiableClient> searchResults = new List<IdentifiableClient>();
  		
  		String clientIDs = '';
  		for (Contact oneClient: reportContacts)
  			clientIDs += oneClient.lastName + ',';
  		clientIDs = clientIDs.removeEnd (',');
  			
        String url = settings.baseURL__c + 'clientsList/' + clientIDs + '/' + settings.Username__c + '/' + settings.Key__c + '/' + settings.Secret__c + '/';
        system.debug ('In getClients url: ' + url);
 		Map<String, IdentifiableClient> clientMap = new Map<String, IdentifiableClient>();
		try
		{
//			Map<String, Object> m= (Map<String, Object>)JSON.deserializeUntyped(RestHelpers.getContent (url));
//			for (Object oneClient: (List<Object>)m.get('objects'))
			for (Object oneClient: (List<Object>)JSON.deserializeUntyped(RestHelpers.getContent (url)))
			{
				Map<String, Object> workingClient = (Map<String, Object>)oneClient;
				system.debug ('Client: ' + (String)workingClient.get('ID'));
				IdentifiableClient newClient = new IdentifiableClient ();
				newClient.FirstName = (String)workingClient.get('firstName');
				newClient.LastName = (String)workingClient.get('lastName');
				newClient.Ref = (String)workingClient.get('ID');
				clientMap.put (newClient.Ref, newClient);
			}
		}
		catch (Exception e)
		{
			system.debug (e.getMessage());
		}

		for (Contact oneContact: reportContacts)
		{
			IdentifiableClient oneClient = clientMap.get (oneContact.LastName);
			if (oneClient != null) 
			{
				oneClient.details = oneContact;
				searchResults.add (oneClient);
			}
		}
		
		system.debug ('In getClients, found: ' + searchResults.size() + ' clients');
  		return searchResults;
 	}
}