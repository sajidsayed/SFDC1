/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |                                              
 |  Aug-2011        Saravanan C                 Initial Creation.Test Class cleanup
    19/10/2012      Anand Sharma                Exception Handling
 |  
 +===========================================================================*/
global class testclassUtils{

   public static CustomSettingDataValueMap__c getCustomSetRec (String Name, String Value) {
   
    CustomSettingDataValueMap__c newRec = new CustomSettingDataValueMap__c (
               Name = Name, DataValue__c = Value );
    
    return newRec ;          
   
   } 
   
   public static void InsertCustomSetRec (String Name, String Value) {
   
    CustomSettingDataValueMap__c newRec = new CustomSettingDataValueMap__c (
               Name = Name, DataValue__c = Value );
    
    insert newRec ;          
   
   }
   
   
   public static void  getCustomSettingrec_Profiles (String Name) {
   
    Profiles__c newRec = new Profiles__c ( 
                             EMC_Grouping_Administrator__c = Name);
   // return newRec ;          
    insert newrec ;
   }
   
   public static DealRegistration_CustomSetting__c getCustomSettingrec_dealreg (string name, string pscQueueId ){
    DealRegistration_CustomSetting__c newrec = DealRegistration_CustomSetting__c.getInstance(name);
        if(newrec== null)
        {
            newrec = new DealRegistration_CustomSetting__c(Name = name, PSC_QueueId__c = pscQueueId);
            insert newrec;
        }
    return newrec ;
   }
   
   public static OpportunityIntegration__c getCustomSettingrec_opptyIntg (string name, string adminConv){
   
    OpportunityIntegration__c newrec = OpportunityIntegration__c.getInstance(name);
        if(newrec== null)
        {
            newrec = new OpportunityIntegration__c(Name = name, Admin_Conversion__c = adminConv);
            insert newrec;
        }
    return newrec ;
   }
   
   public static OpportunityIntegration__c getCustomSettingrec_opptyIntg_IntAdmin (string name, string Intadmin){
     OpportunityIntegration__c newrec = OpportunityIntegration__c.getInstance(name);
        if(newrec== null)
        {
            newrec = new OpportunityIntegration__c(Name = name, House_Account_User__c = Intadmin);
            insert newrec;
        }
    return newrec ;
   }
   
  
   
   public static Lead getLeadrec () {
     Lead newrec = new Lead (
                  Company =  'Test Company', Status = 'New', LastName = 'Last Name',
                  Sales_Force__c = 'EMC', Lead_Originator__c = 'Field', LeadSource = 'Manual' ) ;
     
     return newrec ;              
   }
   
   public static Contact getContact () {
     Account acc = getAccount();
     insert acc ; 
     Contact newrec = new Contact ( LastName = 'Test LName', FirstName = 'Test FName',
         AccountId = acc.Id, Email = 'SfdcTest@emc.com' ) ;
     
     return newrec ;              
   }
   
   public static Account getAccount () {
     Account newrec = new Account ( Name = 'Test Account' ) ;
     
     return newrec ;              
   }
   
   public static User getUser (String profileName, String roleName) {
   
     String ProfileId = [select id from profile where name =: profileName limit 1].Id;
     String RoleId = [select id from userRole where name =: roleName limit 1].id;
        
     User newrec = new User( Alias = EMC_UTILITY.generateRandomString(5), 
         email = EMC_UTILITY.generateRandomString(10) + '@email.com',lastname = EMC_UTILITY.generateRandomString(10),
         username = EMC_UTILITY.generateRandomString(10) + '@email.com', ProfileId = profileId, UserRoleId = roleId,
         BU__c = EMC_UTILITY.generateRandomString(5), Employee_Number__c = EMC_UTILITY.generateRandomString(10)    
      ) ;
     
     return newrec ;              
   }
   
   public static User queryUser (String profileName, String roleName) {
   
     String ProfileId = [select id from profile where name =: profileName limit 1].Id;
     String RoleId = [select id from userRole where name =: roleName limit 1].id;
        
     User u = [Select Id from User where UserRole.Name = 'Worldwide BRM Overlay'
                          and isActive = true limit 2];
     
     return u ;              
   }
   
   public static Opportunity getOppty () {
     Account acc = getAccount ();
     insert acc;
     Opportunity newrec = new Opportunity ( Name = 'Test Oppty', StageName = 'Pipeline',
                  CloseDate = System.today()+2, Sales_Force__c = 'EMC', Sales_Channel__c = 'Direct',
                  VMWare_Related__c = 'Not VMware Related', AccountId = acc.Id  ) ;
     
     return newrec ;              
   }
   
   // Record Type Id`s Utils Methods
   public static String getRecordTypeId(String SobjectName, String recTypeName){
    RecordType recordTypeID = [Select Id from RecordType  
                                 where SobjectType =: SobjectName
                                 and Name =: recTypeName limit 1];
    return recordTypeId.Id ;
  }
   
   public static void getRecord(sObject obj) {
    object a = new Account () ;
   
    system.debug(' Object ==> ' + Obj );
   
   
   }

}