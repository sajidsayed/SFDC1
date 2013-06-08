/*====================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR         DESCRIPTION                               

 |  ====          =========      ==         =========== 

 | 24/9/2010      Ashwini Gowda  Req# 1067  Updated the existing Test class of PRM_LeadRejection 
                                            as per Req# 1067 partner super user profiles the ability 
 |                                          to reject a lead
   21/10/2010     Suman B        Req# 1117  Modified the test class as per change in Profile name 
 |                                          from - 'Tier 2 Partner User' to 'Direct Reseller Partner User' and
                                            'Tier 2 Partner User' to 'Distribution VAR Partner User'using custom settings. 
   8/10/2010     Ashwini Gowda              Commented utils.fromGroup(usrIds).
   20/10/2010    Ashwini Gowda   1318       UnCommented utils.fromGroup(usrIds) as the issue is fixed.   
   12/11/2010    Anirudh Singh              Commented creation of User3 Test Data at line#62
                                            Modified parameters at Line# 73 and Line# 77
 |14/12/2011        Anil                    Removed Query for fetching Partner and used Custom setting Data Helperclass
 |11-JAN-2012	  	Anil					Removed too many Future calls Exception
 |31-Jan-2013      vivek						WR220442 updated the Lead Owner
 |=============================================================================================================== */

