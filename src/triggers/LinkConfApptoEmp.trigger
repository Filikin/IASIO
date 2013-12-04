trigger LinkConfApptoEmp on Seminar_Conference_Application__c (before insert) {

Seminar_Conference_Application__c  wa = Trigger.new[0];
Contact[] c = [select Id from Contact where Contact.Employee_ID__c = :wa.Employee_Number__c limit 1 ];
wa.Employee__c=c[0].id;


}