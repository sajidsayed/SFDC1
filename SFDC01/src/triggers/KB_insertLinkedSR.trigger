trigger KB_insertLinkedSR on Linked_SR__c (before insert,after insert, before update) {

List<Linked_SR__c> lstLinkSR = trigger.new;
KB_SubmitArticleForApproval obj = new KB_SubmitArticleForApproval();

for(Linked_SR__c lnkObj :lstLinkSR){
    if(Trigger.isInsert && Trigger.isBefore){
        lnkObj.Linking_User__c  = UserInfo.getUserId();
        //obj.submitArticleForApproval(trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        
        obj.submitArticleForApproval(trigger.new);
    }
    if(Trigger.isUpdate){
        if(lnkObj.Linked__c == false){
            lnkObj.Article_Solved_My_Problem__c = false;    
        }
        if(lnkObj.Article_Number__c!=trigger.oldMap.get(lnkObj.Id).Article_Number__c){
            obj.submitArticleForApproval(trigger.new);
        }
    }
}

}