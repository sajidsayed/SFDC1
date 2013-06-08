/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  20.07.2010      Anand Sharma    136601      Initial Creation.  Assign sales rep to the opportunity For EMC Type.  
                                                Assumption: Rule record should not be more than 10000; If this wil exceed 10000, then there is lot of changes in the logic.
                                                
 |  27.09.2010      Anand Sharma                updated checked from Account Theater to Account Owner theater to assigned channel rep.                                                              
 |  14.10.2010      Shipra Misra                Channel Visibilty enhancements.
 |                                              1.)Partner Grouping addition.
 |                                              2.)Simplified logic.
 |  22.11.2010      Shipra Misra                Optimization Of code to remove too many Script exception.
 |  21.02.2011      Shipra Misra                Worked for March release.
 |  12.04.2011      Shipra Misra                WR-160455 Included Master grouping for Partner's.Having the ability to select a Master Partner Grouping 
 |                                              hence simplify OAR maintenance and reduce the number of OARs that need to be created.
 |  12.05.2011      Shipra Misra    162881      Worked for Jun release.Changes for including service provider field.
 |  12.06.2011      Shipra Misra    168015      Worked for July release.Changes for House Account.Also updated All Partners for error occured on Production.
 |  08.05.2011      Shipra Misra    169092      Worked for August release.Enable OAR to Overwrite Opportunity Account Owner.
 |  11.09.2011      Shipra Misra    172224      October Release.
 |  11.10.2011      Shipra Misra    173965      November Release.
 |	09.01.2012  	Shipra Misra	172609 		SFA - Add Vertical Field to OAR (MAP Contingent)  
 |	07.04.2012		Shipra Misra	190354		SFA -Production Support Break fix 1(Channel Visibility functionality for All Partner not performing on EMC Vertical.)
 |  03.12.2012  	Sheriff Singla	219248 		Added the code for Heapsize Error.  
 +===========================================================================*/

public class Opp_assignChannelRep
{
    // This method is used to assign sales rep to opportunity record 
    // This is the future method, which will takes opportinityIds, old values of (Tire1 Partner, 
    // Tire2 Partner,Tire2 Deal Partner, Primary Alliance partner, Secondary Alliance partner and Service Provider) and event of Trigger get executed.
    // This method will be used when need to increase governer limit using future method. 
    // This will be used in future if required. 
    @future
    public static void AsynchAssignchannelRepsForEMC(Set<String> setstrOppId,Map<Id,Id> mapTierPartner, Map<Id,Id> mapTire2Partner,
                                         Map<Id,Id> mapPrimaryAllaincePartnerMap,Map<Id,Id> mapSecondaryAllaincePartnerMap,
                                         Map<Id,Id> serviceProviderPartnerMap, boolean isUpdate )
     { 
        Set<id> setOppId= new Set<Id>();
        for(String strId:setstrOppId)
        {
            setOppId.add(strId);
        }
        AssignchannelRepsForEMC(setOppId, mapTierPartner, mapTire2Partner,
                                          mapPrimaryAllaincePartnerMap,
                                         mapSecondaryAllaincePartnerMap,serviceProviderPartnerMap, isUpdate );
     }
    
