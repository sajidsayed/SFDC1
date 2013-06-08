/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  
 | 3 March 2010     Prasad Kothawade 125264     Updated test method to change synergy lead id.
 | 27.01.2011       Shipra Misra    151892      Updated test class as two new required fields which have been introduced to the system. "Primary ISV & Infrastructure" & "Primary Outsourcer & Integrator".
   25-May-2011      Srinivas Nallapati          Chnaged for June11 release
   23-Jul-2011      Anand Sharma                Updated email field value of user record creation
 +===========================================================================*/
@isTest
Private class DeployTrigger{

    public static testmethod void deployLead_CalculateQAge(){
        String owner;
        Lead mylead= new Lead();
        // GroupMember myGrpMem = [Select GroupId, UserOrGroupId from GroupMember limit 1 ];
        QueueSobject myGrpMem = [Select q.SobjectType, q.QueueId From QueueSobject q where SobjectType = 'Lead' limit 1];
        mylead.Synergy_Lead_ID__c='123456789011111';
        mylead.Integration_Error_Message__c='';
        mylead.Status = 'New' ;
        mylead.Company = 'DeployTest' ;
        mylead.Channel__c = 'INDIRECT' ;
        mylead.City = 'DIRECT' ;
        mylead.Street = 'DIRECT' ;
        mylead.Country = 'DIRECT' ;
        mylead.Sales_Force__c = 'EMC' ;
        mylead.LastName = 'EMC' ;
        //mylead.ownerId=myGrpMem.GroupId;
        mylead.ownerId=myGrpMem.QueueId;
        insert mylead;
        //update mylead;
        mylead.Q_Ownership_End__c=System.today().addDays(-1);
        mylead.Q_Ownership_Start__c=System.today().addDays(1);
        update mylead;
        mylead.Running_Q_Ownership_Duration__c=null;
        update mylead;
    }
    
    private static UserRole createRole(String roleName){
        UserRole NewusrRole1=new UserRole(Name=roleName+Math.Random());
        insert NewusrRole1;
        return NewusrRole1;
    } 
   public static User createUser(String Profilename,UserRole Roleinfo){
       Profile amerUserProf = [select Id from Profile where Name=:Profilename];
       //UserRole role = [select Id from UserRole where Name='test'];
        User tempUsr = new User(
             Username='test1234'+Math.random()+'@acme.com.test',
             TimeZoneSidKey='America/New_York',
             ProfileId=amerUserProf.Id,
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             email='john@emc.com',
             Alias='test',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             UserRoleId=Roleinfo.Id,
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782818',
             IsActive=true 
        );
        insert tempUsr;
        return tempUsr;
    }
    
    private static testmethod void deploySetActivityOwner(){
        Lead mylead= new Lead();
        UserRole usrRole=createRole('test111111');
        User myUserTo=createUser('AMER Commercial User',usrRole);
        //User myUserTo =[Select id,Profile_Name__c from User where Profile_Name__c = 'AMER Commercial User' limit 1];
        //User myUserFrom =[Select Profile_Name__c from User where Profile_Name__c = 'AMER Standard User' limit 1];
        //User myUserFrom =[Select Profile_Name__c from User where Profile_Name__c = 'AMER Inside Sales/SMB User' limit 1];
        UserRole usrRole2=createRole('test44444');
        User myUserFrom =createUser('AMER Inside Sales/SMB User',usrRole2);
        mylead.Synergy_Lead_ID__c='12345678905555';
        mylead.Integration_Error_Message__c='';
        mylead.Status = 'New' ;
        mylead.Company = 'DeployTest' ;
        mylead.Channel__c = 'DIRECT' ;
        mylead.City = 'DIRECT' ;
        mylead.Street = 'DIRECT' ;
        mylead.Country = 'DIRECT';
        mylead.Sales_Force__c = 'EMC';
        mylead.LastName = 'EMC';
        mylead.ownerId=myUserFrom.Id;
        mylead.Accept_Lead__c=false;
        mylead.Related_Account__c=(new Account(name='test')).id; 
        insert mylead;

        Event myEvent= new Event();
        myEvent.whoid=mylead.Id;
        myEvent.EndDateTime=System.now().addDays(2);
        myEvent.StartDateTime=System.now().addHours(2);
        myEvent.Type='Appointment Set (SA)';
        myEvent.Subject='Call';
        insert myEvent;
        
        mylead.ownerId=myUserTo.Id;
        mylead.Accept_Lead__c=true;
        update mylead;
  }  
  public static testmethod void deployUpdateLeadPorfiles(){
        Lead mylead= new Lead();
        UserRole usrRole=createRole('test22222');
        User emeauser=createUser('EMEA Commercial User',usrRole);
        //User emeauser =[Select id,Profile_Name__c from User where Profile_Name__c = 'EMEA Commercial User' limit 1];
        
        mylead.Synergy_Lead_ID__c='1234567893333';
        mylead.Integration_Error_Message__c='';
        mylead.Status = 'New' ;
        mylead.Company = 'DeployTest' ;
        mylead.Channel__c = 'DIRECT' ;
        mylead.City = 'DIRECT' ;
        mylead.Street = 'DIRECT' ;
        mylead.Country = 'DIRECT';
        mylead.Sales_Force__c = 'EMC';
        mylead.LastName = 'EMC';
        mylead.ownerId=emeauser.Id;
        mylead.Accept_Lead__c=false;
        insert mylead;
        
        Account acc =[select id,Party_ID__c  from account where Party_ID__c!=''  limit 1];

        mylead.related_account__c= acc.id;        
        mylead.Party_ID__c = acc.Party_ID__c; 
        update mylead;
}
    public static testmethod void deployCheckUserRecordBeforeDelete(){
        UserRole newusrrole=createRole('test99999');
        User_Attribute_Mapping__c new_attribute=new User_Attribute_Mapping__c(
                                                           Name=newusrrole.Name,
                                                           BU__c='Captiva',
                                                           Area__c='Adriatics',
                                                           Country__c='India',
                                                           Division__c='ANZ',
                                                           Super_Division__c='Mid Market',
                                                           Region__c='AMER',
                                                           Sales_Role__c='Admin',
                                                           Super_Area__c='Australia',
                                                           District__c='Accenture',
                                                           Theater__c='APJ');
            
              insert new_attribute;  

                User_Attribute_Mapping__c newAttr=[Select Name,BU__c,
                                                        Area__c,
                                                        Country__c,
                                                        Division__c,
                                                        Region__c,
                                                        Sales_Role__c,
                                                        Super_Area__c,
                                                        District__c,
                                                        Theater__c from User_Attribute_Mapping__c where Name=:new_attribute.Name];
        //insert newAttr;                                                                     
        Delete newAttr;
        }
public static testmethod void deployCreateIndividualUserGroup(){
        UserRole usrRole=createRole('test33333');
        User emeauser=createUser('EMEA Commercial User',usrRole);
        /*User newUser=new User(Employee_Number__c='111111111',
                              BU__c='EMEA',
                              firstName='Test',
                              LastName='12',
                              Alias='emccom',
                              email='b123@bb.com',
                              Username='b123@bb.com',
                              EmailEncodingKey='ISO-8859-1',
                              LanguageLocaleKey='en_US',
                              ProfileId='00e70000001FZyZ',
                              LocaleSidKey='en_US',
                              TimeZoneSidKey='America/Chicago',
                              UserRoleid='00E70000000yjKbEAI'
                              );
        insert newUser;*/        
        }     
        
public static testmethod void deployOpportunityLineItemUpdateLog(){
    List<Account> lstaccount = new List<Account>();
        Account account1 = new Account();
        account1.name = 'Test';
        account1.Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account1.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account1.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account1.Partner_Type__c='ISV';
        lstaccount.add(account1);
        
        Account account2 = new Account();
        account2.name = 'Test2';
        account2.Site_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account2.Parent_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account2.Global_DUNS_Entity__c = String.valueOf(EMC_UTILITY.generateRandomInt(8));
        account2.Partner_Type__c='Outsourcer';
        lstaccount.add(account2);
        
        insert lstaccount;
    Opportunity Oppty = new Opportunity();
        Date closeDate = date.newinstance(2012, 11, 17);
        Date approvalDate = date.newinstance(2014, 11, 1);
        Date expirationDate = date.newinstance(2015, 11, 18);
        Oppty.Name = 'Test Oppty';
        Oppty.Sales_Channel__c = 'Direct';
        Oppty.Sales_Force__c = 'EMC';
        Oppty.StageName = 'Pipeline';
        Oppty.Closed_Reason__c = 'Loss';
        Oppty.Close_Comments__c = 'Lost';
        Oppty.CloseDate = closeDate;
        Oppty.Sell_Relationship__c = 'Direct';
        Oppty.Quote_Version__c='v13';
        Oppty.Quote_Type__c='New';
        Oppty.Approval_Date__c=approvalDate ;
        Oppty.Expiration_Date__c=expirationDate;
        Oppty.AccountId=account1.Id;
        Oppty.Amount=75900;
        Oppty.bypass_validation__c=true;
        // 24/5/2011 Changed for VF rules - Srinivas Nallapati
        //Oppty.Primary_Outsourcer_System_Integrator__c=account2.id;
        //Oppty.Primary_ISV_Infrastructure__c=account1.id;
        //Oppty.Outsourcer_System_Integrator_involved__c = false;
        //Oppty.ISV_Infrastructure_involved__c = false;
        /**/
        
        insert Oppty;
    
    PricebookEntry pricebook=[Select Id from PricebookEntry where IsActive=true and CurrencyIsoCode='USD'limit 1];
    OpportunityLineItem opptyLineItem= new OpportunityLineItem();
    opptyLineItem.OpportunityId=Oppty.Id;
    opptyLineItem.Quantity=5;
    opptyLineItem.Quote_Amount__c=5000;
    opptyLineItem.PricebookEntryId=pricebook.Id;
    insert opptyLineItem;
        
        OpportunityLineItem opplnitem=[Select UnitPrice,OpportunityId from OpportunityLineItem where OpportunityId=:Oppty.Id];
        update opplnitem;

}
}