@isTest
Private Class PRM_LeadRejection_TC{
    Private static testMethod void startTest(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Lead[] lds = [select id,OwnerId,Reject_Lead__c,EMC_Lead_Rejected__c,DealReg_Deal_Registration__c,Accept_Lead__c from lead where Reject_Lead__c = false and 
                     (Sales_Force__c = 'EMC' or Sales_Force__c = 'ESG') and Accept_Lead__c = false and 
                     Related_Account__r.Partner_Type__c=null and DealReg_Deal_Registration__c = false limit 5];
        Profiles__c profileId = Profiles__c.getInstance(); 
        string profile = profileId.Distributor_Partner_User__c;
        user usr = [select id,usertype,profileid from user where usertype != 'PowerPartner' limit 1];    
        Account account = new Account();
        account.name = 'Testing Account234';
        insert account;
        account.IsPartner = true;
        update account;
        System.debug('account---->'+account);
        
        Contact contact1 = createContact(account.id,'test1');
        Contact contact2 = createContact(account.id,'test2');
        Contact contact3 = createContact(account.id,'test3');
        Contact contact4 = createContact(account.id,'test4');    
        

        User insertUser1 = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
        List<User> PartnerUsers = new list<User>();
        Map<String,Id> UserMap = new Map<String,Id>();       
       
        /** Req#1117. **/
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        //String directReseller = data.get('Direct Reseller Partner User').DataValue__c ;
        //String distributionVAR = data.get('Distribution VAR Partner User').DataValue__c ;
        
        String directReseller = data.get('EMEA Direct Reseller Partner User').DataValue__c ;
        String distributionVAR = data.get('EMEA Distribution VAR Partner User').DataValue__c ;
        String distributorSuperUser1 = data.get('EMEA Distributor Super User').DataValue__c ;
        String distributorPartnerUser = data.get('EMEA Distributor Partner User').DataValue__c ;
        /** Changes End. **/
        //Create Users as System Administrator
        UserMap.put(distributorPartnerUser,contact1.id);
        UserMap.put(distributionVAR ,contact2.id);
        UserMap.put(directReseller,contact3.id);
        UserMap.put(distributorSuperUser1,contact4.id);
        
        System.runAs(insertUser1){
            if(UserMap.size()>0){
               PartnerUsers = createUser(UserMap);
            }
            
        }
        
        Test.startTest();
        QueueSobject Queues = [Select Queue.Name,Queue.Id from QueueSobject limit 1];
        runnow(lds,PartnerUsers[0],usr);
       // runnow1(lds,PartnerUsers[3],PartnerUsers[0]);
        //runnow(lds,PartnerUsers[1],usr);
        /*runnow(lds,PartnerUsers[1],PartnerUsers[0]);
        runnow(lds,PartnerUsers[3],usr);
        runnow2(lds,PartnerUsers[1],Queues.Queue.Name);
        runnow2(lds,PartnerUsers[0],'Global Assignment Queue');
        runnow3(lds,PartnerUsers[1],PartnerUsers[0]);
        runnow3(lds,usr,PartnerUsers[0]);*/
                
        Lead[] lds2 = [select id,OwnerId from lead  limit 10];
        list<id> usrIds = new list<id>();
        for(Lead l:  lds2 ){
            usrIds.add(l.OwnerId);
        }
        PRM_CommonUtils utils = new PRM_CommonUtils();
        utils.userDetails(usrIds);
        
        user userId = [select id from User limit 1];
        utils.isPartnerUser(userId.Id);
        
        user[] Ids = [select id from User limit 10];
        user[] partnerIds = [select id from User where usertype = 'PowerPartner' limit 10];
        user[] groupIds = [select id from User limit 10];
        for(user u:  Ids){
            usrIds.add(u.Id);
        }
        for(user u:  partnerIds ){
            usrIds.add(u.Id);
        }
        utils.userType(usrIds);
        utils.fromUser(usrIds);
        utils.fromGroup(usrIds);
        utils.userDetails(usrIds);
        List<Lead> idlist =[select id,OwnerId,Reject_Lead__c,EMC_Lead_Rejected__c,DealReg_Deal_Registration__c,Accept_Lead__c from lead limit 1];
        PRM_LeadRejection LeadOwnerchange = new PRM_LeadRejection();
	        LeadOwnerchange.partnerRejection(idlist,idlist);
        Test.stopTest();
    }
    
    /* @Method <runnow():This method is used to check how the functionality works
                        when partner User rejects lead when its assigned by emc user >.   
    @param <Taking List of Leads,Partner User and EMC User>   
    @return <void>    
    @throws exception - <No Exception>
    */ 
    private static void runnow(lead[] lds,user usr2,user usr){    
        for(lead l: lds){         
            System.runAs(usr2){
                PRM_LeadRejection leadRejection = new PRM_LeadRejection();                
                l.Previous_Owner__c = usr.id;
                l.ownerid = usr2.id;
                l.Reject_Lead__c = true;
                l.Rejection_Reason__c = 'Insufficient Data';
                QueueSobject Queues = [Select Queue.Name,Queue.Id from QueueSobject limit 1];
                l.Last_Assigned_Q__c = 'Queues.Queue.Name';
                leadRejection.ownerAssignment(lds);
                break;
            }   
        }
    }
    
    /* @Method <runnow1():This method is used to check how the functionality works
                        when Tier2 partner User rejects lead when its assigned by Distributor >.   
    @param <Taking List of Leads,Partner User and EMC User>   
    @return <void>    
    @throws exception - <No Exception>
    */ 
    public static void runnow1(lead[] lds,user usr2,user usr){
        for(lead l: lds){         
            System.runAs(usr2){
                PRM_LeadRejection leadRejection = new PRM_LeadRejection();        
                l.Previous_Owner__c = usr.id;
                l.ownerid = usr2.id;
                l.Reject_Lead__c = true;
                l.Rejection_Reason__c = 'Insufficient Data';                 
                leadRejection.ownerAssignment(lds);
                break;
            }   
        }
    }
    
    /* @Method <runnow2():This method is used to check how the functionality works
                        when partner User rejects lead when previous Owner was Queue >.   
    @param <Taking List of Leads,Partner User and EMC User>   
    @return <void>    
    @throws exception - <No Exception>
    */
    public static void runnow2(lead[] lds,user usr2,String QueueName){
        for(lead l: lds){         
            System.runAs(usr2){
                PRM_LeadRejection leadRejection = new PRM_LeadRejection();        
                l.Previous_Owner__c = null;
                l.ownerid = usr2.id;                
                l.Last_Assigned_Q__c = QueueName;
                l.Reject_Lead__c = true;
                l.Rejection_Reason__c = 'Insufficient Data';
                leadRejection.ownerAssignment(lds);
                break;
            }   
        }
    }
    /* @Method <runnow3():This method is used to check how the functionality works
                        when non Owner of the Lead tries to reject a lead >.   
    @param <Taking List of Leads,Partner User and EMC User>   
    @return <void>    
    @throws exception - <No Exception>
    */
    public static void runnow3(lead[] lds,user usr2,user usr){
        for(lead l: lds){         
            System.runAs(usr2){
                PRM_LeadRejection leadRejection = new PRM_LeadRejection();        
                l.Previous_Owner__c = usr.id;
                l.ownerid = usr.id;
                l.Reject_Lead__c = true;
                l.Rejection_Reason__c = 'Insufficient Data';
                leadRejection.ownerAssignment(lds);
                break;
            }   
        }
    }
   
    /* @Method <This method is used create contact for the test class>.   
    @param <Taking Id as paramter which contains accountId and Contact Name>   
    @return <void> - <Contact record>   
    @throws exception - <No Exception>
    */    
    public static Contact createContact(Id accountId,String Name){ 
    //Creating the dummy contact on the previously created account for test class.        
        Contact contact = new Contact(            
        FirstName=Name,            
        LastName='User1121',            
        AccountId=accountId        
        );        
        insert contact;        
        return contact;    
    }
    /* @Method <This method is used create user for the test class>.   
    @param <Taking Id and String as paramters which contains newly created             
    contactId and profileName>   
    @return <void> - <User record>   
    @throws exception - <No Exception>
    */
    private static List<User> createUser(Map<String,Id> UserMap){
    List<User> UserToInsert = new List<User>();
    for(string pfName:UserMap.keyset()){
    
        Profile amerUserProf = [select Id from Profile where Name=:pfName];
        System.debug('Profile---->'+amerUserProf);
        Account account = [Select Id,Name from Account where Name='Testing Account234' limit 1];    
        User tempUsr = new User(
             Username='test1234'+Math.random()+'@acme.com.test',
             TimeZoneSidKey='America/New_York',
             ProfileId=amerUserProf.Id,
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             email='john@acme.com',
             Alias='test',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782000',
             IsActive=true,
             ContactId = UserMap.get(pfName)); 
             UserToInsert.add(tempUsr);
       }             
        insert UserToInsert;
        
        return UserToInsert;
    }
    

}