/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 | 26-April-11   Arif                 This class contains the logic of completing the POB task
 |                                    from Inbound Email.
 | +====================================================================================*/
global class PRM_UpdatePOBTaskFromInboundEmail implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String emailsubject = '',emailBody='';
        String subject='',pobId='';
        Integer checkSubjectCompletion;
        Integer checkSubjectOwnerPowerlink,checkSubjectOwnerSynergy,checkSubjectOwnerCXP,indexOfPOB;
        Authorized_Reseller_Onboarding_Task__c authTask;
        
        try{
              
              emailsubject = email.subject.toLowerCase();      
              checkSubjectCompletion = emailsubject.indexOf('complete');
              checkSubjectOwnerPowerlink = emailsubject.indexOf('powerlink entitlements');
              checkSubjectOwnerSynergy = emailsubject.indexOf('synergy partner activation');
              checkSubjectOwnerCXP = emailsubject.indexOf('reseller addition to distribution var list');
              if(checkSubjectCompletion != -1){    
                 if(checkSubjectOwnerPowerlink != -1){
                    subject = 'Step 3a - Powerlink Setup';
                 }
                 if(checkSubjectOwnerSynergy != -1){
                    subject = 'Step 3c - Synergy Setup';
                 }
                 if(checkSubjectOwnerCXP != -1){
                    subject = 'Step 3b - CXP Setup';
                 }
                 emailBody = email.plainTextBody.trim();
                 System.debug('emailBody----->' +emailBody); 
                 indexOfPOB = emailBody.indexOf('Partner Onboarding Id:');
                 System.debug('indexOfPOB----->' +indexOfPOB); 
                 pobId = emailBody.substring(indexOfPOB+23,indexOfPOB+23+15); 
                 System.debug('pobId----->' +pobId); 
                 System.debug('subject----->' +subject);
                 authTask = [Select Id,Status__c,Subject__c from Authorized_Reseller_Onboarding_Task__c where
                             Partner_Onboarding__c = :pobId and Subject__c = :subject];
                if(authTask!=null){
                     authTask.Status__c = 'Complete';
                     Update authTask; 
                }           
              }
        }
        catch (System.StringException e)
        {
              System.debug('Error in Select statement ' + e);
        }
        
        
        result.success = true;
        return result;
    }
}