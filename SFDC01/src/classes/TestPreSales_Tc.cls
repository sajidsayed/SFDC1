/*===========================================================================+
 |  Created History                                                                  
                                                                 
 |  DATE       DEVELOPER  WORK REQUEST    DESCRIPTION                               
 |  ====       =========  ============    =========== 
 |  14-Jan-12  Anand Sharma              Test class    
 +===========================================================================*/

@isTest
private class TestPreSales_Tc {

    //Presales Task test method starts here
    static testMethod void  preSalesTask(){   
        try{
            Case objCase = [Select Id from Case limit 1];
            List<EmailMessage> caseEmail = new List<EmailMessage>();
            EmailMessage emailMess = new EmailMessage();
            emailMess.ParentId = objCase.Id;
            caseEmail.add(emailMess);           
            insert caseEmail;
        }catch(Exception ex){
        }  
   }  //End of Presales Task test method
} // Class Ends Here