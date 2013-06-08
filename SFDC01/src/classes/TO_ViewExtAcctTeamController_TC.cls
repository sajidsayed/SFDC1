/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE        DEVELOPER           WR       DESCRIPTION                               
 |  ====        =========           ==       =========== 
 |  23-SEPT-09  Devi Prasad Bal              Created
 |  05-OCT-09   Devi Prasad Bal              Updated (Modification was done
 |                                           based on the review comments)                   
 |  17-FEB-10   Saravanan.C        126812    Updated for TestCoverage                                 
 +===========================================================================*/

/**
 * This class contains unit tests for validating the behavior of 
 * Apex Class: TO_ViewExtAcctTeamController
 */
@isTest
private class TO_ViewExtAcctTeamController_TC {

    static testMethod void testTopOffender() {

        // An account record with AccountShare and AccountTeamMember records associated with it is stored in the Account array acc 
        //Account acc = [Select Id FROM Account  limit 1];
        Account a = new Account(name='testAccount', TA_Assignment_Type__c='Create',BillingCountry='US',BillingState='CA',EMC_Classification__c='EMC');
        insert a;
        Group[] grp=[Select id from Group Limit 10];
        User usr=[Select id from User where isActive=true Limit 1];

             AccountShare aShare=new AccountShare(UserOrGroupId=grp[0].Id,accountId=a.Id,AccountAccessLevel='Read',
                                                              OpportunityAccessLevel='Edit',CaseAccessLevel='Edit');
                                                              
       insert aShare;
       
                                                                   
       AccountTeamMember accMember=new AccountTeamMember(AccountId=a.Id,UserId=usr.Id);
       insert accMember;
        
        PageReference acctPage = new PageReference('/apex/TO_ViewExtendedAccountTeam?id=' +a.id);
        Test.setCurrentPage(acctPage);
                      
        // An instance of ApexPages.Standardcontroller is created here with an account record passed in the constructor 
        ApexPages.Standardcontroller sc = new ApexPages.StandardController(a);
        // An instance of the TO_ViewExtAcctTeamController is created here with sc passed in the constructor 
        TO_ViewExtAcctTeamController testVEATC = new TO_ViewExtAcctTeamController(sc);
        // The getAttributes method is invoked here  
        testVEATC.getAttributes();
        // The back method is invoked here 
        testVEATC.back(); 
        testVEATC.getWTOList();
        
        set<Id> grpId=new set<Id>();
        for(Integer i=0;i<grp.size();i++)
        {
            grpId.add(grp[i].Id);
        }
        //testVEATC.createGroupMembers(grpId);
        //testVEATC.getnewSortField();
         //testVEATC.setnewSortField('NAME');
        testVEATC.newSortField = 'NAME';
        //testVEATC.oldSortField = 'NAME';
        testVEATC.doSorting();
/*        List<GroupMember> groupList= [Select UserOrGroupId,Group.Name From GroupMember limit 100];
           Set<Id> GroupIds = new Set<Id>();
           for(GroupMember g :groupList ){
           GroupIds.add(g.UserOrGroupId);
           }
        testVEATC.createGroupMembers(GroupIds); */
    }
    
     }