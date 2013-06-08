/*===========================================================================+
 |  HISTORY      
 |                          
 |  DATE       DEVELOPER      REQ/WR   DESCRIPTION                               
 |  ====       =========     ========  =========== 
 |  25-May-11  Saravanan C   REQ-2879  Initial creation
 |     
 +==========================================================================================*/
@isTest
private class PRM_PartnerUsersCount_TC {
  private static testMethod  void init(){          
   
   
    Account a = new Account ( Name = 'Test'  );
    insert a;
    
    Account_Groupings__c accGroup = new Account_Groupings__c( EMC_Account_Contact__c = userinfo.getuserid(),
     Account__c = a.id, Name = 'Test group ') ;
    insert accgroup;  
    
    a.Grouping__c = accgroup.id;
    
    update a;
    
    contact c = new contact( LastName = 'Test Contact', AccountId =  a.id, Partner_User2__c = True);
    
    Insert c;
    
    c.Partner_User2__c = False ;
    
    update c;
    
    
  }
      
}