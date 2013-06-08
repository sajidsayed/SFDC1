/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER               WR        DESCRIPTION                               

 |  ====          =========               ==        =========== 

 |  14March2013    Ganesh Soma         WR#247113    SOQL Optimization:Instead of quering on the Case object we are getting the Status from the EdServices_CheckRecordType class                            
 +=================================================================================================================================================================**/

trigger EDServices_EmailMessage on EmailMessage (before insert) {
    String caseId;
    String fromAddress;
    String toAddress;
    String ccAddress;
    String rtName = System.label.EDServices_RecordType;
    
    
    EdServices_CheckRecordType edServObj = new EdServices_CheckRecordType();
    String strStatus = edServObj.strCaseStatus;//ganesh added on 14thmarch
    Boolean isEdServices = edServObj.checkCaseEmailRecordType(trigger.new);
    
    if(isEdServices){
    //RecordType rt = [Select Id, Name from RecordType where DeveloperName=:rtName];
        EDServices_Emailmsg emailmsg= new EDServices_Emailmsg ();
        emailmsg.EdServ_emsg(trigger.new);
        
         for(EmailMessage emailMessageLoop:trigger.new){
            caseId = emailMessageLoop.ParentId;
            fromAddress = emailMessageLoop.FromAddress;
            
            toAddress = emailMessageLoop.ToAddress;
        }
        //ganesh commented below statement on 14thmarch2013
        //Case cs = [Select Id,Status,RecordTypeId from Case where Id=:caseId];
        
        Presales_UpdateCaseTeams obj = new Presales_UpdateCaseTeams();
        if(strStatus=='Closed'){
         obj.addToCcToCaseTeam(caseId,ccAddress,fromAddress,toAddress);
       }
     }   
}