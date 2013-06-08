/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  20.08.2010      Anand Sharma    136601      Initial Creation.  Helper class for Channel visibility ,Assign sales rep to the opportunity.               
 |  31.03.2010      Shipra Misra    155151      Update the functionality to send OAR Email Alerts in EMEA.  
 |  01.07.2011      Shipra Misra    168015      Enable OAR to Fire when Opportunity is Owned by House Account.Updated the code to add OAR added for sales team member.         
 |  14.10.2011      Shipra Misra    173695      Worked for Nov release.Introduction new allaince partner & deleting existing  & Outsourcer field.
 |  15.02.2012      Shipra Misra    187056      EMEA Inside sales email alert.
 
 +===========================================================================*/
public class Opp_ChannelVisibilityHelper {
    //used to create opportunity team members using opportunity assignment rule and opportunity
    public static Map<String,OpportunityTeamMember> createOpportunityTeamMember(Opportunity_Assignment_Rule__c objOppAssRule, Opportunity opp, Map<String,OpportunityTeamMember> mapOppTeamMember)
    {
        if(objOppAssRule.Resource_Name__c != null){
            Map<Id, OpportunityTeamMember> mapExistingOppTeamMembers = new Map<Id, OpportunityTeamMember>(opp.OpportunityTeamMembers);
            //check for existing opportunity team members
            boolean checkRecordFound = false;
            if(mapExistingOppTeamMembers.size()>0){
                for(OpportunityTeamMember objOppTeamMember : mapExistingOppTeamMembers.values()){
                    if(objOppTeamMember.OpportunityId == opp.Id && objOppTeamMember.UserId ==objOppAssRule.Resource_Name__c){
                        checkRecordFound = true;
                    }                   
                }
            }
            //Util.isChannelVisibilityExecuted=false;
            //if OTM record not found, then create opportunity team member and detail line records                          
            if(!checkRecordFound){
                if(objOppAssRule.Resource_Name__r.IsActive){
                    // Create Opportunity Team member records
                    OpportunityTeamMember objOppTeamMember = new OpportunityTeamMember();
                    objOppTeamMember.OpportunityId = opp.Id;
                    objOppTeamMember.UserId = objOppAssRule.Resource_Name__c;
                    objOppTeamMember.TeamMemberRole = objOppAssRule.Resource_Opportunity_Sales_Team_Role__c ;
                    if(!mapOppTeamMember.containsKey(opp.Id + '|' + objOppAssRule.Resource_Name__c)){
                        mapOppTeamMember.put(opp.Id + '|' + objOppAssRule.Resource_Name__c, objOppTeamMember);                  
                    }                                       
                }
            }           
        }
        return mapOppTeamMember;        
    }
    
