trigger beforeInsertUpdateOpptyProduct on OpportunityLineItem (before update) {
 
 if(trigger.isBefore){
 if (trigger.isUpdate) {
    new Transformation_OpptyProductOperations().insertOpptyProduct(trigger.newMap);
     }
    }
}