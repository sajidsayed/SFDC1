/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER       WR       DESCRIPTION                               
 |  ====       =========       ==       =========== 
 |  05/18/11   Michael Mutebi           Initial Creation.                             
 |  06/07/11   Nat P.                   Modifications.
 |  03/13/13   Prachi                   Modifications.
 +===========================================================================*/



global class MapHubInfoPopulation implements Database.Batchable <SObject> {

    //Define variables that are going to be used to match IDs and update attributes
    //Prachi:code starts
    public Boolean isTestRun=false;
    //Prachi:code ends
    public string batchName;
    public String query;
    public Map<string, string> hubGtmToSfdcGtmMap = new Map<string, string>();
    public Map<string, boolean> GtmNameToCovertFlagMap = new Map<string, boolean>();
    public String acctErrorMsg; 
    public double totalFailedAccounts {get; set;}
    
    
    //Query customer account attributes with respective IDs(GRID and Party ID) from Hub_OutBound_Staging__c
    
    public MapHubInfoPopulation()
    {
        batchName = 'Hub to SFDC Batch ' + Datetime.now();
        
        acctErrorMsg = 'accounts failed to get updated successfully';
        
        totalFailedAccounts = 0;
        
        List<GTMAttrHubToSfdcMapping__c> gtmMapRecs = [Select g.Name, 
                                                              g.HubInfoGTMAttrName__c,
                                                              g.Convert_Value__c 
                                                       From GTMAttrHubToSfdcMapping__c g];
        for(GTMAttrHubToSfdcMapping__c gtmMapRec : gtmMapRecs)
        {
            if(gtmMapRec.Name != null && gtmMapRec.HubInfoGTMAttrName__c != null)
            {
               hubGtmToSfdcGtmMap.put(gtmMapRec.Name, gtmMapRec.HubInfoGTMAttrName__c);
               GtmNameToCovertFlagMap.put(gtmMapRec.Name, gtmMapRec.Convert_Value__c);
            }
            else
            {
               System.debug('(MAP Error: Invalid values in GTMAttrHubToSfdcMapping custom setting)');
            }
        }              
        System.debug('(MAP debug)Post Column Population');
    }
    
    
    global Database.Querylocator start (Database.BatchableContext BC){
        
           if(!isTestRun){
        
         this.query = 'Select h.SIC_Code__c, h.SIC_Code_Description__c, h.Retry_Count__c, h.Party_ID__c, ';
                      query += 'h.Parent_ID__c, h.PRI__c, h.PRI_Range__c, h.PRI_Penetration__c,';
                      query += 'h.PRI_Headroom__c, h.PRI_Classification__c, h.Last_Update_Date__c, h.IDC_Major_Vertical__c,';
                      query += 'h.Golden_Site_Name__c, h.Golden_Site_Identifier__c, h.Global_Ultimate__c,';
                      query += 'h.Global_Ultimate_Golden_Site_ID__c, h.Global_Employee_Market_Segment__c,';
                      query += 'h.Error_Message__c, h.Error_Code__c,';
                      query += 'h.Employees_Total__c, h.Employees_Total_Range__c, h.EMC_Sub_Vertical__c, h.EMC_Major_Vertical__c,';
                      query += 'h.EMC_AMO__c, h.EMC_AMO_Range__c, h.Domestic_Ultimate__c, h.Domestic_Ultimate_Golden_Site_ID__c,';
                      query += 'h.Domestic_Employee_Market_Segment__c, h.DnB_AMO__c, h.DnB_AMO_Range__c,';
                      query += 'h.Country_Ultimate_Total_Employees_CUTE__c, h.CUTE_Range__c, h.Business_Unit_Ultimate__c, h.Business_Unit_Ultimate_Golden_Site_ID__c,';
                      query += 'h.Booking_Customer_Inception_Year_Qtr__c, h.Annual_Sales_Turnover__c, h.Annual_Sales_Turnover_Range__c,';
                      query += 'h.GTM_AMO__c, h.GTM_AMO_Range__c, h.GTM_AMO_Segment__c,h.EMC_AMO_Segment__c,h.DnB_AMO_Segment__c,h.EMC_SIC_Code__c,';
                      query += 'h.Account_Grouping__c, ';
                      //Prachi: Code Starts
                      query += 'h.ATP_Facilitated_Account__c ';
                      //Prachi: Code Ends
                      query += 'From Hub_Outbound_Staging__c h ';
                      query += 'WHERE h.Retry_Count__c <= 2 ';
                      query += 'AND h.Status__c != \'P\'';
                      System.debug('Not test method');

          }
          else{
          this.query = 'Select h.SIC_Code__c, h.SIC_Code_Description__c, h.Retry_Count__c, h.Party_ID__c, ';
                      query += 'h.Parent_ID__c, h.PRI__c, h.PRI_Range__c, h.PRI_Penetration__c,';
                      query += 'h.PRI_Headroom__c, h.PRI_Classification__c, h.Last_Update_Date__c, h.IDC_Major_Vertical__c,';
                      query += 'h.Golden_Site_Name__c, h.Golden_Site_Identifier__c, h.Global_Ultimate__c,';
                      query += 'h.Global_Ultimate_Golden_Site_ID__c, h.Global_Employee_Market_Segment__c,';
                      query += 'h.Error_Message__c, h.Error_Code__c,';
                      query += 'h.Employees_Total__c, h.Employees_Total_Range__c, h.EMC_Sub_Vertical__c, h.EMC_Major_Vertical__c,';
                      query += 'h.EMC_AMO__c, h.EMC_AMO_Range__c, h.Domestic_Ultimate__c, h.Domestic_Ultimate_Golden_Site_ID__c,';
                      query += 'h.Domestic_Employee_Market_Segment__c, h.DnB_AMO__c, h.DnB_AMO_Range__c,';
                      query += 'h.Country_Ultimate_Total_Employees_CUTE__c, h.CUTE_Range__c, h.Business_Unit_Ultimate__c, h.Business_Unit_Ultimate_Golden_Site_ID__c,';
                      query += 'h.Booking_Customer_Inception_Year_Qtr__c, h.Annual_Sales_Turnover__c, h.Annual_Sales_Turnover_Range__c,';
                      query += 'h.GTM_AMO__c, h.GTM_AMO_Range__c, h.GTM_AMO_Segment__c,h.EMC_AMO_Segment__c,h.DnB_AMO_Segment__c,h.EMC_SIC_Code__c,';
                      query += 'h.Account_Grouping__c, ';
                      //Prachi: Code Starts
                      query += 'h.ATP_Facilitated_Account__c ';
                      //Prachi: Code Ends
                      query += 'From Hub_Outbound_Staging__c h ';
                      query += 'WHERE h.Retry_Count__c <= 2 ';
                      query += 'AND h.Status__c != \'P\' limit 10';
                                            System.debug('----test method----');

          }          
        System.debug('(MAP debug)Query String: ' + query);
        
        system.debug(query);
        
                      
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, LIST<SObject> scope)
    {
            List<Hub_Outbound_Staging__c> stagingRecords = new List<Hub_Outbound_Staging__c>();
            Map<string, double> partyIdToGridMap = new Map<string, double>();
                            
            Set<double> gridSet = new Set<double>();
            Set<double> guGridSet = new Set<double>();
            Set<double> buGridSet = new Set<double>();
            Set<double> duGridSet = new Set<double>();
            //Prachi: Code Starts
            Set<boolean> atpGridSet = new Set<boolean>();
            //Prachi: Code Ends
            
            Set<string> scopeOutBoundPartyIdSet = new Set<string>();
            
            List<string> splitPartyIdList = new List<string>();
            List <string> partyIds;
                
 
            for (SObject h: scope)
            {
                Hub_Outbound_Staging__c scopeRecord = (Hub_Outbound_Staging__c) h;
                stagingRecords.add(scopeRecord);
                gridSet.add(scopeRecord.Golden_Site_Identifier__c);
                        
                guGridSet.add(scopeRecord.Global_Ultimate_Golden_Site_ID__c);
                buGridSet.add(scopeRecord.Business_Unit_Ultimate_Golden_Site_ID__c);
                duGridSet.add(scopeRecord.Domestic_Ultimate_Golden_Site_ID__c);
                //Prachi: Code Starts
                atpGridSet.add(scopeRecord.ATP_Facilitated_Account__c);
                //Prachi: Code Ends
                
                System.debug('(MAP debug)Golden_Site_Identifier__c: ' + scopeRecord.Golden_Site_Identifier__c);
                System.debug('(MAP debug)Business_Unit_Ultimate_Golden_Site_ID__c: ' + scopeRecord.Business_Unit_Ultimate_Golden_Site_ID__c);
                System.debug('(MAP debug)Global_Ultimate_Golden_Site_ID__c: ' + scopeRecord.Global_Ultimate_Golden_Site_ID__c);
                System.debug('(MAP debug)Domestic_Ultimate_Golden_Site_ID__c: ' + scopeRecord.Domestic_Ultimate_Golden_Site_ID__c);
                System.debug('(MAP debug)Domestic_Ultimate_Golden_Site_ID__c: ' + scopeRecord.Party_Id__c);
                //Prachi: Code Starts
                System.debug('(MAP debug)ATP_Facilitated_Account__c: ' + scopeRecord.ATP_Facilitated_Account__c);
                //Prachi: Code Ends
                        
                if(scopeRecord.Party_Id__c != null)
                {
                  partyIds = scopeRecord.Party_Id__c.split(',');
                  for(string partyId:partyIds)
                  {
                      scopeOutBoundPartyIdSet.add(partyId);
                      partyIdToGridMap.put(partyId, scopeRecord.Golden_Site_Identifier__c);
                  }
                }       
           }
                
           List <Hub_Info__c> hubInfoGridList = [Select Id, 
                                                        h.Golden_Site_Identifier__c 
                                                 From   Hub_Info__c h 
                                                 Where  h.Golden_Site_Identifier__c  in :guGridSet
                                                 Or     h.Golden_Site_Identifier__c  in :duGridSet
                                                 Or     h.Golden_Site_Identifier__c  in :buGridSet];
                
           Map<double, Id> gridToIdMap = new Map<double, Id>();
           for(Hub_Info__c rec: hubInfoGridList)
           {
                gridToIdMap.put(rec.Golden_Site_Identifier__c, rec.Id);
           }
               
           List<Hub_Info__c> hubRecords = new List<Hub_Info__c>();
           
           List<Hub_Outbound_Staging_GTM__c> gtmRecords = [Select Golden_Site_Identifier__c,
                                                               GTM_Key__c,
                                                               GTM_Property_Type_Code__c,
                                                               GTM_Property_Value_Code__c,
                                                               Status__c
                                                        From   Hub_Outbound_Staging_GTM__c
                                                        Where  Golden_Site_Identifier__c in :gridSet];
               
           for (Hub_Outbound_Staging__c hos : stagingRecords)
           {
             try
             {
                    Hub_Info__c hubInfoRec = new Hub_Info__c();
                    
                    hubInfoRec.Account_Grouping__c = hos.Account_Grouping__c;
                    hubInfoRec.Annual_Sales_Turnover__c = hos.Annual_Sales_Turnover__c;
                    hubInfoRec.Annual_Sales_Turnover_Range__c = hos.Annual_Sales_Turnover_Range__c;
                    hubInfoRec.Booking_Customer_Inception_Year_Qtr__c  = hos.Booking_Customer_Inception_Year_Qtr__c;

                    hubInfoRec.Business_Unit_Ultimate_Golden_Site_ID__c = hos.Business_Unit_Ultimate_Golden_Site_ID__c;
                    hubInfoRec.Business_Unit_Ultimate__c = hos.Business_Unit_Ultimate__c;
                    if(hos.Business_Unit_Ultimate_Golden_Site_ID__c != null && hos.Golden_Site_Identifier__c != hos.Business_Unit_Ultimate_Golden_Site_ID__c)
                    {
                      hubInfoRec.BUU_Lookup__c = gridToIdMap.get(hos.Business_Unit_Ultimate_Golden_Site_ID__c);
                    }

                    hubInfoRec.CUTE_Range__c = hos.CUTE_Range__c;
                    hubInfoRec.Country_Ultimate_Total_Employees_CUTE__c = hos.Country_Ultimate_Total_Employees_CUTE__c;
                    hubInfoRec.DnB_AMO_Range__c = hos.DnB_AMO_Range__c;
                    hubInfoRec.DnB_AMO__c = hos.DnB_AMO__c;
                    hubInfoRec.Domestic_Employee_Market_Segment__c = hos.Domestic_Employee_Market_Segment__c;

                    hubInfoRec.Domestic_Ultimate_Golden_Site_Identifier__c = hos.Domestic_Ultimate_Golden_Site_ID__c;
                    hubInfoRec.Domestic_Ultimate__c = hos.Domestic_Ultimate__c;
                    if(hos.Domestic_Ultimate_Golden_Site_ID__c != null && hos.Golden_Site_Identifier__c != hos.Domestic_Ultimate_Golden_Site_ID__c)
                    {
                      hubInfoRec.DU_Lookup__c = gridToIdMap.get(hos.Domestic_Ultimate_Golden_Site_ID__c);
                    }
                    

                    hubInfoRec.EMC_AMO_Range__c = hos.EMC_AMO_Range__c;
                    hubInfoRec.EMC_AMO__c = hos.EMC_AMO__c;
                    hubInfoRec.EMC_Major_Vertical__c = hos.EMC_Major_Vertical__c;
                    hubInfoRec.EMC_Sub_Vertical__c = hos.EMC_Sub_Vertical__c;
                    hubInfoRec.Employees_Total_Range__c = hos.Employees_Total_Range__c;
                    hubInfoRec.Employees_Total__c = hos.Employees_Total__c;

                    hubInfoRec.Global_Employee_Market_Segment__c = hos.Global_Employee_Market_Segment__c;

                    hubInfoRec.Global_Ultimate_Golden_Site_Identifier__c = hos.Global_Ultimate_Golden_Site_ID__c;
                    //Prachi: Code Starts
                    hubInfoRec.ATP_Facilitated_Account__c=hos.ATP_Facilitated_Account__c;
                    //Prachi: Code Ends

                    hubInfoRec.Global_Ultimate__c = hos.Global_Ultimate__c;
                    if(hos.Global_Ultimate_Golden_Site_ID__c != null && hos.Golden_Site_Identifier__c != hos.Global_Ultimate_Golden_Site_ID__c)
                    {
                      hubInfoRec.GU_Lookup__c = gridToIdMap.get(hos.Global_Ultimate_Golden_Site_ID__c);
                    }                    
                    

                    hubInfoRec.Golden_Site_Identifier__c = hos.Golden_Site_Identifier__c;
                    hubInfoRec.Golden_Site_Name__c = hos.Golden_Site_Name__c;

                    hubInfoRec.IDC_Major_Vertical__c = hos.IDC_Major_Vertical__c;
                    hubInfoRec.Last_Update_Date__c = hos.Last_Update_Date__c;
                    hubInfoRec.PRI_Classification__c = hos.PRI_Classification__c;
                    hubInfoRec.PRI_Headroom__c = hos.PRI_Headroom__c;
                    hubInfoRec.PRI_Penetration__c = hos.PRI_Penetration__c;
                    hubInfoRec.PRI_Range__c = hos.PRI_Range__c;
                    hubInfoRec.PRI__c = hos.PRI__c;
                    hubInfoRec.Parent_ID__c = hos.Parent_ID__c;

                    hubInfoRec.SIC_Code_Description__c = hos.SIC_Code_Description__c;
                    hubInfoRec.SIC_Code__c = hos.SIC_Code__c;
                    
                    hubInfoRec.GTM_AMO__c = hos.GTM_AMO__c;
                    hubInfoRec.GTM_AMO_Range__c = hos.GTM_AMO_Range__c;
                    hubInfoRec.GTM_AMO_Segment__c = hos.GTM_AMO_Segment__c;
                    hubInfoRec.EMC_AMO_Segment__c = hos.EMC_AMO_Segment__c;
                    hubInfoRec.DnB_AMO_Segment__c = hos.DnB_AMO_Segment__c;
                    hubInfoRec.EMC_SIC_Code__c = hos.EMC_SIC_Code__c;
                    
                    for(Hub_Outbound_Staging_GTM__c gtmRec: gtmRecords)
                    {
                        if(gtmRec.Golden_Site_Identifier__c == hubInfoRec.Golden_Site_Identifier__c)
                        {
                            List<string> test = hubGtmToSfdcGtmMap.values();
                            if(hubGtmToSfdcGtmMap.get(gtmRec.GTM_Property_Type_Code__c) != null)
                            {
                              string value = gtmRec.GTM_Property_Value_Code__c;
                              if(GtmNameToCovertFlagMap.get(gtmRec.GTM_Property_Type_Code__c))
                              {
                                if(value != null)
                                {
                                    if(value.equalsIgnoreCase('Yes') == true)
                                    {
                                        hubInfoRec.put(hubGtmToSfdcGtmMap.get(gtmRec.GTM_Property_Type_Code__c), true);
                                    }
                                    else
                                    {
                                        hubInfoRec.put(hubGtmToSfdcGtmMap.get(gtmRec.GTM_Property_Type_Code__c), false);
                                    }
                                }
                              }
                              else
                              {
                                hubInfoRec.put(hubGtmToSfdcGtmMap.get(gtmRec.GTM_Property_Type_Code__c), value);
                              }
                            }
                            gtmRec.Status__c = 'P';
                        }
                    }
                    
                    hubRecords.add(hubInfoRec);
              }
              catch(Exception ex)
              {
                hos.Status__c = 'E';
                hos.Retry_count__c++;
                hos.Error_Code__c = 'Error Code TBD';
                hos.Error_Message__c = ex.getMessage() + ' ' + ex.getLineNumber();
                System.debug('Exception Occured before DML: ' + ex.getTypeName() + ' ' + ex.getMessage() + ' ' + ex.getLineNumber());
                System.debug(ex.getStackTraceString());
              }      
           } 
                    
           List<Database.upsertResult> uResults = Database.upsert(hubRecords,Hub_Info__c.Golden_Site_Identifier__c, false);
           Map<double, id> gridToHInfoIdMap = new Map<double, id>();
           if(uResults != null)
           {
             for(integer i = 0; i < uResults.size(); i++)
             {
                if(uResults[i].success)
                {
                    gridToHInfoIdMap.put(hubRecords[i].Golden_Site_Identifier__c, uResults[i].id);
                    if((hubRecords[i].Business_Unit_Ultimate_Golden_Site_ID__c != null && hubRecords[i].BUU_Lookup__c == null)
                       || (hubRecords[i].Domestic_Ultimate_Golden_Site_Identifier__c != null && hubRecords[i].DU_Lookup__c == null)
                       || (hubRecords[i].Global_Ultimate_Golden_Site_Identifier__c != null && hubRecords[i].GU_Lookup__c == null))
                    {
                       stagingRecords[i].Status__c = 'E';
                       stagingRecords[i].Retry_count__c++;
                       stagingRecords[i].Error_Message__c = 'Unable to find GU/DU/BUU match with corresponding identifier.';
                       stagingRecords[i].Error_Message__c += 'Rerunning the batch might fix the problem';
                    }
                    else
                     {
                      stagingRecords[i].Status__c = 'P';
                      stagingRecords[i].Retry_Count__c = 0;
                      stagingRecords[i].Error_Message__c = null;
                      stagingRecords[i].Error_Code__c = null;
                    }    
                }
                else
                {
                    System.debug('(MAP debug) Upsert Failure ');
                    stagingRecords[i].Status__c = 'E';
                    stagingRecords[i].Retry_count__c++;
                    stagingRecords[i].Error_Code__c = 'Error Code TBD';
                    for(integer j = 0; j < uResults[i].errors.size(); j++ )
                    {
                      stagingRecords[i].Error_Message__c += uResults[i].errors[j].message;
                      System.debug('(MAP debug) Error: ' + uResults[i].errors[j].message);
                    }                   
                }
              }
            }
           
           update stagingRecords;
           update gtmRecords;
        
           List<account> accountList = [Select Id, Party_ID__c, Hub_Info__c From Account where Party_ID__c in :scopeOutBoundPartyIdSet];
           
           for(Account acct: accountList)
           {
             acct.Hub_Info__c = gridToHInfoIdMap.get(partyIdToGridMap.get(acct.Party_ID__c));
           }
                       
            
             List<Database.SaveResult> accResults = Database.Update(accountList,false);
             
             
             if (accResults !=null)
                {
                for(integer x = 0; x <accResults.size(); x++)
                   {
                   if(accResults[x].success){
                    //We don't need to do anything here
                   }else{
                   totalFailedAccounts++;
                   System.debug('(MAP debug) TotalFailedAcounts =:' + totalFailedAccounts + '|' + acctErrorMsg);
                   System.debug('(MAP debug)Account Party_ID__c =:' + accountList[x].Party_ID__c);
                   System.debug('(MAP debug)Account Hub_Info__c =:' + accountList[x].Hub_Info__c);
                   }
               }
             }
           
    }

    global void finish (Database.BatchableContext Bc )
    {
        List<Hub_Outbound_Staging__c> errors = [Select h.Error_Message__c, 
                                      h.Error_Code__c 
                               From   Hub_Outbound_Staging__c h 
                               Where  h.Status__c = 'E'
                               And    h.Retry_count__c > 2 Limit 200 ];
        string message = batchName + ' Completed. ' + totalFailedAccounts + ' ' + acctErrorMsg + '.' + ' Failures listed below: ';
        for(Hub_Outbound_Staging__c err : errors)
        {
            message += err.Id + '| ' + err.Error_Code__c + '| ' + err.Error_Message__c;
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        List<Email_Notification_List__c> mailingList = [Select Name 
                                                      From Email_Notification_List__c];
        for (Email_Notification_List__c usr : mailingList){
        toAddresses.add(usr.Name);
        }
        mail.setToAddresses(toAddresses);
        mail.setPlainTextBody(message);
        system.debug('(MAP Debug) Error messages: ' + message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
    }      
}