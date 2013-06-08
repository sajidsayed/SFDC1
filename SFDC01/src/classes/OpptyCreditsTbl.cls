global class OpptyCreditsTbl {
    webservice String SfdcUserId;//Split member
    webservice Double CreditPercent;
    
    global void setSfdcUserId(String creditspltmem){
    this.SfdcUserId=creditspltmem;
    }
    global void setCreditPercent(Double spltpercent){
    this.CreditPercent=spltpercent;
    }
    global String getSfdcUserId(){
    return this.SfdcUserId;
    }
    global Double getCreditPercent(){
    return this.CreditPercent;
    }

    public List<OpptyCreditsTbl> getCreditSplit(String sfdcOppyId){
         List <OpptyCreditsTbl> CreditList = new  List <OpptyCreditsTbl>();
        for ( OpportunitySplit  os : [Select SplitOwnerId, SplitPercentage FROM OpportunitySplit  WHERE splittype.developername = 'Overlay' AND OpportunityId =: sfdcOppyId AND IsDeleted=false]){
           
                OpptyCreditsTbl Credit = new OpptyCreditsTbl();
                Credit.SfdcUserId = os.SplitOwnerId;
                Credit.CreditPercent = os.SplitPercentage ;
             
                CreditList.add(Credit);
           }
          return CreditList;
    }
}