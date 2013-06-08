/*===========================================================================+
 | 22/01/2011      Accenture                           Updated trigger to incorporate ByPass Logic
 |                                                    NOTE: Please write all the code after BYPASS Logic
 | 17/05/2013		CSC			Added condition to include Isilon Track Speciality as part of WR 239600
+===========================================================================*/
 trigger beforeInsertUpdate on Account_Groupings__c (before insert,before update) {      
  //Trigger BYPASS Logic
  if(CustomSettingBypassLogic__c.getInstance()!=null){
      if(CustomSettingBypassLogic__c.getInstance().By_Pass_Account_Triggers__c || PRM_VPP_DeltaIdentifer.ProcessOnAfterUpdating){
         return;
        }
  }
    PRM_GroupingOfAssignment Obj = new PRM_GroupingOfAssignment();
    PRM_PAN_VPP_Operations PANVPPOBJ = new PRM_PAN_VPP_Operations();
    if(trigger.isInsert){
        List<Account_Groupings__c> listOfInsertGrouping = Trigger.new;
        Obj.beforeInsertOnGrouping(listOfInsertGrouping);
        PANVPPOBJ.syncSpecialitiesAcheived(listOfInsertGrouping);
    }    
    
    if(trigger.isUpdate){
        List<Account_Groupings__c> lstGroupingToSyncSpeciality = new List<Account_Groupings__c>();
        new PRM_VPP_DeltaIdentifer().deltaPartnerGroupingMarking(TRigger.oldMap,TRigger.NewMap);
        map<Id,Account_Groupings__c> mapOldAccGrouping = trigger.oldMap;
        if(PRM_GroupingOfAssignment.PRM_Logic_Executed){
            return;
        }
        for(Account_Groupings__c groupingObj : Trigger.new){
            if(groupingObj.Consolidate_Specialty__c != mapOldAccGrouping.get(groupingObj.Id).Consolidate_Specialty__c || 
               groupingObj.Advanced_Consolidate_Specialty__c != mapOldAccGrouping.get(groupingObj.Id).Advanced_Consolidate_Specialty__c ||
               groupingObj.Backup_and_Recovery_Specialty__c != mapOldAccGrouping.get(groupingObj.Id).Backup_and_Recovery_Specialty__c ||
               groupingObj.Governance_and_Archive_Specialty__c != mapOldAccGrouping.get(groupingObj.Id).Governance_and_Archive_Specialty__c ||
               groupingObj.Isilon_Track_Specialty__c != mapOldAccGrouping.get(groupingObj.Id).Isilon_Track_Specialty__c ||
               groupingObj.Cloud_Builder_Specialty__c != mapOldAccGrouping.get(groupingObj.Id).Cloud_Builder_Specialty__c ){
                   lstGroupingToSyncSpeciality .add(groupingObj);
               }
        }
        if(lstGroupingToSyncSpeciality.size()>0){
           PANVPPOBJ.syncSpecialitiesAcheived(lstGroupingToSyncSpeciality); 
        }
        /* if(PRM_EducationHelper.bypassTriggers){
            return;
        }*/
        
        else{
            PRM_GroupingOfAssignment.PRM_Logic_Executed=true;        
            //This flage is set here to avoid the execution of the trigger AfterUpdateOfAccountGrouping
            PRM_GroupingOfAssignment.PartnerGroupingCreation=true;
            List<Account_Groupings__c> updateListOfGroup = Trigger.new;
            Map<Id,Account_Groupings__c> newMasterGrouping = Trigger.newMap;
            Map<Id,Account_Groupings__c> oldMasterGrouping = Trigger.oldMap;
            Obj.updateOfGrouping(updateListOfGroup,newMasterGrouping,oldMasterGrouping);
            //Obj.beforeUpdateOnGrouping(listOfExcludeGrouping);
        }
    }
}