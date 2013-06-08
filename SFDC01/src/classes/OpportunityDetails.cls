global class OpportunityDetails{
    
    webservice OpportunityHeader POpptyHeaderBo;
    webservice List<OpptyProductTbl>POpptyProductBoTblItem; 
    Webservice List<OpptyCreditsTbl>POpptyCreaditsBoTblItem;
    
    global OpportunityHeader getPOpptyHeaderBo(){
        return this.POpptyHeaderBo;
    }
    
    global List<OpptyProductTbl> getPOpptyProductBoTblItem(){
        return this.POpptyProductBoTblItem;
    }
    
    global List<OpptyCreditsTbl> getPOpptyCreaditsBoTblItem(){
        return this.POpptyCreaditsBoTblItem;
    }
    
    public OpportunityDetails(string sfdcOppyId){
        POpptyHeaderBo = new OpportunityHeader(sfdcOppyId);
        POpptyProductBoTblItem= new  OpptyProductTbl().getProductList(sfdcOppyId);
        POpptyCreaditsBoTblItem= new OpptyCreditsTbl().getCreditSplit(sfdcOppyId);
    }
    
}