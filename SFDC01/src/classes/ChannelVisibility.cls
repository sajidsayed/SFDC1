global class ChannelVisibility{
  public static Map<String,String> userTeamMemberRole=new Map<String,String>();
  public static Map<String,String> OppandUserMap=new Map<String,String>();
  //webservice Static 
 public void insertChannelUser(List<String> OppIds,List<String> ChannelUserIds,List<Integer> percentage, List<String> ForecastGroup){
    System.debug('Oppids'+OppIds);
    System.debug('ChannelUserIds'+ChannelUserIds);
    List<Opportunity> OppRecs=new List<Opportunity>();
    List<String> Accountids=new List<String>();
    List<SalesTeamMember> stmList=new List<SalesTeamMember>();
    OppRecs=[Select id,AccountId from Opportunity where id in:OppIds];
    for(Integer i=0;i<OppIds.size();i++){
        OppandUserMap.put(OppIds[i],ChannelUserIds[i]);
    }
    System.debug('OppandUserMap-->'+OppandUserMap);
    for(Opportunity op:OppRecs){
        Accountids.add(Op.AccountId);
    }
    for(AccountTeamMember[] accTeamMem:[Select a.AccountId, a.TeamMemberRole, a.UserId from AccountTeamMember a where AccountId in:Accountids and UserId in:ChannelUserIds]){
        for(AccountTeamMember teammem:accTeamMem){
            userTeamMemberRole.put((String)teammem.Userid,(String)teammem.TeamMemberRole);            
        }
    }
    integer i=0;
    for(String Opportunityid:OppIds){
    SalesTeamMember newSalesTeam=createSalesTeamMember(Opportunityid,ForecastGroup[i],percentage[i]); 
        System.debug('stmList--->'+stmList);
        stmList.add(newSalesTeam);
        i++;
    }
    System.debug('stmList--->'+stmList.size());      
    OP_SSF_CommonUtils CommonUtils=new OP_SSF_CommonUtils();
    CommonUtils.addSalesTeamMembers(stmList); 
    System.debug('Inserted Successfully');   
   }
  public static SalesTeamMember createSalesTeamMember(String OppId,String FG, integer Percentage){
      System.debug('In CreateSaleTeamMem'+OppId);
      SalesTeamMember stm;
      OpportunityTeamMember OpptyTeamMem = new OpportunityTeamMember();
      OpptyTeamMem.OpportunityId=OppId  ; 
      OpptyTeamMem.TeamMemberRole=userTeamMemberRole.get(OppandUserMap.get(OppId))!=null?userTeamMemberRole.get(OppandUserMap.get(OppId)):'Other';
      System.debug('OppandUserMap.get(OppId)'+OppandUserMap.get(OppId));
      System.debug('userTeamMemberRole.get(OppandUserMap.get(OppId))'+userTeamMemberRole.get(OppandUserMap.get(OppId)));
      OpptyTeamMem.UserId=OppandUserMap.get(OppId);
      Detail_Line__c detailln=new Detail_Line__c();
      detailln.Opportunity_Access_Level__c='Edit'; 
      detailln.Split__c=Percentage;
      detailln.OwnerId=OpptyTeamMem.UserId;
      detailln.Forecast_Group__c =FG;
      stm=new SalesTeamMember(false,OpptyTeamMem,detailln);
   return stm;
  }  
}