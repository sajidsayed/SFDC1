/******************************************************************

Updated By  Date
Prasad      04 May 2011 Deal Reg Bypass
22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                      NOTE: Please write all the code after BYPASS Logic

********************************************************************/
trigger Lead_CalculateQAge on Lead (before update) {
    //Trigger BYPASS Logic
     if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
                return;
         }
     } 
        // declare local vars 
        Set <String> uniqueQOwnerIds = new Set <String>(); 

        // run through and look for any Q owners 
        for (Lead lead : trigger.new) {
            if (String.valueOf(lead.OwnerId).startsWith('00G') && 
                ! lead.DealReg_Deal_Registration__c) {  //bypass for deal reg
                uniqueQOwnerIds.add(String.valueOf(lead.OwnerId));  
            }
        }
        
        if(uniqueQOwnerIds.size()>0){
            
            // now query for the names of the unique Qs found
            Map <Id, Group> qId2Q = new Map<Id, Group>([Select Name From Group Where Id IN :uniqueQOwnerIds]);
            
            // set the last owned Q name field
            for (Lead lead : trigger.new) {
                if (String.valueOf(lead.OwnerId).startsWith('00G')) {
                    lead.Last_Assigned_Q__c = qId2Q.get(lead.OwnerId).Name; 
                }
            }
        }
        
        // calculate Q age data
        for (Integer x = 0; x < trigger.new.size(); x++) {
            if ( ! trigger.new.get(x).DealReg_Deal_Registration__c &&  //bypass for deal reg
                 (trigger.new.get(x).Q_Ownership_End__c != trigger.old.get(x).Q_Ownership_End__c) && 
                 (trigger.new.get(x).Q_Ownership_End__c != null) && (trigger.new.get(x).Q_Ownership_Start__c != null)) {
                Date startDate =  trigger.new.get(x).Q_Ownership_Start__c;
                Date endDate = trigger.new.get(x).Q_Ownership_End__c;
    
                trigger.new.get(x).Q_Ownership_Duration__c = startDate.daysBetween(endDate);
                
                if (trigger.new.get(x).Running_Q_Ownership_Duration__c == null) {
                    trigger.new.get(x).Running_Q_Ownership_Duration__c = 
                        trigger.new.get(x).Q_Ownership_Duration__c;
                } else {
                    trigger.new.get(x).Running_Q_Ownership_Duration__c += 
                        trigger.new.get(x).Q_Ownership_Duration__c;     
                }
            }
        }
        
     }