    //used to remove opportunity team member from opportunity
    public static void removeOpportunityTeamMember(Map<id,Set<id>> mapOpptyTeamMembertobeDeleted){
                                    
        if(mapOpptyTeamMembertobeDeleted.size() >0){
            List<OpportunityTeamMember> lstOppTeamMember = new List<OpportunityTeamMember>();
            Set<id> userIds=new Set<Id>();
            for(Set<Id> setUserId:mapOpptyTeamMembertobeDeleted.values())
            {
                userIds.addAll(setUserId);
            }
            List<OpportunitySplit> lstOppSplits = new List<OpportunitySplit>();
            List<Detail_Line__c> lstDetailLines = new List<Detail_Line__c>();
            System.debug('+++Before setOppDeleteIds---> '+ mapOpptyTeamMembertobeDeleted.keySet());
            System.debug('+++Before setOppTeamUserIds---> '+ mapOpptyTeamMembertobeDeleted.values());                    
            //Fetch opportunity team member records where opportunity id in setOppDeleteIds and user id in setOppTeamUserIds.
            List<OpportunityTeamMember> lstOppTeamMemberData = [Select UserId, Id,OpportunityId from OpportunityTeamMember where OpportunityId IN:mapOpptyTeamMembertobeDeleted.keySet() AND UserId IN:userIds];
            System.debug('+++ Before lstOppTeamMember--->'+ lstOppTeamMember);
            //Fetch opportunity split records where opportunity id in setOppDeleteIds and user id in setOppTeamUserIds.
            List<OpportunitySplit> lstOppSplitsData = [Select Id,SplitOwnerId,OpportunityId from OpportunitySplit where OpportunityId IN:mapOpptyTeamMembertobeDeleted.keySet() AND SplitOwnerId IN:userIds];
            //Fetch detail line  records where opportunity id in setOppDeleteIds and user id in setOppTeamUserIds.
            List<Detail_Line__c> lstDetailLinesData = [Select Id,Owner__c,Opportunity__c from Detail_Line__c where Opportunity__c IN:mapOpptyTeamMembertobeDeleted.keySet() AND Owner__c IN:userIds];
            System.debug('+++ lstOppSplits--->'+ lstOppSplits);
            
            for(OpportunityTeamMember optm:lstOppTeamMemberData )
            {
                if(mapOpptyTeamMembertobeDeleted.get(optm.OpportunityId).contains(optm.UserId))
                {
                    lstOppTeamMember.add(optm);
                }
            }
            for(OpportunitySplit opSplits:lstOppSplitsData )
            {
                if(mapOpptyTeamMembertobeDeleted.get(opSplits.OpportunityId).contains(opSplits.SplitOwnerId))
                {
                    lstOppSplits.add(opSplits);
                }
            }
            for(Detail_Line__c opDetailLine:lstDetailLinesData )
            {
                if(mapOpptyTeamMembertobeDeleted.get(opDetailLine.Opportunity__c).contains(opDetailLine.Owner__c))
                {
                    lstDetailLines.add(opDetailLine);
                }
            }
            // delete all the fetched opportunity split records..
            List<Database.DeleteResult> lstDeletedOppSplitResult = Database.delete(lstOppSplits,false);
            // delete all the fetched opportunity team member records..
            List<Database.DeleteResult> lstDeletedOTMResult = Database.delete(lstOppTeamMember,false);
            System.debug('+++ after sr--->'+ lstDeletedOTMResult);
            // delete all the fetched detail line records..
            List<Database.DeleteResult> lstDeletedDetailLineResult = Database.delete(lstDetailLines,false);            
            // look for any errors
            //So we have to use an index to iterate through the results in order to get the ID from the
            //deleteInstances list
            List<EMCException> errors = new List <EMCException>();
            for (integer i = 0; i < lstDeletedOTMResult.size(); i++) {
                Database.DeleteResult objDeleteResult = lstDeletedOTMResult[i];
                if (!objDeleteResult.isSuccess()) {
                    // if the particular record did not get deleted, we log the data error 
                    String dataErrs = '';
                    for (Database.Error err : objDeleteResult.getErrors()) {
                        dataErrs += err.getMessage();
                    }
                    errors.add(new EMCException(dataErrs, 'ChannelVisibility: Delete OpportunityTeamMember ', new String [] {lstOppTeamMember[i].Id}));
                }
            }               
            // log any errors that occurred
            if (errors.size() > 0) { 
                EMC_UTILITY.logErrors(errors);  
            }                   
        }
    }
    
