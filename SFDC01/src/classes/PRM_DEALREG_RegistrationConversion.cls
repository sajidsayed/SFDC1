/*=====================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR                    DESCRIPTION 
 |  ====          =========               ==                    =========== 
 |  18/05/2011    Anand Sharma           2278,2276, 2261, 2322, This class is used help in Deal Conversion 
 |  23/05/2011    Anand Sharma                                  Added LeadAccept flag to handle recursive call
 |  19/07/2011    Anand Sharma                                  Added condition DealReg_Deal_Registration__c = true into
 |                                                              validateRelatedOpportunity method to handle deal only record.
 |                                                               
 |                                                              Added condition User.IsActive = true to fetch only active 
 |                                                              AccountTeamMember from account    
 |  21/07/2011    Prasad Kothawade                              Quick fix to change the staus back to deal reg only not on lead.
 |                                                              line #291.            
 |                                                               
 |  17/08/2011    Anand Sharma                                  Created method populateProductDetailsOnOpportunity to 
 |                                                              populate Products field value on opportunity
 |  07/11/2011    Suman B                IM7246476              Updated the logic to populate the changed Opportunity Owner Email 
 |                                                              on related DealReg inside updateDealStatusFromRelatedOpportunity(). 
 |   7 Feb 2012    Arif                   185037                 Updated method updateDealStatusFromRelatedOpportunity to include scenerio
 |                                                               when Oppty changed to close when DR changed to 'Closed-Won'.Also removed a query  
 |   19 Feb 2012   Arif                   185037                 Reverted back the logic as this requirement gets cancelled.
 |	 19-Feb-12	   Kaustav										Fixed FIELD_CUSTOM_VALIDATION_EXCEPTION Issue   
 |
 |  20-Aug-2012		Devi Bal			WR#198089				Populate the new Product Filter field                                                                                 
 |                                                                                                                                                                                                                                                            
 +=====================================================================================================*/
public class PRM_DEALREG_RegistrationConversion {
     
    //added to handle Lead conversion recurrsive call
    public static Boolean LeadAccept =false;
    
    
    /* @Method <updateSalesforceStatusOfLead(): This method will update Salesforce field value on lead record.>
       @param - <Lead  as List> 
       @return <void> -
       @throws exception - <No Exception>
    */
    public static List<Lead> updateSalesforceStatusOfLead(List<Lead> lstLead){
        map<Id, Set<String>> mapLeadBUProduct = new map<Id, Set<String>>();
        Set<Id> setLeadIds = new Set<Id>();
        for(Lead objLead : lstLead){
            if(objLead.DealReg_Deal_Registration__c == true){
                setLeadIds.add(objLead.Id);
            }           
        }
        Map<Id, Registration_Product__c> mapRegistrationProduct= new map<Id, Registration_Product__c>(
                                            [Select Deal_Registration__c, Partner_Product_Catalog__c,
                                                Product_BU__c ,Partner_Product_Catalog__r.Product__c 
                                            from Registration_Product__c
                                            where Deal_Registration__c in: setLeadIds]);
        
                                                
        if(mapRegistrationProduct.size() >0 ){
            for(Registration_Product__c objRegistrationProduct :mapRegistrationProduct.values()){
                if(mapLeadBUProduct.containsKey(objRegistrationProduct.Deal_Registration__c)){
                    mapLeadBUProduct.get(objRegistrationProduct.Deal_Registration__c).add(objRegistrationProduct.Product_BU__c);
                }else{
                    mapLeadBUProduct.put(objRegistrationProduct.Deal_Registration__c, new Set<String>());
                    mapLeadBUProduct.get(objRegistrationProduct.Deal_Registration__c).add(objRegistrationProduct.Product_BU__c);
                }
            }
        }                                               
        
        for(Lead objLead : lstLead){
            if(mapLeadBUProduct.containsKey(objLead.Id)){
                if(mapLeadBUProduct.get(objLead.Id).size() > 0){
                    Boolean checkESG = true;
                    for(String strProduct : mapLeadBUProduct.get(objLead.Id)){
                        if(strProduct != null && (!strProduct.toUpperCase().contains('CMA'))){
                            objLead.Sales_Force__c ='EMC';
                            checkESG = false;
                            break;
                        }
                    }
                    if(checkESG){
                        objLead.Sales_Force__c ='ESG';
                    }                   
                }else{
                    objLead.Sales_Force__c ='EMC';
                }               
            }           
        }
        
        return lstLead;
    } 
    
