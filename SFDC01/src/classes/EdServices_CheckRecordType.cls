/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER               WR        DESCRIPTION                               

 |  ====          =========               ==        =========== 

 |  14/10/2011     Shalabh Sharma                   This class is used to check whether case record is related to Education Services or not.     
 |  14March2013    Ganesh Soma         WR#247113    SOQL Optimization:Instead of quering on the RecordType object created a formula feild to get the developer name                             
 +=================================================================================================================================================================**/
 public class EdServices_CheckRecordType{
 public static Boolean isRun = true;
 public static Boolean isNewEmail = true;
 public string strCaseStatus = '';
 
/* @Method <This method execute is used to check if the case is related to Education Services or not>
@param <This method takes List<Case> as parameter>
@returns List<Case>- <Returning list of case>
@throws exception - <No Exception>
*/   
     /*
     //commented by Ganesh on 14thmarch2013
     public List<Case> checkRecordType(List<Case> lstCase){
     Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>();
     List<Case> lstEdServiceCase = new List<Case>();
     if(isRun){
     //Quering database for all case record types where developer name contains 'Education_Services'
      mapRecordType = new Map<Id,RecordType>([select id,Name from RecordType where sObjectType='Case' and DeveloperName like 'Education_Services%']);
     } 
     isRun = false;   
         for(Case caseRecord:lstCase){
            if(mapRecordType.size()>0 && mapRecordType.containsKey(caseRecord.RecordTypeId)){
                lstEdServiceCase.add(caseRecord);
            }
         }
         
         return lstEdServiceCase;
         
     } */
     
      public List<Case> checkRecordType(List<Case> lstCase){
     Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>();
     List<Case> lstEdServiceCase = new List<Case>();
         for(Case caseRecord:lstCase){
            if(caseRecord.Record_Type_Developer_Name__c!=null && caseRecord.Record_Type_Developer_Name__c.Contains('Education_Services')){
            	lstEdServiceCase.add(caseRecord);
            }
         }
         
         return lstEdServiceCase;
         
     }
/* @Method <This method execute is used to check if the Case is related to Education Services or not>
@param <This method takes List<EmailMessage> as parameter>
@returns Boolean- <Returning Boolean>
@throws exception - <No Exception>
*/
  /* ganesh commented on 14thmarch2013
    public Boolean checkCaseEmailRecordType(List<EmailMessage> caseEmail){
        Boolean isEdServices=false;
        Case caseRecord = new Case();
        if(isNewEmail){
            for(EmailMessage emailMessageLoop:caseEmail){
                caseRecord = [Select id,RecordTypeId from Case where Id =:emailMessageLoop.ParentId];
            }
            //Quering database for all case record types where developer name contains 'Education_Services'
            Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>([select id,Name from RecordType where sObjectType='Case' and DeveloperName like 'Education_Services%']);
            if(mapRecordType.containsKey(caseRecord.RecordTypeId)){
                isEdServices=true;    
            }
        }
        isNewEmail=false;
        return isEdServices;
    } */
    
    
      public Boolean checkCaseEmailRecordType(List<EmailMessage> caseEmail){
        Boolean isEdServices=false;
         strCaseStatus = '';
        Case caseRecord = new Case();
        if(isNewEmail){
            for(EmailMessage emailMessageLoop:caseEmail){
                caseRecord = [Select id,Status,Record_Type_Developer_Name__c,RecordTypeId from Case where Id =:emailMessageLoop.ParentId];
            }
          
            if(caseRecord!=null && (caseRecord.Record_Type_Developer_Name__c!=null && caseRecord.Record_Type_Developer_Name__c.Contains('Education_Services'))){
                strCaseStatus = caseRecord.Status;
                isEdServices=true;    
            }
        }
        isNewEmail=false;
        return isEdServices;
    }      
 }