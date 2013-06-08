/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER               WR        DESCRIPTION                               

 |  ====          =========               ==        =========== 

 |  14March2013    Ganesh Soma         WR#247113    SOQL Optimization:Instead of quering on the RecordType object created a formula feild to get the developer name                             
 +=================================================================================================================================================================**/

public class EDServices_Emailmsg {
Id caseId;
String fromAddress;
//Boolean isIncoming;
//String toAddress;
//String bccAddress;
String subject;
String body;
Case cs;
//EmailMessage emailMessageLoop;
Education_Services_Contact__c edserv = new Education_Services_Contact__c();
public List<Education_Services_Contact__c> lstEdServiceContact = new List<Education_Services_Contact__c>();
 
 /*
    public void EdServ_emsg(List<EmailMessage> emsg){

    for(EmailMessage emailMessageLoop:emsg){
        caseId = emailMessageLoop.ParentId;
        fromAddress = emailMessageLoop.FromAddress;
        //isIncoming = emailMessageLoop.Incoming;
        //toAddress = emailMessageLoop.ToAddress;
        subject = emailMessageLoop.Subject;
        body = emailMessageLoop.TextBody;
        cs=[SELECT RecordtypeId,EDS_Contact_Email__c,Status,IsMailAfterClose__c FROM Case WHERE Id =: emailMessageLoop.ParentId]; 
        RecordType id = [select Id,Name,DeveloperName from RecordType where Id =:cs.RecordTypeId and SobjectType='Case'];
//Reuben L - added fromAddress != null check to if and else if statements to prevent null email address errors with mailer daemon servers
        if( id.DeveloperName== (System.label.EDServices_RecordType) && emailMessageLoop.Incoming == true && fromAddress != null)
        {          
            lstEdServiceContact=[Select Name,id from Education_Services_Contact__c where name=:fromAddress];
            if(lstEdServiceContact.size()>0 && cs.EDS_Contact_Email__c == null)
                cs.EDS_Contact_Email__c = lstEdServiceContact[0].Id;
            else if(cs.EDS_Contact_Email__c == null && fromAddress != null)
            {
                edserv.Name=fromAddress;
                insert edserv;
                cs.EDS_Contact_Email__c=edserv.Id;     
            } 
            if(cs.Status=='Closed'){
                cs.IsMailAfterClose__c = true;
            }
            
            update cs;       
        }        
    }   
    }*/
    
    
    
    
       public void EdServ_emsg(List<EmailMessage> emsg){

    for(EmailMessage emailMessageLoop:emsg){
        caseId = emailMessageLoop.ParentId;
        fromAddress = emailMessageLoop.FromAddress;
        //isIncoming = emailMessageLoop.Incoming;
        //toAddress = emailMessageLoop.ToAddress;
        subject = emailMessageLoop.Subject;
        body = emailMessageLoop.TextBody;
        cs=[SELECT RecordtypeId,Record_Type_Developer_Name__c,EDS_Contact_Email__c,Status,IsMailAfterClose__c FROM Case WHERE Id =: emailMessageLoop.ParentId]; 
        // Ganesh commneted below to get the Developer name from the formula field instead of quering on the Recordtype object 
       // RecordType id = [select Id,Name,DeveloperName from RecordType where Id =:cs.RecordTypeId and SobjectType='Case'];
//Reuben L - added fromAddress != null check to if and else if statements to prevent null email address errors with mailer daemon servers
        if((cs.Record_Type_Developer_Name__c!=null && cs.Record_Type_Developer_Name__c == (System.label.EDServices_RecordType)) && emailMessageLoop.Incoming == true && fromAddress != null)
        {          
            lstEdServiceContact=[Select Name,id from Education_Services_Contact__c where name=:fromAddress];
            if(lstEdServiceContact.size()>0 && cs.EDS_Contact_Email__c == null)
                cs.EDS_Contact_Email__c = lstEdServiceContact[0].Id;
            else if(cs.EDS_Contact_Email__c == null && fromAddress != null)
            {
                edserv.Name=fromAddress;
                insert edserv;
                cs.EDS_Contact_Email__c=edserv.Id;     
            } 
            if(cs.Status=='Closed'){
                cs.IsMailAfterClose__c = true;
            }
            
            update cs;       
        }        
    }   
    }
    
    
    
    
/* @Method <This method execute is used to auto assign a case to a queue according to the assignment rule.>
@param <This method takes List<Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/
    public void autoAssignmentToQueue(List<Case> lstCase){
        List<Case> lstToUpdate = [select Id,OwnerId from Case where Id in:lstCase]; 
        List<CaseShare> cs = new List<CaseShare>();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        if(lstToUpdate.size()>0){
            for(Case caseRecord:lstToUpdate){
                caseRecord.setOptions(dmo);
                               
            }            
        }        
        update lstToUpdate;   
    }
}