    /* @Method <addProductOnOpportunity(): This method would add product on opportunity>
       @param - <Map<String, Opportunity>> 
       @return <void> -
       @throws exception - <No Exception>
    */
    public static void addProductOnOpportunity(Map<String, Opportunity> convertedOpportunityMap){
        
        Set<Id> setProductIds = new Set<Id>();
        Set<String> setProductCurrencyISOCode = new Set<String>();
        List<OpportunityLineItem> itemsToInsert = new List<OpportunityLineItem>();
        Map<Id,Set<Id>> mapLeadWithProducts = new Map<Id, Set<Id>>();
        Map<String,Set<Id>> mapProductWithLineItems = new Map<String, Set<Id>>();
        Set<String> setCurrencyCode = new Set<String>();
         
        Map<Id, Registration_Product__c> mapRegistrationProduct= new map<Id, Registration_Product__c>(
                                            [Select Deal_Registration__c, Partner_Product_Catalog__c,
                                                Product_BU__c ,Partner_Product_Catalog__r.Product__c,
                                                Partner_Product_Catalog__r.Product__r.CurrencyIsoCode 
                                            from Registration_Product__c
                                            where Deal_Registration__c in: convertedOpportunityMap.keySet()]);
                                            
        for(Opportunity objOpp: convertedOpportunityMap.values()){
            if(objOpp.CurrencyIsoCode != null){
                setCurrencyCode.add(objOpp.CurrencyIsoCode);
            }           
        }
                                            
        for(Registration_Product__c objRegProduct: mapRegistrationProduct.values()){
            if(objRegProduct.Partner_Product_Catalog__c != null && objRegProduct.Partner_Product_Catalog__r.Product__c != null){
                setProductIds.add(objRegProduct.Partner_Product_Catalog__r.Product__c);         
                if(mapLeadWithProducts.containsKey(objRegProduct.Deal_Registration__c)){
                    mapLeadWithProducts.get(objRegProduct.Deal_Registration__c).add(objRegProduct.Partner_Product_Catalog__r.Product__c);
                }else{
                    mapLeadWithProducts.put(objRegProduct.Deal_Registration__c, new Set<Id>());
                    mapLeadWithProducts.get(objRegProduct.Deal_Registration__c).add(objRegProduct.Partner_Product_Catalog__r.Product__c);
                }
            }               
        }   
        
        List<PriceBookEntry> lstPBEntry = [select Id, Product2Id, CurrencyIsoCode from PricebookEntry 
                                            where  Product2Id in :setProductIds and isActive=true AND CurrencyIsoCode in: setCurrencyCode
                                                   //AND Pricebook2.Name='Standard Price Book' AND CurrencyIsoCode ='USD' 
                                                   ];
        for(PriceBookEntry objPB: lstPBEntry){
            if(mapProductWithLineItems.containsKey(objPB.Product2Id + objPB.CurrencyIsoCode)){
                mapProductWithLineItems.get(objPB.Product2Id + objPB.CurrencyIsoCode ).add(objPB.Id);
            }else{
                mapProductWithLineItems.put(objPB.Product2Id + objPB.CurrencyIsoCode , new Set<Id>());
                mapProductWithLineItems.get(objPB.Product2Id + objPB.CurrencyIsoCode).add(objPB.Id);
            }
        }
        
        
        for(String objLeadId: convertedOpportunityMap.keySet()){
            if(mapLeadWithProducts.containsKey(objLeadId)){
                for(Id productId: mapLeadWithProducts.get(objLeadId)){
                    if(mapProductWithLineItems.containsKey(productId + convertedOpportunityMap.get(objLeadId).CurrencyIsoCode)){
                        for(Id proceBookEntryId : mapProductWithLineItems.get(productId + convertedOpportunityMap.get(objLeadId).CurrencyIsoCode)){
                            itemsToInsert.add( new OpportunityLineItem(OpportunityId = convertedOpportunityMap.get(objLeadId).Id, PricebookEntryId = proceBookEntryId, UnitPrice = 0.0));
                        }
                    }
                }
            }
        }
        System.debug('Product itemsToInsert ----> ' + itemsToInsert);   
        if(itemsToInsert.size() > 0){
            insert   itemsToInsert;             
            //DataBase.insert(itemsToInsert, false);        
        }
    }
    
