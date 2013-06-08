/*=====================================================================================================================================

History 
24 Feb 12	Shipra Misra		  Updated for WR-184402
26 May 12	Shipra Misra		  Updated for WR-192797
======================================================================================================================================*/
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
private class TC_Enterprise_Under_Pen_Email_Notify 
{

    static testMethod void EnterPriseUnderpenEmailAlertUnitTest() 
    {
        // TO DO: implement unit test
        //Create set to be used for Underpen Alert type.
        Set<String> underPenAccntType = new Set<String>();
		underPenAccntType.add('Strategic Account');
		//underPenAccntType.add('Country Account');
		//underPenAccntType.add('Area Account');
        //Holds list of Under pen accounts.
    	List<Account> lstAccount= new List<Account>([Select id,Under_Pen_Account_Type__c,Account_Status__c from Account where Under_Pen_Account_Type__c in:underPenAccntType limit 2 ]);
    	
    	List<Contact> lstContact= new List<Contact>([Select id,name,email from contact limit 2 ]);
    	//Valid user to be assigned as the account owner on opportunity.
    	List<User> lstUser = new List<User>([Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
        emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, Profile_Name__c,IsActive, State, Forecast_Group__c from User where  UserType='Standard' and Country__c='N/A'   and Profileid in ('00e70000000wBza') and Division__c='Management/Ops' and Forecast_Group__c='Direct' and IsActive=True limit 4]);
    	//Create Enterprise_Email_Win_Notification__c record. 
    	System.runAs(lstUser[0])
    	{
    	List<Enterprise_Email_Win_Notification__c> lstEntEmailNot= new List<Enterprise_Email_Win_Notification__c>();
    	List<Enterprise_Email_Notification_Member__c> lstentNotMember= new List<Enterprise_Email_Notification_Member__c>();
    	
    	Enterprise_Email_Win_Notification__c entNot1= new Enterprise_Email_Win_Notification__c();
    	entNot1.Active__c=true;
    	entNot1.Country__c='N/A';
    	entNot1.Min_Amount__c=100000;
    	entNot1.Max_Amount__c=499999;
    	entNot1.Opportunity_Status__c='Booked';
    	entNot1.Under_Pen_Account_Type__c='Strategic Account';
    	lstEntEmailNot.add(entNot1);
    	
    	Enterprise_Email_Win_Notification__c entNot2= new Enterprise_Email_Win_Notification__c();
    	entNot2.Active__c=true;
    	entNot2.Division__c='Management/Ops';
    	entNot2.Opportunity_Status__c='Booked';
    	entNot2.Min_Amount__c=500000;
    	entNot2.Under_Pen_Account_Type__c='Strategic Account';
    	lstEntEmailNot.add(entNot2);
    	
    	Enterprise_Email_Win_Notification__c entNot3= new Enterprise_Email_Win_Notification__c();
    	entNot3.Active__c=true;
    	entNot3.Super_Area__c='Team';
    	entNot3.Min_Amount__c=500000;
    	entNot3.Opportunity_Status__c='Booked';
    	entNot3.Under_Pen_Account_Type__c='Strategic Account';
    	lstEntEmailNot.add(entNot3);
    	
    	Enterprise_Email_Win_Notification__c entNot4= new Enterprise_Email_Win_Notification__c();
    	entNot4.Active__c=true;
    	entNot4.Region__c='N/A';
    	entNot4.Min_Amount__c=500000;
    	entNot4.Opportunity_Status__c='Booked';
    	entNot4.Under_Pen_Account_Type__c='Strategic Account';
    	lstEntEmailNot.add(entNot4);
    	
    	Enterprise_Email_Win_Notification__c entNot5= new Enterprise_Email_Win_Notification__c();
    	entNot5.Active__c=true;
    	entNot5.Region__c='N/A';
    	entNot5.Min_Amount__c=100000;
    	entNot5.MAX_Amount__c=499999;
    	entNot5.Opportunity_Status__c='Booked';
    	entNot5.Under_Pen_Account_Type__c='Strategic Account';
    	lstEntEmailNot.add(entNot5);
    	
    	Enterprise_Email_Win_Notification__c entNot6= new Enterprise_Email_Win_Notification__c();
    	entNot6.Active__c=true;
    	entNot6.Country__c='N/A';
    	entNot6.Min_Amount__c=500000;
    	entNot6.Opportunity_Status__c='Booked';
    	entNot6.Under_Pen_Account_Type__c='Strategic Account';
    	lstEntEmailNot.add(entNot6);
    	
    	//insert Enterprise_Email_Win_Notification__c record.
    	insert lstEntEmailNot;
    	//Create Enterprise_Email_Notification_Member__c record.
    	Enterprise_Email_Notification_Member__c entNotMember1=new Enterprise_Email_Notification_Member__c();
    	entNotMember1.Enterprise_Email_Win_Notification__c=lstEntEmailNot[0].id;
    	entNotMember1.Team_Member__c=lstUser[0].id;
    	lstentNotMember.add(entNotMember1);
    	Enterprise_Email_Notification_Member__c entNotMember2=new Enterprise_Email_Notification_Member__c();
    	entNotMember2.Enterprise_Email_Win_Notification__c=lstEntEmailNot[1].id;
    	entNotMember2.Team_Member__c=lstUser[1].id;
    	lstentNotMember.add(entNotMember2);
    	Enterprise_Email_Notification_Member__c entNotMember3=new Enterprise_Email_Notification_Member__c();
    	entNotMember3.Enterprise_Email_Win_Notification__c=lstEntEmailNot[2].id;
    	entNotMember3.Team_Member__c=lstUser[2].id;
    	lstentNotMember.add(entNotMember3);
    	
    	Enterprise_Email_Notification_Member__c entNotMember4=new Enterprise_Email_Notification_Member__c();
    	entNotMember4.Enterprise_Email_Win_Notification__c=lstEntEmailNot[3].id;
    	entNotMember4.Team_Member__c=lstUser[3].id;
    	lstentNotMember.add(entNotMember4);
    	
    	Enterprise_Email_Notification_Member__c entNotMember5=new Enterprise_Email_Notification_Member__c();
    	entNotMember5.Enterprise_Email_Win_Notification__c=lstEntEmailNot[4].id;
    	entNotMember5.Team_Member__c=lstUser[0].id;
    	lstentNotMember.add(entNotMember5);
    	
    	//insert Enterprise_Email_Notification_Member__c record.
    	insert lstentNotMember;
    	//Create valid opportunity with account as Underpen account type.
    	List<Opportunity> lstOppty=NEW List<Opportunity>();
    	List<Opportunity> lstUpdateOppty=NEW List<Opportunity>();
    	Opportunity Oppty1 = new Opportunity(Name = 'Test Opportunity 1' 
                            ,AccountId=lstAccount.get(0).Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            //,Opportunity_Owner__c=lstUser[1].id
                            ,Area_Manager__c=lstContact[0].id
                            ,District_Manager__c=lstContact[1].id
                            ,SO_Number__c='1234233255'
                            ,Competitor__c='Adobe'
                            
                            ,Quote_Cart_Number__c='3452343443'
                            ,StageName ='Pipeline',CloseDate = System.today(),VCE_Related__c='VMWare Other',Amount = 500000);
        System.debug('lstOppty1 --->'+Oppty1);
        System.debug('The value of AccountId  is--->'+lstAccount.get(0));
        //Insert underpen account type opportunity.
        lstOppty.add(Oppty1);
        Opportunity Oppty2 = new Opportunity(Name = 'Test Opportunity 2' 
                            ,AccountId=lstAccount.get(0).Id
                            ,Sales_Force__c='EMC'
                            ,CurrencyIsoCode='USD'
                            //,Opportunity_Owner__c=lstUser[2].id
                            ,Area_Manager__c=lstContact[0].id
                            ,District_Manager__c=lstContact[1].id
                            ,SO_Number__c='12344555'
                            ,Competitor__c='Adobe'
                            ,Quote_Cart_Number__c='345465443'
                            ,StageName ='Pipeline',CloseDate = System.today(),VCE_Related__c='VMWare Other',Amount = 300000);
        
        lstOppty.add(Oppty2);
        insert lstOppty;
        test.startTest();
        //update status of opportunity as booked.
        Oppty1.StageName='Booked';
        Oppty2.StageName='Booked';
        lstUpdateOppty.add(Oppty1);
        lstUpdateOppty.add(Oppty2);
        update lstUpdateOppty;
        test.stopTest();
    	}
        
    }
    
}