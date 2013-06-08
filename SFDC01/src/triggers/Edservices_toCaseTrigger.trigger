/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR             DESCRIPTION                               

 |  ====          =========                ==             =========== 

 |  04/22/2013   Ganesh Soma                             Updated code to make the ‘SLA_Completed__c’ field value to blank when the Case status changed from ‘Resolved’ to some other status.
                                                         checking condition to restrict recursive execution of calculateClosureTime method
 +==============================================================================================================================================================**/

trigger Edservices_toCaseTrigger on Case (after insert, before update) {
    String rtName = System.label.EDServices_RecordType;
    List<Case> lstCase = new List<Case>();
    
    EdServices_CheckRecordType edServObj = new EdServices_CheckRecordType();
    lstCase = edServObj.checkRecordType(trigger.new);
    
    
    if(trigger.isInsert){
        EDServices_Emailmsg obj = new EDServices_Emailmsg();
        for(Case cs:lstCase){
            if(lstCase.size()>0){
                obj.autoAssignmentToQueue(lstCase);
                
            }
        }
    }
    
    //Commented by Ganesh on 22Arpil2013
    /*
    if(trigger.isUpdate){
        Map<Id,Case> mapResolvedCase = new Map<Id,Case>();
        for(Case cs:lstCase){
            if(cs.Status=='Resolved'&& lstCase.size()>0){
               mapResolvedCase.put(cs.Id,cs); 
            }
        }
        Presales_Calculate_Closure_Time obj = new Presales_Calculate_Closure_Time(); 
        if(mapResolvedCase.size()>0){
            obj.calculateClosureTime(mapResolvedCase,trigger.oldMap);
        }
    }
    */
    //Added by Ganesh on 22Arpil2013
      if(trigger.isBefore && trigger.isUpdate){
        Map<Id,Case> mapResolvedCase = new Map<Id,Case>();
        for(Case cs:lstCase){        	
        	 if(cs.Status == 'Resolved' && cs.Status != trigger.oldMap.get(cs.id).Status){          
               mapResolvedCase.put(cs.Id,cs); 
        	 }
        	 else if(trigger.oldMap.get(cs.id).Status== 'Resolved'&& cs.Status != trigger.oldMap.get(cs.id).Status){
                cs.SLA_Completed__c = null;
            }
        }        
        if(mapResolvedCase.size()>0){
        	Presales_Calculate_Closure_Time obj = new Presales_Calculate_Closure_Time();
            obj.calculateClosureTime(mapResolvedCase,trigger.oldMap);
        }
    }
}