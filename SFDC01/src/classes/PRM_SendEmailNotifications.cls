/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER          WR       DESCRIPTION                               

 |  ====          =========          ==       =========== 

 |  15/11/2010    Ashwini Gowda               This class will would send Notification to 
                                              Designated List of users for the selected
                                              Template.
    24/11/2010    Suman B                     Change the method signature of sendEmailNotification() 
                                               for userList from List<Id> to List<User>.   
 +==================================================================================================================**/

public class PRM_SendEmailNotifications {
    /* @Method <sendEmailNotification(): This is method would send Notification to the
                                          Designated List of users for the selected
                                          Template.>
       @param - <This method will take List of Users along with the Template Name as arguments>
       @return <void> - <returning nothing>
       @throws exception - <No Exception>
    */ 
     public void sendEmailNotification(List<User> usersList,String emailTemplateName){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();         
        List<String> toAddresses = new List<String>();
    /** List<User> usersEmailIdLlist = [Select u.Email, u.Id 
                                        from User u
                                        where Id in:usersList]; **/
                                                
        for(User user : usersList){
            toAddresses.add(user.Email); 
        }
        mail.setToAddresses(toAddresses);
        EmailTemplate Template = [Select e.Body,e.Name, e.Subject 
                                  From EmailTemplate e
                                  where name =:emailTemplateName];  
        mail.setSubject(Template.Subject);
        mail.setPlainTextBody(Template.body);   
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });                                      
     }
}