@isTest
private class PRM_InsertDeleteGroupMembers_TC {
    
   
    static list<Profile> amerApjprofile = [Select Id,Name from Profile where Profile.Name IN ('AMER Inside Sales/SMB User' ,'APJ Inside Sales/SMB User')];    
    static UserRole roleId1 = [Select Id from UserRole where UserRole.Name ='Worldwide EMC Corporate' limit 1];
    static list<User> listUser = new list<User>();
    static list<Group> listGroup = [SELECT Name, Id,Type FROM Group where Name in ('America Inside Sales','APJ Inside Sales')];
    static User SysAdmin = [Select id,name from User where Profile.Name = 'System Administrator' and isActive = true limit 1];
    static list<Lead> listLead = new list<Lead>();
    static map<string,ProfilesAndGroups__c> mapCustomSetting = ProfilesAndGroups__c.getall();
    
    static User tempUsr;
    static list<Lead> listAcc = new list<Lead>();
    
    static List<User> createUser(){
        
           tempUsr = new User(
             Username='test1234@emc.com.test',
             TimeZoneSidKey='America/New_York',
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             ProfileId = amerApjprofile[0].Id,
             UserRoleId = roleId1.Id,
             email='john@emc.com',
             Alias='test',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782818',
             IsActive=false 
        );
      
        listUser.add(tempUsr);
            
                 
             tempUsr = new User(
             Username='xyz0987@emc.com.test',
             TimeZoneSidKey='America/New_York',
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep_1',
             ProfileId = amerApjprofile[0].Id,
             UserRoleId = roleId1.Id,
             email='johnabc@emc.com',
             Alias='testAbc',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782819',
             IsActive=true 
        );
        
        listUser.add(tempUsr);
        return listUser;
  }
 /**************************************************************************************/   
    static void createGroupAndCustomSetting(){
        Group amerApjGrp;
        list<Group> lstGroupToBeInsert = new list<Group>(); 
        list<ProfilesAndGroups__c> lstCustomSettingRecordToBeInsert = new list<ProfilesAndGroups__c>();
        if(listGroup.isEmpty()){
            amerApjGrp = new Group(name='America Inside Sales');
            lstGroupToBeInsert.add(amerApjGrp); 
            amerApjGrp = new Group(name='APJ Inside Sales');
            lstGroupToBeInsert.add(amerApjGrp); 
            insert lstGroupToBeInsert; 
            listGroup = lstGroupToBeInsert;       
        }
    
        if(mapCustomSetting.isEmpty()){
                
            ProfilesAndGroups__c newPandG1= new ProfilesAndGroups__c(
            Name=amerApjprofile[0].Id,
            GroupId__c=listGroup[0].Id);
            lstCustomSettingRecordToBeInsert.add(newPandG1);
             
            newPandG1= new ProfilesAndGroups__c(
            Name=amerApjprofile[1].Id,
            GroupId__c=listGroup[1].Id);
            lstCustomSettingRecordToBeInsert.add(newPandG1);
            insert lstCustomSettingRecordToBeInsert;   
                            
        }
    }  
    
  /**********************************************************************************/
    
    static list<Lead> createLead(){
        System.debug('Hello');
        Account newAcc = new Account( 
        name = 'UNITTESTAcc',
        Party_Number__c = '1234',        
        BillingCountry ='United States',
        Synergy_Account_Number__c = '10',
        Status__c='A',
        State_Province_Local__c = 'testState1',
        Street_Local__c='test1',
        Zip_Postal_Code_Local__c='23454'
        );
        insert newAcc;
        
        
        Lead objLead=new Lead(
        Company='Accenture',
        Lead_Rank__c='4',
        Status='New',
        LastName='AbcTest',
        City='Pune',
        Country='United States of America',
        Related_Account__c =newAcc.Id,
        Sales_Force__c='EMC',
        Email ='Dealreg1@dealreg.com',
        EMC_Convert_To_Deal_Reg__c=false
        );
        listLead.add(objLead);
        
        Lead objLead1=new Lead(
        Company='Accenture',
        Lead_Rank__c='4',
        Status='New',
        LastName='AbcTestAbc',
        City='Bangalore',
        Country='United States of America',
        Related_Account__c =newAcc.Id,
        Sales_Force__c='EMC',
        Email ='Dealreg1@dealreg.com',
        EMC_Convert_To_Deal_Reg__c=true
        );
        listLead.add(objLead1);
        
        return listLead;
    }
    

 /************************************************************************************/   
    static testMethod void testConvertToDeal() {
        Test.startTest();
        listLead = createLead();
        insert listLead;
        for(Lead lead:listLead){
                System.debug('Deal Reg should be false:'+lead.DealReg_Deal_Registration__c);
                if(lead.EMC_Convert_To_Deal_Reg__c==false){
                        lead.EMC_Convert_To_Deal_Reg__c=true;
                }
                                        
        }
        update listLead;
               
        Test.stopTest();
        
   }
/***********************************************************************************/    
    static testMethod void testGroup() {
        system.debug('Before mapCustomSetting ----------->' +mapCustomSetting);
        System.RunAs(SysAdmin){
           createGroupAndCustomSetting();
        }   
        system.debug('After mapCustomSetting ----------->' +mapCustomSetting);
        listUser = createUser();
        Test.startTest();
        insert listUser;
       
        System.debug('Before Update of Users:'+listUser);
                
        for(User user: listUser){
            if(!user.IsActive){
                user.IsActive=true;
            }
            else{
                user.ProfileId=amerApjprofile[1].Id;
            }
        }       
            
        update listUser;
  
        System.debug('After Update of Users:'+listUser);
        listUser[0].IsActive=false;
        
        update listUser;
        System.debug('After Update of Users:'+listUser);
        Test.stopTest();    
        
    }
}