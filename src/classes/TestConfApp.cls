/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestConfApp {

    static testMethod void myUnitTest() {
        Seminar_Conference_Application__c W = new Seminar_Conference_Application__c();
		w.Employee_Number__c='11';
		Database.insert(W);
		Contact c = [Select Id, Firstname FROM Contact where Employee_ID__c = '11' LIMIT 1 ];
		Seminar_Conference_Application__c D = [Select Id FROM Seminar_Conference_Application__c where Employee__c = :c.Id LIMIT 1 ];
		System.assertNotEquals(null, D);
    }
}