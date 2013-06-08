/*===========================================================================+ 

 |  HISTORY  |                                                                            

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 
 
 |  13/09/2010     Anand Sharma                 Create test class for the unit testing of PortalVisibility class.
 |  14/12/2011      Anil                        Removed Query for fetching Partner and used Custom setting Data Helper
 |  11-JAN-2012     Anil                        Removed role Id
                                                                          
 +===========================================================================*/

@isTest
private class PRM_PortalVisibility_TC {

    public static testmethod void deployPRM_PortalVisibility(){
        //Create Partner User 
           User objUser;
           User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
            System.runAs(insertUser)
            {
            PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
            }
           List<Account> acc = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();       
           insert acc;
           acc[0].Type='Partner';
           update acc[0];
           Contact cont = UserProfileTestClassDataHelper.createContact();
           cont.AccountId=acc[0].Id;
           insert cont; 
              System.runAs(insertUser)
            {      
           Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
           String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
           Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
           //UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='AVNET TECHNOLOGY SOLUTIONS SANAYI VE TICARET A.S. Partner Executive'];
           objUser = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
           insert objUser; 
            }   
        
                      
        //Create Lead Data              
        Lead lead= new Lead(Channel__c='Indirect',Company='Deploy Lead',LastName='Doe',Status ='New', Sales_Force__c='EMC', LeadSource='Manual', Lead_Originator__c='Field',email='doe_john1@salesforce.com');
        insert lead;
        lead.OwnerId =objUser.Id;
        update lead;
        
        //update Lead Record
        Lead lead02 = [Select id , OwnerId, Partner__c, Tier_2_Partner__c from Lead where id=:lead.Id];
        lead02.Tier_2_Partner__c = acc[0].Id;  
        lead02.Partner__c = acc[0].Id;
                
        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        Map<Id,Lead> newLeadMap = new Map<Id,Lead>();
        //Put leads into map 
        oldLeadMap.put(lead.id,lead);
        newLeadMap.put(lead02.id,lead02);
         
        PRM_PortalVisibility visibilty = new PRM_PortalVisibility();
        //call setVisibility method 
        visibilty.setVisibility(null,oldLeadMap);
        visibilty.setVisibility(oldLeadMap,newLeadMap);
        
    }
      
 }