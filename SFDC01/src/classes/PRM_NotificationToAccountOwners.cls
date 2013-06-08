/*==========================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 |  12/3/2010     Ashwini Gowda            1191     This class is used to update Custom Date
 .                                         1192     field on Account and CAP to send Notifications
                                                    to CAM and EMC Approver for Quarterly review
                                                    and Account Owners of all profiled Accounts
                                                    on Sept30th to start building CAP.  
    12/23/2010    Ashwini Gowda                     Introduced new method 
                                                    updateProfiledAccountsForAmericas()to send 
                                                    notification on Q1 and Q3 for Americas 
  | 28/06/2011	  Anil Sure							Added extra checks for Partner Approver in 
  													DML Query.                                                                                        
 +==========================================================================================*/
public class PRM_NotificationToAccountOwners {
    
/* @Method <updateProfiledAccounts(): This method would fetch all Account Owners of all profiled 
                                      Accounts for APJ and EMEA and update CAP Creation Date Field  
                                      with current date to send them a notification to create CAP.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/      
    public void updateProfiledAccountsForAPJEMEA(){             
        List<Account> profiledAccountsList = [Select a.Id, a.CAP_Creation_Date__c,a.Theater1__c, 
                                              a.PROFILED_ACCOUNT_FLAG__c,a.CAP_Required__c 
                                              from Account a  
                                              where PROFILED_ACCOUNT_FLAG__c = true
                                              AND a.CAP_Required__c='Yes'
                                              AND (Theater1__c='APJ' or Theater1__c='EMEA')];
        List<Account> accountsListToUpdate = new List<Account>();
        if(profiledAccountsList.size()>0){
            for(Account ProfiledAccount: profiledAccountsList){
                ProfiledAccount.CAP_Creation_Date__c = System.today();
                accountsListToUpdate.add(ProfiledAccount);
            }           
        }  
        if(accountsListToUpdate.size()>0){
            update accountsListToUpdate;
        }                                   
    }
    
/* @Method <updateProfiledAccountsForAmericas(): This method would fetch all Account Owners of  
                                                 all profiled Accounts for Americas and update  
                                                 CAP Creation Date Field  with current date to  
                                                 send them a notification to create CAP.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/      
    public void updateProfiledAccountsForAmericas(){            
        List<Account> profiledAccountsList = [Select a.Id, a.CAP_Creation_Date__c,a.Theater1__c, 
                                              a.PROFILED_ACCOUNT_FLAG__c,a.CAP_Required__c 
                                              from Account a  
                                              where PROFILED_ACCOUNT_FLAG__c = true
                                              AND a.CAP_Required__c='Yes'
                                              AND (Theater1__c='Americas')];
        List<Account> accountsListToUpdate = new List<Account>();
        if(profiledAccountsList.size()>0){
            for(Account ProfiledAccount: profiledAccountsList){
                ProfiledAccount.CAP_Creation_Date__c = System.today();
                accountsListToUpdate.add(ProfiledAccount);
            }           
        }  
        if(accountsListToUpdate.size()>0){
            update accountsListToUpdate;
        }                                   
    }
/* @Method <updateQtrNotificationDateOnCAP(): This method would update Quarterly_Notification_Date
                                             Date Field with current date to send notification
                                             to CAM and EMC Approver for completing the quarterly 
                                             business review with the partner.>
   @param - <void>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/  
    public void updateQtrNotificationDateOnCAP(){
        List<SFDC_Channel_Account_Plan__c> channelPlans = new List<SFDC_Channel_Account_Plan__c>(); 
        /*List<SFDC_Channel_Account_Plan__c>  channelAccountPlansList = 
                                            [Select s.EMC_Sales_Mgt_Approver__c, s.OwnerId,
                                             s.Quarterly_Notification_Date__c,s.Plan_End__c  
                                            from SFDC_Channel_Account_Plan__c s
                                            where s.Plan_End__c >= :System.today()];*/
   
   //Added By Anil
                                            
        List<SFDC_Channel_Account_Plan__c>  channelAccountPlansList =           
        									[Select s.EMC_Sales_Mgt_Approver__c, s.OwnerId,
        									s.Quarterly_Notification_Date__c,s.Plan_End__c 
        									from SFDC_Channel_Account_Plan__c s 
        									where Partner_approver__r.IsActive = true and Partner_approver__r.contactid != null  
            								and Plan_End__c >= :System.today()];

        
        if(channelAccountPlansList.size()>0){
            for(SFDC_Channel_Account_Plan__c channelPlan: channelAccountPlansList){
                channelPlan.Quarterly_Notification_Date__c = System.today();
                channelPlans.add(channelPlan);
            }
        }
        if(channelPlans.size()>0){
            update channelPlans;            
        }                        
    }
}