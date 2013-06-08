/*==========================================================================================================+

|  HISTORY  |
|  DATE          DEVELOPER               WR         DESCRIPTION 
  ====          =========               ==         =========== 
| 03/08/2011    Anand Sharma                       This class will be used for User and profile 
                                                   data creation for test classes. 
 +=============================================================================================================*/
global class UserProfileTestClassDataHelper {

    public static User createUser(Id profileId,Id roleId){
        User tempUsr = new User(
             Username='test1234'+Math.random()+'@emc.com.test',
             TimeZoneSidKey='America/New_York',
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             ProfileId = profileId,
             UserRoleId = roleId,
             email='john@emc.com',
             Alias='test',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782818',
             IsActive=true 
        );
        return tempUsr;
    }
     public static User createPortalUser(Id profileId,Id roleId,Id contactid){
        User tempUsr = new User(
             Username='test1234'+Math.random()+'@emc.com.test',
             TimeZoneSidKey='America/New_York',
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             ProfileId = profileId,
             UserRoleId = roleId,
             ContactId = contactid,
             email='john@emc.com',
             Alias='test',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782818',
             IsActive=true 
        );
        return tempUsr;
    }
    
    public static Contact createContact(){ 
        Contact cont = new Contact();
        cont.LastName = 'testContact';
        cont.Active__c = true ;
        cont.Email = 'hanumann786@emc.com' ;
        return cont ;   
    }  
   
   global static Account getAccount(){
        Account tempAcc = new Account (
            Name = 'test1234'+Math.random()        
        );
        
        return tempAcc;    
    }
    
    global static Contact getContact(){
        Contact tempCont = new Contact (
            FirstName = 'TestFName123'+Math.random() ,
            LastName =  'TestLName123'+Math.random() ,
            email = 'test1@test.com' ,
            Active__c = true         
        );
        
        return tempCont;    
    }
    
    global static Lead getLead (){
        Lead templead = new Lead (
            Company = 'TestCompany' ,
            firstname = 'TestFirstName' ,
            LastName = 'TestLastName' ,
            Accept_Lead__c = false ,
            Reject_Lead__c = false , 
            Rejection_Reason__c = null ,
            Email = 'test2@emc.com'        
        );
        
        return templead ;    
    }
    
     global static User fetchPartnerUser (){
        User partner = [SELECT  u.Id, u.Contact.Account.Owner.Email, u.Contact.Account.Name 
                        FROM    User u 
                        WHERE   u.isActive=True and u.UserType='PowerPartner' limit 1];
        
        return partner ;    
    }
    
    public static Education__c createEducation() {
        Education__c objEducation = new Education__c();
        objEducation.Education_ID__c ='1234567';
        objEducation.Training_ID__c ='ABC123456'; 
        objEducation.Education_Batch_Number__c = 1;
        return objEducation ;
    }
}