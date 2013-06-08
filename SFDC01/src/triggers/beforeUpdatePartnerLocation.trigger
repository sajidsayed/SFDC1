trigger beforeUpdatePartnerLocation on Partner_Location__c (before insert,before update) {
    
    list<Partner_Location__c> lstPartnerLocation=new list<Partner_Location__c>();
    for(Integer i=0;i<Trigger.New.size();i++)
    {
        if(trigger.IsUpdate){
            if(Trigger.New[i].eBus_Location_Enabled__c!=Trigger.Old[i].eBus_Location_Enabled__C &&
            Trigger.New[i].eBus_Location_Enabled__c==TRUE)
            {
                lstPartnerLocation.add(Trigger.New[i]);
            }
            else if(Trigger.New[i].eBus_Location_Enabled__c!=Trigger.Old[i].eBus_Location_Enabled__C &&
            Trigger.New[i].eBus_Location_Enabled__c==FALSE)
            {
                Trigger.New[i].eBus_Lead_Admin__c=null;
            }
        }
        else if(trigger.IsInsert){
            if(Trigger.New[i].eBus_Location_Enabled__c==TRUE){
               lstPartnerLocation.add(Trigger.New[i]); 
            }
        }
    } 
	
    if(lstPartnerLocation!=null && lstPartnerLocation.size()>0)
    {
        PartnerInfoIntegrationOperation partnerObj=new PartnerInfoIntegrationOperation();
        partnerObj.updateLocationFieldsBasedOnAccount(lstPartnerLocation);
    }
}