     public static void AssignchannelRepsForEMC(Set<Id> setOppId,Map<Id,Id> mapTierPartner, Map<Id,Id> mapTire2Partner,
                                         Map<Id,Id> mapPrimaryAllaincePartnerMap,
                                         Map<Id,Id> mapSecondaryAllaincePartnerMap,Map<Id,Id> serviceProviderPartnerMap, boolean isUpdate )
     {
        //Map<String, OpportunityTeamMember> mapOppTeamMember = new Map<String,OpportunityTeamMember>();
        //hold the All Partner type as key and Opportunity_Assignment_Rule record as value 
        Map<String, List<Opportunity_Assignment_Rule__c>> mapAllPartnertypeOppAssRule = new Map<String, List<Opportunity_Assignment_Rule__c>>();
        //hold the Service Provider Partner type as key and Opportunity_Assignment_Rule record as value 
        Map<String, List<Opportunity_Assignment_Rule__c>> mapServiceProviderPartnertypeOppAssRule = new Map<String, List<Opportunity_Assignment_Rule__c>>();
        //hold the Alliance Partner type as key and Opportunity_Assignment_Rule record as value 
        Map<String, List<Opportunity_Assignment_Rule__c>> mapAlliancePartnertypeOppAssRule = new Map<String, List<Opportunity_Assignment_Rule__c>>();
        //hold the Tier1/Tier2 sfdcId as key and Opportunity_Assignment_Rule record as value 
        Map<String, List<Opportunity_Assignment_Rule__c>> mapTier1Tier2PartnerOppAssRule = new Map<String, List<Opportunity_Assignment_Rule__c>>();
        //hold the Partner Grouping and Partner type as key and Opportunity_Assignment_Rule record as value 
        Map<String, List<Opportunity_Assignment_Rule__c>> mappartnerGroupingPartnertypeOppAssRule = new Map<String, List<Opportunity_Assignment_Rule__c>>();
        //hold selected list of Maps to be considered.
        Map<id,Opportunity_Assignment_Rule__c> mapOppAssignmentRule =new Map<id,Opportunity_Assignment_Rule__c>();
		//Boolean NamedPartner =false;
        Boolean PartnerGrouping=true;
        //Boolean Tier12Partner=true;
        Boolean checkRecordFound = false;
        //Hold Boolean for exclusion on OAR found.
        Boolean ExclusionFound=false;
        System.debug('mapSecondaryAllaincePartnerMap===>'+mapSecondaryAllaincePartnerMap); 
        System.debug('mapTire2Partner===>'+mapTire2Partner);   
        //fetch all opportunity using opportunity Ids into list lstOpportunity
        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([Select Id,Country__c, ownerid , Opportunity_Owner__r.FirstName, Opportunity_Owner__r.LastName,
                                     Opportunity_Owner__r.District__c, Opportunity_Owner__r.Country__c,Opportunity_Owner__r.Name,Account.EMC_CLASSIFICATION__c,
                                     Opportunity_Owner__r.Area__c, Opportunity_Owner__r.Theater__c,Opportunity_Owner__r.State,  Sales_Force__c,Opportunity_Owner__r.region__c,
                                     Partner__c,Partner__r.Name,Partner__r.Grouping__c,Partner__r.Master_Grouping__c,Tier_2_Partner__r.Name, Tier_2_Partner__c,Tier_2_Partner__r.Grouping__c,Tier_2_Partner__r.Master_Grouping__c,
                                     Tier_2_Partner_from_Deal_Reg__c,Opportunity_Owner__r.Division__c,Primary_Alliance_Partner__c,
                                     Secondary_Alliance_Partner__c,Primary_Alliance_Partner__r.Grouping__c,Primary_Alliance_Partner__r.Master_Grouping__c,
                                     Secondary_Alliance_Partner__r.Grouping__c,Secondary_Alliance_Partner__r.Master_Grouping__c,
                                     Account.Coverage_Model__c,Name,Opportunity_Number__c,Account_Name1__c,Account.EMC_Major_Vertical__c,Account.Customer_Segment__c, Account.Theater1__c,
                                     Service_Provider__c,Service_Provider__r.Grouping__c,Service_Provider__r.Master_Grouping__c, Account.BillingState,Account.BillingPostalCode, Account.Grouping__c, Account.BillingCountry, CurrencyIsoCode,
                                     (Select OpportunityAccessLevel, OpportunityId, TeamMemberRole, UserId From OpportunityTeamMembers),
                                     (Select Id, OpportunityId, PricebookEntryId,UnitPrice, PricebookEntry.Product2Id, Quote_Amount__c, Product_Type__c From OpportunityLineItems)                                   
                                   From Opportunity
                                   where Id IN: setOppId]); 
        
           
        //Fetch all custom label values
        String strAllPartnerType = System.Label.AllPartners_PartnerType.toLowerCase();
        String strNamedPartnerType = System.Label.NamedPartners_PartnerType.toLowerCase();
        String strAlliancePartnerType = System.Label.Alliance_PartnerType.toLowerCase();
        String strServiceProviderPartnerType = System.Label.Service_Provider.toLowerCase();
        System.debug('The value of Service Provider is'+strServiceProviderPartnerType);
        List<House_Account_For_OAR__c> lstHouseAccnt = House_Account_For_OAR__c.getAll().values();
        //hold id of oppty with owner as house account.
        Set<Id> setOpptyHouseAccount = new Set<id>();
        //Loop on opportunity record 
        
        if(mapTierPartner.size()>0 && mapTierPartner!=null)
        {
            String Partner=strNamedPartnerType;
            mapOppAssignmentRule.putAll(mapOppAssignmentRuleRecords(mapOpportunity,mapTierPartner,mapOppAssignmentRule,isUpdate,Partner));
        }
        //For Tier 2 Partner
        if(mapTire2Partner.size()>0 && mapTire2Partner!=null)
        {
            String Partner=strNamedPartnerType;
            mapOppAssignmentRule.putAll(mapOppAssignmentRuleRecords(mapOpportunity,mapTire2Partner,mapOppAssignmentRule,isUpdate,Partner));
        }
        //For Primary Alliance Partner
        if(mapPrimaryAllaincePartnerMap.size()>0 && mapPrimaryAllaincePartnerMap!=null)
        {
            System.debug('mapPrimaryAllaincePartnerMap-->'+mapPrimaryAllaincePartnerMap);
            String Partner=strAlliancePartnerType;
            mapOppAssignmentRule.putAll(mapOppAssignmentRuleRecords(mapOpportunity,mapPrimaryAllaincePartnerMap,mapOppAssignmentRule,isUpdate,Partner));
            System.debug('mapOppAssignmentRule===>Primary'+mapOppAssignmentRule);
        }
        //For Service Provider Partner
        if(serviceProviderPartnerMap.size()>0 && serviceProviderPartnerMap!=null)
        {
            String Partner=strServiceProviderPartnerType;
            mapOppAssignmentRule.putAll(mapOppAssignmentRuleRecords(mapOpportunity,serviceProviderPartnerMap,mapOppAssignmentRule,isUpdate,Partner));
            System.debug('mapOppAssignmentRule--->Inside service provider'+mapOppAssignmentRule);
        }
        //For Secondary Alliance Partner
        System.debug('mapSecondaryAllaincePartnerMap---> '+mapSecondaryAllaincePartnerMap);
        if(mapSecondaryAllaincePartnerMap.size()>0 && mapSecondaryAllaincePartnerMap!=null)
        {
            System.debug('mapSecondaryAllaincePartnerMap-->'+mapSecondaryAllaincePartnerMap);
            String Partner=strAlliancePartnerType;
            mapOppAssignmentRule.putAll(mapOppAssignmentRuleRecords(mapOpportunity,mapSecondaryAllaincePartnerMap,mapOppAssignmentRule,isUpdate,Partner));
            System.debug('mapOppAssignmentRule===>Secondary'+mapOppAssignmentRule);
        }
        //For all Partner
        if(mapOpportunity.size()>0 && mapOpportunity!=null)
        {
            Map<id,id> mapAllPartner=new Map<id,id> ();
            String Partner=strAllPartnerType;
            System.debug('Partner==='+Partner);
            mapOppAssignmentRule.putAll(mapOppAssignmentRuleRecords(mapOpportunity,mapAllPartner,mapOppAssignmentRule,isUpdate,Partner));
        }
        System.debug('mapOppAssignmentRule after query--->'+mapOppAssignmentRule);
        
        //Hold key value
        String strKeyValue ='';
        
        for(House_Account_For_OAR__c objHouseAccnt:lstHouseAccnt)
        {
        	setOpptyHouseAccount.add(objHouseAccnt.Name);
        }

        //Add a query for Opportunity.
        for(Opportunity opp: mapOpportunity.values())
        {
            //ID idOpptyOwner=opp.Opportunity_Owner__r.id;
            ID idOpptyOwner=opp.Ownerid;
            String mat='';
            if(opp.Account.Theater1__c!=null)
            {
                mat=mat+'accounttheater'+opp.Account.Theater1__c.toLowerCase()+'accounttheater'+',';
            }
            if(opp.Account.BillingCountry!=null)
            {
                mat=mat+'country'+opp.Account.BillingCountry.toLowerCase()+'country'+',';
            }
            if(opp.Account.BillingState!=null)
            {
                mat=mat+'state'+opp.Account.BillingState.toLowerCase()+'state'+',';
            }
            if(opp.Account.Coverage_Model__c!=null)
            {
                mat=mat+'coveragemodel'+opp.Account.Coverage_Model__c.toLowerCase()+'coveragemodel'+',';
            }
            if(opp.Account.Customer_Segment__c!=null)
            {
                mat=mat+'customersegment'+opp.Account.Customer_Segment__c.toLowerCase()+'customersegment'+',';
            }
            if(opp.Account.EMC_Major_Vertical__c!=null)
            {
                mat=mat+'emcmajorvertical'+opp.Account.EMC_Major_Vertical__c.toLowerCase()+'emcmajorvertical'+',';
            }
            if(opp.Account.EMC_CLASSIFICATION__c!=null)
            {
                mat=mat+'classification'+opp.Account.EMC_CLASSIFICATION__c.toLowerCase()+'classification'+',';
            }
            if(opp.Sales_Force__c!=null)
            {
                mat=mat+'salesforce'+opp.Sales_Force__c.toLowerCase()+'salesforce'+',';
            }
            if(opp.Opportunity_Owner__r.Theater__c!=null)
            {
                mat=mat+'theater'+opp.Opportunity_Owner__r.Theater__c.toLowerCase()+'theater'+',';
            }
            if(opp.Opportunity_Owner__r.area__c!=null)
            {
                mat=mat+'area'+opp.Opportunity_Owner__r.area__c.toLowerCase()+'area'+',';
            }
            if(opp.Opportunity_Owner__r.District__c!=null)
            {
                mat=mat+'district'+opp.Opportunity_Owner__r.District__c.toLowerCase()+'district'+',';
            }
            if(opp.Opportunity_Owner__r.Division__c!=null)
            {
                mat=mat+'division'+opp.Opportunity_Owner__r.Division__c.toLowerCase()+'division'+',';
            }
            if( opp.Opportunity_Owner__r.region__c!=null)
            {
                mat=mat+'region'+opp.Opportunity_Owner__r.region__c.toLowerCase()+'region'+',';
            }
           mat=mat+opp.Opportunity_Owner__c;
                    
            for(Opportunity_Assignment_Rule__c oppAssignmnetRule : mapOppAssignmentRule.values())
            {
                //Re-Setting all boolean variables for the new record.  
//                Tier12Partner=true;
  //              PartnerGrouping=true;
                ExclusionFound=false;
                List<OAR_Exclusion_Condition__c> lstOarExclusion= oppAssignmnetRule.OAR_Exclusion_Conditions__r;
                System.debug('oppAssignmnetRule--->'+oppAssignmnetRule);
                if(lstOarExclusion.size()>0 && lstOarExclusion!=null)
                {
                    System.debug('lstOarExclusion--->'+lstOarExclusion);
                    ExclusionFound=processExclusionFound(lstOarExclusion,opp);
                    System.debug('Value of Exclusion Found'+ExclusionFound);
                    if(ExclusionFound)
                    	continue;
                }
                
                if(setOpptyHouseAccount.contains(opp.OwnerId))
                {
                    if(oppAssignmnetRule.Apply_to_House_Account__c ==false)
                        continue;
  
                }
                else if(oppAssignmnetRule.Apply_to_House_Account__c==true)
                {
                    continue;
                }
                
                
                if(oppAssignmnetRule.Expression_Oar__c!=null)
                {
                	Boolean expressionMatch=false;
                    Pattern MyPattern = Pattern.compile(oppAssignmnetRule.Expression_Oar__c);
                    System.debug('Thevalue of matis'+mat);
                    Matcher OpptyMatcher= MyPattern.matcher(mat);
                    expressionMatch = OpptyMatcher.matches();
                    if(!expressionMatch)
                    	continue;
                    System.debug('The value of expressionMatch is'+expressionMatch);
                }
                
                if(opp.Account.BillingPostalCode !=null)
                {
                	Boolean ZipCodeFound=false;
                    if(oppAssignmnetRule.Zip_Postal_Code_List__c !=null)
                    {
                        String[] arrZipPostalCodeList = oppAssignmnetRule.Zip_Postal_Code_List__c.split(',');
                        for(Integer j=0; j<arrZipPostalCodeList.size(); j++)
                        {
                            if(arrZipPostalCodeList[j].contains(opp.Account.BillingPostalCode))
                            {
                                ZipCodeFound=True;
                            }
                            
                        }
                        if(!ZipCodeFound)
                        {
                            continue;
                        }
                    }
                    //if list if postal code is not present then search for Range of Postal Code on OAR.
                    else
                    {
                        if(oppAssignmnetRule.Zip_Postal_Code_Low_Range__c !=null && oppAssignmnetRule.Zip_Postal_Code_High_Range__c !=null)
                        {
                            if( oppAssignmnetRule.Zip_Postal_Code_Low_Range__c<=opp.Account.BillingPostalCode && oppAssignmnetRule.Zip_Postal_Code_High_Range__c>=opp.Account.BillingPostalCode)
                            {
                                
                            }
                            else
                            {
                                continue;
                            }
                        }
                    }
                }
                
                if(oppAssignmnetRule.Partner_Type__c.toLowerCase()==strAllPartnerType)
                {
                    strKeyValue =Opp.Id;
                        if(mapAllPartnertypeOppAssRule.containsKey(strKeyValue))
                        {
                            mapAllPartnertypeOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                        }else
                        {
                            mapAllPartnertypeOppAssRule.put(strKeyValue, new List<Opportunity_Assignment_Rule__c>());
                            mapAllPartnertypeOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                        }
                }
				else if(oppAssignmnetRule.Partner_Grouping__c !=null )
                {
                    strKeyValue = opp.id+'|'+oppAssignmnetRule.Partner_Grouping__c + '|' + oppAssignmnetRule.Partner_Type__c.toLowerCase();
                    System.debug('strKeyValue ISV partner value--->'+strKeyValue);
                    if(mappartnerGroupingPartnertypeOppAssRule.containsKey(strKeyValue))
                    {
                        mappartnerGroupingPartnertypeOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                    }
                    else
                    {
                        //PartnerGrouping=false;
                        mappartnerGroupingPartnertypeOppAssRule.put(strKeyValue, new List<Opportunity_Assignment_Rule__c>());
                        mappartnerGroupingPartnertypeOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                    }
                    System.debug('mappartnerGroupingPartnertypeOppAssRule For Secondary Allaince field'+mappartnerGroupingPartnertypeOppAssRule);
                }
                else if(oppAssignmnetRule.Partner_Type__c.toLowerCase()==strAlliancePartnerType)
                {
                    if(oppAssignmnetRule.Alliance_Partner__c!= null )
                    {
                       strKeyValue =opp.id+'|'+oppAssignmnetRule.Alliance_Partner__c;
                        if(mapAlliancePartnertypeOppAssRule.containsKey(strKeyValue))
                        {
                            mapAlliancePartnertypeOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                        }else
                        {
                            mapAlliancePartnertypeOppAssRule.put(strKeyValue, new List<Opportunity_Assignment_Rule__c>());
                            mapAlliancePartnertypeOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                        }
                        System.debug('*mapAlliancePartnertypeOppAssRule*--->'+mapAlliancePartnertypeOppAssRule);
                    }
                }
				else if(oppAssignmnetRule.Partner_Type__c.toLowerCase()==strServiceProviderPartnerType)
                {
                    if(oppAssignmnetRule.Service_Provider__c!= null )
                    {
                        strKeyValue =opp.id+'|'+oppAssignmnetRule.Service_Provider__c;
                        if(mapServiceProviderPartnertypeOppAssRule.containsKey(strKeyValue))
                        {
                            mapServiceProviderPartnertypeOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                        }else
                        {
                            mapServiceProviderPartnertypeOppAssRule.put(strKeyValue, new List<Opportunity_Assignment_Rule__c>());
                            mapServiceProviderPartnertypeOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                        }
                        System.debug('*mapServiceProviderPartnertypeOppAssRule*--->'+mapServiceProviderPartnertypeOppAssRule);
                    }
                }
                else if(oppAssignmnetRule.Tier1Tier2_Partner_Name__c !=null )
                {
                    strKeyValue = opp.id+'|'+oppAssignmnetRule.Tier1Tier2_Partner_Name__c;
                    if(mapTier1Tier2PartnerOppAssRule.containsKey(strKeyValue))
                    {
                        mapTier1Tier2PartnerOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                    }
                    else
                    {
                        //Tier12Partner=false;
                        mapTier1Tier2PartnerOppAssRule.put(strKeyValue, new List<Opportunity_Assignment_Rule__c>());
                        mapTier1Tier2PartnerOppAssRule.get(strKeyValue).add(oppAssignmnetRule);
                    }
                }
                //create map for AllPartner type

            }
            System.debug('SCRIPT STATEMENTS EXECUTED 1ST TIME: '+Limits.getScriptStatements());
            System.debug('SCRIPT STATEMENTS CAN EXECUTE 1ST TIME: '+Limits.getLimitScriptStatements());
        }
        System.debug('SCRIPT STATEMENTS EXECUTED 1ST TIME AFTER FOR LOOP: '+Limits.getScriptStatements());
        System.debug('SCRIPT STATEMENTS CAN EXECUTE 1ST TIME AFTER FOR LOOP: '+Limits.getLimitScriptStatements());
        // If the Trigger executed on Update event
        if(isUpdate)
        {   // hold the list of Opportunity_Assignment_Rule__c records
            List<Opportunity_Assignment_Rule__c> lstOppAssignmentRuleTemp = new List<Opportunity_Assignment_Rule__c>();
            OpportunityTeamMember objOppTeamMember = new OpportunityTeamMember();
            // hold the id of user which need to delete from Opportunity team member object
            Set<Id> setOarResourceId = new Set<Id>();
            // hold the id of opprtunity which need to delete from Opportunity team member object
            Set<Id> setOppDeleteIds = new Set<Id>();
            //hold the map of Partner Account with Partner Grouping.
          	Map<id,Account> mapAccountGroupingsData=null;
            List<Id> partnerAccountIds = new List<id>();
            partnerAccountIds.addAll(mapTierPartner.values());
            partnerAccountIds.addAll(mapTire2Partner.values());
            partnerAccountIds.addAll(mapSecondaryAllaincePartnerMap.values());
            partnerAccountIds.addAll(mapPrimaryAllaincePartnerMap.values());
            partnerAccountIds.addAll(serviceProviderPartnerMap.values());
            Map<id,Set<id>> mapOpptyTeamMembertobeDeleted= new Map<Id,Set<id>>();

            mapAccountGroupingsData = new Map<id,Account>
                                    ([Select Grouping__c,Master_Grouping__c,id from Account where id in:partnerAccountIds and Grouping__c!=null]);

         
            for(Opportunity opp: mapOpportunity.values())
            {              
				processOarToRemoveSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,mapAccountGroupingsData,mapTierPartner,opp.Partner__r.Grouping__c,opp.Partner__r.Master_Grouping__c,opp.Partner__c,strNamedPartnerType,mapTier1Tier2PartnerOppAssRule,setOarResourceId);
				processOarToRemoveSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,mapAccountGroupingsData,mapTire2Partner,opp.Tier_2_Partner__r.Grouping__c,opp.Tier_2_Partner__r.Master_Grouping__c,opp.Tier_2_Partner__c,strNamedPartnerType,mapTier1Tier2PartnerOppAssRule,setOarResourceId);
				processOarToRemoveSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,mapAccountGroupingsData,mapPrimaryAllaincePartnerMap,opp.Primary_Alliance_Partner__r.Grouping__c,opp.Primary_Alliance_Partner__r.Master_Grouping__c,opp.Primary_Alliance_Partner__c,strAlliancePartnerType,mapAlliancePartnertypeOppAssRule,setOarResourceId);
				processOarToRemoveSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,mapAccountGroupingsData,mapSecondaryAllaincePartnerMap,opp.Secondary_Alliance_Partner__r.Grouping__c,opp.Secondary_Alliance_Partner__r.Master_Grouping__c,opp.Secondary_Alliance_Partner__c,strAlliancePartnerType,mapAlliancePartnertypeOppAssRule,setOarResourceId);
				processOarToRemoveSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,mapAccountGroupingsData,serviceProviderPartnerMap,opp.Service_Provider__r.Grouping__c,opp.Service_Provider__r.Master_Grouping__c,opp.Service_Provider__c,strServiceProviderPartnerType,mapServiceProviderPartnertypeOppAssRule,setOarResourceId);
				//if no partner is present.
				if(opp.Tier_2_Partner__c==null && opp.Partner__c==null && opp.Primary_Alliance_Partner__c==null && opp.Secondary_Alliance_Partner__c== null && opp.Service_Provider__c==null )
				{
				    lstOppAssignmentRuleTemp = mapAllPartnertypeOppAssRule.get(opp.id );
				    if(lstOppAssignmentRuleTemp != null)
				    {
				       setOarResourceId = Opp_ChannelVisibilityHelper.getResourceIds(lstOppAssignmentRuleTemp, setOarResourceId);
					}
				}             
				//Remove opportunity Owner Id from user set
				if(setOarResourceId.contains(opp.ownerid))
				{
				    setOarResourceId.remove(opp.ownerid);
				}
				mapOpptyTeamMembertobeDeleted.put(opp.id, setOarResourceId);
            }
            Opp_ChannelVisibilityHelper.removeOpportunityTeamMember(mapOpptyTeamMembertobeDeleted);        
        }  
        
        Map<Id,Opportunity> mapOppty = new Map<Id,Opportunity>([Select Id,Country__c, ownerid , Opportunity_Owner__r.FirstName, Opportunity_Owner__r.LastName,
                                     Opportunity_Owner__r.District__c, Opportunity_Owner__r.Country__c,Opportunity_Owner__r.Name,Account.EMC_CLASSIFICATION__c,
                                     Opportunity_Owner__r.Area__c, Opportunity_Owner__r.Theater__c,Opportunity_Owner__r.State,  Sales_Force__c,Opportunity_Owner__r.region__c,
                                     Partner__c,Partner__r.Name,Partner__r.Grouping__c,Partner__r.Master_Grouping__c,Tier_2_Partner__r.Name, Tier_2_Partner__c,Tier_2_Partner__r.Grouping__c,Tier_2_Partner__r.Master_Grouping__c,
                                     Tier_2_Partner_from_Deal_Reg__c,Opportunity_Owner__r.Division__c,Primary_Alliance_Partner__c,
                                     Secondary_Alliance_Partner__c,Primary_Alliance_Partner__r.Grouping__c,Primary_Alliance_Partner__r.Master_Grouping__c,
                                     Secondary_Alliance_Partner__r.Grouping__c,Secondary_Alliance_Partner__r.Master_Grouping__c,
                                     Account.Coverage_Model__c,Account.Customer_Segment__c,Account.EMC_Major_Vertical__c, Account.Theater1__c,
                                     Service_Provider__c,Service_Provider__r.Grouping__c,Service_Provider__r.Master_Grouping__c, Account.BillingState,Account.BillingPostalCode, Account.Grouping__c, Account.BillingCountry, CurrencyIsoCode,
                                     (Select OpportunityAccessLevel, OpportunityId, TeamMemberRole, UserId From OpportunityTeamMembers),
                                     (Select Id, OpportunityId, PricebookEntryId,UnitPrice, PricebookEntry.Product2Id, Quote_Amount__c, Product_Type__c From OpportunityLineItems)                                   
                                   From Opportunity
                                   where Id IN: setOppId]);              
        
        List<Opportunity_Assignment_Rule__c> lstOppAssignmentRuleTemp = new List<Opportunity_Assignment_Rule__c>();
        Map<Id,List<Opportunity_Assignment_Rule__c>> mapTeamOAR = new Map<id,List<Opportunity_Assignment_Rule__c>>();
        Map<id,List<Opportunity_Assignment_Rule__c>> mapOppAssRule =new Map<id,List<Opportunity_Assignment_Rule__c>>();
        List<Opportunity_Assignment_Log__c> lstOppAssignLog = new List<Opportunity_Assignment_Log__c>();
        List<OpportunityShare> lstOppShared= new List<OpportunityShare>();
        List<Detail_Line__c> lstDetailLines = new List<Detail_Line__c>();
        List<OpportunityShare> lstOppShare = new List<OpportunityShare>();
        Map<String, OpportunityTeamMember> mapOppTeamMember = new Map<String,OpportunityTeamMember>();
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<Id> setUserIds = new Set<Id>();
        List<Opportunity_Assignment_Rule__c> lstOppAssignRule = new List<Opportunity_Assignment_Rule__c>();
        OpportunityTeamMember objOppTeamMember = new OpportunityTeamMember();
        Opportunity_Assignment_Log__c objOppAssLog = new Opportunity_Assignment_Log__c();           
        Opportunity_Assignment_Rule__c objOppAssRuleAdded = new Opportunity_Assignment_Rule__c();           
        Set<Id> setOarResourceId = new Set<Id>();
            
        for(Opportunity opp: mapOppty.values())
        {
            //Boolean for tracking if any Named Partner is found for Oppty's with salesforce=ESG then AllPartners should not run.
            List<Opportunity_Assignment_Rule__c> lstOAR= NEW List<Opportunity_Assignment_Rule__c>();
            Boolean namedPartnerFound=False;
            Boolean blnGrouping=false;
            //Check if opportunity contains Primary Alliance partner name
            System.debug('***OPPORTUNITY ID***='+opp.id);
            //Call method to find accurate OAR. for assignment.
            								//Opportunity, LIST<Opportunity_Assignment_Rule__c>, Id, Id, Id, String, MAP<String,LIST<Opportunity_Assignment_Rule__c>>,  MAP<String,OpportunityTeamMember>, LIST<Opportunity_Assignment_Rule__c>, Boolean, Boolean
            processOarToCreateSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,opp.Primary_Alliance_Partner__r.Grouping__c,opp.Primary_Alliance_Partner__r.Master_Grouping__c,opp.Primary_Alliance_Partner__c,strAlliancePartnerType,mapAlliancePartnertypeOppAssRule,mapOppTeamMember,mapTeamOAR,checkRecordFound,blnGrouping,namedPartnerFound);
            processOarToCreateSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,opp.Secondary_Alliance_Partner__r.Grouping__c,opp.Secondary_Alliance_Partner__r.Master_Grouping__c,opp.Secondary_Alliance_Partner__c,strAlliancePartnerType,mapAlliancePartnertypeOppAssRule,mapOppTeamMember,mapTeamOAR,checkRecordFound,blnGrouping,namedPartnerFound);
            processOarToCreateSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,opp.Service_Provider__r.Grouping__c,opp.Service_Provider__r.Master_Grouping__c,opp.Service_Provider__c,strServiceProviderPartnerType,mapServiceProviderPartnertypeOppAssRule,mapOppTeamMember,mapTeamOAR,checkRecordFound,blnGrouping,namedPartnerFound);
            namedPartnerFound=processOarToCreateSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,opp.Partner__r.Grouping__c,opp.Partner__r.Master_Grouping__c,opp.Partner__c,strNamedPartnerType,mapTier1Tier2PartnerOppAssRule,mapOppTeamMember,mapTeamOAR,checkRecordFound,blnGrouping,namedPartnerFound);
            namedPartnerFound=processOarToCreateSalesTeam(opp,lstOppAssignmentRuleTemp,mappartnerGroupingPartnertypeOppAssRule,opp.Tier_2_Partner__r.Grouping__c,opp.Tier_2_Partner__r.Master_Grouping__c,opp.Tier_2_Partner__c,strNamedPartnerType,mapTier1Tier2PartnerOppAssRule,mapOppTeamMember,mapTeamOAR,checkRecordFound,blnGrouping,namedPartnerFound);
            
            System.debug('NamedPartnerFound*--->'+namedPartnerFound);
            if(namedPartnerFound==false)
            {
                if(opp.Tier_2_Partner__c==null && opp.Partner__c==null && opp.Primary_Alliance_Partner__c==null && opp.Secondary_Alliance_Partner__c== null  && opp.Service_Provider__c==null )
                {}
                else
                {
                    lstOppAssignmentRuleTemp = mapAllPartnertypeOppAssRule.get(opp.id);
                    System.debug('mapAllPartnertypeOppAssRule===>'+mapAllPartnertypeOppAssRule);
                    System.debug('lstOppAssignmentRuleTemp FOR ALL PARTNER'+lstOppAssignmentRuleTemp);
                    if(lstOppAssignmentRuleTemp != null)
                    {
                        checkRecordFound = true;
                        for(Opportunity_Assignment_Rule__c objOppAssRule :lstOppAssignmentRuleTemp)
                        {                                    
                            if(objOppAssRule.Resource_Name__c != null)
                            {
                                mapOppTeamMember = Opp_ChannelVisibilityHelper.createOpportunityTeamMember(objOppAssRule, opp, mapOppTeamMember);                                       
                                if(mapOppTeamMember!=null && mapOppTeamMember.size()>0)
                                {
                                    lstOAR.add(objOppAssRule);
                                    if(mapTeamOAR.containsKey(opp.id))
			                        {
			                        	lstOAR.addAll(mapTeamOAR.get(opp.id));
			                        }
                                    mapTeamOAR.put(opp.id,lstOAR);
                                }
                            }                                   
                        }
                    }
                }
            }
            mapOppAssRule.putAll(mapTeamOAR);
            if(mapOppAssRule.size()>0)
            {
                System.debug('mapOppAssRule--->'+mapOppAssRule);
                for(Id opptyId: mapOppAssRule.keySet())
                {
                    objOppAssLog = new Opportunity_Assignment_Log__c();
                    List<Opportunity_Assignment_Rule__c> lstAssignmentRule = mapOppAssRule.get(opptyId);
                    for(Opportunity_Assignment_Rule__c objOppAssRule :lstAssignmentRule)
                    {
                        objOppAssLog.Opportunity__c=opptyId;
                        objOppAssLog.Assignment_Rule__c=objOppAssRule.id;
                        if(checkRecordFound)
                        {                   
                            objOppAssLog.Error_Description__c = System.Label.No_Active_User_For_Assignment;                                     
                        }else
                        {
                            objOppAssLog.Error_Description__c =System.Label.No_User_Found_For_Assignment;
                        }
                        lstOppAssignLog.add(objOppAssLog);
                    }
                }
                System.debug('lstOppAssignLog--->'+lstOppAssignLog);
            }
        }
        System.debug('SCRIPT STATEMENTS EXECUTED 4TH TIME: '+Limits.getScriptStatements());
        System.debug('SCRIPT STATEMENTS CAN EXECUTE 4TH TIME:'+Limits.getLimitScriptStatements());
        if(mapOppTeamMember.size() >0)
        {
            System.debug('*** THE VALUE FO mapOppTeamMember IS***==='+mapOppTeamMember);
            for(OpportunityTeamMember objOppTeamMem : mapOppTeamMember.values())
            {
                lstOppShared.add( new OpportunityShare(OpportunityId = objOppTeamMem.OpportunityId, UserOrGroupId = objOppTeamMem.UserId,   OpportunityAccessLevel='Edit'));
                setOpportunityIds.add(objOppTeamMem.OpportunityId);
                setUserIds.add(objOppTeamMem.UserId);
            }
            System.debug('mapOppAssRule--->**'+mapOppAssRule);
            System.debug('SCRIPT STATEMENTS EXECUTED 5TH TIME: '+Limits.getScriptStatements());
            System.debug('SCRIPT STATEMENTS CAN EXECUTE 5TH TIME: '+Limits.getLimitScriptStatements());           
        }
        
        System.debug('List of  Opportunity share--->' + lstOppShared);
        System.debug('List of Opportunity team Member--->' + mapOppTeamMember);
        System.debug('Set of opportunity ids--->' + setOpportunityIds);
        System.debug('Seo of userids--->' + setUserIds);
        //Create Opportunity line Item and shared record using helper class Opp_ChannelVisibilityHelper CreateTeamMemberAndShareRecord method
        Opp_ChannelVisibilityHelper.CreateTeamMemberAndShareRecord(lstOppShared, mapOppTeamMember, lstOppAssignLog, mapOppAssRule,checkRecordFound,mapOpportunity );
        //Create Detail line item records   
        Opp_ChannelVisibilityHelper.CreateDetailLineItemsRecords(mapOpportunity, setOpportunityIds, setUserIds);
    }
    private static void clearAll(String Partner,Set<String> setPartnerGrouping,Set<Id> setAccountId,Set<Id> setSecondaryAlliancePartnerId,Set<Id> setPrimaryAlliancePartnerId,Set<Id> setServiceProviderId,Set<String> setCountry,Set<String> setCoverageModel,Set<String> setCustomerSegment,Set<String> setPostalCode,Set<String> setState,Set<String> setEMCMajorVertical)
    {
            Partner='';
            setPartnerGrouping.clear();
            setAccountId.clear();
            setSecondaryAlliancePartnerId.clear();
            setPrimaryAlliancePartnerId.clear();
            setServiceProviderId.clear();
            setCountry.clear();
            setCoverageModel.clear();
            setCustomerSegment.clear();
            setPostalCode.clear();
            setState.clear();
            setEMCMajorVertical.clear();
            
    }
    public static boolean processExclusionFound(List<OAR_Exclusion_Condition__c> lstOarExclusion,Opportunity opp) 
    {
        for(integer k=0;k<lstOarExclusion.size();k++)
        {
            //System.debug('lstOarExclusion.size()--->'+lstOarExclusion.size());
            If(lstOarExclusion[k].Opportunity_Assignment_Rule_del__c !=null)
            {
                System.debug('lstOarExclusion[k].OAR_Field_API_Name__c--->'+lstOarExclusion[k].OAR_Field_API_Name__c);
                If (lstOarExclusion[k].OAR_Field_API_Name__c  != null)
                {
                    String[] arrExcludedValue = lstOarExclusion[k].Exclusion_Value__c.split(',');
                    if(lstOarExclusion[k].OAR_Field_API_Name__c =='area__c'|| lstOarExclusion[k].OAR_Field_API_Name__c =='region__c' || lstOarExclusion[k].OAR_Field_API_Name__c=='District__c' || lstOarExclusion[k].OAR_Field_API_Name__c=='Theater__c'
                    ||lstOarExclusion[k].OAR_Field_API_Name__c =='Division__c'  )
                    {
                        for(Integer j=0; j<arrExcludedValue.size(); j++)
                        {   
                            If(Opp.Opportunity_Owner__r.get(lstOarExclusion[k].OAR_Field_API_Name__c) == arrExcludedValue[j])
                            {
                                return true;
                            }
                        }
                    }
                    if(lstOarExclusion[k].OAR_Field_API_Name__c =='BillingPostalCode'||  lstOarExclusion[k].OAR_Field_API_Name__c=='BillingState' || lstOarExclusion[k].OAR_Field_API_Name__c=='BillingCountry'
                        ||lstOarExclusion[k].OAR_Field_API_Name__c=='EMC_Major_Vertical_Account__c'||lstOarExclusion[k].OAR_Field_API_Name__c =='EMC_CLASSIFICATION__c' ||lstOarExclusion[k].OAR_Field_API_Name__c =='Coverage_Model__c'||lstOarExclusion[k].OAR_Field_API_Name__c =='Customer_Segment__c'
                        )
                    {
                        for(Integer j=0; j<arrExcludedValue.size(); j++)
                        {   
                            If(Opp.Account.get(lstOarExclusion[k].OAR_Field_API_Name__c) == arrExcludedValue[j])
                            {
                                return true;
                            }
                        }
                    }
                    if(lstOarExclusion[k].OAR_Field_API_Name__c =='Tier_2_Partner_from_Deal_Reg__c')
                    {
                        for(Integer j=0; j<arrExcludedValue.size(); j++)
                        {
                            If(Opp.get(lstOarExclusion[k].OAR_Field_API_Name__c) == arrExcludedValue[j])
                            {
                                return true;
                            }
                        }
                    }
                }
                if(lstOarExclusion[k].Partner_Grouping_Excluded__c !=null)
                {
                    if(Opp.Partner__r.Grouping__c == lstOarExclusion[k].Partner_Grouping_Excluded__c||Opp.Partner__r.Master_Grouping__c == lstOarExclusion[k].Partner_Grouping_Excluded__c)
                    {
                        return true;
                    }
                    else
                    {
                        if(Opp.Tier_2_Partner__r.Grouping__c == lstOarExclusion[k].Partner_Grouping_Excluded__c||Opp.Tier_2_Partner__r.Master_Grouping__c == lstOarExclusion[k].Partner_Grouping_Excluded__c)
                        {
                           return true;
                        }
                        else
                        {
                            if(Opp.Secondary_Alliance_Partner__r.Grouping__c == lstOarExclusion[k].Partner_Grouping_Excluded__c || Opp.Secondary_Alliance_Partner__r.Master_Grouping__c == lstOarExclusion[k].Partner_Grouping_Excluded__c )
                            {
                                return true;
                            }
                            else
                            {
                                if(Opp.Primary_Alliance_Partner__r.Grouping__c ==lstOarExclusion[k].Partner_Grouping_Excluded__c ||Opp.Primary_Alliance_Partner__r.Master_Grouping__c ==lstOarExclusion[k].Partner_Grouping_Excluded__c )
                                {
                                    return true;
                                }
                                else
                                {
                                    if(Opp.Service_Provider__r.Grouping__c ==lstOarExclusion[k].Partner_Grouping_Excluded__c ||Opp.Service_Provider__r.Master_Grouping__c ==lstOarExclusion[k].Partner_Grouping_Excluded__c)
                                    {
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
                if(lstOarExclusion[k].Account_Look_Up__c!= null)
                {
                    //String[] arrExcludedValue = lstOarExclusion[k].Exclusion_Value__c.split(',');
                    If(Opp.Partner__c == lstOarExclusion[k].Account_Look_Up__c)
                    {
                        return true;
                    }
                    else
                    {
                        If(Opp.Tier_2_Partner__c == lstOarExclusion[k].Account_Look_Up__c)
                        {
                           return true;
                        }
                        else
                        {
                            If(Opp.Primary_Alliance_Partner__c == lstOarExclusion[k].Account_Look_Up__c)
                            {
                                return true;
                            }
                            else
                            {
                                If(Opp.Secondary_Alliance_Partner__c == lstOarExclusion[k].Account_Look_Up__c)
                                {
                                    return true;
                                }
                                else
                                {
                                    If(Opp.Service_Provider__c == lstOarExclusion[k].Account_Look_Up__c)
                                    {
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return false;
    }
    
    public static void processOarToRemoveSalesTeam(Opportunity opp,List<Opportunity_Assignment_Rule__c> lstOppAssignmentRuleTemp,Map<String, List<Opportunity_Assignment_Rule__c>> mappartnerGroupingPartnertypeOppAssRule,  Map<id,Account> mapAccountGroupingsData, Map<Id,Id> mapPartnerAccount,ID partnerGrouping, ID partnerMasterGrouping,ID partnerId,String PartnerType, Map<String,List<Opportunity_Assignment_Rule__c>> mapPartnertypeOppAssRule,Set<Id> setOarResourceId)
    {
        if(mapPartnerAccount.get(opp.Id) != null)
       {
            if(mapAccountGroupingsData.get(mapPartnerAccount.get(opp.Id))  != null)
            {
                ID PartnerAccountGrouping= mapAccountGroupingsData.get(mapPartnerAccount.get(opp.Id)).Grouping__c;
                System.debug('PartnerAccountGrouping-->'+PartnerAccountGrouping);
                //fetch Opportunity_Assignment_Rule__c record where Partner Grouping match
                lstOppAssignmentRuleTemp = mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+PartnerAccountGrouping+ '|' + PartnerType );
                if(lstOppAssignmentRuleTemp!=null && mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+mapAccountGroupingsData.get(mapPartnerAccount.get(opp.Id)).Master_Grouping__c+ '|' + PartnerType)!=null && (partnerMasterGrouping!=mapAccountGroupingsData.get(mapPartnerAccount.get(opp.Id)).Master_Grouping__c))
                {
                    PartnerAccountGrouping= mapAccountGroupingsData.get(mapPartnerAccount.get(opp.Id)).Master_Grouping__c;
                    lstOppAssignmentRuleTemp.addAll(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+PartnerAccountGrouping+ '|' + PartnerType ));
                }
                else if (lstOppAssignmentRuleTemp==null && mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+mapAccountGroupingsData.get(mapPartnerAccount.get(opp.Id)).Master_Grouping__c+ '|' + PartnerType)!=null && (partnerMasterGrouping!=mapAccountGroupingsData.get(mapPartnerAccount.get(opp.Id)).Master_Grouping__c))
                {
                    PartnerAccountGrouping= mapAccountGroupingsData.get(mapPartnerAccount.get(opp.Id)).Master_Grouping__c;
                    lstOppAssignmentRuleTemp=mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+PartnerAccountGrouping+ '|' + PartnerType );
                }
                System.debug('lstOppAssignmentRuleTemp===>INSIDE REMOVE'+lstOppAssignmentRuleTemp);
                if(lstOppAssignmentRuleTemp != null)
                {
                    setOarResourceId = Opp_ChannelVisibilityHelper.getResourceIds(lstOppAssignmentRuleTemp, setOarResourceId);
				}
            }
            System.debug('mapPartnertypeOppAssRule====>'+mapPartnertypeOppAssRule);
            System.debug('mapPartnerAccount.get(opp.Id)===>'+mapPartnerAccount.get(opp.Id)+'***partnerId===>'+partnerId);
            lstOppAssignmentRuleTemp = mapPartnertypeOppAssRule.get(opp.id+'|'+mapPartnerAccount.get(opp.Id));
            System.debug('lstOppAssignmentRuleTemp===>INSIDE REMOVE 2***'+lstOppAssignmentRuleTemp);
            if(lstOppAssignmentRuleTemp!=null)
            {
                setOarResourceId = Opp_ChannelVisibilityHelper.getResourceIds(lstOppAssignmentRuleTemp, setOarResourceId);
			}
            System.debug('SCRIPT STATEMENTS EXECUTED 2ND TIME:  '+Limits.getScriptStatements());
            System.debug('SCRIPT STATEMENTS CAN EXECUTE 2ND TIME:'+Limits.getLimitScriptStatements());
        }
    }
    
    													//Opportunity, LIST<Opportunity_Assignment_Rule__c>, 						,Map<String, List<Opportunity_Assignment_Rule__c>>										,	Id, 					Id, 				Id, 				String, 	MAP<String,LIST<Opportunity_Assignment_Rule__c>>, 							MAP<String,OpportunityTeamMember>, 					LIST<Opportunity_Assignment_Rule__c>, 			Boolean, 				Boolean
    public static Boolean processOarToCreateSalesTeam(Opportunity opp,List<Opportunity_Assignment_Rule__c> lstOppAssignmentRuleTemp,Map<String, List<Opportunity_Assignment_Rule__c>> mappartnerGroupingPartnertypeOppAssRule,  ID partnerGrouping, ID partnerMasterGrouping,ID partnerId,String PartnerType, Map<String,List<Opportunity_Assignment_Rule__c>> mapPartnertypeOppAssRule,Map<String,OpportunityTeamMember> mapOppTeamMember,Map<id,List<Opportunity_Assignment_Rule__c>> mapTeamOAR, Boolean checkRecordFound,Boolean blnGrouping,Boolean namedPartnerFound)
    {
        String strNamedPartnerType = System.Label.NamedPartners_PartnerType.toLowerCase();
        if(partnerId != null )
        {                
            lstOppAssignmentRuleTemp = mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerGrouping + '|' + PartnerType );
            if(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+opp.Primary_Alliance_Partner__r.Master_Grouping__c + '|' + PartnerType )!=null)
            {
            	if(lstOppAssignmentRuleTemp!=null)
                {
                    lstOppAssignmentRuleTemp.addAll(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType ));
                }
                else if(lstOppAssignmentRuleTemp ==null )
                {
                    lstOppAssignmentRuleTemp=mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType );
                }
            }
            if(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+opp.Secondary_Alliance_Partner__r.Master_Grouping__c + '|' + PartnerType )!=null)
            {
            	if(lstOppAssignmentRuleTemp!=null)
                {
                    lstOppAssignmentRuleTemp.addAll(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType ));
                }
                else if(lstOppAssignmentRuleTemp ==null )
                {
                    lstOppAssignmentRuleTemp=mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType );
                }
            }
            if(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+opp.Partner__r.Master_Grouping__c + '|' + PartnerType )!=null)
            {
            	if(lstOppAssignmentRuleTemp!=null)
                {
                    lstOppAssignmentRuleTemp.addAll(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType ));
                }
                else if(lstOppAssignmentRuleTemp ==null )
                {
                    lstOppAssignmentRuleTemp=mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType );
                }
            }
            if(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+opp.Tier_2_Partner__r.Master_Grouping__c + '|' + PartnerType )!=null)
            {
            	if(lstOppAssignmentRuleTemp!=null)
                {
                    lstOppAssignmentRuleTemp.addAll(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType ));
                }
                else if(lstOppAssignmentRuleTemp ==null )
                {
                    lstOppAssignmentRuleTemp=mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType );
                }
            }
            if(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+opp.Service_Provider__r.Master_Grouping__c + '|' + PartnerType )!=null)
            {
            	if(lstOppAssignmentRuleTemp!=null)
                {
                    lstOppAssignmentRuleTemp.addAll(mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType ));
                }
                else if(lstOppAssignmentRuleTemp ==null )
                {
                    lstOppAssignmentRuleTemp=mappartnerGroupingPartnertypeOppAssRule.get(opp.id+'|'+partnerMasterGrouping + '|' + PartnerType );
                }
            }
            System.debug('lstOppAssignmentRuleTemp--->'+lstOppAssignmentRuleTemp);
            if(PartnerType!=strNamedPartnerType)
            {
            	fetchMatchingOAR(opp,lstOppAssignmentRuleTemp,mapOppTeamMember,mapTeamOAR,checkRecordFound,blnGrouping);
            }
            else if(PartnerType==strNamedPartnerType)
            {
            	namedPartnerFound=fetchMatchingOARForNamedPartner(opp,lstOppAssignmentRuleTemp,mapOppTeamMember,mapTeamOAR,checkRecordFound,namedPartnerFound,blnGrouping);
            }
            
            if(blnGrouping!=true)
            {
                lstOppAssignmentRuleTemp = mapPartnertypeOppAssRule.get(opp.id+'|'+partnerId);
                if(PartnerType!=strNamedPartnerType)
                {
                	fetchMatchingOARForAccountId(opp,lstOppAssignmentRuleTemp,mapOppTeamMember,mapTeamOAR,checkRecordFound);	
                }
                else if(PartnerType==strNamedPartnerType)
                {
                	namedPartnerFound=fetchMatchingOARForNamedPartnerWithPartnerGrp(opp,lstOppAssignmentRuleTemp,mapOppTeamMember,mapTeamOAR,checkRecordFound,namedPartnerFound);
                }
            }
            blnGrouping=false;
        }
        return namedPartnerfound;
    }
    public static void fetchMatchingOAR(Opportunity opp,List<Opportunity_Assignment_Rule__c> lstOppAssignmentRuleTemp,  Map<String, OpportunityTeamMember> mapOppTeamMember,Map<Id,List<Opportunity_Assignment_Rule__c>> mapTeamOAR,boolean checkRecordFound ,boolean  blnGrouping)
    {
        if(lstOppAssignmentRuleTemp != null)
        {
            List<Opportunity_Assignment_Rule__c> lstOAR= new List<Opportunity_Assignment_Rule__c>();
            checkRecordFound = true;
            for(Opportunity_Assignment_Rule__c objOppAssRule :lstOppAssignmentRuleTemp)
            {                                    
                if(objOppAssRule.Resource_Name__c != null)
                {
                    mapOppTeamMember = Opp_ChannelVisibilityHelper.createOpportunityTeamMember(objOppAssRule, opp, mapOppTeamMember);                                       
                    blnGrouping=true;
                    if(mapOppTeamMember!=null && mapOppTeamMember.size()>0)
                    {
                        lstOAR.add(objOppAssRule);
                        if(mapTeamOAR.containsKey(opp.id))
                        {
                        	lstOAR.addAll(mapTeamOAR.get(opp.id));
                        }
                        mapTeamOAR.put(opp.id,lstOAR);
                        lstOAR.clear();
                    }
                }
            }
        }
    }
    public static void fetchMatchingOARForAccountId(Opportunity opp,List<Opportunity_Assignment_Rule__c> lstOppAssignmentRuleTemp,  Map<String, OpportunityTeamMember> mapOppTeamMember,Map<id,List<Opportunity_Assignment_Rule__c>> mapTeamOAR,boolean checkRecordFound)
    {
        if(lstOppAssignmentRuleTemp != null)
        {                        
            List<Opportunity_Assignment_Rule__c> lstOAR= new List<Opportunity_Assignment_Rule__c>();
            checkRecordFound = true;
            for(Opportunity_Assignment_Rule__c objOppAssRule :lstOppAssignmentRuleTemp)
            {       
                if(objOppAssRule.Resource_Name__c !=null)
                {
                    if(objOppAssRule.Resource_Name__r.IsActive)
                    {
                        mapOppTeamMember = Opp_ChannelVisibilityHelper.createOpportunityTeamMember(objOppAssRule, opp, mapOppTeamMember);
                        if(mapOppTeamMember!=null && mapOppTeamMember.size()>0)
                        {
                            lstOAR.add(objOppAssRule);
                            if(mapTeamOAR.containsKey(opp.id))
	                        {
	                        	lstOAR.addAll(mapTeamOAR.get(opp.id));
	                        }
                        	mapTeamOAR.put(opp.id,lstOAR);
                        	lstOAR.clear();
                        }
                    }
                }
            }
        }
    }
    public static Boolean fetchMatchingOARForNamedPartner(Opportunity opp,List<Opportunity_Assignment_Rule__c> lstOppAssignmentRuleTemp,  Map<String, OpportunityTeamMember> mapOppTeamMember,Map<Id,List<Opportunity_Assignment_Rule__c>> mapTeamOAR,boolean checkRecordFound,boolean namedPartnerFound,boolean blnGrouping)
    {
        if(lstOppAssignmentRuleTemp != null)
        {
            checkRecordFound = true;
            List<Opportunity_Assignment_Rule__c> lstOAR= new List<Opportunity_Assignment_Rule__c>();
            System.debug('***INSIDE METHOD fetchMatchingOARForNamedPartner'+lstOppAssignmentRuleTemp);
            System.debug('***mapOppTeamMember INSIDE FETCHMATCHINGOARFORNAMEDPARTNER***==='+mapOppTeamMember);
            for(Opportunity_Assignment_Rule__c objOppAssRule :lstOppAssignmentRuleTemp)
            {                                    
                if(objOppAssRule.Resource_Name__c != null)
                {
                    mapOppTeamMember = Opp_ChannelVisibilityHelper.createOpportunityTeamMember(objOppAssRule, opp, mapOppTeamMember);                                       
                    System.debug('***mapOppTeamMember INSIDE FETCHMATCHINGOARFORNAMEDPARTNER 222***==='+mapOppTeamMember);
            		blnGrouping=true;
                    if(mapOppTeamMember!=null && mapOppTeamMember.size()>0)
                    {
                        lstOAR.add(objOppAssRule);
                        if(mapTeamOAR.containsKey(opp.id))
                        {
                        	lstOAR.addAll(mapTeamOAR.get(opp.id));
                        }
                        mapTeamOAR.put(opp.id,lstOAR);
                    }
                    if(opp.Sales_Force__c=='ESG')
                    {
                        namedPartnerFound=true;
                    }
                } 
                lstOAR.clear();                                   
            }
        }
        return namedPartnerFound;
    }
    public static Boolean fetchMatchingOARForNamedPartnerWithPartnerGrp(Opportunity opp,List<Opportunity_Assignment_Rule__c> lstOppAssignmentRuleTemp,  Map<String, OpportunityTeamMember> mapOppTeamMember,Map<Id,List<Opportunity_Assignment_Rule__c>> mapTeamOAR,boolean checkRecordFound,boolean namedPartnerFound)
    {
        if(lstOppAssignmentRuleTemp!=null)
        {
            List<Opportunity_Assignment_Rule__c> lstOAR= new List<Opportunity_Assignment_Rule__c>();
            checkRecordFound = true;
            for(Opportunity_Assignment_Rule__c objOppAssRule :lstOppAssignmentRuleTemp)
            {                                    
                if(objOppAssRule.Resource_Name__c != null)
                {
                    mapOppTeamMember = Opp_ChannelVisibilityHelper.createOpportunityTeamMember(objOppAssRule, opp, mapOppTeamMember);                                       
                    if(mapOppTeamMember!=null && mapOppTeamMember.size()>0)
                    {
                        lstOAR.add(objOppAssRule);
                        if(mapTeamOAR.containsKey(opp.id))
                        {
                        	lstOAR.addAll(mapTeamOAR.get(opp.id));
                        }
                        mapTeamOAR.put(opp.id,lstOAR);
                    }
                    if(opp.Sales_Force__c=='ESG')
                    {
                        namedPartnerFound=true;
                    }
                }
                lstOAR.clear();                                   
            }
        }
        return namedPartnerFound;
     }
     public static Map<id,Opportunity_Assignment_Rule__c> mapOppAssignmentRuleRecords (Map<Id,Opportunity> mapOpportunity,Map<Id,Id> mapPartner,Map <id,Opportunity_Assignment_Rule__c> mapOppAssignmentRule, Boolean isUpdate,String Partner)
     {
        //Declare variable 
        String query='';
        String strconditions ='';
        List<Opportunity_Assignment_Rule__c> lstOppAssRule= new List<Opportunity_Assignment_Rule__c>();
        //hold the countries of opportunity
        Set<String> setCountry  = new Set<String>(); 
        //hold the State of opportunity
        Set<String> setState  = new Set<String>(); 
        //hold the Postal Code of opportunity
        Set<String> setPostalCode =new Set<String>(); 
        //hold the Customer Segment of opportunity
        Set<String> setCustomerSegment  = new Set<String>(); 
        //hold the Coverage Model of opportunity
        Set<String> setSalesforce  = new Set<String>(); 
        //hold the Salesforce of opportunity
        Set<String> setCoverageModel  = new Set<String>(); 
        //hold the EMC Major Vertical
        Set<String> setEMCMajorVertical = new Set<String>();
        //hold the Partner Grouping of opportunity
        Set<String> setPartnerGrouping  = new Set<String>();
        //hold the Account id of opportunity
        Set<Id> setAccountId  = new Set<Id>(); 
        //hold the id of service provider partner type.
        Set<Id> setServiceProviderId = new Set<id>();
        //holds the Id of Secondary Alliance Partner Type.
        Set<Id> setSecondaryAlliancePartnerId= new Set<Id>(); 
        //holds the id of Primary Alliance Partner Type.
        Set<Id> setPrimaryAlliancePartnerId= new Set<id>();
        //Fetch all custom label values
        String strAllPartnerType = System.Label.AllPartners_PartnerType.toLowerCase();
        String strNamedPartnerType = System.Label.NamedPartners_PartnerType.toLowerCase();
        String strAlliancePartnerType = System.Label.Alliance_PartnerType.toLowerCase();
        String strServiceProviderPartnerType = System.Label.Service_Provider.toLowerCase();
        List<House_Account_For_OAR__c> lstHouseAccnt = House_Account_For_OAR__c.getAll().values();
        System.debug('mapPartner==='+mapPartner);
        for(Id partnerId: mapPartner.keySet())
        {
            System.debug('Entered mapPartner map'+mapPartner);
            Opportunity opp = mapOpportunity.get(partnerId);
            System.debug('opp--->'+opp);
            if(opp.AccountId != null)
            {
                if(opp.Account.BillingCountry != null) setCountry.add(opp.Account.BillingCountry);
                if(opp.Account.BillingState != null) setState.add(opp.Account.BillingState);
                if(opp.Account.BillingPostalCode != null) setPostalCode.add(opp.Account.BillingPostalCode);
                if(opp.Account.Customer_Segment__c != null) setCustomerSegment.add(opp.Account.Customer_Segment__c);
                if(opp.Account.Coverage_Model__c != null) setCoverageModel.add(opp.Account.Coverage_Model__c);
                if(opp.Account.EMC_Major_Vertical__c != null)setEMCMajorVertical.add(opp.Account.EMC_Major_Vertical__c);
            }
            System.debug('opp==='+opp+'opp.Primary_Alliance_Partner__r.Grouping__c==='+opp.Primary_Alliance_Partner__r.Grouping__c);
            System.debug('setCountry==='+setCountry);
            if(opp.Partner__c!=null)
            {
                if(opp.Partner__r.Grouping__c !=null)setPartnerGrouping.add(opp.Partner__r.Grouping__c);
                if(opp.Partner__r.Master_Grouping__c !=null)setPartnerGrouping.add(opp.Partner__r.Master_Grouping__c);
                if(opp.Partner__c!=null)setAccountId.add(opp.Partner__c);
            }
            if(opp.Tier_2_Partner__c!=null)
            {
                if(opp.Tier_2_Partner__r.Grouping__c !=null)setPartnerGrouping.add(opp.Tier_2_Partner__r.Grouping__c);
                if(opp.Tier_2_Partner__r.Master_Grouping__c !=null)setPartnerGrouping.add(opp.Tier_2_Partner__r.Master_Grouping__c);
                if(opp.Tier_2_Partner__c!=null)setAccountId.add(opp.Tier_2_Partner__c);
            }
            if(opp.Primary_Alliance_Partner__c!=null)
            {
                if(opp.Primary_Alliance_Partner__r.Grouping__c !=null)setPartnerGrouping.add(opp.Primary_Alliance_Partner__r.Grouping__c);
                if(opp.Primary_Alliance_Partner__r.Master_Grouping__c !=null)setPartnerGrouping.add(opp.Primary_Alliance_Partner__r.Master_Grouping__c);
                if(opp.Primary_Alliance_Partner__c != null) setPrimaryAlliancePartnerId.add(opp.Primary_Alliance_Partner__c);
            }
            if(opp.Secondary_Alliance_Partner__c!=null)
            {
                if(opp.Secondary_Alliance_Partner__r.Grouping__c !=null)setPartnerGrouping.add(opp.Secondary_Alliance_Partner__r.Grouping__c);
                if(opp.Secondary_Alliance_Partner__r.Master_Grouping__c !=null)setPartnerGrouping.add(opp.Secondary_Alliance_Partner__r.Master_Grouping__c);
                if(opp.Secondary_Alliance_Partner__c != null) setPrimaryAlliancePartnerId.add(opp.Secondary_Alliance_Partner__c);
            }
            if(opp.Service_Provider__c!=null)
            {
                if(opp.Service_Provider__r.Grouping__c !=null)setPartnerGrouping.add(opp.Service_Provider__r.Grouping__c);
                if(opp.Service_Provider__r.Master_Grouping__c !=null)setPartnerGrouping.add(opp.Service_Provider__r.Master_Grouping__c);
                if(opp.Service_Provider__c != null) setServiceProviderId.add(opp.Service_Provider__c);
            }
        }
        System.debug('setPartnerGrouping==='+setPartnerGrouping);
        if(isUpdate)
        {
            List<Account> PartnerAccountGrouping =new List<Account> 
                                        ([Select Grouping__c,Master_Grouping__c,id from Account where Grouping__c!=null and (id in:mapPartner.values()) ]);
            System.debug('The value of opportunity in dynamic query is mapOpportunity--->'+mapOpportunity);
            for(Opportunity opp: mapOpportunity.values())
            {
                if(mapPartner.get(opp.Id)  != null)setAccountId.add(mapPartner.get(opp.Id));
                if(mapPartner.get(opp.Id)  != null)setPrimaryAlliancePartnerId.add(mapPartner.get(opp.Id));
                if(mapPartner.get(opp.Id)  != null)setServiceProviderId.add(mapPartner.get(opp.Id));
            }
            for(Integer i=0;i<PartnerAccountGrouping.size();i++)
            {
                if(PartnerAccountGrouping[i].Grouping__c  != null)setPartnerGrouping.add(PartnerAccountGrouping[i].Grouping__c);
                if(PartnerAccountGrouping[i].Master_Grouping__c  != null)setPartnerGrouping.add(PartnerAccountGrouping[i].Master_Grouping__c);
            }
       }
        
        
        query='Select Id, Name, OwnerId, ResourceTheatre__c, ResourceState__c, ResourceRegion__c, ResourceDivision__c, ResourceDistrict__c, '+
        'ResourceCountry__c, ResourceArea__c ,Resource_Title__c,Active__c,Resource_Active__c, Resource_Name__c, Resource_Name__r.Name, Resource_Name__r.IsActive,'+
        'Resource_Name__r.Role__c,Copy_Resource_Attributes__c,Name_Account_Owner__c,Name_Account_Owner__r.Name,Coverage_Model__c,Customer_Segment__c,Partner_Type__c,Alliance_Partner__c,'+
        'ResourceAccountTheater__c,EMC_Major_Vertical_Account__c, Resource_Forecast_Group__c, Resource_Opportunity_Sales_Team_Role__c, Resource_Sales_Force__c,EMC_CLASSIFICATION__c, Partner_Grouping__c,'+
        'Expression_Oar__c,Apply_to_House_Account__c,Overwrite_the_Account_Owner__c, Zip_Postal_Code_Low_Range__c,Zip_Postal_Code_List__c,Zip_Postal_Code_High_Range__c ,Service_Provider__c,Tier1Tier2_Partner_Name__c ,'+
        '(Select Name, OAR_Field_API_Name__c, Opportunity_Assignment_Rule_del__c, Exclusion_Value__c, Partner_Grouping_Excluded__c, Account_Look_Up__c From OAR_Exclusion_Conditions__r)'+
        'From    Opportunity_Assignment_Rule__c ';
        
        String strNo='\''+'NO'+'\'';
        if(Partner==strNamedPartnerType)
        {
            //Partner='\''+Partner+'\'';
            
            if(setPostalCode.size()>0)
            {
                strconditions=' ((Resource_Name__c !=null AND Partner_Type__c =:Partner and Active__c=true and Resource_Active__c !='+strNo+' ) and (Partner_Grouping__c in:setPartnerGrouping or Tier1Tier2_Partner_Name__c in:setAccountId ) and ((ResourceCountry__c in:setCountry OR ResourceCountry__c = null)AND (EMC_Major_Vertical_Account__c in:setEMCMajorVertical OR EMC_Major_Vertical_Account__c = null) AND(Customer_Segment__c in:setCustomerSegment OR Customer_Segment__c = null )AND(Coverage_Model__c in:setCoverageModel OR Coverage_Model__c = null'+ 
                                    ')AND(Zip_Postal_Code_List__c in: setPostalCode OR Zip_Postal_Code_List__c = null) AND(Zip_Postal_Code_Low_Range__c <=: setPostalCode OR Zip_Postal_Code_Low_Range__c = null) AND(Zip_Postal_Code_High_Range__c >=: setPostalCode OR Zip_Postal_Code_High_Range__c = null)  )) limit 10000';
            
            }
            else
            {
                strconditions='((Resource_Name__c !=null AND Partner_Type__c =:Partner and Active__c=true and Resource_Active__c!='+strNo+') and (Partner_Grouping__c in:setPartnerGrouping or Tier1Tier2_Partner_Name__c in:setAccountId) and ((ResourceCountry__c in:setCountry OR ResourceCountry__c = null)AND (EMC_Major_Vertical_Account__c in:setEMCMajorVertical OR EMC_Major_Vertical_Account__c = null) AND(Customer_Segment__c in:setCustomerSegment OR Customer_Segment__c = null )AND(Coverage_Model__c in:setCoverageModel OR Coverage_Model__c = null'+
                                    +'))) limit 10000'; 
            }
            query += ' where ' + strconditions;
        }
        System.debug('Partner==='+Partner);
        if(Partner==strAlliancePartnerType)
        {
            //Partner='\''+Partner+'\'';
            if(setPostalCode.size()>0)
            {
                System.debug('strAlliancePartnerType==='+strAlliancePartnerType);
                strconditions=' ((Resource_Name__c !=null AND Partner_Type__c =:Partner and Active__c=true and Resource_Active__c !='+strNo+' ) and (Partner_Grouping__c in:setPartnerGrouping or Alliance_Partner__c in:setPrimaryAlliancePartnerId) and ((ResourceCountry__c in:setCountry OR ResourceCountry__c = null)AND(Customer_Segment__c in:setCustomerSegment OR Customer_Segment__c = null )AND (EMC_Major_Vertical_Account__c in:setEMCMajorVertical OR EMC_Major_Vertical_Account__c = null) AND(Coverage_Model__c in:setCoverageModel OR Coverage_Model__c = null'
                                    +')AND(Zip_Postal_Code_List__c in: setPostalCode OR Zip_Postal_Code_List__c = null) AND(Zip_Postal_Code_Low_Range__c <=: setPostalCode OR Zip_Postal_Code_Low_Range__c = null) AND(Zip_Postal_Code_High_Range__c >=: setPostalCode OR Zip_Postal_Code_High_Range__c = null)  )) limit 10000';
            }
            else
            {
                strconditions='((Resource_Name__c !=null AND Partner_Type__c =:Partner and Active__c=true and Resource_Active__c !='+strNo+') and (Partner_Grouping__c in:setPartnerGrouping or Alliance_Partner__c in:setPrimaryAlliancePartnerId) and ((ResourceCountry__c in:setCountry OR ResourceCountry__c = null)AND(Customer_Segment__c in:setCustomerSegment OR Customer_Segment__c = null )AND (EMC_Major_Vertical_Account__c in:setEMCMajorVertical OR EMC_Major_Vertical_Account__c = null) AND(Coverage_Model__c in:setCoverageModel OR Coverage_Model__c = null'
                                    +'))) limit 10000'; 
            }
            query += ' where ' + strconditions;
            System.debug('The value of query string is'+query);
        }
        if(Partner==strServiceProviderPartnerType)
        {
            //Partner='\''+Partner+'\'';
            if(setPostalCode.size()>0)
            {
                strconditions=' ((Resource_Name__c !=null AND Partner_Type__c =:Partner  and Active__c=true and Resource_Active__c !='+strNo+' ) and (Partner_Grouping__c in:setPartnerGrouping or Service_Provider__c in:setServiceProviderId) and ((ResourceCountry__c in:setCountry OR ResourceCountry__c = null)AND (EMC_Major_Vertical_Account__c in:setEMCMajorVertical OR EMC_Major_Vertical_Account__c = null)AND(Customer_Segment__c in:setCustomerSegment OR Customer_Segment__c = null )AND(Coverage_Model__c in:setCoverageModel OR Coverage_Model__c = null'
                                    +')AND(Zip_Postal_Code_List__c in: setPostalCode OR Zip_Postal_Code_List__c = null) AND(Zip_Postal_Code_Low_Range__c <=: setPostalCode OR Zip_Postal_Code_Low_Range__c = null) AND(Zip_Postal_Code_High_Range__c >=: setPostalCode OR Zip_Postal_Code_High_Range__c = null)  )) limit 10000';
            }
            else
            {
                strconditions='((Resource_Name__c !=null AND Partner_Type__c =:Partner and Active__c=true and Resource_Active__c !='+strNo+') and (Partner_Grouping__c in:setPartnerGrouping or Service_Provider__c in:setServiceProviderId) and ((ResourceCountry__c in:setCountry OR ResourceCountry__c = null)AND (EMC_Major_Vertical_Account__c in:setEMCMajorVertical OR EMC_Major_Vertical_Account__c = null)AND(Customer_Segment__c in:setCustomerSegment OR Customer_Segment__c = null )AND(Coverage_Model__c in:setCoverageModel OR Coverage_Model__c = null'
                                    +'))) limit 10000'; 
            }
            query += ' where ' + strconditions;
            
            System.debug('The value of query string is'+query);
        }
        if(Partner==strAllPartnerType)
        {
            for(Opportunity opp : mapOpportunity.values())
            {
                if(opp.AccountId != null)
                {
                    if(opp.Account.BillingCountry != null) setCountry.add(opp.Account.BillingCountry);
                    if(opp.Account.BillingState != null) setState.add(opp.Account.BillingState);
                    if(opp.Account.BillingPostalCode != null) setPostalCode.add(opp.Account.BillingPostalCode);
                    if(opp.Account.Customer_Segment__c != null) setCustomerSegment.add(opp.Account.Customer_Segment__c);
                    if(opp.Account.Coverage_Model__c != null) setCoverageModel.add(opp.Account.Coverage_Model__c);
                    //Updated for Production fix on All Partners.07.04.2012.
                    if(opp.Account.EMC_Major_Vertical__c != null)setEMCMajorVertical.add(opp.Account.EMC_Major_Vertical__c);
                }
                if(opp.Sales_Force__c != null) setSalesforce.add(opp.Sales_Force__c);
            }
            System.debug('setCountry===>'+setCountry);
            if(setPostalCode.size()>0)
            {
                strconditions=' ((Resource_Name__c !=null AND Partner_Type__c =:Partner and Active__c=true and Resource_Active__c !='+strNo+' ) and ((ResourceCountry__c in:setCountry OR ResourceCountry__c = null)AND (EMC_Major_Vertical_Account__c in:setEMCMajorVertical OR EMC_Major_Vertical_Account__c = null)AND(Customer_Segment__c in:setCustomerSegment OR Customer_Segment__c = null )AND(Coverage_Model__c in:setCoverageModel OR Coverage_Model__c = null'
                                    +')AND(Zip_Postal_Code_List__c in: setPostalCode OR Zip_Postal_Code_List__c = null) AND(Zip_Postal_Code_Low_Range__c <=: setPostalCode OR Zip_Postal_Code_Low_Range__c = null) AND(Zip_Postal_Code_High_Range__c >=: setPostalCode OR Zip_Postal_Code_High_Range__c = null)AND (Resource_Sales_Force__c in:setSalesforce OR Resource_Sales_Force__c=NULL)  )) limit 10000';
            }
            else
            {
                strconditions='((Resource_Name__c !=null AND Partner_Type__c =:Partner   and Active__c=true and Resource_Active__c !='+strNo+')  and ((ResourceCountry__c in:setCountry OR ResourceCountry__c = null)AND (EMC_Major_Vertical_Account__c in:setEMCMajorVertical OR EMC_Major_Vertical_Account__c = null)AND(Customer_Segment__c in:setCustomerSegment OR Customer_Segment__c = null )AND(Coverage_Model__c in:setCoverageModel OR Coverage_Model__c = null'
                                    +'))) limit 10000'; 
            } 
            query += ' where ' + strconditions;
            System.debug('The value of query string for ALL PARTNERS is'+query);
        }
        lstOppAssRule=Database.query(query);
        System.debug('lstOppAssRule----> Inside query main method'+lstOppAssRule);
        if(lstOppAssRule.size()>0 && lstOppAssRule!=null)
        {
            System.debug('lstOppAssRule----> Inside query main method'+lstOppAssRule);
            for(Opportunity_Assignment_Rule__c oppAssRule:lstOppAssRule)
            {
                mapOppAssignmentRule.put(oppAssRule.id, oppAssRule);
                System.debug('mapOppAssignmentRule--->'+mapOppAssignmentRule);
            }
        }
        clearAll(Partner,setPartnerGrouping,setAccountId,setSecondaryAlliancePartnerId,setPrimaryAlliancePartnerId,setServiceProviderId,setCountry,setCustomerSegment,setCoverageModel,setPostalCode,setState,setEMCMajorVertical);
        return mapOppAssignmentRule;
     }
}