    /* @Method <syncDealRelatedOpportunity(): This method will use to sync lead with opportunity partners.>
       @param - <Lead as List> 
       @return <void> -
       @throws exception - <No Exception>
    */
    public static void syncDealRelatedOpportunity(List<Lead> lstLead){
        Set<Id> setLeadIds = new Set<Id>();
        map<Id, Lead> mapLead = new map<Id, Lead>();
        map<Id, Lead> mapOpportunityidLead = new map<Id, Lead>();
        List<Opportunity> lstUpdateOpportunity = new List<Opportunity>();
        Opportunity objOpp;
        
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c DealrecordType = DataValueMap.get('DealRegistration');
        String strDealrecordType = DealrecordType.DataValue__c;
        
        if(lstLead.size() >0){
            for(Lead objLead : lstLead){
                String strLeadRecordType = objLead.RecordTypeId;
                if(strLeadRecordType !=null && strLeadRecordType !='' && strLeadRecordType.length() >15){
                    strLeadRecordType= strLeadRecordType.substring(0,15);
                }
                if(strDealrecordType.contains(strLeadRecordType)){
                    setLeadIds.add(objLead.Id);
                    if(objLead.Related_Opportunity__c != null){
                        mapLead.put(objLead.Related_Opportunity__c, objLead);
                    }
                }
            }
            
            if(setLeadIds.size() > 0){
                Map<Id, Opportunity> mapDealRelatedOpportunity = new Map<Id, Opportunity>([
                                                    Select Id, Partner__c, Tier_2_Partner__c, Deal_Lead__c  
                                                    from Opportunity 
                                                    where Id in: mapLead.keySet()]);
                
                //update Distributor/Direct Reseller and Distribution VAR fields are synced between the Deal Reg and the Opportunity
                if(mapDealRelatedOpportunity.size() >0){                    
                    for(Lead objLead : lstLead){
                        if(objLead.Related_Opportunity__c != null && mapDealRelatedOpportunity.containsKey(objLead.Related_Opportunity__c )){
                            objOpp = mapDealRelatedOpportunity.get(objLead.Related_Opportunity__c);
                            if(objOpp != null){
                                objOpp.Partner__c =objLead.Partner__c;
                                objOpp.Tier_2_Partner__c = objLead.Tier_2_Partner__c;
                                lstUpdateOpportunity.add(objOpp);
                            }   
                        }
                    }
                }
                // update opportunity 
                try{
                    update lstUpdateOpportunity;
                }catch(Exception ex){
                    String strErrorMessage = 'Error :  '+ ex.getMessage();              
                    if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                        strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
                    }
                    if(strErrorMessage.endsWith(': []')){
                        strErrorMessage = strErrorMessage.substring(0, strErrorMessage.length() -4);
                    }
                    for(Lead objLead: lstLead){
                        objLead.addError(strErrorMessage);
                    }
                }
                                                                    
            }
        }
    }
    
    /* @Method <validateRelatedOpportunity(): This method validate that opportunity is only related to only one deal.>
       @param - <Lead as list> 
       @return <void> - 
       @throws exception - <No Exception>
    */
    //only allow one Deal Reg record to be related to an Oppty
    public static void validateRelatedOpportunity(List<Lead> lstLead){
        Map<Id, List<Lead>> mapOpportunityidLeads = new Map<Id, List<Lead>>();
        map<Id, Lead> mapLead = new map<Id, Lead>();        
        if(lstLead.size() >0){
            
            Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
            CustomSettingDataValueMap__c DealrecordType = DataValueMap.get('DealRegistration');
            String strDealrecordType = DealrecordType.DataValue__c;
            
            for(Lead objLead : lstLead){
                String strLeadRecordType = objLead.RecordTypeId;
                if(strLeadRecordType !=null && strLeadRecordType !='' && strLeadRecordType.length() >15){
                    strLeadRecordType= strLeadRecordType.substring(0,15);
                }
                if(strDealrecordType.contains(strLeadRecordType)){
                    if(objLead.Related_Opportunity__c != null){
                        mapLead.put(objLead.Related_Opportunity__c, objLead);
                    }
                }               
                                
            }
            
            if(mapLead.size() > 0){
                Map<Id, Lead> mapLeadForRelatedAccount = new Map<Id, Lead>([
                                                            Select Id , Related_Opportunity__c from Lead
                                                            Where Related_Opportunity__c in: mapLead.KeySet() and DealReg_Deal_Registration__c = true
                                                            ]);
                if(mapLeadForRelatedAccount.size() > 0){
                    for(Lead objLead : mapLeadForRelatedAccount.values()){
                        if(mapOpportunityidLeads.containsKey(objLead.Related_Opportunity__c)){
                            mapOpportunityidLeads.get(objLead.Related_Opportunity__c).add(objLead);
                        }else{
                            mapOpportunityidLeads.put(objLead.Related_Opportunity__c, new List<Lead>());
                            mapOpportunityidLeads.get(objLead.Related_Opportunity__c).add(objLead);
                        }
                    }
                    if(mapLeadForRelatedAccount.size() >0 ){
                        for(Lead objLead : lstLead){                
                            if(mapOpportunityidLeads.containsKey(objLead.Related_Opportunity__c)){
                                objLead.addError(' Only one Deal Registration can be linked to an Opportunity at a time.');
                            }               
                        }
                    }                           
                }
            }
        }
    }
    
    /* @Method <updateDealStatusFromRelatedOpportunity(): This method will update record.>
       @param - <List<Opportunity> of Opprotunity> 
       @return <void> - 
       @throws exception - <No Exception>
    */
    
    public static void updateDealStatusFromRelatedOpportunity(List<Opportunity> lstOpprotunity){
        Set<Id> setOpportunityIds = new Set<Id>();
                
        if(lstOpprotunity.size() > 0){
            for(Opportunity objOpp: lstOpprotunity){
                setOpportunityIds.add(objOpp.Id);
            }           
            if(setOpportunityIds.size()>0){
                Map<Id, Lead> mapLeadwithRelatedOpportunity = New Map<Id, Lead>([
                                                            Select Id , DealReg_Deal_Registration_Status__c, Related_Opportunity__c,Related_Opportunity__r.StageName,Related_Opportunity__r.Owner.Email  
                                                            from Lead 
                                                            Where Related_Opportunity__c in:setOpportunityIds and dealreg_Deal_Registration__c=true]);
                
               // Added for populating the changed Owner of the Oppty to DR - IM7246476.
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c DealrecordType = DataValueMap.get('DealRegOpportunityStage');
        String strDealrecordType = DealrecordType.DataValue__c;

             /*   Map<Id,Opportunity> owner_OpportunityList = new Map<Id,Opportunity>([
                                Select id,name,Owner.Email, ownerId 
                                FROM Opportunity where id IN : setOpportunityIds]);*/
                                          
       for(Lead objLead : mapLeadwithRelatedOpportunity.values()){
           //WR185037
           if(objLead.Related_Opportunity__r.StageName == strDealrecordType){
                  objLead.DealReg_Deal_Registration_Status__c ='Closed-Won';
           }
           objLead.Linked_Opportunity_Owner__c = objLead.Related_Opportunity__r.Owner.Email;
       } 
       try{
              update mapLeadwithRelatedOpportunity.values();
          }catch(System.DmlException ex){
              string errorMessage = ex.getMessage();
              integer start = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION');
              if(start != -1){
                  errorMessage = errorMessage.substring(start+35,errorMessage.indexOf(']')+1);
                  ex.setMessage(errorMessage);
              }     
          }               
                /*
                if(mapLeadwithRelatedOpportunity.size()> 0){
                    if(mapOpportunityidLeads.containsKey(objLead.Related_Opportunity__c)){
                        mapOpportunityidLeads.get(objLead.Related_Opportunity__c).add(objLead);
                    }else{
                        mapOpportunityidLeads.put(objLead.Related_Opportunity__c, new List<Lead>());
                        mapOpportunityidLeads.get(objLead.Related_Opportunity__c).add(objLead);
                    }
                }                                                       
            }
            
            for(Opportunity objOpp: lstOpprotunity){                
                if(mapOpportunityidLeads.containsKey(objOpp.Id)){
                    objLead =mapOpportunityidLeads.containsKey(objOpp.Id);
                    objLead.DealReg_Deal_Registration_Status__c = objOpp.StageName;
                    lstLeadUpdate.add(objLead);
                }
                */
            }
        }
    }
        
    /* @Method <getOpportunityOwner(): This method will get owner for oppotunity>
       @param - <List<Opportunity> of Opprotunity> 
       @return <void> - 
       @throws exception - <No Exception>
    */
    //public Map<String, Set<Id>> getDirectRepForLead(List<Lead> lstLead){
    public static Map<String,AccountTeamMember> getOpportunityOwner(List<Lead> lstLead){
        Set<Id> accountIds = new Set<Id>();
        //acountid, role and list of team member
        Map<String, Map<String,List<AccountTeamMember>>> mapAccountIdKeyRoleAccountTeam = new Map<String, Map<String,List<AccountTeamMember>>>();
                
        Map<String, AccountTeamMember> mapAccuntTeamMember = new Map<String, AccountTeamMember>(); 
        for(Lead objDealReg: lstLead){          
            if(objDealReg.Related_Account__c!=null ){               
                accountIds.add(objDealReg.Related_Account__c);                  
            }
        }
        
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c DealregDirectRepRoleOrder = DataValueMap.get('DealregDirectRepRoleOrder');
        String setOfRoles = DealregDirectRepRoleOrder.DataValue__c;
        
        List<String> setUserRoles = setOfRoles.split(';');
        
        if(accountIds.size() >0){
            Map<String,List<AccountTeamMember>> mapRoleAccountTeamMember = new Map<String,List<AccountTeamMember>>();
            Map<Id, AccountTeamMember> mapAccountTeam = new Map<Id, AccountTeamMember>(
                                                            [Select AccountId, Id, TeamMemberRole, UserId , User.Name,User.BU_Attribute__c, Account.Master_Grouping__c
                                                            from AccountTeamMember
                                                            where AccountId in:accountIds AND TeamMemberRole in :setUserRoles AND User.IsActive = true
                                                                and (User.BU_Attribute__c like '%Core%' OR User.BU_Attribute__c like '%CMA%') 
                                                            ]);
            if(mapAccountTeam.size() > 0){
                String strBUAttribute = '';
                for(AccountTeamMember accTeam : mapAccountTeam.values()){
                    strBUAttribute = accTeam.User.BU_Attribute__c;  
                    if(strBUAttribute.contains('Core')){
                        strBUAttribute ='Core';
                    }else{
                        strBUAttribute ='CMA';
                    }               
                    if(mapAccountIdKeyRoleAccountTeam.containsKey(accTeam.AccountId + '' + strBUAttribute)){    
                        mapRoleAccountTeamMember = mapAccountIdKeyRoleAccountTeam.get(accTeam.AccountId + '' + strBUAttribute);
                        if(mapRoleAccountTeamMember.containsKey(accTeam.TeamMemberRole)){
                            mapRoleAccountTeamMember.get(accTeam.TeamMemberRole).add(accTeam);
                        }else{
                            mapRoleAccountTeamMember.put(accTeam.TeamMemberRole, new List<AccountTeamMember>());
                            mapRoleAccountTeamMember.get(accTeam.TeamMemberRole).add(accTeam);
                        }
                    }   
                    else{
                        mapAccountIdKeyRoleAccountTeam.put(accTeam.AccountId + '' + strBUAttribute, new Map<String,List<AccountTeamMember>>());
                        mapRoleAccountTeamMember = mapAccountIdKeyRoleAccountTeam.get(accTeam.AccountId + '' + strBUAttribute);
                        if(mapRoleAccountTeamMember.containsKey(accTeam.TeamMemberRole)){
                            mapRoleAccountTeamMember.get(accTeam.TeamMemberRole).add(accTeam);
                        }else{
                            mapRoleAccountTeamMember.put(accTeam.TeamMemberRole, new List<AccountTeamMember>());
                            mapRoleAccountTeamMember.get(accTeam.TeamMemberRole).add(accTeam);
                        }
                    }
                    mapAccountIdKeyRoleAccountTeam.put(accTeam.AccountId + '' + strBUAttribute,mapRoleAccountTeamMember);
                }
                
                for(Lead objLead :lstLead){
                    if(objLead.Related_Account__c != null){
                        if(objLead.Sales_Force__c == 'EMC'){
                            if(mapAccountIdKeyRoleAccountTeam.containsKey(objLead.Related_Account__c + 'Core' )){
                                for(String strRoles : setUserRoles){
                                    if(mapAccountIdKeyRoleAccountTeam.get(objLead.Related_Account__c + 'Core').containsKey(strRoles)){                                      
                                        mapAccuntTeamMember.put(objLead.Related_Account__c, mapAccountIdKeyRoleAccountTeam.get(objLead.Related_Account__c + 'Core').get(strRoles).get(0));                                      
                                    }
                                }
                            }
                        }   
                    }
                }
            }                                                       
        }       
        system.debug('mapAccuntTeamMember----------->' +mapAccuntTeamMember);
        return mapAccuntTeamMember;
    }   
    
    /* @Method <populateProductDetailsOnOpportunity(): This method will set products details on oppotunity>
       @param - <Map<Id, Opportunity> of Opprotunity> 
       @return <void> - 
       @throws exception - <No Exception>
    */
    
    public static void populateProductDetailsOnOpportunity(Map<Id,Opportunity> MapOpptysToUpdate ){
        Map<Id,set<Id>> OpptyWithPriceBookEntry = new Map<Id,set<Id>>();
        List<PricebookEntry> lstPriceBookEntry=New List<PricebookEntry>();
        List<Id> lstPriceBookEntryId = new List<Id>();
        Map<Id,String> mapPbookPrdctName=new Map<Id,String>();
        String ProductName='';
        String ProductFilter=''; //DB Aug - 2012
        Map<Id,String> OpptyWithProductName= New Map<Id,String>();
        Map<Id,String> OpptyWithProductFilter= New Map<Id,String>(); //DB Aug - 2012
        
        List<OpportunityLineItem> lstOpptyLineItem=[Select Id,PricebookEntryId,OpportunityId  from OpportunityLineItem where OpportunityId in :MapOpptysToUpdate.keyset()];
        for(OpportunityLineItem opptyLineItem :lstOpptyLineItem){
            set<Id> setPriceBookId= OpptyWithPriceBookEntry.get(opptyLineItem.OpportunityId);
            if(setPriceBookId==null){
                setPriceBookId= new set<Id>();
                OpptyWithPriceBookEntry.put(opptyLineItem.OpportunityId,setPriceBookId);
            }
            OpptyWithPriceBookEntry.get(opptyLineItem.OpportunityId).add(opptyLineItem.PricebookEntryId);
        }
         
        for(Id OpptyId:OpptyWithPriceBookEntry.keyset()){
             for(id pricebookId:OpptyWithPriceBookEntry.get(OpptyId)){
                 lstPriceBookEntryId.add(pricebookId);
             }
        }
        lstPriceBookEntry=[Select Id,Name from PriceBookEntry where Id in :lstPriceBookEntryId];
        for(PriceBookEntry pbook :lstPriceBookEntry){
             mapPbookPrdctName.put(pbook.Id,pbook.Name);
        }
        for(id opptyId :OpptyWithPriceBookEntry.keyset()){
             for(Id pbId:OpptyWithPriceBookEntry.get(opptyId)){
                 ProductName=ProductName+mapPbookPrdctName.get(pbId)+'; ';
             }
             ProductName= ProductName.substring(0,ProductName.length()-2 );
             OpptyWithProductName.put(OpptyId,ProductName);
			 //DB Aug - 2012
             if(ProductName.length() > 250){
             	ProductFilter= ProductName.substring(0, 250) + ' etc;';	
             }
             else{
             	ProductFilter= ProductName;	
             }
             OpptyWithProductFilter.put(OpptyId,ProductFilter);
             //DB Aug - 2012
        }
        for(id opptyId :MapOpptysToUpdate.keyset()){
             MapOpptysToUpdate.get(opptyId).Products__c=OpptyWithProductName.get(OpptyId);
             MapOpptysToUpdate.get(opptyId).Products_Filter__c=OpptyWithProductFilter.get(OpptyId); //DB Aug - 2012      
        }
    }
}