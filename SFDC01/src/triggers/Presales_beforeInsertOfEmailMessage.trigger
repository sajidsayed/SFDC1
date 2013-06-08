/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER               WR        DESCRIPTION                               

 |  ====          =========               ==        =========== 

 |  14March2013    Ganesh Soma         WR#247113    SOQL Optimization:Instead of quering on the Case object we are getting the Status from the Presales_CheckRecordType class                            
 +=================================================================================================================================================================**/

/*Trigger to invoke class Presales_UpdateCaseTeams*/

trigger Presales_beforeInsertOfEmailMessage on EmailMessage (before insert) {
     Presales_CheckRecordType classObject = new Presales_CheckRecordType();
    Boolean isPresales = classObject.checkCaseEmailRecordType(trigger.new);
    String strStatus = classObject.strCaseStatus;
    System.debug('strStatus :'+strStatus  + 'isPresales  :'+isPresales);
    if(isPresales){
        Id caseId;
        String ccAddress;
        String fromAddress;
        Boolean isIncoming;
        String toAddress;
        String bccAddress;
        String subject;
        String body;
        
        /*Iterating over incoming email*/
        for(EmailMessage emailMessageLoop:trigger.new){
            caseId = emailMessageLoop.ParentId;
            fromAddress = emailMessageLoop.FromAddress;
            isIncoming = emailMessageLoop.Incoming;
            toAddress = emailMessageLoop.ToAddress;
            subject = emailMessageLoop.Subject;
            body = emailMessageLoop.TextBody;
            
            system.debug('isIncoming --->'+isIncoming);
            system.debug('case id--->'+caseId);
            system.debug('from address--->'+fromAddress); 
            system.debug('subject---->'+subject);
            if(emailMessageLoop.CcAddress!=null){            
                ccAddress = emailMessageLoop.CcAddress;
                system.debug('email cc address--->'+emailMessageLoop.CcAddress);      
            }
            
            if(emailMessageLoop.BCcAddress!=null){            
                bccAddress = emailMessageLoop.BCcAddress;
                system.debug('email cc address--->'+emailMessageLoop.BCcAddress);      
            }               
                
        }
        /*Creating object of Presales_UpdateCaseTeams class*/
        Presales_UpdateCaseTeams obj = new Presales_UpdateCaseTeams();
//Commented for defect 108- auto mails are not getting send.
//        if(ccAddress!=null && caseId!=null && fromAddress!=null&& isIncoming==true){

       if(caseId!=null && fromAddress!=null&& isIncoming==true){
            
          obj.addToCcToCaseTeam(caseId,ccAddress,fromAddress,toAddress);
          
     }
       

       //Defect :- 5055, chk if the toadd,ccadd, bccadd same as fromadd. while incoming mail to the system.
         
        boolean chkMailRows=false;
        //Commented by Ganesh on 12march2013
        //string caseStatus =[select status from case where id =: caseId].status ;
        
        boolean chkForAdditionalTo=false;
          if(strStatus == Label.Presales_Case_Auto_Close && caseId!=null && fromAddress!=null && isIncoming==true){

                system.debug('inside chkmail m/d--->');
                
               // if(fromAddress.contains(toAddress)){
                    chkForAdditionalTo = true;
              //  }
                
                system.debug('status--->'+ '<---chkForAdditionalTo--->'+chkForAdditionalTo+ '<---email add--->'+ fromAddress +'=='+ toAddress +'=='+ ccAddress +'==' +bccAddress);
                

        //  if(chkForAdditionalTo == true || fromAddress == ccAddress || fromAddress == bccAddress ){
                 chkMailRows= obj.chkemailContents(caseId,subject,body);
        //     }
             if(chkMailRows){
                Trigger.New[0].ToAddress.addError('Exception');
             }
          }

       
        /*Invoking method only for incoming emails*/
        if(caseId!=null && fromAddress!=null && isIncoming==true){
            
            //obj.populateRequestorDetailsEmailToCase(caseId,fromAddress);
        }
    }
 }