/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  06/09/2011     Shalabh Sharma       This class is used to autoescalate a case on receiving the requestor's email response.                                         
 +==================================================================================================================**/
global class Presales_EscalateCaseFromInboundEmail implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String emailsubject = '',emailBody='';
        String subject='',caseId='';
        Integer checkSubjectCompletion,checkSubjectEscalation;    
        Integer indexOfCase;
        Case caseRecord;       
        try{                           
              emailsubject = email.subject.toLowerCase();
              emailsubject = email.subject; 
              /*Checking if email subject contains word "escalate"*/     
              checkSubjectEscalation = emailsubject.indexOf('escalate');
              /*Checking if email subject contains word "close"*/ 
              checkSubjectCompletion = emailsubject.indexOf('close');
              if(checkSubjectEscalation!= -1){     
                 caseId = emailsubject.substring(checkSubjectEscalation+8,checkSubjectEscalation+26); 
                 System.debug('caseId----->' +caseId); 
                 System.debug('subject----->' +subject);
                 caseRecord= [Select Id,Status,IsEscalated from Case where
                             Id =:caseId];
                 system.debug('case recrord---->>>'+caseRecord); 
                /*If case status is not closed then escalating the case*/      
                if(caseRecord!=null&& caseRecord.Status!='Closed'){
                     caseRecord.IsEscalated = true;
                     caseRecord.Escalation__c = 'Email Auto Escalated';
                     Update caseRecord; 
                }
                /*If case status is closed then checking the IsMailAfterClose checkbox*/
                else if(caseRecord!=null && caseRecord.Status == 'Closed'){
                    
                    CaseComment caseComment = new CaseComment();
                    caseComment.ParentId = caseId;
                    system.debug('email.plainTextBody--->'+email.plainTextBody);
                    caseComment.CommentBody = email.plainTextBody;
                    insert caseComment;
                    system.debug('caseComment--->'+caseComment);
                    caseRecord.IsMailAfterClose__c = true;
                    system.debug('caseRecord.IsMailAfterClose__c--->'+caseRecord.IsMailAfterClose__c);
                    Update caseRecord;
                    system.debug('caseRecord.IsMailAfterClose__c--->'+caseRecord.IsMailAfterClose__c);
                }           
              }
              if(checkSubjectCompletion != -1){
                  caseId = emailsubject.substring(checkSubjectCompletion+5,checkSubjectCompletion+23);
                  CaseComment caseComment = new CaseComment();
                  caseComment.ParentId = caseId;
                  caseComment.CommentBody = 'Please close the case.';
                  insert caseComment;
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