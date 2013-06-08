/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER          WR       DESCRIPTION                               

 |  ====          =========          ==       =========== 

 |  9/2/2011     Anirudh Singh      Req#1746  This class will allow designated internal
                                              EMC users to clone related objectives of 
 |                                            Parent Cahnnel Plan from which a new channel
                                              Plan is cloned.    
 |  3/05/2011    Anirudh Singh      Req#2774  Updated cloneObjective Method to include cloning
                                              of related Strategies of Channel Plan.         
   11/23/2011    Prasad                       Changed whole clonning logic                                                                              
 +==================================================================================================================**/

public class PRM_CloneChannelPlan {
    
/*@Method <cloneObjective(): This Method would create copy of associated Objectives 
                             and strategies of the current Channel Account plan record which is 
                              getting cloned.>
@param - <This method is taking list of cloned channel plan as input parameters>
@return - <None>
@throws exception - <No Exception>
*/
     public void cloneobjectives(List<SFDC_Channel_Account_Plan__c> triggerList){
        set<string> ParentPlansId = New set<string>();
            
        String StrParentPlansId=''; 
        Map<String,String>OriginalClonedObjectiveIDs = new Map<String,String>();
        
        for(SFDC_Channel_Account_Plan__c channelPlan :triggerList){
            if(StrParentPlansId==''){
                StrParentPlansId='\''+channelPlan.Clone__c;
            }else{
                StrParentPlansId=StrParentPlansId+'\',\''+channelPlan.Clone__c;    
            }
            OriginalClonedObjectiveIDs.put(channelPlan.Clone__c,channelPlan.Id);
        }
        StrParentPlansId=StrParentPlansId+'\'';
        System.debug('OriginalClonedObjectiveIDs ' +OriginalClonedObjectiveIDs); 
       
       Map<String, Schema.SObjectField> StrategyFieldMap = Schema.SObjectType.Strategy__c.fields.getMap();
       String fields='';
       for(String name :StrategyFieldMap.keySet()){
            if(name.toLowerCase()=='id') continue;
            if(fields==''){
                fields=name;
            }else{
                fields=fields+','+name;    
            }
        }
        
       
       String objectiveQuery='Select '+fields + ' from Strategy__c where Channel_Plan__c in ('+StrParentPlansId + ')';
       List<Strategy__c> StrategyList = Database.query(objectiveQuery);
       List<Strategy__c> ClonedStrategyList = new List<Strategy__c>(); 
       if(StrategyList.size()>0){
           
           for(Strategy__c item: StrategyList){
               Strategy__c obj=item.clone(false,false,false,false);
               System.debug('obj.Channel_Plan__c '+(''+obj.Channel_Plan__c).substring(0,15));
               obj.Channel_Plan__c = OriginalClonedObjectiveIDs.get((''+obj.Channel_Plan__c).substring(0,15));
               System.debug('obj.Channel_Plan__c '+obj.Channel_Plan__c);
               ClonedStrategyList.add(obj);
               
           }
           insert ClonedStrategyList;
       }
       
    
       
       
       Map<String, Schema.SObjectField> ObjectiveFieldMap = Schema.SObjectType.SFDC_Objective__c.fields.getMap();
       fields='';
       for(String name :ObjectiveFieldMap.keySet()){
            if(name.toLowerCase()=='id') continue;
            if(fields==''){
                fields=name;
            }else{
                fields=fields+','+name;    
            }
        }
       
       objectiveQuery='Select '+fields + ' from SFDC_Objective__c where Channel_Account_Plan__c in ('+StrParentPlansId + ')';
       List<SFDC_Objective__c> objectivesList = Database.query(objectiveQuery);
       
       if(objectivesList.size()>0){
           Map<String,String>MapOriginalClonedStrategyId= new Map<String,String>(); 
           for( integer i=0 ;i < ClonedStrategyList.size();i++){
               MapOriginalClonedStrategyId.put(StrategyList[i].id,ClonedStrategyList[i].id);
           }
           
           
           List<SFDC_Objective__c> ClonedobjectivesList =  new List<SFDC_Objective__c>();
          
           for(SFDC_Objective__c item: objectivesList ){
               SFDC_Objective__c obj=item.clone(false,false,false,false);
               
               obj.Channel_Account_Plan__c = OriginalClonedObjectiveIDs.get((''+obj.Channel_Account_Plan__c).substring(0,15));
               obj.Strategy__c=MapOriginalClonedStrategyId.get(''+obj.Strategy__c);
               System.debug('obj.Channel_Plan__c '+obj.Channel_Account_Plan__c);
               ClonedobjectivesList.add(obj);
           }
           insert ClonedobjectivesList;
       } 
   }   
       
}