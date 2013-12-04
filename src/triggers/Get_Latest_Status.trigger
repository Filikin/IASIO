trigger Get_Latest_Status on Client_Referral__c (before update) {
Client_Referral__c c = Trigger.new[0];

if(c.Latest_Status_Outcome__c <> null  )
{  Client_Outcome__c o =[select Reason_for_Discontinued__c, Status__c, Client__c,Outcome_Types__c  from Client_Outcome__c where Placement_Date__c = :c.Latest_Status_Outcome__c and Referral__c=:c.id LIMIT 1 ];
	
	
   c.Latest_Status__c=o.Status__c;
   c.Latest_Outcome__c=o.Outcome_Types__c;
   
   c.Reason_for_Termination__c=o.Reason_for_Discontinued__c;
	
}
if(c.Historical_Latest_Status_Date__c <> null  )
{  Client_Outcome__c ou =[select Reason_for_Discontinued__c, Status__c, Client__c  from Client_Outcome__c where Placement_Date__c = :c.Historical_Latest_Status_Date__c and Referral__c=:c.id LIMIT 1 ];
	
	
   c.Previous_Latest_Status__c=ou.Status__c;
  
	
}
}