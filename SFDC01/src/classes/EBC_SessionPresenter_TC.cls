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
private class EBC_SessionPresenter_TC {

    static testMethod void EBC_SessionPresenter()
    {
    	
    	Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
                Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
                Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
                Id internalContact= record_Type_name_RT.getRecordTypeId();
                
                
    	EBC_Briefing_Event__c bEvent=new EBC_Briefing_Event__c(Name='test',Start_Date__c=date.today(),End_Date__c=date.today(),Briefing_Status__c='Pending');
		insert bEvent;
		EBC_Topics__c topic =new EBC_Topics__c(Name='topic');
		insert topic;
		EBC_Session__c sess=new EBC_Session__c(Name='sessions',Topic__c=topic.Id,Briefing_Event__c=bEvent.Id,Session_Start_Time__c=datetime.now(),Session_End_Time__c=datetime.now(),Session_Start_Date__c=date.today(),Session_End_Date__c=date.today());
		insert sess;
		Contact con=new contact(lastName='cont',RecordTypeId=internalContact);
		insert con;
		EBC_Topic_Presenters__c tp=new EBC_Topic_Presenters__c(Topic__c=topic.Id,Presenter__c=con.Id);
		insert tp;
		EBC_Session_Presenter__c sp=new EBC_Session_Presenter__c(Guest_Presenter__c=false,Session__c=sess.Id,Guest_Presenter_Last_Name__c='gp',Guest_Presenter_Email__c='gp@gp.com',Guest_Presenter_EBC_Title__c='title');
		insert sp;
		
    	ApexPages.currentPage().getParameters().put('Id',null);
    	ApexPages.currentPage().getParameters().put('sessId',sess.Id);
    	ApexPages.currentPage().getParameters().put('guestPresenter','1');
    	ApexPages.StandardController ctController=new ApexPages.StandardController(sp);
    	EBC_SessionPresenter sessionPres = new EBC_SessionPresenter(ctController);
    	sessionPres.objSPresenter=sp;
    	sessionPres.topicName='topic';
    	sessionPres.getresult();
    	sessionPres.setresult(true);
    	sessionPres.saveRecord();
    	EBC_Session_Presenter__c sp2=new EBC_Session_Presenter__c(Guest_Presenter__c=true,Session__c=sess.Id,Topic_Presenters__c=tp.Id);
		insert sp2;
    	ApexPages.currentPage().getParameters().put('Id',sp2.Id);
    	ApexPages.currentPage().getParameters().put('guestPresenter','0');
    	ApexPages.StandardController ctControllers=new ApexPages.StandardController(sp2);
    	EBC_SessionPresenter sessionPrest = new EBC_SessionPresenter(ctControllers);
    	sessionPrest.objSPresenter=sp;
    	sessionPrest.topicName='topic';
    	sessionPrest.getresult();
    	sessionPrest.setresult(false);
    	sessionPrest.saveRecord();
    	sessionPrest.doCancel();
    	
    	
    	
    	ApexPages.currentPage().getParameters().put('Id',sp.Id);
    	ApexPages.currentPage().getParameters().put('guestPresenter',null);
    	ApexPages.StandardController spControllers=new ApexPages.StandardController(sp2);
    	EBC_SessionPresenter sessionPrestr = new EBC_SessionPresenter(spControllers);
    	sessionPrestr.objSPresenter=sp;
    	sessionPrestr.topicName='topic';
    	sessionPrestr.getresult();
    	sessionPrestr.setresult(false);
    	sessionPrestr.saveRecord();
    	sessionPrestr.doCancel();
    }
}