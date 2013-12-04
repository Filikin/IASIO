public with sharing class SecureDataController
{
	private secure_settings__c settings;
    private Contact client;
    public String secureFirstName {get; set;}
    public String secureLastName {get; set;}
    public String secureAddress1Type {get; set;}
    public String secureAddress1 {get; set;}
    public String secureAddress2Type {get; set;}
    public String secureAddress2 {get; set;}
    public String secureAddress3Type {get; set;}
    public String secureAddress3 {get; set;}
    public String securePhone1 {get; set;}
    public String securePhone2 {get; set;}
    public String securePhone3 {get; set;}
    public String secureEmergencyPerson {get; set;}
    public String secureEmergencyNumber {get; set;}
    public String secureEmergencyRelationship {get; set;}
    public String secureNickname {get; set;}
    public Boolean editting {get; set;}
    public Boolean permissionToEdit {get; set;}
    private Boolean notInDB;
    
    
    public SecureDataController(ApexPages.StandardController controller)
    {
        settings = secure_settings__c.getOrgDefaults();
    
        client = (Contact)controller.getRecord();
        client = [select id, LastName from Contact where id = :client.id];
        editting = false;
        notInDB = true;
    }

    public void clearFields ()
    {
        secureFirstName = '';
        secureLastName = '';
        securePhone1 = '';
        securePhone2 = '';
        securePhone3 = '';
        secureAddress1Type = '';
        secureAddress1 = '';
        secureAddress2Type = '';
        secureAddress2 = '';
        secureAddress3Type = '';
        secureAddress3 = '';
        secureEmergencyPerson = '';
        secureEmergencyNumber = '';
        secureEmergencyRelationship = '';
        secureNickname = '';
    }
    
    public pageReference loadSensitiveData ()
    {
        String client_id = client.LastName;
        String url = settings.baseURL__c + 'api/client/' + client_id + '/?User=' + settings.Username__c + '&key=' + settings.Key__c + '&secret=' + settings.Secret__c;
        String result = RestHelpers.getContent (url);
        if (result.contains('404 Not Found'))
        {
            notInDB = true;
            clearFields ();
        }
        else
        {
            notInDB = false;
            secureFirstName = parseResponse ('firstName', result);
            secureLastName = parseResponse ('lastName', result);
            securePhone1 = parseResponse ('Phone1', result);
            securePhone2 = parseResponse ('Phone2', result);
            securePhone3 = parseResponse ('Phone3', result);
            secureAddress1Type = parseResponse ('Address1Type', result);
            secureAddress1 = parseResponse ('Address1', result);
            secureAddress2Type = parseResponse ('Address2Type', result);
            secureAddress2 = parseResponse ('Address2', result);
            secureAddress3Type = parseResponse ('Address3Type', result);
            secureAddress3 = parseResponse ('Address3', result);
            secureEmergencyPerson = parseResponse ('EmergencyPerson', result);
            secureEmergencyNumber = parseResponse ('EmergencyNumber', result);
            secureEmergencyRelationship = parseResponse ('EmergencyRelationship', result);
            secureNickname = parseResponse ('Nickname', result);
        }
        
        permissionToEdit = checkPermissionToEdit();
        
        return null;
    }

//  @TestVisible private void saveSensitiveData ()
    public void saveSensitiveData ()
    {
        if (secureAddress1Type == 'Blank') secureAddress1Type = '';
        if (secureAddress3Type == 'Blank') secureAddress3Type = '';
 	    if (secureAddress2Type == 'Blank') secureAddress2Type = '';
    	
    	JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeBooleanField('notindb', notInDB);
        gen.writeStringField('ID', client.LastName);
        gen.writeStringField('firstName', secureFirstName);
        gen.writeStringField('lastName', secureLastName);
        gen.writeStringField('phone1', securePhone1);
        gen.writeStringField('phone2', securePhone2);
        gen.writeStringField('phone3', securePhone3);
        gen.writeStringField('address1type', secureAddress1Type);
        gen.writeStringField('address1', secureAddress1);
        gen.writeStringField('address2type', secureAddress2Type);
        gen.writeStringField('address2', secureAddress2);
        gen.writeStringField('address3type', secureAddress3Type);
        gen.writeStringField('address3', secureAddress3);
        gen.writeStringField('emergencyPerson', secureEmergencyPerson);
        gen.writeStringField('emergencyNumber', secureEmergencyNumber);
        gen.writeStringField('emergencyRelationship', secureEmergencyRelationship);
        gen.writeStringField('nickname', secureNickname);
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        
        system.debug (jsonString);
        
        String url = settings.baseURL__c + 'api/client/?User=' + settings.Username__c + '&key=' + settings.Key__c + '&secret=' + settings.Secret__c;
        RestHelpers.postContent(url, jsonString);
        notInDB = false; // assume it is now in the database
    }
    
    public Boolean checkPermissionToEdit ()
    {
        List<ContactShare> shares = [select ID, RowCause from ContactShare where ContactID = :client.id and (ContactAccessLevel = 'All' or ContactAccessLevel = 'Edit')];
        system.debug (shares);
        return shares.size() > 0;
    }
    
    public pageReference deleteSecureDetails ()
    {
        editting = false;
        clearFields ();
        if (notInDB == false) saveSensitiveData ();
        return null;    
    }
    
    public pageReference saveSecureDetails ()
    {
        editting = false;
        saveSensitiveData ();
        return null;    
    }
    
    public pageReference cancelSecureDetails ()
    {
        editting = false;
        loadSensitiveData ();
        return null;    
    }
    
    public pageReference editSecureDetails ()
    {
        editting = true;
        return null;    
    }
    
    private String parseResponse (String tokenName, String JSONContent)
    {
        try
        {
            JSONParser parser = JSON.createParser(JSONContent);
            // Advance to the next token.
            while (parser.nextToken() != null) 
            {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == tokenName))
                {
                    // Get the value.
                    parser.nextToken();
                    return parser.getText();
                }
            }
            return null;
        }
        catch (Exception e)
        {
            return '';
        }
    }
    
}