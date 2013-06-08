trigger EdServices_beforeInsertUpdateOfEducationServiceContact on Education_Services_Contact__c (before insert, before update) {
    List<String> lstEdServContactEmail = new List<String>();
    List<Education_Services_Contact__c> lstEdServContact = new List<Education_Services_Contact__c>();
    if(trigger.isInsert){
        for(Education_Services_Contact__c edServ : trigger.new){
        system.debug('edServ--->'+edServ);
            if(edServ.Name !=null){
                lstEdServContactEmail.add(edServ.Name);    
            }
        }
    }
    if(trigger.isUpdate){
        for(Education_Services_Contact__c edServ : trigger.newMap.values()){
            if(edServ.Name != null && edServ.Name != trigger.oldMap.get(edServ.Id).Name){
                lstEdServContactEmail.add(edServ.Name); 
            }
        }
    }
    if(lstEdServContactEmail.size()>0){
        lstEdServContact = [Select Id,Name from Education_Services_Contact__c where Name in:lstEdServContactEmail];
    }
    if(lstEdServContact.size()>0){
        for(Education_Services_Contact__c edSer :trigger.new){
            edSer.addError('An active Education Services Contact with this email address already exists in Salesforce.com.');
        }
    }
}