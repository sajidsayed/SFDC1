Public class OpportunityVisibility{
    Map<String, Opportunity> OpenOpportunityMap = new Map<String, Opportunity>();
    Map<String,Set<String>> AccountTeamMemberJudgementGroup = new Map<String,Set<String>>();
    Map<String,Set<String>> OpportunityTeamMemberJudgementGroup = new Map<String,Set<String>>();   
    Map<String,Set<String>> OpportunityProductForecastGroup = new Map<String,Set<String>>();
           
    public OpportunityVisibility(List<Opportunity> Opportunities){
    for(Opportunity OpenOpportunity:Opportunities){
       OpenOpportunityMap.put(OpenOpportunity.Id,OpenOpportunity);
       }
       this.AccountTeamMemberJudgementGroup = getAccountTeamMemberJudgementGroup();
       this.OpportunityTeamMemberJudgementGroup = getOpportunityTeamMemberJudgementGroup();
       this.OpportunityProductForecastGroup = getOpportunityProductJudgementGroup();
    }
             
    public Map<String, Set<String>> getOpportunityTeamMemberJudgementGroup(){        
        Set<String> OpptyForecastGroups;
        Map<String,Set<String>> OpportunityTeamMemberJudgementGroup = new Map<String,Set<String>>();
        try{
            for(OpportunityTeamMember member : [Select o.Id, o.OpportunityId, o.Opportunity.AccountId, o.UserId, o.User.Forecast_Group__c from OpportunityTeamMember o where o.OpportunityId in :OpenOpportunityMap.keyset()] ){
                if(OpportunityTeamMemberJudgementGroup.get(member.OpportunityId)==null){
                    OpptyForecastGroups = new Set<String>();                                  
                 }      
                else{
                        OpptyForecastGroups = OpportunityTeamMemberJudgementGroup.get(member.OpportunityId);        
                    }
                    OpptyForecastGroups.add(member.User.Forecast_Group__c);
                    OpportunityTeamMemberJudgementGroup.put(member.OpportunityId,OpptyForecastGroups);
                }
               
            }
        catch(QueryException e){
            System.debug('Exception is'+e);
        }
        
        return OpportunityTeamMemberJudgementGroup;
    }
       
    public Map<String, Set<String>> getAccountTeamMemberJudgementGroup(){
        Map<String,Set<String>> AccountTeamMemberJudgementGroup = new Map<String,Set<String>>();
        Set<String> AcctForecastGroups;
        Set<String> AccountIds = new Set<String>();
       
        for(Opportunity Oppty:OpenOpportunityMap.values()){            
            AccountIds.add(Oppty.AccountId);    
            }
        try{
            for(AccountTeamMember member : [Select a.AccountId, a.Id, a.UserId, a.User.Forecast_Group__c from AccountTeamMember a where a.IsDeleted=false and a.AccountId in :AccountIds] ){
                if(AccountTeamMemberJudgementGroup.get(member.AccountId)==null){
                    AcctForecastGroups = new Set<String>();  
                }     
                else{
                        AcctForecastGroups = AccountTeamMemberJudgementGroup.get(member.AccountId);        
                    }
                AcctForecastGroups.add(member.User.Forecast_Group__c);
                AccountTeamMemberJudgementGroup.put(member.AccountId,AcctForecastGroups);
            }
        }
            
        catch(QueryException e){
            System.debug('Exception is' +e);
        } 
        
        return AccountTeamMemberJudgementGroup;
    }
      
    public Map<String, Set<String>> getOpportunityProductJudgementGroup(){    
        
        Map<String,List<Id>> OpportunityProductJudgementGroup = new Map<String,List<Id>>();
        Map<String,Set<String>> OpportunityProductForecastGroup = new Map<String,Set<String>>();      
        try{
                for(OpportunityLineItem opptyItem: [Select o.OpportunityId, o.PricebookEntryId, o.PricebookEntry.Product2Id from OpportunityLineItem o  where o.OpportunityId in :OpenOpportunityMap.keyset()]){
                    if(OpportunityProductJudgementGroup.containsKey(opptyItem.PricebookEntry.Product2Id)){
                    	List <id> temp = OpportunityProductJudgementGroup.get(opptyItem.PricebookEntry.Product2Id);
                    	temp.add(opptyItem.OpportunityId);
                    	OpportunityProductJudgementGroup.put(opptyItem.PricebookEntry.Product2Id,temp);
                    }
                    else
                    OpportunityProductJudgementGroup.put(opptyItem.PricebookEntry.Product2Id,new List<Id> {opptyItem.OpportunityId});
                }          
                
                for(Forecast_Group_Product__c product : [Select f.Forecast_Mapping__r.Forecast_Group__c,f.Product__c  from Forecast_Group_Product__c f where Product__c in : OpportunityProductJudgementGroup.keySet() and f.Forecast_Mapping__r.Create_User_Assignment__c=true]){ 
                  
                  List<Id> OpportunityIds=OpportunityProductJudgementGroup.get(product.Product__c); 
                  
                  system.debug('OpportunityId uday '+OpportunityIds);
                  for(Id OpportunityId : OpportunityIds){
                  Set<String> ProductForecastGroups =OpportunityProductForecastGroup.get(OpportunityId);
                   if(ProductForecastGroups==null){
                   	        system.debug('ProductForecastGroups if loop uday');
                            ProductForecastGroups = new set<String>();
                    }
                    ProductForecastGroups.add(product.Forecast_Mapping__r.Forecast_Group__c);
                    OpportunityProductForecastGroup.put(OpportunityId,ProductForecastGroups);
                    system.debug('OpportunityProductForecastGroup uday '+OpportunityProductForecastGroup);
                  }
                }
            
        }        
        catch(QueryException e){
            System.debug('Exception is' +e);
        }
        return OpportunityProductForecastGroup;
    }
         
    public Map<String,List<Opportunity>> getOpportunityWithNoForecastGroupMember(){
        Map<String,List<Opportunity>> OpportunityForecastGroup = new Map<String,List<Opportunity>>();
        Set<String> productForecastGroups;
        Set<String> salesTeamForecastGroups;
        system.debug('uday OpportunityProductForecastGroup '+OpportunityProductForecastGroup);
        if(OpportunityProductForecastGroup.size()==0){
            return OpportunityForecastGroup;
        }
        
        for(Opportunity opportunity : OpenOpportunityMap.values()){              
            productForecastGroups = OpportunityProductForecastGroup.get(Opportunity.id);
            if(productForecastGroups == null){
                productForecastGroups = new Set<String>();
            }
            System.debug('The size of Products ForecastGroups '+ productForecastGroups.size());
            salesTeamForecastGroups = OpportunityTeamMemberJudgementGroup.get(opportunity.id);
            if(salesTeamForecastGroups == null){
                salesTeamForecastGroups = new Set<String>();
            }
            System.debug('The size of SalesTeam ForecastGroups '+ salesTeamForecastGroups.size());
            List <Opportunity> Opportunitylist;
            system.debug('uday productForecastGroups '+productForecastGroups);
            system.debug('uday salesTeamForecastGroups '+salesTeamForecastGroups);
            for(String productsFG:productForecastGroups){
                if (!salesTeamForecastGroups.contains(productsFG)){
                	system.debug('first if '+productsFG);                
                    if ( OpportunityForecastGroup.get(productsFG)!= null ){                    
                        Opportunitylist= OpportunityForecastGroup.get(productsFG);   
                        system.debug('second if '+Opportunitylist);                                   
                    }
                    else{           
                    	Opportunitylist = new List<Opportunity>();
                        system.debug('else stmt '+Opportunitylist);    
                    }
                    Opportunitylist.add(opportunity);
                    OpportunityForecastGroup.put(productsFG,Opportunitylist);
                    }
                }                     
        }
        return OpportunityForecastGroup;
    }
    
    
    public List<Opportunity> getPartnerOpportunityWithNoChannelMember(){        
        List<Opportunity> OpportunityList = new List<Opportunity>();
        
        for(Opportunity opportunity:OpenOpportunityMap.values()){
            Set<String> salesTeamForecastGroups = OpportunityTeamMemberJudgementGroup.get(opportunity.id);
            if(salesTeamForecastGroups == null){
                salesTeamForecastGroups = new Set<String>();
            }
            if(opportunity.Partner__c!=null || opportunity.Tier_2_Partner__c!=null){
                if(!salesTeamForecastGroups.contains('Channel')){         
                     Opportunitylist.add(opportunity);
                 }
            }        
        }        
        return Opportunitylist;
    }
        
    public List<Opportunity> getHouseAccountOpportunity(){ 
        List<Opportunity> OpportunityList = new List<Opportunity>();
        List<OpportunityIntegration__c> houseAcct = OpportunityIntegration__c.getall().Values();
        //System.debug('House account is---->'+houseAcct[0].House_Account_User__c);
         
        for(Opportunity opportunity:OpenOpportunityMap.values()){
            if(opportunity.OwnerId == houseAcct[0].House_Account_User__c){            
                Opportunitylist.add(opportunity);
            }
        }
        return Opportunitylist;
    }
        
   public List<User_Assignment__c> createUserAssigments(String ForecastGroup,List<Opportunity> Opportunities){ 
        List<User_Assignment__c> UserAssignmentlist = new List<User_Assignment__c>();      
        
        for(Opportunity opportunity:Opportunities){
            User_Assignment__c  UserAssignment = new User_Assignment__c ();
            UserAssignment.Opportunity__c = opportunity.Id;
            UserAssignment.Account__c = opportunity.AccountId;
            UserAssignment.Assignment_Group__c = ForecastGroup;
            UserAssignment.Assignment_Status__c = 'Not Assigned';
            UserAssignment.Unique_Key__c = opportunity.id+ForecastGroup;                     
            UserAssignment.Account_Team_contains_Forecast_Group__c = AccountTeamContainsForecastGroupMember(ForecastGroup,opportunity.AccountId); 
            UserAssignmentlist.add(UserAssignment);
        }
        return UserAssignmentlist;  
    } 
    
    
    public Database.SaveResult[] insertUserAssigments(List<User_Assignment__c> UserAssignments){         
        Database.SaveResult[] lsr = Database.insert(UserAssignments,false);   
        for(Database.SaveResult sr : lsr){
            if(!sr.isSuccess()){
                Database.Error err = sr.getErrors()[0];
            }
        }  
        return lsr;
    }
    
    public boolean AccountTeamContainsForecastGroupMember(String ForecastGroup,String AccountId){
        Set<String> AcctTeamForecastGrpMember = AccountTeamMemberJudgementGroup.get(AccountId);
        
        if(AcctTeamForecastGrpMember!=null){
            return AcctTeamForecastGrpMember.contains(ForecastGroup);
        }
        else{
            return false;
        }
    }
    
    /*public void removeUserAssignment(String UserAssignmentId){
        User_Assignment__c  UserAssignment = [Select u.Id from User_Assignment__c u where Id=:UserAssignmentId];
        try{
            Database.delete(UserAssignment);
        }
        Catch(DmlException e){
        }        
    } */ 
        
    /*public void assignOpportuintySalesTeamMember(List<SalesTeamWrapper> SalesTeamWrapper){
        
    }  */
             
}