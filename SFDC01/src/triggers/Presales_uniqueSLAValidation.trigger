/*Trigger to validate unique SLA*/
trigger Presales_uniqueSLAValidation on Presales_SLA__c (before insert,before update,before delete) {

      List<Presales_SLA__c> slaLst= Trigger.new;   
      List<Presales_SLA__c> slaOldLst= Trigger.old;
      Presales_SLA_Class obj = new Presales_SLA_Class(); 
      boolean chkValid; 
      boolean executeTrigger=false;
      string triggerType;
      if(trigger.isUpdate){
          triggerType='Update';
      }//end of if
     /* for(Presales_SLA__c PSO : slaOldLst){
              for(Presales_SLA__c PSN : slaLst){

        System.debug('--->'+PSO.Priority__c +'--->'+PSN.Priority__c +'--->'+PSO.Case_Record_Type__c +'--->'+ PSN.Case_Record_Type__c +'--->'+PSO.Theater__c +'--->'+ PSN.Theater__c);

              if(PSO.Priority__c != PSN.Priority__c || 
                PSO.Case_Record_Type__c != PSN.Case_Record_Type__c ||
                       PSO.Theater__c != PSN.Theater__c)
                        { 
                          executeTrigger= true;           
                        }
                      }
                  }*/
    if(triggerType == 'Update'){
        for(Presales_SLA__c PSN : trigger.newMap.values()){
            if(PSN.Priority__c != trigger.oldMap.get(PSN.Id).Priority__c ||
               PSN.Case_Record_Type__c != trigger.oldMap.get(PSN.Id).Case_Record_Type__c ||
               PSN.Theater__c != trigger.oldMap.get(PSN.Id).Theater__c || PSN.Country__c != trigger.oldMap.get(PSN.Id).Country__c)
               { 
                 executeTrigger= true;           
                }
            }//end of For
         }
      else if(trigger.isInsert){
          executeTrigger=true;
          triggerType='Insert';
      }
      System.debug('executeTrigger--->'+executeTrigger);
      if(executeTrigger == true){
      System.debug('executeTrigger1--->'+executeTrigger);
            chkValid=obj.chkUniqueSLAValidation(slaLst,triggerType);
    }
     
    if(chkValid == true){
        slaLst[0].addError('SLA already exists, Kindly enter new values');
    }

    if(trigger.isDelete){
        System.debug('slaLst--->'+slaOldLst);
        boolean chkDeleteValid = obj.chkSLABeforeDelete(slaOldLst);
        if(chkDeleteValid == true){
            slaOldLst[0].addError('SLA is associated with a Case.');
        }
    }
 }