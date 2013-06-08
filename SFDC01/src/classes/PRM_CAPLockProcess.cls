/*=======================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 |  12/8/2010     Ashwini Gowda                     This class is used When the CAP is 
                                                    approved by the designated partner approver,
                                                    the Channel account plan and objectives 
                                                    should be locked.  
 +======================================================================================*/
public class PRM_CAPLockProcess {
        
    
            
/* @Method <lockChannelAccountPlans(): This method would flip the RecordTypes to Locked
                                       when a Channel Account Plan is approved by PartnerApprover.>
   @param - <List<SFDC_Channel_Account_Plan__c>: from Trigger when Status is Approved.>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void lockChannelAccountPlans(Map<Id,SFDC_Channel_Account_Plan__c> approvedChannelPlanMap){       
        
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        String AmericasDistributorCAP = data.get('AmericasDistributorCAP').DataValue__c;
        String AmericasDistributorCAPLocked = data.get('AmericasDistributorCAPLocked').DataValue__c;
        String AmericasResellerCAP = data.get('AmericasResellerCAP').DataValue__c;
        String AmericasResellerCAPLocked = data.get('AmericasResellerCAPLocked').DataValue__c;
        String APJDistributorCAP = data.get('APJDistributorCAP').DataValue__c;
        String APJDistributorCAPLocked = data.get('APJDistributorCAPLocked').DataValue__c;
        String APJResellerCAP = data.get('APJResellerCAP').DataValue__c;
        String APJResellerCAPLocked = data.get('APJResellerCAPLocked').DataValue__c;
        String EMEADistributorCAP = data.get('EMEADistributorCAP').DataValue__c;
        String EMEADistributorCAPLocked = data.get('EMEADistributorCAPLocked').DataValue__c;
        String EMEAResellerCAP = data.get('EMEAResellerCAP').DataValue__c;
        String EMEAResellerCAPLocked = data.get('EMEAResellerCAPLocked').DataValue__c;
        
        List<SFDC_Channel_Account_Plan__c> AmericasCAPList = new 
                                                    List<SFDC_Channel_Account_Plan__c>();
        //List<SFDC_Channel_Account_Plan__c> AmericasResellerCAPList = new 
        //                                          List<SFDC_Channel_Account_Plan__c>();
        List<SFDC_Channel_Account_Plan__c> APJCAPList = new 
                                                    List<SFDC_Channel_Account_Plan__c>();
        //List<SFDC_Channel_Account_Plan__c> APJResellerCAPList = new 
        //                                          List<SFDC_Channel_Account_Plan__c>();
        //List<SFDC_Channel_Account_Plan__c> EMEADistributorCAPList = new 
       //                                           List<SFDC_Channel_Account_Plan__c>();
        List<SFDC_Channel_Account_Plan__c> EMEAResellerList = new 
                                                    List<SFDC_Channel_Account_Plan__c>();
                                                                                                                                                                                    
        for(SFDC_Channel_Account_Plan__c approvedPlan: approvedChannelPlanMap.values()){
            if(approvedPlan.RecordTypeId==AmericasDistributorCAP){
                approvedPlan.RecordTypeId=AmericasDistributorCAPLocked;
                
            }
            else if(approvedPlan.RecordTypeId==AmericasResellerCAP){
                approvedPlan.RecordTypeId=AmericasResellerCAPLocked;
                
            }
            else if(approvedPlan.RecordTypeId==APJDistributorCAP){
                approvedPlan.RecordTypeId=APJDistributorCAPLocked;
            }
            else if(approvedPlan.RecordTypeId==APJResellerCAP){
                approvedPlan.RecordTypeId=APJResellerCAPLocked;
            }
            else if(approvedPlan.RecordTypeId==EMEADistributorCAP){
                approvedPlan.RecordTypeId=EMEADistributorCAPLocked;
                
            }
            else if(approvedPlan.RecordTypeId==EMEAResellerCAP){
                approvedPlan.RecordTypeId=EMEAResellerCAPLocked;
                
            }             
        }
        lockObectives(approvedChannelPlanMap.keySet());
        lockStrategy(approvedChannelPlanMap.keySet());
    }
/* @Method <lockObectives(): This method would flip the RecordTypes to Lock Objectives
                             when a Channel Account Plan is approved by PartnerApprover.>
   @param - <List<SFDC_Channel_Account_Plan__c>: from Trigger when Status is Approved.>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void lockObectives(Set<Id> approvedChannelPlanIds){          
        List<SFDC_Objective__c> objectivesList = new List<SFDC_Objective__c>();
        
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();    
        String AmericasObjective = data.get('AmericasObjective').DataValue__c;
        String AmericasObjectiveLocked = data.get('AmericasObjectiveLocked').DataValue__c;
        String APJObjective = data.get('APJObjective').DataValue__c;
        String APJObjectiveLocked = data.get('APJObjectiveLocked').DataValue__c;
        String EMEAObjective = data.get('EMEAObjective').DataValue__c;
        String EMEAObjectiveLocked = data.get('EMEAObjectiveLocked').DataValue__c;
        
        
            List<SFDC_Objective__c> objectives = [Select s.Channel_Account_Plan__c, s.Id,s.RecordTypeId 
                                                  from SFDC_Objective__c s  
                                                  where Channel_Account_Plan__c in:approvedChannelPlanIds];
            for(SFDC_Objective__c objective: objectives){
                    if(objective.RecordTypeId==AmericasObjective){
                        objective.RecordTypeId=AmericasObjectiveLocked;
                        
                    }
                    else if(objective.RecordTypeId==APJObjective){
                        objective.RecordTypeId=APJObjectiveLocked;
                        
                    }
                    else if(objective.RecordTypeId==EMEAObjective){
                        objective.RecordTypeId=EMEAObjectiveLocked;
                    }
            }
          if(objectives.size()>0){
            update objectives;
          }                                            
     }
        
/* @Method <lockStrategy(): This method would flip the RecordTypes to Lock Objectives
                             when a Channel Account Plan is approved by PartnerApprover.>
   @param - <List<SFDC_Channel_Account_Plan__c>: from Trigger when Status is Approved.>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void lockStrategy(Set<Id> approvedChannelPlanIds){           
        List<SFDC_Objective__c> objectivesList = new List<SFDC_Objective__c>();
        
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();    
        String AmericasObjective = data.get('AMERStrategy').DataValue__c;
        String AmericasObjectiveLocked = data.get('AMERStrategyLocked').DataValue__c;
        String APJObjective = data.get('APJStrategy').DataValue__c;
        String APJObjectiveLocked = data.get('APJStrategyLocked').DataValue__c;
        String EMEAObjective = data.get('EMEAStrategy').DataValue__c;
        String EMEAObjectiveLocked = data.get('EMEAStrategyLocked').DataValue__c;
        
        
            List<Strategy__c> Strategies = [Select s.Channel_Plan__c, s.Id,s.RecordTypeId 
                                                  from Strategy__c s  
                                                  where Channel_Plan__c in:approvedChannelPlanIds];
            for(Strategy__c Strategy : Strategies){
                    if(Strategy.RecordTypeId==AmericasObjective){
                        Strategy.RecordTypeId=AmericasObjectiveLocked;
                        
                    }
                    else if(Strategy.RecordTypeId==APJObjective){
                        Strategy.RecordTypeId=APJObjectiveLocked;
                        
                    }
                    else if(Strategy.RecordTypeId==EMEAObjective){
                        Strategy.RecordTypeId=EMEAObjectiveLocked;
                    }
            }
          if(Strategies.size()>0){
            update Strategies;
          }                                            
     }
     
     
            
/* @Method <unlockChannelAccountPlans(): This method would flip the RecordTypes to Locked
                                       when a Channel Account Plan is approved by PartnerApprover.>
   @param - <List<SFDC_Channel_Account_Plan__c>: from Trigger when Status is Approved.>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void unlockChannelAccountPlans(Map<Id,SFDC_Channel_Account_Plan__c> approvedChannelPlanMap){     
        
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        String AmericasDistributorCAP = data.get('AmericasDistributorCAP').DataValue__c;
        String AmericasDistributorCAPLocked = data.get('AmericasDistributorCAPLocked').DataValue__c;
        String AmericasResellerCAP = data.get('AmericasResellerCAP').DataValue__c;
        String AmericasResellerCAPLocked = data.get('AmericasResellerCAPLocked').DataValue__c;
        String APJDistributorCAP = data.get('APJDistributorCAP').DataValue__c;
        String APJDistributorCAPLocked = data.get('APJDistributorCAPLocked').DataValue__c;
        String APJResellerCAP = data.get('APJResellerCAP').DataValue__c;
        String APJResellerCAPLocked = data.get('APJResellerCAPLocked').DataValue__c;
        String EMEADistributorCAP = data.get('EMEADistributorCAP').DataValue__c;
        String EMEADistributorCAPLocked = data.get('EMEADistributorCAPLocked').DataValue__c;
        String EMEAResellerCAP = data.get('EMEAResellerCAP').DataValue__c;
        String EMEAResellerCAPLocked = data.get('EMEAResellerCAPLocked').DataValue__c;
        
        List<SFDC_Channel_Account_Plan__c> AmericasCAPList = new 
                                                    List<SFDC_Channel_Account_Plan__c>();
        //List<SFDC_Channel_Account_Plan__c> AmericasResellerCAPList = new 
        //                                          List<SFDC_Channel_Account_Plan__c>();
        List<SFDC_Channel_Account_Plan__c> APJCAPList = new 
                                                    List<SFDC_Channel_Account_Plan__c>();
        //List<SFDC_Channel_Account_Plan__c> APJResellerCAPList = new 
        //                                          List<SFDC_Channel_Account_Plan__c>();
        //List<SFDC_Channel_Account_Plan__c> EMEADistributorCAPList = new 
       //                                           List<SFDC_Channel_Account_Plan__c>();
        List<SFDC_Channel_Account_Plan__c> EMEAResellerList = new 
                                                    List<SFDC_Channel_Account_Plan__c>();
                                                                                                                                                                                    
        for(SFDC_Channel_Account_Plan__c approvedPlan: approvedChannelPlanMap.values()){
            if(approvedPlan.RecordTypeId==AmericasDistributorCAPLocked){
                approvedPlan.RecordTypeId=AmericasDistributorCAP;
                
            }
            else if(approvedPlan.RecordTypeId==AmericasResellerCAPLocked){
                approvedPlan.RecordTypeId=AmericasResellerCAP ;
                
            }
            else if(approvedPlan.RecordTypeId==APJDistributorCAPLocked){
                approvedPlan.RecordTypeId=APJDistributorCAP;
            }
            else if(approvedPlan.RecordTypeId==APJResellerCAPLocked){
                approvedPlan.RecordTypeId=APJResellerCAP;
            }
            else if(approvedPlan.RecordTypeId==EMEADistributorCAPLocked){
                approvedPlan.RecordTypeId=EMEADistributorCAP;
                
            }
            else if(approvedPlan.RecordTypeId==EMEAResellerCAPLocked){
                approvedPlan.RecordTypeId=EMEAResellerCAP;
                
            }           
        }
        unlockObectives(approvedChannelPlanMap.keySet());
        unlockStrategy(approvedChannelPlanMap.keySet());
    }
/* @Method <unlockObectives(): This method would flip the RecordTypes to Lock Objectives
                             when a Channel Account Plan is approved by PartnerApprover.>
   @param - <List<SFDC_Channel_Account_Plan__c>: from Trigger when Status is Approved.>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void unlockObectives(Set<Id> approvedChannelPlanIds){            
        List<SFDC_Objective__c> objectivesList = new List<SFDC_Objective__c>();
        
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();    
        String AmericasObjective = data.get('AmericasObjective').DataValue__c;
        String AmericasObjectiveLocked = data.get('AmericasObjectiveLocked').DataValue__c;
        String APJObjective = data.get('APJObjective').DataValue__c;
        String APJObjectiveLocked = data.get('APJObjectiveLocked').DataValue__c;
        String EMEAObjective = data.get('EMEAObjective').DataValue__c;
        String EMEAObjectiveLocked = data.get('EMEAObjectiveLocked').DataValue__c;
        
        
            List<SFDC_Objective__c> objectives = [Select s.Channel_Account_Plan__c, s.Id,s.RecordTypeId 
                                                  from SFDC_Objective__c s  
                                                  where Channel_Account_Plan__c in:approvedChannelPlanIds];
            for(SFDC_Objective__c objective: objectives){
                    if(objective.RecordTypeId==AmericasObjectiveLocked){
                        objective.RecordTypeId=AmericasObjective;
                        
                    }
                    else if(objective.RecordTypeId==APJObjectiveLocked){
                        objective.RecordTypeId=APJObjective;
                        
                    }
                    else if(objective.RecordTypeId==EMEAObjectiveLocked){
                        objective.RecordTypeId=EMEAObjective;
                    }
            }
          if(objectives.size()>0){
            update objectives;
          }                                            
     }
        
/* @Method <unlockStrategy(): This method would flip the RecordTypes to Lock Objectives
                             when a Channel Account Plan is approved by PartnerApprover.>
   @param - <List<SFDC_Channel_Account_Plan__c>: from Trigger when Status is Approved.>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void unlockStrategy(Set<Id> approvedChannelPlanIds){         
        List<SFDC_Objective__c> objectivesList = new List<SFDC_Objective__c>();
        
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();    
        String AmericasObjective = data.get('AMERStrategy').DataValue__c;
        String AmericasObjectiveLocked = data.get('AMERStrategyLocked').DataValue__c;
        String APJObjective = data.get('APJStrategy').DataValue__c;
        String APJObjectiveLocked = data.get('APJStrategyLocked').DataValue__c;
        String EMEAObjective = data.get('EMEAStrategy').DataValue__c;
        String EMEAObjectiveLocked = data.get('EMEAStrategyLocked').DataValue__c;
        
        
            List<Strategy__c> Strategies = [Select s.Channel_Plan__c, s.Id,s.RecordTypeId 
                                                  from Strategy__c s  
                                                  where Channel_Plan__c in:approvedChannelPlanIds];
            for(Strategy__c Strategy : Strategies){
                    if(Strategy.RecordTypeId==AmericasObjectiveLocked){
                        Strategy.RecordTypeId=AmericasObjective;
                        
                    }
                    else if(Strategy.RecordTypeId==APJObjectiveLocked){
                        Strategy.RecordTypeId=APJObjective;
                        
                    }
                    else if(Strategy.RecordTypeId==EMEAObjectiveLocked){
                        Strategy.RecordTypeId=EMEAObjective;
                    }
            }
          if(Strategies.size()>0){
            update Strategies;
          }                                            
     }



/* @Method <populatePartnerApproverOnObjective(): This method would fetch the Partner Approver
                                                   associated to Channel Account Plan.>
   @param - List<SFDC_Objective__c>: List of objectives from Trigger.>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void populatePartnerApproverOnObjective(List<SFDC_Objective__c> objectivesList){
        Set<Id> channelPlanIds = new Set<Id>();
        for(SFDC_Objective__c objective: objectivesList){
            if(objective.Channel_Account_Plan__c!=null){
                channelPlanIds.add(objective.Channel_Account_Plan__c);
            }
        } 
        List<SFDC_Channel_Account_Plan__c> channelPlans = [Select id,Partner_Approver__c 
                                                            from SFDC_Channel_Account_Plan__c
                                                            where Id in :channelPlanIds]; 
        Map<Id,Id> partnerApprover = new Map<Id,Id>();
        if(channelPlans.size()>0){
            for(SFDC_Channel_Account_Plan__c channelPlan: channelPlans ){
                partnerApprover.put(channelPlan.id,channelPlan.Partner_Approver__c);
            }  
        } 
        for(SFDC_Objective__c objective: objectivesList){
            for(Id channelId:partnerApprover.KeySet()){
                if(objective.Channel_Account_Plan__c==channelId){
                    objective.Partner_Approver__c=partnerApprover.get(objective.Channel_Account_Plan__c);
                }
            }
        }
    }
    
}