/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE           DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====           =========       ======      =========== 
 |  13.10.2010     Ashwini Gowda   #1143       Updated the Test Class to check
                                               Blank out the EMC Lead Rejected checkbox 
                                               after a lead has been accepted by a different user.   
 |  Aug-2011        Saravanan C         		Test Class cleanup											   
 +=========================================================================================================================*/

@isTest
Private Class MAP_LeadAccept_TC{
    Private static testMethod void startTest(){
         List<User> userlist = new List<User>();
        userlist = [Select u.Id from User u
                          where u.UserRole.Name = 'Worldwide BRM Overlay'
                          and u.isActive = true
                          limit 2];
        if (userlist.size()>1) {
            // create Lead for user1 and save
            Lead testlead =  testclassUtils.getLeadrec () ;
            testlead.Company = 'testcompany';
            testlead.LastName = 'testlast';
            testlead.Sales_Force__c = 'testsf';
            testlead.BU__c = 'testbu';
            testlead.Country = 'United States';
            testlead.Country__c = 'United States';
            testlead.Lead_Originator__c = 'testoriginator';
            testlead.ownerId = userlist[0].id;
            insert testlead;
            
            // as user2 update ownership to user2
            testlead.OwnerId = userlist[1].id;
            System.runAs(userlist[1]){
                update testlead;
            }
            //check when the lead is accepted is EMC_Lead_Rejected__c false
            System.assertEquals(false, testlead.EMC_Lead_Rejected__c);
        }
        
    }
}