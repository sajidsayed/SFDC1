/*============================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR       DESCRIPTION                               

 |  ====          =========         ==       =========== 

 |  03/05/2011    Anand Sharma     2338     Trigger to calulate "# of Associated Products" on a Deal Reg.     
 	14/07/2011    Ashwini Gowda    			Commented check to display error message for PSC when DR is approved 
 											and updated to display for Partner Users. 
 +==============================================================================================================*/
trigger beforeInsertUpdateDeleteOnRegistrationProduct on Registration_Product__c (before delete, before insert, before update) {
    
    Set<Id> setDealId = new Set<Id>();
    List<Registration_Product__c> lstRegistrationProduct = new List<Registration_Product__c>();
    if(Trigger.isDelete){
        lstRegistrationProduct = Trigger.old;   
                
    }else if(Trigger.isInsert){
        lstRegistrationProduct = Trigger.new;           
    }
    
    if(lstRegistrationProduct.size() >0){
        for(Registration_Product__c regProduct: lstRegistrationProduct){
            if(regProduct.Deal_Registration__c!=null){
                setDealId.add(regProduct.Deal_Registration__c);                            
            }
        }
    } 
    
    if(setDealId.size() >0){
               
        Map<Id, Lead> mapDealRecord = new Map<Id, Lead>([Select id, DealReg_Deal_Registration_Status__c,DealReg_Submission_Source__c , DealReg_PSC_Owner__c from Lead where id in:setDealId]);
        for(Registration_Product__c regProduct: lstRegistrationProduct){
            if(regProduct.Deal_Registration__c !=null){
                if(mapDealRecord.containsKey(regProduct.Deal_Registration__c)){
                    if(Userinfo.getUserType()== 'PowerPartner' && (mapDealRecord.get(regProduct.Deal_Registration__c).DealReg_Deal_Registration_Status__c =='Approved') && 
                    	(mapDealRecord.get(regProduct.Deal_Registration__c).DealReg_Submission_Source__c != 'Powerlink')&& userInfo.getUserId().indexOf('00570000001L8zr')!=-1){
                        regProduct.addError(System.Label.ApprovedDealRegError);
                    }/*else if((Userinfo.getUserType()!= 'PowerPartner') && (mapDealRecord.get(regProduct.Deal_Registration__c).DealReg_Submission_Source__c != 'Powerlink') && ((mapDealRecord.get(regProduct.Deal_Registration__c).DealReg_PSC_Owner__c == null)
                         || ( mapDealRecord.get(regProduct.Deal_Registration__c).DealReg_PSC_Owner__c != Userinfo.getUserId()))){
                        regProduct.addError(System.Label.ApprovedDealRegErrorForNonPartnerUser);                            
                    }*/
                }                                 
            }  
        }
                    
    }
}