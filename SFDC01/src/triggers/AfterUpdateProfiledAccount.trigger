/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
 ======================================================================================================================================*/
//This trigger is used during the grouping creation or updation of group

trigger AfterUpdateProfiledAccount on Account_Groupings__c (after update,after insert) {
    //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
       if(CustomSettingBypassLogic__c.getInstance().By_Pass_Grouping_Triggers__c){
            return;
       }
    }
    
    PRM_GroupingOfAssignment Obj = new PRM_GroupingOfAssignment();

//When an insertion operation is performed on grouping this get executed

    if(Trigger.isInsert){
        //This flage is set here to avoid the execution of the trigger AfterUpdateOfAccountGrouping
        PRM_GroupingOfAssignment.PartnerGroupingCreation=true;
        List<Account_Groupings__c> groupingList = Trigger.new;
        Obj.createGrouping(groupingList);
        PRM_PAN_VPP_Operations PANVPPOBJ = new PRM_PAN_VPP_Operations();
        PANVPPOBJ.RollupSpecialitiesPanlevel(Trigger.new);
        
    }
    if(Trigger.isUpdate){
         PRM_PAN_VPP_Operations PANOperations = new PRM_PAN_VPP_Operations();
         PANOperations.syncPANAttributes(Trigger.OldMap,Trigger.NewMap);
         PANOperations.RollupSpecialitiesPanlevel(Trigger.new);
         
    }
    
//This is executed when any updation on grouping is done.
/*
    if(Trigger.isUpdate){
        //This flage is set here to avoid the execution of the trigger AfterUpdateOfAccountGrouping
        PRM_GroupingOfAssignment.PartnerGroupingCreation=true;

        List<Account_Groupings__c> updateListOfGroup = Trigger.new;
        Map<Id,Account_Groupings__c> newMasterGrouping = Trigger.newMap;
        Map<Id,Account_Groupings__c> oldMasterGrouping = Trigger.oldMap;
        Obj.updateOfGrouping(updateListOfGroup,newMasterGrouping,oldMasterGrouping);
    }*/
 }