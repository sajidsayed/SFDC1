/**
    * Class Name: OpptySalesTeamController
    * Author: Accenture
    * Date: 05-Jun-2008
    * Requirement/Project Name: <EMC_SFDC>
    * Requirement/Project Description: <Controller class for visual force page 'saleTeamInformation'>
    
    Update on: 12-Jan-2011
    Update By: Sunil Bansal
    Updated for: WR 156054 - Fix Labeling on Opportuntiy Sales Team Access so it is consistent
*/

/*
    *------Revision------
    *   Version 1.0: Pilot Release
    *   By: <Developer – Gajanand k chalkapure>
    *          Version 2.0: CR 1.0 - Not to delete the access 
    *   By: <Developer – Gajanand k chalkapure> 
    *           
*/


public class OpptySalesTeamController { 

    Public Integer Pageheight{get;set;} 
    
    Public String OpportunityId=ApexPages.currentPage().getParameters().get('Id');
            
    public List<OpportunitySalesTeam> OpportunitySalesTeam =new List<OpportunitySalesTeam>(); 
    
    public List<OpportunitySalesTeam> getOpportunitySalesTeam(){
    
        return this.OpportunitySalesTeam;
    }
    
    List <OpportunityTeamMember> salesTeamMember=null;
    
    Map<String,String> DetailLineMap=new Map<String,String>(); 
    
    Map<String,String> OppTeamMap=new Map<String,String>();
    
    public OpptySalesTeamController(ApexPages.StandardController Controller){     
        Pageheight=0;
        
        salesTeamMember = [  Select o.User.Name,o.UserId,o.TeamMemberRole, o.OpportunityAccessLevel,o.User.Forecast_Group__c  From OpportunityTeamMember o where o.OpportunityId=:OpportunityId order by o.User.Forecast_Group__c desc];
        
        for(Detail_Line__c dt:[Select d.Opportunity__c, d.OpportunityTeamMember__c, d.Split__c from Detail_Line__c d  where d.Opportunity__r.Id=:OpportunityId]){
        
             DetailLineMap.put(dt.OpportunityTeamMember__c,''+dt.Split__c);
        }
        
        String SplitPercentage='';

        for(OpportunityTeamMember teammem:salesTeamMember){
           if(DetailLineMap.size()>0)
              SplitPercentage=DetailLineMap.get(teammem.Id);
        OpportunitySalesTeam.add(new OpportunitySalesTeam(teammem,SplitPercentage,teammem.User.Forecast_Group__c));
           
        if(salesTeamMember.size()==1){
                Pageheight=Pageheight+30;
        }
            Pageheight=Pageheight+42;
        }
    }    
        
    public class OpportunitySalesTeam{
    
    public OpportunityTeamMember OppTeamMem{get;set;}
    
    public String split{get;set;} 
    
    public String accessLevel{get;set;} 
//public String forecastgroup{get;set;}   
       
    public OpportunitySalesTeam(OpportunityTeamMember member,String split,String forecastgroup){
            this.OppTeamMem=member;
            this.split= split;
        	if(member.OpportunityAccessLevel == 'Private' || member.OpportunityAccessLevel == 'None')
        		accessLevel = 'Full Access';
        	else
        		accessLevel = member.OpportunityAccessLevel;
//      this.forecastGroup=forecastgroup;
        }
       }
}