    //used to fetch forecast group for opportunity
    public static Map<Id,Map<String,String>> getOpportunityForecastGroup (Map<Id,Opportunity> mapOpportunity){
        //OpportunityId, UserId, Forecastgroup
        Map<Id,Map<String,String>> mapOpportunityForecastGroup = new Map<Id,Map<String,String>>();
        Set<Id> setUserIds = new Set<Id>();
        
        for(Opportunity objOpp : mapOpportunity.values()){
            Map<Id, OpportunityTeamMember> mapExistingOppTeamMembers = new Map<Id, OpportunityTeamMember>(objOpp.OpportunityTeamMembers);
            //check for existing opportunity team members
            if(mapExistingOppTeamMembers.size()>0){
                for(OpportunityTeamMember objOppTeamMember : mapExistingOppTeamMembers.values()){
                    if(!setUserIds.contains(objOppTeamMember.UserId)){
                        setUserIds.add(objOppTeamMember.UserId);
                    }                   
                }
            }   
        }
        
        Map<Id, User> mapUsers = new Map<Id,User>([Select Id, Forecast_Group__c from User where Id in: setUserIds]);
        
        for(Opportunity objOpp : mapOpportunity.values()){
            Map<String, String> mapUseridForecastGroup = new Map<String, String>();
            Map<Id, OpportunityTeamMember> mapExistingOppTeamMembers = new Map<Id, OpportunityTeamMember>(objOpp.OpportunityTeamMembers);
            //check for existing opportunity team members
            if(mapExistingOppTeamMembers.size()>0){
                for(OpportunityTeamMember objOppTeamMember : mapExistingOppTeamMembers.values()){                   
                    if(!mapUseridForecastGroup.containsKey(mapUsers.get(objOppTeamMember.UserId).Forecast_Group__c)){
                        mapUseridForecastGroup.put( mapUsers.get(objOppTeamMember.UserId).Forecast_Group__c,objOppTeamMember.UserId);
                    }                               
                }
            }
            mapOpportunityForecastGroup.put(objOpp.Id,mapUseridForecastGroup);  
        }
        return mapOpportunityForecastGroup;
                
    }
    
