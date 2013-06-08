/*============================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR       DESCRIPTION                               

 |  ====          =========         ==       =========== 

 |  03/05/2011    Ashwini Gowda     2338     Trigger to calulate "# of Associated Products" on a Deal Reg.     
 +==============================================================================================================*/
trigger afterInsertUpdateDeleteOnRegistrationProduct on Registration_Product__c (after delete, after insert, after update) {
    
    Map<Id,List<Registration_Product__c>> leadWithProductsMap = new Map<Id,List<Registration_Product__c>>();
    Map<Id,Registration_Product__c> mapLeadWithProduct = new Map<Id,Registration_Product__c>();
    Set<Id> setLeadIds = new Set<Id>();
    
    if(Trigger.isInsert){
        for(Registration_Product__c regProduct: Trigger.New){
            if(regProduct.Deal_Registration__c!=null){
                setLeadIds.add(regProduct.Deal_Registration__c);
            }
        }
    }else if(trigger.isUpdate){
        for(Registration_Product__c regProduct: Trigger.old){
            if(regProduct.Deal_Registration__c!=null){
                setLeadIds.add(regProduct.Deal_Registration__c);
            }
        }
    }else if(Trigger.isDelete){
        for(Registration_Product__c regProduct: Trigger.Old){
            if(regProduct.Deal_Registration__c!=null){
				setLeadIds.add(regProduct.Deal_Registration__c);               
            }
        }
    }
    if(setLeadIds.size()>0){

        mapLeadWithProduct = new Map<Id,Registration_Product__c>([
                                    Select r.Deal_Registration__c, r.Id, r.Name, r.Partner_Product_Catalog__c, r.Product__c 
                                    from Registration_Product__c r
                                    where Deal_Registration__c in: setLeadIds
                                    ]);
        System.debug('setLeadIds-----> '+ setLeadIds);                                  
        System.debug('mapLeadWithProduct-----> '+ mapLeadWithProduct);
        System.debug('mapLeadWithProduct of size-----> '+ mapLeadWithProduct.size());
        for(Registration_Product__c regProduct: mapLeadWithProduct.values()){
            if(regProduct.Deal_Registration__c!=null || regProduct.Deal_Registration__c!=''){
                if(leadWithProductsMap.containsKey(regProduct.Deal_Registration__c)){
                    leadWithProductsMap.get(regProduct.Deal_Registration__c).add(regProduct);
                }
                else{
                    leadWithProductsMap.put(regProduct.Deal_Registration__c, new List<Registration_Product__c>());
                    leadWithProductsMap.get(regProduct.Deal_Registration__c).add(regProduct);
                }
            }
        }
        
        List<Lead> dealRegsWithProducts = [Select id,DealReg_Of_Registration_Products__c
                                            from Lead 
                                            where id in: leadWithProductsMap.KeySet()];
        for(Lead dealReg: dealRegsWithProducts ){  
            System.debug('dealRegsWithProducts before-----> '+ leadWithProductsMap.get(dealReg.id).size());          
            dealReg.DealReg_Of_Registration_Products__c = leadWithProductsMap.get(dealReg.id).size();
            System.debug('dealRegsWithProducts-----> '+ dealReg.DealReg_Of_Registration_Products__c);
        } 
        System.debug('dealRegsWithProducts-----> '+ dealRegsWithProducts);
        Database.Saveresult[] arrResult = Database.update( dealRegsWithProducts, false);
        PRM_DEALREG_ApprovalRouting.addErrorOnRecords(arrResult, dealRegsWithProducts, leadWithProductsMap );
        if(setLeadIds.size()>0 && mapLeadWithProduct.size()==0){
            List<Lead> dealRegswithoutProducts = [Select id,DealReg_Of_Registration_Products__c
                                                    from Lead 
                                                    where id in: setLeadIds];
            for(Lead dealReg: dealRegswithoutProducts){
                dealReg.DealReg_Of_Registration_Products__c = 0;
            }
            System.debug('dealRegswithoutProducts-----> '+ dealRegswithoutProducts);
            Database.Saveresult[] arrResultWithoutProduct = Database.update( dealRegswithoutProducts, false);  
            PRM_DEALREG_ApprovalRouting.addErrorOnRecords(arrResultWithoutProduct , dealRegswithoutProducts, leadWithProductsMap );                                           
        }
                                                
    }

}