/*====================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 21/10/2010      Suman B           Req# 1117    Modified the test class as per change in Profile name 
 |                                                'Direct Reseller Partner User' using custom settings. 
 | 20/06/2011      Anirudh Singh                  Modified the Test Class as per the Updated Profile Names        
 | Aug-2011        Saravanan C                 		Test Class cleanup 
 | 12/11/2011     Anand Sharma            			Fixed test fail issue
 | 1-12-2011     	Anil               				Fixed Mixed_DML Exceptions and removed Queries  
 |=============================================================================================================== */

@isTest  
private class PRM_PartnerUserGroup_TC{
   
    private static testMethod void partnerUserGroup(){
    	
        Map<Id,User> olduserMap = new Map<Id,User>();
        Map<Id,User> newuserMap = new Map<Id,User>();
        List<User> lstuser=new List<User>();
	    List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
	    insert acc;
	    Contact cont = UserProfileTestClassDataHelper.createContact();
	    cont.AccountId=acc[0].id;
	    cont.Email='test24@abc.com';
	    insert cont;
	    User u;
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
         System.runAs(insertUser)
        {  
           PRM_VPP_JobDataHelper.createVPPCustomSettingData();
           Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
           String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
           Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
           u = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);  
           u.IsActive=true;
           insert u;
           System.debug('user profile Id:'+u.ProfileId);
           olduserMap.put(u.id,u); 
           u.email = 'asd@abc.com';			         				   
           u.ProfileId = '00e70000001Fbrf';         
          /*Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
          String SysAdmin = data.get('System Administrator').DataValue__c ;          
          user u = UserProfileTestClassDataHelper.createUser(SysAdmin, null);
          u.email='test@emc.com';
          u.IsActive=true;
          insert u;
          System.debug('user profile Id:'+u.ProfileId);
          olduserMap.put(u.id,u); 
          u.email = 'asd@emc.com';			         				   
          u.ProfileId = '00e70000001Fbrf';
          //u.Profile_Name__c='EMC Contract & Grouping Administrator';
          update u;*/
          newuserMap.put(u.id,u); 
        }
        System.Debug(' user olduserMap ===> ' + olduserMap );
        System.Debug(' user newuserMap ===> ' + newuserMap);
        
        PRM_PartnerUserGroup obj = new PRM_PartnerUserGroup();
        obj.createUserGroupOnUpdate(olduserMap,newuserMap);
        obj.createProfiledUserGrouping(newuserMap);        
    }
}