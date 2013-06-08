/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 | 26/04/2012    Leonard Victor            This class is used for populating Partner Related Fields on Case
 | 30/05/2012    Leonard Victor            Updated class to include partner case creation through SFDC system
 +==================================================================================================================**/


public class Presales_PartnerCaseOperation {

    public Static Boolean partnerFlag = false;
    public Static Boolean instPartner = false;
    
    
    /* @Method <This method execute is used to populate Partner Related Fields on Case record on Insert or Update>
    @param <This method takes List<Case> as parameter>
    @return void - <Not returning anything>
    @throws exception - <No Exception>
    */ 
    
    public void insertPartner(List<Case> lstCase , Boolean updateGrp , List<Id> partnerCase){
    
    if(!partnerFlag){
        
        Map<Id,String> mapMailLst = new Map<Id,String>();
        Set<ID> caseSt = new Set<ID>();
        List<Id> cntList = new List<ID>();
        Set<ID> acctST = new Set<ID>();
        Map<Id,List<Id>> mapId = new Map<Id,List<Id>>();
        Map<Id,Account> mapAccount = new Map<Id,Account>();
        Map<Id,Account_Groupings__c> mapGrp = new Map<Id,Account_Groupings__c>();
        List<Account>  accList = new List<Account>();
        List<Account_Groupings__c>  grpLst = new List<Account_Groupings__c>();
        
        for(Case csObj : lstCase){

            //mapMailLst.put(csObj.id,csObj.Contact_Email1__c);
            cntList.add(csObj.contactid);
        }
        if (!updateGrp){
        
        Map<Id,Contact>  cntMap=new map<Id,Contact>([Select id,Partner_Contact2__c,Account.Grouping__c,Account.BillingCountry,Account.Theater1__c,accountid,email from contact where id in :cntList 
                                 and Partner_Contact2__c = true and Account.IsPartner=true]);
                                 
                
        if(cntMap.size()>0)
        {
    
            
            for(Case cse:lstCase){
                    if(cse.contactid!=null){
                    cse.Partner_Case__c = true;
                    cse.Partner_Grouping_Name__c = cntMap.get(cse.contactid).Account.Grouping__c; 
                    cse.Partner_Country__c = cntMap.get(cse.contactid).Account.BillingCountry;
                    cse.Partner_Theater__c = cntMap.get(cse.contactid).Account.Theater1__c;
                   }
		   else
                   {
                     cse.Partner_Country__c = null;
                     cse.Partner_Theater__c = null;
                   }
                                    
        }

        
    }

    else{

        instPartner = true;
    }
    
      
    }
    
    if((updateGrp && partnerCase.size()>0) || (instPartner && partnerCase.size()>0)){
        
        Map<ID,Id> mapAcc = new Map<Id,Id>();
        
        
        grpLst = [SELECT Profiled_Account__c,id FROM Account_Groupings__c where id in: partnerCase];
        
        System.debug('updateGrp'+updateGrp);
        System.debug('updateGrp Section'+grpLst);
        
        for(Account_Groupings__c accGrp : grpLst){
            
            mapAcc.put(accGrp.Profiled_Account__c,accGrp.id);
        }
        
        if(mapAcc.keySet().size()>0){
            
            accList = [SELECT BillingCountry,Theater1__c,id FROM Account where id in: mapAcc.keyset()];
            
        }
        
        System.debug('updateGrp Section accList'+accList);
        
        if(accList.size()>0){
        
        for(Account acc:accList){
            
            if(mapAcc.containsKey(acc.id)){
            mapAccount.put(mapAcc.get(acc.id),acc);
            }
        }
        
        if(mapAccount.size()>0){
            
            for(Case cse:lstCase){
                
                    cse.Partner_Case__c = true;
                    cse.Partner_Country__c = mapAccount.get(cse.Partner_Grouping_Name__c).BillingCountry;
                    cse.Partner_Theater__c = mapAccount.get(cse.Partner_Grouping_Name__c).Theater1__c;
                    
                
        }
    }
        }
        
        else
        {
            for(Case cse:lstCase){
                if(cse.Partner_Grouping_Name__c!=null)
                cse.Partner_Grouping_Name__c.addError(System.Label.Presales_PartnerGrouping);
		else
                {
		   cse.Partner_Country__c = null;
                   cse.Partner_Theater__c = null;
                }
                
        }
            
        }
        
    }
    
       partnerFlag = true;
       
       }
    
    }
    
    
    

}