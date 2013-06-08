/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23.11.2010      Suman B         #1297      This is TestClass for PRM_PartnerQueueMembers.
 |  12/12/2011      Anil                       Created Custom Setting Manually and Removed SQL Query                                                         
 +========================================================================================================================*/
@isTest
Private Class PRM_PartnerQueueMembers_TC {


 /* @Method <getPartnerQueueLeadsTest: Test method>
    */
  Public testmethod static void getPartnerQueueLeadsTest() {
    User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
    String inputqry =   'Partner' + '%' ;
    Group   groupQueue = [SELECT g.Id, g.name 
                                    FROM Group g 
                                    WHERE g.name like : inputqry limit 1];
     Lead ld = new Lead(LastName= 'Test Lead', Company='Test Company' ,ownerid =groupQueue.id,Channel__c = 'INDIRECT');
     insert ld;
     List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();       
     insert acc;
     acc[0].Queue_Name__c = ld.owner.name;
     update acc;
     PRM_PartnerQueueMembers leadpartnerQueue = new PRM_PartnerQueueMembers() ;
     leadpartnerQueue.getPartnerQueueLeads();
     leadpartnerQueue.getGroupMembers();
   }
  
 }