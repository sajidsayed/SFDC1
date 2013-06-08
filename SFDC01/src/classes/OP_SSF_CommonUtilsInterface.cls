/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  28-OCT-09  Anand N                Initial creation
 +===========================================================================*/
public interface OP_SSF_CommonUtilsInterface {
    /**
    Returns all Sales Team Member associated with the opportunity along with their
    split information that is stored in the Detail_Line__c
    
    @param Id opptyId - Salesforce Id of the Opportunity to return the sales team for  
    */
    List<SalesTeamMember> getSalesTeamMembers(Id opptyId);

    OP_SSF_SaveResult addSalesTeamMembers(List<SalesTeamMember> salesTeamMbrs);

    OP_SSF_SaveResult removeSalesTeamMembers(List<SalesTeamMember> salesTeamMbrs);

    OP_SSF_SaveResult addProducts(List<OpportunityLineItem> products,Boolean createLineItems);
    //OP_SSF_SaveResult updateProducts(Map<Id,OpportunityLineItem> productMap);

    OP_SSF_SaveResult removeProducts(List<OpportunityLineItem> products,boolean deleteProducts);
    
    OP_SSF_SaveResult updateSplits(List<SalesTeamMember> splits);

    void changeOwner(Map<Id,Id> ownerMap,Boolean updateOppty);

}