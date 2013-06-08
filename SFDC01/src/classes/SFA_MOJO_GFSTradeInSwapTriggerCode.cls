/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  10 Oct 2012     Avinash K       MOJO        Initial Creation.Creating this Class to post a chatter feed on Opportunity
                                                when the Regsitration Id field is updated.
+========================================================================================================================*/


public class SFA_MOJO_GFSTradeInSwapTriggerCode 
{
    public static Boolean blnTriggerExecuted = false;
    
    public static void postToChatter(Map<Id, Trade_Ins_Competitive_Swap__c> mapNewTradeIns, Map<Id, Trade_Ins_Competitive_Swap__c> mapOldTradeIns)
    {
        if(blnTriggerExecuted == false)
        {
            blnTriggerExecuted = true;

            String baseURL = URL.getSalesforceBaseUrl().getHost();

            List<FeedItem> lstFeedItem = new List<FeedItem>();

            Set<Id> setOppIds = new Set<Id>();

            Set<Trade_Ins_Competitive_Swap__c> setTradeIns = new Set<Trade_Ins_Competitive_Swap__c>();

            for (Trade_Ins_Competitive_Swap__c tradein : mapNewTradeIns.values()) 
            {
                if (tradein.Registration_ID__c != mapOldTradeIns.get(tradein.id).Registration_ID__c) 
                {
                    setTradeIns.add(tradein);
                    setOppIds.add(tradein.Related_Opportunity__c);
                }
                
            }

            Map<Id, Opportunity> mapIDOpportunity = new Map<Id, Opportunity>([Select id,Name, Account.Name,Opportunity_Number__c 
                From Opportunity
                Where id in :setOppIds
                Limit 50000]);

            for (Trade_Ins_Competitive_Swap__c tradein : setTradeIns) 
            {
            System.debug('tradein.Registration_ID__c-->'+tradein.Related_Opportunity__r.Opportunity_Number__c); 
                if(tradein.Registration_ID__c != null  ){
                FeedItem fi = new FeedItem(
                    //Title = 'Registration Approval: '+ System.Userinfo.getFirstName() + ' ' + System.Userinfo.getLastName() + ' for '+ mapIDOpportunity.get(tradein.Related_Opportunity__c).Account.Name +' account', 
                    Body = 'Registration Approval: '+ System.Userinfo.getFirstName() + ' ' + System.Userinfo.getLastName() + ' for '+ mapIDOpportunity.get(tradein.Related_Opportunity__c).Account.Name +' account \n \n The following opportunity has been registered with GFS. \n To see the Opportunity detail, the assets related and the GFS registration information, please use this link.',// + 'https://' + baseURL + '/' + tradein.Related_Opportunity__c, 
                    LinkUrl = 'https://' + baseURL + '/' + tradein.Related_Opportunity__c,
                    ParentId = tradein.Related_Opportunity__c);
                    lstFeedItem.add(fi);
                }
                else{
                    string num;
                    if(mapIDOpportunity.get(tradein.Related_Opportunity__c).Opportunity_Number__c != null)
                    {num=mapIDOpportunity.get(tradein.Related_Opportunity__c).Opportunity_Number__c;}
                    else{
                        num='';
                    }
                    FeedItem f1 = new FeedItem(
                    Title = 'Reregistration required for Opportunity  '+ num, 
                    Body = 'Reregistration required for Opportunity  '+ num +'\n \n For Opportunity number '+ num +', the Assets have been changed, so the Registration ID and the Swap Value have been removed. This Opportunity will need to be reregistered with GFS.', 
                    LinkUrl = 'https://' + baseURL + '/' + tradein.Related_Opportunity__c,
                    ParentId = tradein.Related_Opportunity__c);
                    lstFeedItem.add(f1);
                    System.debug('fi-->'+f1);
                }
            }

            if (lstFeedItem != null && lstFeedItem.size() > 0) 
            {
                try
                {
                    insert lstFeedItem;
                }
                catch(Exception e)
                {
                    system.debug('#### Exception Occurred while inserting Chatter posts');
                }
            }
        }
    }
}