trigger CreateLeaveApp on Web_HR_Absence__c (before insert) {
Web_HR_Absence__c  wa = Trigger.new[0];
Contact[] c = [select Id from Contact where Contact.Employee_ID__c = :wa.Employee_No__c limit 1 ];
HR_Absence__c hra= new HR_Absence__c (Name_Submitted_Online__c=wa.Your_Name__c, Email_Address__c=wa.Email_Address__c, Start_Date__c=wa.Start_Date__c,Amount__c=wa.No_of_Days__c,Finish_Date__c=wa.Return_Date__c,Type__c=wa.Type__c,Employee_Comments__c=wa.Comments__c,Employee__c=c[0].Id);
insert hra;
}