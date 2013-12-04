trigger ChangeContactName on Contact (after insert) 
{
	if (secure_settings__c.getOrgDefaults().Disable_Triggers__c) return;
	
	ID clientRecordType = [select ID from RecordType where Name = 'Client' limit 1].id;
	Set <ID> recordsToChange = new Set <ID> ();
	for (Contact oneContact: trigger.new)
	{
		if (oneContact.RecordTypeId == clientRecordType)
		{
			recordsToChange.add (oneContact.id);
		}
	}
	List<Contact> insertedContacts = [select ID, FirstName, LastName, Client_Ref__c from Contact where ID in :recordsToChange];
	for (Contact oneContact: insertedContacts)
	{
		oneContact.FirstName = '';
		oneContact.LastName = oneContact.Client_Ref__c;
	}
	if (insertedContacts.size() > 0) update insertedContacts;
}