//   Date              Initial Creation              Updated By        Req no           Reason
//   3 March 2010      Prasad Kothawade             Prasad Kothawade   125264      Updated test method to change synergy lead id.  

global class CreateAccountTeam
{

    List <Lead> Leads= new List<Lead>();    
    Set<String> related_accounts= new Set<String>();    
    Set<String> lead_owners= new Set<String>();     


    public void createAccountTeam(Lead[] objLeads){

    for(integer i=0;i<objLeads.size();i++){
    System.debug('objLeads[i].Related_Account__c'+objLeads[i].Related_Account__c);
    System.debug('objLeads[i].Synergy_Lead_ID__c'+objLeads[i].Synergy_Lead_ID__c);
    System.debug('objLeads[i].Integration_Error_Message__c'+objLeads[i].Integration_Error_Message__c);
    System.debug('objLeads[i].Status'+objLeads[i].Status);

           if(objLeads[i].Related_Account__c != null
           && objLeads[i].Synergy_Lead_ID__c != null
           && objLeads[i].Integration_Error_Message__c == null
           && objLeads[i].Status == 'Qualified' 
           && ! objLeads[i].DealReg_Deal_Registration__c ) {

            Leads.add(objLeads[i]);
            related_accounts.add(objLeads[i].Related_Account__c);
            lead_owners.add(objLeads[i].ownerid);
        
        }  
    }
    System.debug('Leads'+Leads);
    
    // if no leads then return
        if(Leads.size()==0){
            return;
        }
    //if lead owner is already on account team member then return
        removeExistingAccountTeamMember();

         Savepoint sp=Database.setSavepoint();  
           
        try
        {
    System.debug('Leads.size() 0===> '+Leads.size());
        //create Account Team member
            createAccountTeamMember();
    
    System.debug('Leads.size() 1===> '+Leads.size());

        //create Account share
            createAccountSharing();
       System.debug('Leads.size() 2===> '+Leads.size());
        }
        catch(Exception e)
        {
        System.debug('Error '+e);   
            Database.rollback(sp);
        }
       
    }
    
   
    private void removeExistingAccountTeamMember() {
        AccountTeamMember[] objAccTeam = [Select Id,UserId,AccountId from AccountTeamMember where AccountId in: related_accounts and UserId in: lead_owners];
        for(integer accont_team_iterator=0; accont_team_iterator< objAccTeam.size();accont_team_iterator++ ){
        for(integer lead_iterator =0; lead_iterator< Leads.size(); lead_iterator ++ ){
            if(objAccTeam[accont_team_iterator].UserId==Leads[lead_iterator].ownerId && objAccTeam[accont_team_iterator].AccountId==Leads[lead_iterator].Related_Account__c )   
                Leads.remove(lead_iterator);
        }

    } 
    }

    private void createAccountTeamMember()
    {
        List <AccountTeamMember> objAccTeams = new List <AccountTeamMember>();
        for(integer lead_iterator =0; lead_iterator< Leads.size(); lead_iterator ++ ){
        
        AccountTeamMember objAccTeam = new AccountTeamMember();
           
        objAccTeam.AccountId = Leads[lead_iterator].Related_Account__c;
        objAccTeam.UserId = Leads[lead_iterator].OwnerId;
        objAccTeam.AccountAccessLevel ='Edit';
        objAccTeam.TeamMemberRole ='Lead Owner';

        objAccTeams.add(objAccTeam);
        
      }
       if(objAccTeams.size()>0){    
              insert objAccTeams;
        }
        }




    private void createAccountSharing( )
    {
     List <AccountShare> objAccShares = new List <AccountShare>();
     System.debug('Leads.size() ===> '+Leads.size());
     for(integer lead_iterator =0; lead_iterator< Leads.size(); lead_iterator ++ ){
                   
            AccountShare objAccShare = new AccountShare();
            objAccShare.AccountId = Leads[lead_iterator].Related_Account__c;
            objAccShare.UserOrGroupId = Leads[lead_iterator].OwnerId;
        objAccShare.AccountAccessLevel ='Edit';
        objAccShare.OpportunityAccessLevel ='None';
        //objAccShare.CaseAccessLevel ='None';
        objAccShares.add(objAccShare);
    }
    if(objAccShares.size()>0){      
            insert objAccShares;
    }
      }

}