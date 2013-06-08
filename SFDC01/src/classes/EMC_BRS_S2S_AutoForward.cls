public class EMC_BRS_S2S_AutoForward {
  /*
  Flag added Pratibh, 16-Sep-2010: Flag to prevent chained execution of trigger Opportunity_UpdateLog.
  */
  public static Boolean Opportunity_UpdateLogFlag=false;
  public void autoForwardToEMCBRS(List<EMC_BRS_Opportunity__c> recsToUpdt){
    Map<Id,EMC_BRS_Opportunity__c> brsOpptyMap = new Map<Id,EMC_BRS_Opportunity__c>(recsToUpdt);
    
      List<PartnerNetworkConnection> connMap = new List<PartnerNetworkConnection>(
         [select Id, ConnectionStatus, ConnectionName 
           from PartnerNetworkConnection 
           where ConnectionStatus = 'Accepted' and ConnectionName='EMC BRS']);
    Set<Id> existingConnList = new Set<Id>();
    System.debug('connMap*****'+connMap);
    for(PartnerNetworkRecordConnection recConn:[select LocalRecordId 
                          from PartnerNetworkRecordConnection
                          where LocalRecordId in :brsOpptyMap.keySet()
                          and Status='Connected'])
    {
      existingConnList.add(recConn.LocalRecordId);                        
    }
    System.debug('existingConnList*****'+existingConnList);       
    List<PartnerNetworkRecordConnection> prncList = new List<PartnerNetworkRecordConnection>(); 
    for(EMC_BRS_Opportunity__c emcBrsOppty : recsToUpdt){
      if(!existingConnList.contains(emcBrsOppty.Id)){
            for(PartnerNetworkConnection network : connMap) {
                String cid = network.Id;
                String status = network.ConnectionStatus;
                String connName = network.ConnectionName;
                
                PartnerNetworkRecordConnection prnc = new PartnerNetworkRecordConnection();
                
                prnc.ConnectionId = cid;
                prnc.localRecordId = emcBrsOppty.Id;
                prnc.SendClosedTasks = false;
                prnc.SendOpenTasks = false;
                prnc.SendEmails = false;
                prncList.add(prnc);
                //System.debug('prnc*****b4'+prnc);
                //insert prnc;
                //System.debug('prnc*****after'+prnc);

            }
      }
      
    }
    System.debug('prncList*****'+prncList);
    System.debug('prncList*****'+prncList.size());
    if(prncList.size()>0){
      insert prncList;
    }    
  }
}