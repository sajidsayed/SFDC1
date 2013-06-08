/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  06.12.2010      Shipra Misra    151285      Add Install Base flag to Leads - Updated trigger to update/flag all Leads 
                                                where Related Account is marked as Install Base 
    17.01.2011      Shipra Misra    151285      Added variable Tst data"isLeadInsertUpdateExecuted" to handle recurrsive call
    22/01/2011      Accenture                   Updated trigger to incorporate ByPass Logic
 |                                              NOTE: Please write all the code after BYPASS Logic       
 +========================================================================================================================*/

trigger UpdateLeadPorfiles on Lead (After update)

{
  //Trigger BYPASS Logic 
     if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
                return;
         }
     } 
    if(!Util.isLeadInsertUpdateExecuted)
    {       
        Util.isLeadInsertUpdateExecuted = true;
        Map <String,String> lead_account = new Map<String,String>();   
        Set<String> owners= new Set<String>();
        //Shipra on 06/12/2010 to update install base on lead.
        //Hold Set Of Lead Id's.
        Set<Id> leadIdSet= new Set<Id>();
        for(id leadUpdate:trigger.newMap.keySet())
        {
            Lead leadNew =Trigger.newMap.get(leadUpdate);
            Lead leadOld =Trigger.oldMap.get(leadUpdate);
            if(leadNew.Related_Account__c!= leadOld.Related_Account__c )
            {
                leadIdSet.add(leadNew.id);
            }       
        }
        if(leadIdSet.size()>0)
        {
            Acc_updateInstallBaseAccount.updateInstallBaseAccountFromLeadCallFuture(leadIdSet);
        }
        //End of Code Update By Shipra.
       
        integer i=0; 
        
         for( i=0;i<Trigger.new.size();i++){
                 owners.add(Trigger.new[i].ownerId);
        }    
        
        System.debug('1  '+owners);
        
        if(owners.size()==0){
        return;
        }
        
    
        Map <Id,User> Users= new Map<Id,User>([select id,Profile_Name__c from user where id in:owners and Profile_Name__c ='EMEA Standard User' ]);  
           
        for( i=0;i<Trigger.new.size();i++){
        
            if( (Trigger.isUpdate && Trigger.new[i].related_account__c != Trigger.old[i].related_account__c) && Users.get(Trigger.new[i].ownerId)!=null ){
            
                lead_account.put(Trigger.new[i].id,Trigger.new[i].related_account__c);
            }
            
        }
        
         System.debug('2  '+ lead_account.size());
        if(lead_account.size()==0){
        return;
        }
        
    
        List<ProfileCustom__c> Profiles = new List<ProfileCustom__c>();
        Profiles=[Select id,Account_del__c,Prospect__c from ProfileCustom__c where Prospect__c in: lead_account.keySet() limit 1000];
        
        System.debug('3  '+ Profiles.size());
        
        for( i=0;i<Profiles.size();i++){
        Profiles[i].Account_del__c=lead_account.get( Profiles[i].Prospect__c );
        }
        if(Profiles.size()>0){
            update Profiles;
        }   
        System.debug('4 Done ');
    
    }
  }