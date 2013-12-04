trigger AddClient on Client_Outcome__c (before insert ){
Client_Outcome__c c = Trigger.new[0];
Client_Referral__c[] accs = [select client__c from Client_Referral__c where Client_Referral__c.Id = :c.Referral__c LIMIT 1] ;

if(accs.size() > 0)
{c.Client__c=accs[0].client__c;}

}