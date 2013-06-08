/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER               WR        DESCRIPTION                               

 |  ====          =========               ==        =========== 
    
 |  14March2013    Ganesh Soma         WR#247113    SOQL Optimization:Instead of quering on the RecordType object created a formula feild to get the developer name                             
 +=================================================================================================================================================================**/

public class Presales_VLabContactOperations {
	/*
	// ganesh  commented on 12thmarch2013
	public void populateVLabRequestor(List<Case> lstCase){
		Map<String,List<Case>> mapEmailCase = new Map<String,List<Case>>();
		Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>([select id,Name from RecordType where sObjectType='Case' and DeveloperName = 'Presales_vLab_Demo']);
		for(Case caseRecord:lstCase){
			if(mapRecordType.containsKey(caseRecord.RecordTypeId) && caseRecord.vLab_Contact_Email__c != null){
				caseRecord.Contact_Email1__c = caseRecord.vLab_Contact_Email__c;			
			}
		}
	}
	*/
	
	public void populateVLabRequestor(List<Case> lstCase){
		Map<String,List<Case>> mapEmailCase = new Map<String,List<Case>>();		
		for(Case caseRecord:lstCase){
			if((caseRecord.Record_Type_Developer_Name__c!=null && caseRecord.Record_Type_Developer_Name__c.contains('Presales_vLab_Demo')) && caseRecord.vLab_Contact_Email__c != null){
				caseRecord.Contact_Email1__c = caseRecord.vLab_Contact_Email__c;			
			}
		}
	}
}