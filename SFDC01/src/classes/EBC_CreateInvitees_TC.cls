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
 
//Test class for EBC_CreateInvitees trigger,EBC_CreateInvitees class,EBC_UpdateNBame trigger and EB_SetTopic Override trigger.
@isTest
private class EBC_CreateInvitees_TC {

    static testMethod void EBC_CreateInvitees() {

        Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
                Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
                Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
                Id internalContact= record_Type_name_RT.getRecordTypeId();
        EBC_Briefing_Event__c bEvent=new EBC_Briefing_Event__c(Name='xyz',Start_Date__c=date.today(),End_Date__c=date.today(),Briefing_Status__c='Pending');
        insert bEvent;
        Contact con=new Contact(LastName='testPresenter',RecordTypeId=internalContact);
        insert con;
        EBC_Topics__c topic=new EBC_Topics__c(Name='Topics');
        insert topic;
        EBC_Topic_Presenters__c tp=new EBC_Topic_Presenters__c(Presenter__c=con.Id,topic__c=topic.Id,Name='test');
        insert tp;
        EBC_Session__c sess=new EBC_Session__c(Topic__c=topic.Id,Briefing_Event__c=bEvent.Id);
        insert sess;
        EBC_Session_Presenter__c sp=new EBC_Session_Presenter__c(Name='test',Session__c=sess.Id,Topic_Presenters__c=tp.Id,Guest_Presenter_Email__c='abc@abc.com',Guest_Presenter_Last_Name__c='abc');
        insert sp;
        update sp;
    }
}