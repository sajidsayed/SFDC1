/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  14/10/2011     Shalabh Sharma       This class is used to check whether case record is related to presales or not.    
 |  14March2013    Ganesh Soma         WR#247113    SOQL Optimization:Instead of quering on the RecordType object created a formula feild to get the developer name                                    
 +==================================================================================================================**/
 public class Presales_CheckRecordType{
    
    public string strCaseStatus = '';
/* @Method <This method execute is used to check if the case is related to Presales or not>
@param <This method takes List<Case> as parameter>
@returns List<Case>- <Returning list of case>
@throws exception - <No Exception>
*/   
     /* // ganesh commented on 12thmarch2013
     
     public List<Case> checkRecordType(List<Case> lstCase){
     System.debug('TEST**********'+lstCase);
     List<Case> lstPresalesCase = new List<Case>();
     Quering database for all case record types where developer name contains 'Presales'
     Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>([select id,Name from RecordType where sObjectType='Case' and DeveloperName like 'Presales%']);
         for(Case caseRecord:lstCase){
            if(mapRecordType.containsKey(caseRecord.RecordTypeId)){
                lstPresalesCase.add(caseRecord);
            }
         }
         return lstPresalesCase;
     } */
     
     public List<Case> checkRecordType(List<Case> lstCase){
     System.debug('TEST**********'+lstCase);
     List<Case> lstPresalesCase = new List<Case>();     
         for(Case caseRecord:lstCase){
             if(caseRecord.Record_Type_Developer_Name__c != null && caseRecord.Record_Type_Developer_Name__c.contains('Presales')){             
                lstPresalesCase.add(caseRecord);
            }
         }
         return lstPresalesCase;
     }
/* @Method <This method execute is used to check if the task is related to Presales or not>
@param <This method takes List<Task> as parameter>
@returns List<Task>- <Returning list of Task>
@throws exception - <No Exception>
*/    
    public List<Task> checkTaskRecordType(List<Task> lstTask){
     
     List<Task> lstPresalesTask = new List<Task>();
     /*Quering database for all task record types where developer name contains 'Presales'*/
     Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>([select id,Name from RecordType where sObjectType='Task' and DeveloperName like 'Presales%']);
         for(Task taskRecord:lstTask){
            if(mapRecordType.containsKey(taskRecord.RecordTypeId)){
                lstPresalesTask.add(taskRecord);
            }
         }
         return lstPresalesTask ;
     }
/* @Method <This method execute is used to check if the Case is related to Presales or not>
@param <This method takes List<EmailMessage> as parameter>
@returns Boolean- <Returning Boolean>
@throws exception - <No Exception>
*/

/* //Commented by Ganesh on 12march2013

    public Boolean checkCaseEmailRecordType(List<EmailMessage> caseEmail){
        Boolean isPresales=false;
        Case caseRecord = new Case();
        for(EmailMessage emailMessageLoop:caseEmail){
            caseRecord = [Select id,RecordTypeId from Case where Id =:emailMessageLoop.ParentId];
        }
        //Quering database for all case record types where developer name contains 'Presales'
        Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>([select id,Name from RecordType where sObjectType='Case' and DeveloperName like 'Presales%']);
        if(mapRecordType.containsKey(caseRecord.RecordTypeId)){
            isPresales=true;    
        }
        return isPresales;
    } 
    
    */    
    
     public Boolean checkCaseEmailRecordType(List<EmailMessage> caseEmail){
        Boolean isPresales=false;
        strCaseStatus = '';
        Case caseRecord = new Case();
        for(EmailMessage emailMessageLoop:caseEmail){
            caseRecord = [Select id,Status,Record_Type_Developer_Name__c,RecordTypeId from Case where Id =:emailMessageLoop.ParentId];
        }      
        if(caseRecord!=null && (caseRecord.Record_Type_Developer_Name__c != null && caseRecord.Record_Type_Developer_Name__c.Contains('Presales')))
        {
             strCaseStatus = caseRecord.Status;
             isPresales=true;    
        }        
        return isPresales;
    } 
    
    
/* @Method <This method execute is used to check if case is created by Conversion Admin>
@param <This method takes no parameter>
@returns Boolean- <Returning Boolean>
@throws exception - <No Exception>
*/ 
    public Boolean checkIFConversionAdmin(){
        Boolean isAPI = false;
        Profile profileLoginUser = [Select Id,Name from Profile where Id=:UserInfo.getProfileId()];
        system.debug('profileLoginUser--->'+profileLoginUser);
        if(profileLoginUser.Name == 'System Administrator - API Only'){
            isAPI = true;   
        }   
        return isAPI;
    }     
 }