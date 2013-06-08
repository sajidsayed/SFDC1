public with sharing class EBC_ShowProfiles {
    
    public EBC_Briefing_Event__c BE {get;set;}
    public String errMsg{get; set;}
    public ProfileCustom__c[] showprofiles {get; set;} // to hold the events associated with the Briefing Event. 

    public EBC_ShowProfiles(ApexPages.StandardController controller) {
        
        BE =[Select Id, Name, Customer_Name__c from EBC_Briefing_Event__c where Id=:ApexPages.currentPage().getParameters().get('Id') LIMIT 1];
    }

    public List<ProfileCustom__c> getProfiles()
    {
        errMsg='';
        if(String.valueof(BE.Customer_Name__c)!=Null && String.valueof(BE.Customer_Name__c)!='')
        showprofiles = [Select Id, Name, Account_del__c from ProfileCustom__c where Account_del__c=:BE.Customer_Name__c];
        else
        return NULL;
        if(showprofiles.size()<=0)
        {
            errMsg='No records found.';
        }
        return showprofiles;
    } 
}