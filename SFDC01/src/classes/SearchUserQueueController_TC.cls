/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==              =========== 
 |  25.10.2010      Anand Sharma                    Test class for the unit test of SearchUserQueueController class. 
 |  10.12.2010      Anand Sharma                    Updated test class for better code coverage.    
 
 +=========================================================================================================================*/
@isTest
private class SearchUserQueueController_TC {

    static testMethod void searchUserQueueUnitTest() {
        // TO DO: implement unit test
        
        SearchUserQueueController objSearchUserUnit = new SearchUserQueueController();
        objSearchUserUnit.newUserName = '';
        objSearchUserUnit.getItems();
        objSearchUserUnit.isQueueResult = true;
        objSearchUserUnit.isUserResult = true;
        objSearchUserUnit.getQueueRecords();
        objSearchUserUnit.getUserRecords();        
        objSearchUserUnit.selectedOwnerId = Userinfo.getUserId();
        
        objSearchUserUnit.userType ='User';
        objSearchUserUnit.searchUser(); 
        objSearchUserUnit.ApplyFilter();
        objSearchUserUnit.userType ='Queue';      
        objSearchUserUnit.searchUser();
        objSearchUserUnit.userType ='PartnerUser';      
        objSearchUserUnit.searchUser();
        
        objSearchUserUnit.newUserName = Userinfo.getName();
        
        objSearchUserUnit.userType ='User';
        objSearchUserUnit.searchUser(); 
        objSearchUserUnit.ApplyFilter();
        objSearchUserUnit.userType ='Queue';      
        objSearchUserUnit.searchUser();
        objSearchUserUnit.userType ='PartnerUser';      
        objSearchUserUnit.searchUser();        
    }
    
    static testMethod void searchUserQueuePartnerUserUnitTest() {
        
        SearchUserQueueController objSearchUserUnit = new SearchUserQueueController(); 
            
        User objUser = [Select Id , Name from User 
                        where   UserType='PowerPartner' and isactive=true and IsPortalEnabled =true 
                                AND Accountid !=null limit 1];
        System.runAs(objUser){ 
            objSearchUserUnit.userType ='Queue';      
            objSearchUserUnit.searchUser();
        }       
    }
}