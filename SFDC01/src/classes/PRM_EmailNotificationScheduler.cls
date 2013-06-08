/*=========================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR        DESCRIPTION                               

 |  ====          =========         ==        =========== 

 |  17/11/2010    Ashwini Gowda     Req#1297  This class is used for the Scheduling Purpose
                                              to send Notifications to Designated List of
                                              users for the selected Template.
    24/11/2010    Suman B                     Modified the execute method to pass the List<user>
                                              in the sendEmailNotification() method.
    26/11/2010    Ashwini Gowda               Renamed the Email Template to 'Lead Notification to
                                              Partner Users' from 'partner email template'
    8/12/2010     Ashwini Gowda     1191,1192 Updated the execute method to incorporate PRM R2 Reqts.                               
    11/12/2010    Prasad Kothawade            Added Check (listqueuemembers.size()>0).
    23/12/2010    Ashwini Gowda               Updated execute method to invoke 
                                              updateProfiledAccountsForAmericas() on Mar 31st and 
                                              Sept 30th to send notifications to Account Owners to
                                              create CAP.
 +=========================================================================================*/ 
global class PRM_EmailNotificationScheduler implements Schedulable {
    /* @Method <execute(): for scheduling>
       @param <SchedulableContext SC>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
    global void execute(SchedulableContext SC){     
        Date Present_Day = Date.today();
        Integer Month = Present_Day.Month();
        Integer Day = Present_Day.day();
        
        Map<String,CustomSettingDataValueMap__c> data = CustomSettingDataValueMap__c.getall();
        Integer March = data.get('March').DateValue__c.intValue();
        Integer June = data.get('June').DateValue__c.intValue();
        Integer September = data.get('September').DateValue__c.intValue();
        Integer December = data.get('December').DateValue__c.intValue();
        Integer Thirty = data.get('Thirty').DateValue__c.intValue();
        Integer ThirtyFirst = data.get('ThirtyFirst').DateValue__c.intValue();
        
        PRM_SendEmailNotifications sendEmailNotification = new PRM_SendEmailNotifications();
        PRM_PartnerQueueMembers leadpartnerQueue = new PRM_PartnerQueueMembers() ;
        
        List<User> listqueuemembers = leadpartnerQueue.getGroupMembers();   
        if(listqueuemembers.size()>0 ){
            sendEmailNotification.sendEmailNotification(listqueuemembers,'Lead Notification to Partner Users');
        }
        /*
        At the end of the third quarter (March31st,September 30th) a notification should be sent to 
        the Account Owner of all profiled accounts that reminds them it is time to start 
        building the Channel Account Plan for the upcoming quarter/year. 
        Check if current date is September 30*/      
        if((Month==March && Day==ThirtyFirst)||(Month==September && Day==Thirty)){
            PRM_NotificationToAccountOwners notificationToCAM = new PRM_NotificationToAccountOwners();
            notificationToCAM.updateProfiledAccountsForAmericas();
        }
        /*
        On the last day of every quarter (March31st,June30th,September30th,December31st)
        a notification should be sent to the Account Owners and the manager/regional 
        sales management reminding them it is time to complete the quarterly business
        review with the partner and notification should be sent to 
        the Account Owner of all profiled accounts(APJ and EMEA) that reminds them it is time  
        to start building the Channel Account Plan for the upcoming quarter/year.
        Check for above menioned month and dates*/ 
        if((Month==March && Day==ThirtyFirst)||(Month==June && Day==Thirty)||
          (Month==September && Day==Thirty)||(Month==December && Day==ThirtyFirst)){
            PRM_NotificationToAccountOwners notificationToCAM = new PRM_NotificationToAccountOwners();
            notificationToCAM.updateQtrNotificationDateOnCAP();
            notificationToCAM.updateProfiledAccountsForAPJEMEA();
        }
      }
 }