    //used to create details line for opportunity
    public static void CreateDetailLineItemsRecords(Map<Id,Opportunity> mapOpportunity, Set<Id> setOpportunityIds, Set<Id> setUserIds){
            
        Set<Id> setProductId=new Set<Id>();
        Boolean blnCreatedetailline=false;
        List<Detail_Line__c> lstDetailLines = new List<Detail_Line__c>();
        List<OpportunitySplit> lstOpportunitySplits = new List<OpportunitySplit>();
        Map<Id, List<OpportunityTeamMember>> mapOppAndOpportunityTeamMember = new Map<Id, List<OpportunityTeamMember>>();
        Map<Id,List<String>> prodGrpMap = new Map<Id,List<String>>();
        Map<Id,Set<ID>> prdToLook = new Map<Id,Set<Id>>(); 
        List<String> forecastGroups;
        Map<Id, OpportunityTeamMember> mapCreatedOpportunityTeamMember = new Map<Id, OpportunityTeamMember>([Select Id, OpportunityAccessLevel, OpportunityId, TeamMemberRole, UserId, User.Forecast_group__c 
                                                                                                             From OpportunityTeamMember 
                                                                                                             where OpportunityId in:setOpportunityIds AND UserId in:setUserIds]);
        
        //Get the list of Product's on Oppty.
        Map<id,OpportunityLineItem> mapOpptyProducts = new Map<id,OpportunityLineItem>([ select Id,OpportunityId,PricebookEntry.Product2Id,UnitPrice,Opportunity.CurrencyIsoCode,Quote_Amount__c
                                                    from OpportunityLineItem where OpportunityId=:setOpportunityIds]);
        for(OpportunityLineItem item: mapOpptyProducts.values()){
            if(prdToLook.containsKey(item.OpportunityId  )){
                prdToLook.get(item.OpportunityId).add(item.PricebookEntry.Product2Id);
            }                       
            else{
                prdToLook.put(item.OpportunityId, new set<Id>());
                prdToLook.get(item.OpportunityId).add(item.PricebookEntry.Product2Id);
            }                        
        }
        for(Set<Id> setPrdtId:prdToLook.values())
        {
            setProductId.addall(setPrdtId);
        }
        
        for(Forecast_Group_Product__c grpProduct: [ Select  f.Product__c,f.Product__r.id,f.Forecast_Mapping__r.Default_Sales_Team_User__c, 
                                                            f.Forecast_Mapping__r.Forecast_Group__c, f.Forecast_Mapping__c 
                                                    From Forecast_Group_Product__c f
                                                    where Product__r.id in : setProductId])
        {
            if(prodGrpMap.containsKey(grpProduct.Product__c)){
                forecastGroups=prodGrpMap.get(grpProduct.Product__c); 
            }else{
                forecastGroups = new List<String>();
                prodGrpMap.put(grpProduct.Product__c,forecastGroups);
            }
            forecastGroups.add(grpProduct.Forecast_Mapping__r.Forecast_Group__c);
        }
        //create map for opportunity id as key and list of Opportunity Team Member as values
        for(OpportunityTeamMember objOppTeamMembr: mapCreatedOpportunityTeamMember.values()){
            //List<String> lstGrp=prdGroupMap.get(product.PricebookEntry.Product2Id);
            if(mapOppAndOpportunityTeamMember.containsKey(objOppTeamMembr.OpportunityId  )){
                mapOppAndOpportunityTeamMember.get(objOppTeamMembr.OpportunityId).add(objOppTeamMembr);
            }                       
            else{
                mapOppAndOpportunityTeamMember.put(objOppTeamMembr.OpportunityId, new List<OpportunityTeamMember>());
                mapOppAndOpportunityTeamMember.get(objOppTeamMembr.OpportunityId).add(objOppTeamMembr);
            } 
        }
        Map<Id, Map<String, String>> mapOppForecastGrp = Opp_ChannelVisibilityHelper.getOpportunityForecastGroup(mapOpportunity);
        //hold newly assigned rep on opportunity forcast group
        Map<Id,Set<String>> mapNewlyAssignedOppForecastgroup = new Map<Id,Set<String>>();
        ///////////////////////
        if(mapOppAndOpportunityTeamMember.size()>0){
            Detail_Line__c objDetailLine = new Detail_Line__c();
            for(Id opportunityId :mapOppAndOpportunityTeamMember.keyset()){
                for(OpportunityTeamMember objOTM : mapOppAndOpportunityTeamMember.get(opportunityId)){
                    //**Logic to find if product is present for the User wih same Forecast Group.**//
                    blnCreatedetailline=false;
                    if(prdToLook.containsKey(opportunityId))
                    {
                        Set<Id> product=prdToLook.get(opportunityId);
                        for(Id idPrd:product)
                        {
                            if(prodGrpMap.containsKey(idPrd))
                            {
                                List<String> lstFgofProduct=prodGrpMap.get(idPrd);
                                if(lstFgofProduct!=null)
                                {   
                                    for(integer i=0;i<lstFgofProduct.size();i++)
                                    {
                                        if(objOTM.User.Forecast_group__c==lstFgofProduct.get(i))
                                        {
                                            blnCreatedetailline=true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(!blnCreatedetailline)
                    continue;
                    //get forecast group for opportunity
                    Map<String, String> mapUserForecastGrp = mapOppForecastGrp.get(objOTM.OpportunityId);
                    //fetch opportunity id for team member
                    Opportunity opp = mapOpportunity.get(objOTM.OpportunityId);
                    //get product(opportunity line items) on opportunity
                    List<OpportunityLineItem> lstExistingOppLineItems = opp.OpportunityLineItems;
                    Set<String> setNewlyAssignedForecastGroup = mapNewlyAssignedOppForecastgroup.get(opp.Id);
                    //Set<ID> setNewlyAssignedProduct = prdToLook.get(opp.id);
                    Boolean checkForecastFlag = false;
                    Decimal decSplitValue = 0.00;
                    if(setNewlyAssignedForecastGroup !=null){
                        if(setNewlyAssignedForecastGroup.contains(objOTM.User.Forecast_group__c)){
                            checkForecastFlag = true;
                        }
                    }
                    if(mapUserForecastGrp.containsKey(objOTM.User.Forecast_group__c) ||checkForecastFlag ){
                        decSplitValue =0.0;    
                    }else{
                        decSplitValue =100.0;
                        if(mapNewlyAssignedOppForecastgroup.containsKey(opp.Id)){
                            mapNewlyAssignedOppForecastgroup.get(opp.Id).add(objOTM.User.Forecast_group__c);
                        }                       
                        else{
                            mapNewlyAssignedOppForecastgroup.put(opp.Id, new Set<String>());
                            mapNewlyAssignedOppForecastgroup.get(opp.Id).add(objOTM.User.Forecast_group__c);
                        }   
                    }
                    
                    if(lstExistingOppLineItems.size()>0){                       
                        for(OpportunityLineItem objOppLineItem :lstExistingOppLineItems){
                            objDetailLine = new Detail_Line__c();                        
                            if(opp.Opportunity_Owner__c==objOTM.User.id && opp.id==opportunityId)
                            continue;
                            System.debug('opp.Opportunity_Owner__c==objOTM.User.id && opp.id==opportunityId'+opp.Opportunity_Owner__c+'***'+objOTM.User.id+'**'+opp.id+'*'+opportunityId);
                            objDetailLine.Opportunity__c = opp.Id;
                            objDetailLine.CurrencyIsoCode = opp.CurrencyIsoCode;                        
                            objDetailLine.Forecast_Group__c = objOTM.User.Forecast_group__c;
                            objDetailLine.OpportunityTeamMember__c = objOTM.Id;
                            objDetailLine.OwnerId = objOTM.UserId;
                            objDetailLine.Owner__c = objOTM.UserId; 
                            objDetailLine.Direct_Amount__c = objOppLineItem.UnitPrice;
                            objDetailLine.Opportunity_Product__c = objOppLineItem.Id;
                            objDetailLine.Product__c = objOppLineItem.PricebookEntry.Product2Id;
                            objDetailLine.Quote_Amount__c = objOppLineItem.Quote_Amount__c;
                            objDetailLine.Split__c = decSplitValue;        
                            lstDetailLines.add(objDetailLine);                          
                            OpportunitySplit objOpportuitySplit = new OpportunitySplit(  OpportunityId=opp.Id,
                                                            SplitPercentage=objDetailLine.Split__c,
                                                            SplitOwnerId=objOTM.UserId,
                                                            SplitNote=objDetailLine.Split__c +' %');
                            lstOpportunitySplits.add(objOpportuitySplit);
                        }                        
                    }                   
                }
            }
        }
        System.debug('lstDetailLines--->'+lstDetailLines);
        System.debug('lstOpportunitySplits--->'+lstOpportunitySplits);
        //Add detail lines
        if(lstDetailLines.size() >0){
            Database.Saveresult[] saveDetailLineResults = Database.insert(lstDetailLines, false);
        }
        //add opportunity split
        if(lstOpportunitySplits.size()>0){
            Database.Saveresult[] saveOppSplitResults = Database.insert(lstOpportunitySplits, false);
        }
    }
    /**
    Get the list of Products grouped by Forecast Group for products passed in the input from the 
    Forecast_Mapping and Forecast_Group_Product objects     
    */
    public Map<Id,List<String>> getProductGroupMapping(List<OpportunityLineItem> products){
        //log('getProductGroupMapping:products='+products);
        List<String> forecastGroups;
        Map<Id,Id> prdToLook = new Map<Id,Id>(); 
        for(OpportunityLineItem item: products){
            if(!prdToLook.containsKey(item.PricebookEntry.Product2Id)){
                prdToLook.put(item.PricebookEntry.Product2Id,item.PricebookEntry.Product2Id);
            }
        }
        Map<Id,List<String>> prodGrpMap = new Map<Id,List<String>>();
        for(Forecast_Group_Product__c grpProduct: [ Select  f.Product__c,f.Forecast_Mapping__r.Default_Sales_Team_User__c, 
                                                            f.Forecast_Mapping__r.Forecast_Group__c, f.Forecast_Mapping__c 
                                                    From Forecast_Group_Product__c f
                                                    where Product__c in :prdToLook.values()])
        {
            if(prodGrpMap.containsKey(grpProduct.Product__c)){
                forecastGroups=prodGrpMap.get(grpProduct.Product__c); 
            }else{
                forecastGroups = new List<String>();
                prodGrpMap.put(grpProduct.Product__c,forecastGroups);
            }
            forecastGroups.add(grpProduct.Forecast_Mapping__r.Forecast_Group__c);
        }
        //log('getProductGroupMapping:prodGrpMap='+prodGrpMap);
        return prodGrpMap;      
    }
    //used to create Team member, shared record and splits for opportunity.
    public static void CreateTeamMemberAndShareRecord(List<OpportunityShare> lstOppShare, Map<String, OpportunityTeamMember> mapOppTeamMember,List<Opportunity_Assignment_Log__c> lstOppAssignLog,Map<id,List<Opportunity_Assignment_Rule__c>> mapOppAssignRule, boolean checkRecordFound ,Map<id,Opportunity> mapOpportunity){
                    
        if(mapOppTeamMember.size() >0){
            
            Set <id> setOpptyId = new set<id>();
            Set<Id> setOppDeleteIds= new set<id>();
            Set<Id> setOppTeamUserIds= new set<id>();
            List<Opportunity_Assignment_Rule__c> lstOARValid = new List<Opportunity_Assignment_Rule__c>();
            Map<id,Opportunity_Assignment_Rule__c> mapTeamOar=new Map<Id,Opportunity_Assignment_Rule__c>();
            System.debug('mapOppAssignRule--->'+mapOppAssignRule);
            List<OAR_Member_Added__c> lstOarMemAdded= new List<OAR_Member_Added__c>();
            
            for(OpportunityTeamMember OpptyMemAdded:mapOppTeamMember.values())
            {
                System.debug('For loop entered');
                lstOARValid=mapOppAssignRule.get(OpptyMemAdded.OpportunityId);
                Set<String> setCheckOARDuplicate= new Set<String>();
                for(Integer i=0;i<lstOARValid.size();i++)
                {
                    System.debug('THE VALUE OF OAR IS===:::'+lstOARValid[i].Resource_Name__c);
                    if(OpptyMemAdded.UserId==lstOARValid[i].Resource_Name__c)
                    {
                        OAR_Member_Added__c OarMemAdded = new OAR_Member_Added__c();
                        String strUserAndOpptyId='';
                        strUserAndOpptyId=lstOARValid[i].id+'|'+OpptyMemAdded.OpportunityId;
                        if(setCheckOARDuplicate.contains(strUserAndOpptyId))continue;
                        setCheckOARDuplicate.add(strUserAndOpptyId);
                        System.debug('THE VALUE OF SET FOR OAR ON OPPORTUNITY IS :::'+setCheckOARDuplicate);
                        OarMemAdded.Team_Member_Added__c =OpptyMemAdded.UserId;
                        OarMemAdded.Condition__c='Channel Visibility';
                        //OarMemAdded.Name=OarMemAdded.Team_Member_Added__r.Name;
                        OarMemAdded.Text_1__c =OpptyMemAdded.OpportunityId;
                        OarMemAdded.Text_2__c =mapOpportunity.get(OpptyMemAdded.OpportunityId).Name;
                        OarMemAdded.Text_3__c=mapOpportunity.get(OpptyMemAdded.OpportunityId).Opportunity_Number__c;
                        OarMemAdded.Text_4__c=mapOpportunity.get(OpptyMemAdded.OpportunityId).Account_Name1__c;
                        //Updated this piece of code for OAR added on Opportunity Assignment Log.
                        OarMemAdded.Assignment_Rule__c=lstOARValid[i].id;
                        //Opportunity_Assignment_Rule__c objOAR = mapOppAssignRule.get(OpptyMemAdded.OpportunityId);
                        System.debug('OarMemAdded--->'+OarMemAdded);
                        lstOarMemAdded.add(OarMemAdded);
                        setOpptyId.add(OpptyMemAdded.OpportunityId);
                    }
                }
            }
            
            Database.SaveResult[] arrOpptyTeamMemberSave = Database.insert(mapOppTeamMember.values(),false);
            Database.Saveresult[] arrMemberSendMail=Database.insert(lstOarMemAdded,false);
            System.debug('+++After Team member details have been added to OAR Member Added object'+lstOarMemAdded);             
            System.debug('+++after mapOppTeamMember.values()--->'+ mapOppTeamMember.values());
            //System.debug('arrOpptyAccountOwnerChange--->'+arrOpptyAccountOwnerChange);
            Opp_ChannelVisibilityHelper.CreateLog(arrOpptyTeamMemberSave, 'ChannelVisibility:Team Member Creation Error: ', mapOppTeamMember);
            
            System.debug('+++ mapOppTeamMember--->'+ mapOppTeamMember);
            System.debug('+++ OpptyShareSave--->'+ lstOppShare);
            if(lstOppShare.size() >0){
                System.debug('+++ OpptyShareSave--->'+ lstOppShare);
                Database.SaveResult[] arrOpptyShareSave = Database.insert(lstOppShare,false);
                System.debug('+++ arrOpptyShareSave--->'+ arrOpptyShareSave);
                Opp_ChannelVisibilityHelper.CreateLog(arrOpptyShareSave, 'ChannelVisibility:Share Record Creation Error : ', mapOppTeamMember);                
            }            
            
        }else{
            if(checkRecordFound || mapOppTeamMember.size()==0){
                System.debug('+++after lstOppAssignLog--->'+ lstOppAssignLog);
                Database.SaveResult[] arrOpptyAssignLogSave = Database.insert(lstOppAssignLog,false);                
                Opp_ChannelVisibilityHelper.CreateLog(arrOpptyAssignLogSave, 'ChannelVisibility:Assign Log Creation Error : ', mapOppTeamMember);                            
            }
        }
                                                   
    }
    //Create log if any error occur in dml operations
    public static void CreateLog(Database.SaveResult[] arrResult, String strMessage, Map<String, OpportunityTeamMember> mapOppTeamMember){
        List<EMCException> errors = new List <EMCException>();
        for (integer i = 0; i < arrResult.size(); i++) {
            Database.SaveResult objResult = arrResult[i];
            System.debug('+++ objResult--->'+ objResult);
            if (!objResult.isSuccess()) {
                // if the particular record did not get deleted, we log the data error 
                String dataErrs = '';
                for (Database.Error err : objResult.getErrors()) {
                    dataErrs += err.getMessage();
                }
                errors.add(new EMCException(dataErrs, strMessage, new String [] {mapOppTeamMember.values().get(i).OpportunityId}));
            }
        }
        // log any errors that occurred
        if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
        }
    }
    //create set of resource id 
    public static Set<Id> getResourceIds(List<Opportunity_Assignment_Rule__c> lstOppAssignmentRuleTemp, Set<Id> setOppTeamUserIds){
        if(lstOppAssignmentRuleTemp != null){
            for(Opportunity_Assignment_Rule__c objOppAssRule :lstOppAssignmentRuleTemp){                                    
                //Fetch channel reps from list
                if(objOppAssRule.Resource_Name__c != null){
                    if(!setOppTeamUserIds.contains(objOppAssRule.Resource_Name__c)){
                        setOppTeamUserIds.add(objOppAssRule.Resource_Name__c);
                    }
                }                                   
            }
        }
        return setOppTeamUserIds;
    }
}