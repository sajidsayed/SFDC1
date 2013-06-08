/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE           DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====           =========       ======     =========== 
 |  11.10.2010     Ashwini Gowda   #1143      Blank out the EMC Lead Rejected checkbox 
                                              after a lead has been accepted by a different user.
 |  04-05-2011     Prasad                     By pass for deal reg
    
 |  1 Aug 2012     Kaustav         WR 198481  Added code to update rejection date  
 +=========================================================================================================================*/

public class MAP_LeadAccept {

    public static void UpdateAcceptFlag(List<Lead> oldrecs, List<Lead> newrecs) {
    for(integer i=0; i<newrecs.Size();i++){
            if (   !newrecs[i].DealReg_Deal_Registration__c    //bypass for deal reg
                   && newrecs[i].OwnerId != oldrecs[i].OwnerId
                   && newrecs[i].OwnerId == UserInfo.getUserId() ) {
                newrecs[i].Accept_Lead__c = true;
                //Added as per Req# 1143
                newrecs[i].EMC_Lead_Rejected__c=false;
                newrecs[i].eBus_Lead_Status__c='Accepted';
                newrecs[i].Date_Accepted__c = System.Now();
            }
            /*Code added for WR 198481*/
            if (   !newrecs[i].DealReg_Deal_Registration__c    //bypass for deal reg
                   && newrecs[i].EMC_Lead_Rejected__c==true
                   
                ) {
                //newrecs[i].Accept_Lead__c = true;
                //Added as per Req# 1143
                //newrecs[i].EMC_Lead_Rejected__c=false;
                newrecs[i].Date_Rejected__c = System.Now();
                newrecs[i].eBus_Lead_Status__c='Rejected';
            }   
            /*End of Code added for WR 198481*/
            
        }
    }
    /**
        * Method <setAcceptFlag(List<Lead> newrecs)is to set the Accept Lead Flag if the>
        *   @param <This method is taking List<Lead> as argument.> 
        *   @return <void> - <Not Returning anything>
        *   @throws exception-<No exception >
     */
    public static void setAcceptFlag(List<Lead> newrecs){
        List<String> LeadOwners = new List<String>();
        Set<String> PartnerUsers = new Set<String>();
        PRM_CommonUtils prmUtil = new PRM_CommonUtils();
        
        //Add all the Owners to a list
        for(integer i=0; i<newrecs.Size();i++){
            LeadOwners.add(newrecs[i].OwnerId);
        }
        System.debug('LeadOwners size--->'+LeadOwners.size());
        
        if(newrecs.Size()>0){
            PartnerUsers = prmUtil.userType(LeadOwners);
        }
        System.debug('PartnerUsers size--->'+PartnerUsers.size());
        
        for(integer i=0; i<newrecs.Size();i++){
        for(integer j=0; j<PartnerUsers.Size();j++){           
            //If Originator is Partner, owner is partner user and same as current logged in user.Set the Accept field to true
                if (    !newrecs[i].DealReg_Deal_Registration__c    //bypass for deal reg
                        && newrecs[i].Lead_Originator__c=='Partner' 
                        && newrecs[i].OwnerId == UserInfo.getUserId() 
                        && PartnerUsers.contains(newrecs[i].OwnerId) ) {
                        newrecs[i].Accept_Lead__c = true;
                        newrecs[i].eBus_Lead_Status__c='Accepted';
                    System.debug('newrecs[i].Accept_Lead__c--->'+newrecs[i].Accept_Lead__c);
                }
            }
        }
    }
}