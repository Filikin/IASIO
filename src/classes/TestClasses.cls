@isTest
public class TestClasses 
{
 	public static testMethod void testSearch ()
    {
//    	createContacts (10);
 
        
     	FindClientController tc = new FindClientController();
    	tc.searchLastNameString = 'Smith';
    	
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    	tc.Search();
		
		PageReference pageRef = Page.FindClientPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('lastname', 'Smith');
        tc.performSearch();
    }

 	public static testMethod void testSecureDataArea ()
    {
     	List <Contact> contacts = createContacts (10);

 		ApexPages.StandardController contactPage = new ApexPages.StandardController(contacts[0]);
 
      	SecureDataController tc = new SecureDataController(contactPage);
      	tc.clearFields();
    	tc.loadSensitiveData();
    	tc.saveSensitiveData();
    }
    
	@isTest(SeeAllData=true)
 	public static void testSecureDataAreaWithMockResponse ()
    {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		Contact testContact = [select ID from Contact limit 1];
 		ApexPages.StandardController contactPage = new ApexPages.StandardController(testContact);
 
      	SecureDataController tc = new SecureDataController(contactPage);
    	tc.loadSensitiveData();
    	tc.saveSensitiveData();
    }
    
    public static List<Contact>  createContacts (Integer nContacts)
    {
    	List<Contact> newContacts = new List<Contact>();
    	ID clientType = [select ID from RecordType where Name = 'Client' limit 1].id;
    	for (Integer i=1; i<=nContacts; i++)
    	{
    		Contact c = new Contact (LastName='Client' + i, RecordTypeID = clientType);
    		newContacts.add (c);
    	}	
    	insert newContacts;
    	
    	createIdentifiableClients ();
    	
    	return newContacts;
    }
    
    public static Map<String, IdentifiableClient> createIdentifiableClients ()
    {
     	ID clientType = [select ID from RecordType where Name = 'Client' limit 1].id;
    	Map<String, IdentifiableClient> ics = new Map <String, IdentifiableClient> ();
    	List<Contact> contacts = [select ID, LastName from Contact where RecordTypeID = :clientType];
    	for (Contact oneC: contacts)
    	{
    		IdentifiableClient ic = new IdentifiableClient ();
    		ic.Ref = oneC.LastName;
    		ic.details=oneC;
    		ics.put (ic.Ref, ic);
    	}
    	return ics;
    }
    
    public static List<Client_Referral__c> createReferrals (List<Contact> contacts, Integer nCount)
    {
     	Date lastMonth = system.today() - 28;
    	List <Client_Referral__c> refs = new List<Client_Referral__c>();
    	
     	ID referralType = [select ID from RecordType where Name = 'Linkage' and sObjectType = 'Client_Referral__c' limit 1].id;
    	for (Contact oneContact: contacts)
    	{
	    	for (Integer i=1; i<nCount; i++)
    		{
    			Client_Referral__c cr = new Client_Referral__c (Client__c = oneContact.id, Referred_By__c = 'Fred', RecordTypeID=referralType);
    			refs.add (cr);
    		}
    	}
    	insert refs;
    	return refs;
    }
    
    public static List<Client_Outcome__c> createOutcomes (List<Client_Referral__c> referrals, Integer nCount)
    {
    	Date lastMonth = system.today() - 28;
    	List <Client_Outcome__c> outcomes = new List<Client_Outcome__c>();
    	
    	for (Client_Referral__c oneRef: referrals)
    	{
	    	for (Integer i=1; i<nCount; i++)
    		{
    			Client_Outcome__c oc = new Client_Outcome__c (Placement_Date__c = lastMonth + i, Referral__c = oneRef.id);
    			outcomes.add (oc);
    		}
    	}
    	insert outcomes;
    	return outcomes;
    }
    
    public static testMethod void testMonthlyReport ()
    {
     	List<Contact> nc = createContacts (10);
     	List<Client_Referral__c> cr = createReferrals (nc, 10);
     	List<Client_Outcome__c> oc = createOutcomes (cr, 10);
     	ReportParametersClass params = new ReportParametersClass();
     	params.save();
    	//MonthlyReferralsController mc = new MonthlyReferralsController ();
    }

	@isTest(SeeAllData=true)
    public static void testMonthlyReportWithMockResponse ()
    {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
     	ReportParametersClass params = new ReportParametersClass();
     	params.save();
    	MonthlyReferralsController mc = new MonthlyReferralsController ();
    }
    
    public static testMethod void testHRWebAbsence ()
    {
    	Contact c = new Contact (LastName='Fred', Employee_ID__c = '1');
    	insert c;
		Web_HR_Absence__c whra= new Web_HR_Absence__c (Employee_No__c='1', Your_Name__c = 'Fred', Email_Address__c='test@test.com', Start_Date__c=system.today(),No_of_Days__c=2,Return_Date__c=system.today()+1,Type__c='Certified Sick',Comments__c='Cold');
		insert whra;
    }
}