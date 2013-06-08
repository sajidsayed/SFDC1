/*================================================================================
 |  ---------       ----------      ------      Initial Creation
 |  09.09.2011      Srinivas N      174032      Ensure Lead fields on Opportunity are populated when Related Opportunity is populated
 |  04.11.2011      Srinivas N                  Fix for Prod exception ""caused by: System.ListException: Duplicate id in list: 0067000000MBP9NAAX
    22/01/2011      Accenture                   Updated trigger to incorporate ByPass Logic
 |                                              NOTE: Please write all the code after BYPASS Logic      
==================================================================================*/

// This trigger is used to set Reporting and Previous Owner Fileds on Lead.
trigger SetOwners on Lead (before insert,before update) {
    //Trigger BYPASS Logic
     if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
                return;
         }
     }
    //We are setting the Current Owner 
    for(Integer i=0;i<Trigger.new.size();i++)   
    {
        if(String.valueOf(Trigger.new[i].OwnerId).startsWith('005'))
            Trigger.new[i].Reporting_Owner__c=Trigger.new[i].OwnerId;
        else
            Trigger.new[i].Reporting_Owner__c=null;
    }
    //We are setting the Previous Owner
    if(Trigger.isUpdate) {
        for(integer i=0; i<Trigger.new.Size();i++){
            String oldOwnerId=Trigger.old[i].ownerid;
            if( Trigger.new[i].ownerid != Trigger.old[i].ownerid){
                if(oldOwnerId.startsWith('005')){
                    Trigger.new[i].Previous_Owner__c=Trigger.old[i].ownerid;
                    }
                else{
                    Trigger.new[i].Previous_Owner__c=null;
                }
            }
        }
    }
    //Change for WR-174032 
    if(trigger.isUpdate){
        map<id,Opportunity> mapOppty = new map<id,Opportunity>();
        for(lead led : trigger.new){
            if(led.Related_Opportunity__c != null && led.Status == 'Converted to Opportunity'){
                Opportunity  opt = new Opportunity(id=led.Related_Opportunity__c);
                opt.Originator__c = led.Lead_Originator__c;
                opt.Originator_Detail__c = led.Originator_Details__c;
                opt.Other_Originator_Detail__c = led.Other_Originator_Details__c;
                opt.Campaign_Identifier__c = led.Lead_Identifier__c;
                opt.Campaign_Event_Name__c = led.Campaign_Event_Name__c;
                
                mapOppty.put(opt.id, opt);
            }   
        }
        if(mapOppty.values()!= null && mapOppty.values().size() > 0)
            Database.update(mapOppty.values(),false); 
    }
    //End of change for WR-174032
  }