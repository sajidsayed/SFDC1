/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 | 12/09/2012    Hemavathi N M   204033       Trigger for updating record on Pricing Request Share object on modification of oppty owner      
                                                                                  
 +==================================================================================================================**/
trigger afterOpptyUpdate on Opportunity (after update) {

Transformation_PricingShare_Class pricObj = new Transformation_PricingShare_Class();
List<Opportunity> lstOpportunity = new List<Opportunity>();
Map<Id,Opportunity> mapOpportunity = new map<Id,Opportunity>();
list<Id> oldId = new list<id>();
list<Id> newId = new list<id>();

if(trigger.isAfter && trigger.isUpdate){
for(Opportunity prObj : Trigger.new){
            
            if(prObj.Opportunity_Owner__c!=null && (prObj.Opportunity_Owner__c != trigger.oldMap.get(prObj.id).Opportunity_Owner__c)){
            	newId.add(prObj.Opportunity_Owner__c);
            	oldId.add(trigger.oldMap.get(prObj.id).Opportunity_Owner__c);
            	mapOpportunity.put(prObj.Id,prObj);
            }           
        }
        System.debug('newId--->'+ newId + 'oldId--->' + oldId);
        if(newId.size() > 0){
        pricObj.updateShare(oldId,Trigger.new);
        } 
        if(mapOpportunity.size() > 0){
        pricObj.updateTheaterFieldOppty(mapOpportunity);
        } 

}
}