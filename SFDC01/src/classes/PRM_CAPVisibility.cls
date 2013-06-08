/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER           WR      DESCRIPTION                               

 |  ====          =========           ==      =========== 

 |  6/12/2010     Ashwini Gowda      1155     This is class is used to allow partners users
                                              and CMs to access the channel account plan. 
 |  15/12/2010    Ashwini Gowda      1489     The PRM tool will allow the below mentioned
                                     1457     Groups to have access to Channel Account plans
                                              upon creation by the CAM. 
 |  23/12/2010    Ashwini Gowda               Method createObjectiveShareforApproversAndGroups()
                                              removed as no need of having sharing on Objective
 |                                            since the relationship changed from Look up to
                                              Master-Detail.    
 |                                             
   12/05.2011     PRasad             181716 Updated the condition for null check on EMC_Sales_Mgt_Approver for creating shares.                                                                                                                                      
 +===========================================================================*/
public class PRM_CAPVisibility {
    Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
    String AmericasDistributorCAP = data.get('AmericasDistributorCAP').DataValue__c;
    String AmericasResellerCAP = data.get('AmericasResellerCAP').DataValue__c;
    String APJDistributorCAP = data.get('APJDistributorCAP').DataValue__c;
    String APJResellerCAP = data.get('APJResellerCAP').DataValue__c;
    String EMEADistributorCAP = data.get('EMEADistributorCAP').DataValue__c;
    String EMEAResellerCAP = data.get('EMEAResellerCAP').DataValue__c;
    
    String AmericasMarketing = data.get('AmericasMarketing').DataValue__c;
    String APJMarketing = data.get('APJMarketing').DataValue__c;
    String EMEAMarketing = data.get('EMEAMarketing').DataValue__c;
    
/* @Method <This method is used to create the sharing access on Channel Account Plan>.
   @param <This is method is taking only on parameter List of Channel Account Plan>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void createCAPShareforApprovers(List<SFDC_Channel_Account_Plan__c> channelPlanList){ 
        Map<String,Id> channelPlanMap = new Map<String,Id>();
        for(SFDC_Channel_Account_Plan__c channelPlan: channelPlanList){
            System.debug('v: plan --'+channelPlan);
            if(channelPlan.Partner_Approver__c!=null){
                    System.debug('v: chaanel approver --'+channelPlan.Partner_Approver__c);
                    channelPlanMap.put(channelPlan.Partner_Approver__c,channelPlan.id);
             }
            if(channelPlan.EMC_Sales_Mgt_Approver__c!=null){
                 channelPlanMap.put(channelPlan.EMC_Sales_Mgt_Approver__c,channelPlan.id);
            }
        }
        if(channelPlanMap.size()>0){
            System.debug('v: chaanel plan Map:'+channelPlanMap);
            createCAPShare(channelPlanMap); 
        }
        
    }

/* @Method <This method is used to create the sharing access on Channel Account Plan for Groups>.
   @param <This is method is taking only on parameter List of Channel Account Plan>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void createCAPShareforGroups(List<SFDC_Channel_Account_Plan__c> channelPlanList){    
        Map<String,Id> APJMarketingVisibility = new Map<String,Id>();
        Map<String,Id> AmericasMarketingVisibility = new Map<String,Id>();
        Map<String,Id> EMEAMarketingVisibility = new Map<String,Id>();  
        
        for(SFDC_Channel_Account_Plan__c channelPlanVisibility: channelPlanList){
            if(channelPlanVisibility.RecordTypeId==EMEAResellerCAP || 
                channelPlanVisibility.RecordTypeId==EMEADistributorCAP){
                EMEAMarketingVisibility.put(EMEAMarketing,channelPlanVisibility.id);
            }
            else if(channelPlanVisibility.RecordTypeId==APJDistributorCAP || 
                channelPlanVisibility.RecordTypeId==APJResellerCAP){
                APJMarketingVisibility.put(APJMarketing,channelPlanVisibility.id);  
            }
            else if(channelPlanVisibility.RecordTypeId==AmericasDistributorCAP || 
                channelPlanVisibility.RecordTypeId==AmericasResellerCAP){
                AmericasMarketingVisibility.put(AmericasMarketing,channelPlanVisibility.id);    
            }
        }
        if(EMEAMarketingVisibility.size()>0){
            createCAPShare(EMEAMarketingVisibility);    
        }
        if(APJMarketingVisibility.size()>0){
            createCAPShare(APJMarketingVisibility);
        }
        if(AmericasMarketingVisibility.size()>0){
            createCAPShare(AmericasMarketingVisibility);
        }
    }

/* @Method <This method is used to create the sharing access on Channel Account Plan>.
   @param <This is method is taking only on parameter set of ID's>
   <Set<Id> -- Which contains user ID's>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

    public void createCAPShare(Map<String,Id> UserIds){
        System.debug('v: plan size channelPlanMap'+UserIds);
        List<SFDC_Channel_Account_Plan__Share> channelPlanShare = new List<SFDC_Channel_Account_Plan__Share>();
        try{
            for(String userId :UserIds.keySet()){
                channelPlanShare.add(new SFDC_Channel_Account_Plan__Share(UserOrGroupId=userId,
                                                                          AccessLevel='Edit',
                                                                          ParentId = UserIds.get(userId)));
           }
           insert channelPlanShare;
       }
       Catch(DmlException ex){          
       }
    }   
    
    
}