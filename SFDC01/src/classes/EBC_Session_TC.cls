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
private class EBC_Session_TC {

    static testMethod void EBC_Session()
    {
        EBC_Briefing_Event__c bEvent=new EBC_Briefing_Event__c(Name='test',Start_Date__c=date.today(),End_Date__c=date.today(),Briefing_Status__c='Pending');
        insert bEvent;
        EBC_Topics__c topic =new EBC_Topics__c(Name='topic');
        insert topic;
        EBC_Session__c sess=new EBC_Session__c(Name='sessions',Topic__c=topic.Id,Briefing_Event__c=bEvent.Id,Session_Start_Time__c=datetime.now(),Session_End_Time__c=datetime.now(),Session_Start_Date__c=date.today(),Session_End_Date__c=date.today());
        insert sess;
        ApexPages.currentPage().getParameters().put('retURL','%2F'+bEvent.Id);
        ApexPages.currentPage().getParameters().put('Id',sess.Id);
        ApexPages.StandardController ctController=new ApexPages.StandardController(sess);
        EBC_Session session = new EBC_Session(ctController);
        session.objSession=sess;
        session.EndHours='10';
        session.StartHours='10';
        session.StartMinutes='15';
        session.TwntyFourHour=true;
        session.getMinuteOptions();
        session.getHourOptions();
        session.saveRecord();
        session.SaveAndNew();
        session.doCancel();
        
        EBC_Session sessions = new EBC_Session(ctController);
        sessions.TwntyFourHour=false;
        sessions.EndHours='10';
        sessions.StartHours='10';
        sessions.StartMinutes='15';
        session.EndMinutes='30';
        sessions.getMinuteOptions();
        sessions.getHourOptions();
        sessions.saveRecord();
    }
}