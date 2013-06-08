/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER          WR       DESCRIPTION                               

 |  ====          =========          ==       =========== 

    24/11/2010    Suman B                     This is TestClass for PRM_SendEmailNotifications. 

 +==================================================================================================================**/
@isTest
Private class PRM_SendEmailNotifications_TC {
  /* @Method <sendEmailNotificationTest: Test method>
    */
 public testmethod static void sendEmailNotificationTest(){
   List<User> listuser = [SELECT id,name,email 
                                 FROM User limit 10]; 
    PRM_SendEmailNotifications sendEMs = new PRM_SendEmailNotifications();
   
     sendEMs.sendEmailNotification(listuser, 'partner email template');
   }
   
 }