trigger UpdateLatestStatusFlagsOnClientOutcomes on Client_Outcome__c (after insert, after update) 
{
	if (secure_settings__c.getOrgDefaults().Disable_Triggers__c) return;
	
	UpdateLatestStatusFlagsOnClientOutcomes up = new UpdateLatestStatusFlagsOnClientOutcomes (trigger.new);
}