/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       	DEVELOPER     DESCRIPTION                               
 |  ====       	=========     =========== 
 | 06.09.2011	Shipra Misra  Oppty OAR:  Trigger OAR when Account Owner changes from any House Account to a real user.
 | 16.12.2011	Shipra Misra  Channel Visibility-- Fire OAR for owner change only if Rep has valid F.G.
 | 27.02.2012	Shipra Misra  Fixed Zip-Code issue for Account owner changes. 
+===========================================================================*/


public class Opp_UpdateOwner 
{
	//Declaring variable. 
	Set<String> setCountry= new Set<String>();
	Set<String> setState= new Set<String>();
	ID KeyValue;
	Map<Id,Opportunity_Assignment_Rule__c> mapZipPostalRangeOppAssRule= new Map<Id,Opportunity_Assignment_Rule__c>();
	Map<Id,Opportunity_Assignment_Rule__c> mapZipPostalOppAssRule= new Map<Id,Opportunity_Assignment_Rule__c>();
	Map<Id,Opportunity_Assignment_Rule__c> mapStateOppAssRule= new Map<Id,Opportunity_Assignment_Rule__c>();
	Map<Id,Opportunity_Assignment_Rule__c> mapCountryOppAssRule= new Map<Id,Opportunity_Assignment_Rule__c>();
	Map<Id,Opportunity_Assignment_Rule__c> mapTheaterOppAssRule= new Map<Id,Opportunity_Assignment_Rule__c>();
	Map<String,Special_Forecast_Groups__c>  mapSpecial_Forecast_Groups = Special_Forecast_Groups__c.getAll();
	String strAllPartnerType = System.Label.AllPartners_PartnerType.toLowerCase();
    String strNamedPartnerType = System.Label.NamedPartners_PartnerType.toLowerCase();
    String strOutsourcerPartnerType = System.Label.GlobalPartner_PartnerType.toLowerCase();
    String strAlliancePartnerType = System.Label.Alliance_PartnerType.toLowerCase();
    String strServiceProviderPartnerType = System.Label.Service_Provider.toLowerCase();
    //Hold Boolean for exclusion on OAR found.
    Boolean ExclusionFound=false;
        
	public map<id,Opportunity_Assignment_Rule__c> updateAccountOwner (map <Id,Opportunity> mapOpptyHouseAccount,map<id,Opportunity_Assignment_Rule__c> mapOppIdResourceId)
	{
		 //fetch all opportunity using opportunity Ids into list lstOpportunity
        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([Select Id,Country__c, ownerid , Opportunity_Owner__r.FirstName, Opportunity_Owner__r.LastName,
                                     AccountId,Opportunity_Owner__r.District__c, Opportunity_Owner__r.Country__c,Opportunity_Owner__r.Name,Account.EMC_CLASSIFICATION__c,
                                     Opportunity_Owner__r.Area__c, Opportunity_Owner__r.Theater__c,Opportunity_Owner__r.State,  Sales_Force__c,Opportunity_Owner__r.region__c,
                                     Partner__c,Partner__r.Name,Partner__r.Grouping__c,Partner__r.Master_Grouping__c,Tier_2_Partner__r.Name, Tier_2_Partner__c,Tier_2_Partner__r.Grouping__c,Tier_2_Partner__r.Master_Grouping__c,
                                     Tier_2_Partner_from_Deal_Reg__c,Opportunity_Owner__r.Division__c,Primary_Alliance_Partner__c,Primary_Alliance_Partner__r.Grouping__c,Primary_Alliance_Partner__r.Master_Grouping__c,
                                     Secondary_Alliance_Partner__c,Secondary_Alliance_Partner__r.Grouping__c,Secondary_Alliance_Partner__r.Master_Grouping__c,
                                     Account.Coverage_Model__c,Account.EMC_Major_Vertical__c,Account.Customer_Segment__c, Account.Theater1__c,
                                     Service_Provider__c,Service_Provider__r.Grouping__c,Service_Provider__r.Master_Grouping__c, Account.BillingState,Account.BillingPostalCode, Account.Grouping__c, Account.BillingCountry, CurrencyIsoCode,
                                     (Select OpportunityAccessLevel, OpportunityId, TeamMemberRole, UserId From OpportunityTeamMembers),
                                     (Select Id, OpportunityId, PricebookEntryId,UnitPrice, PricebookEntry.Product2Id, Quote_Amount__c, Product_Type__c From OpportunityLineItems)                                   
                                   From Opportunity
                                   where Id IN: mapOpptyHouseAccount.keySet()]); 
        Set<id> setAccId=new Set<id>();
        for(Opportunity oppAccId:mapOpptyHouseAccount.values())
        {
        	setAccId.add(oppAccId.AccountId);
        	setAccId.add(oppAccId.Partner__c);
        	setAccId.add(oppAccId.Tier_2_Partner__c);
        	setAccId.add(oppAccId.Secondary_Alliance_Partner__c);
        	setAccId.add(oppAccId.Primary_Alliance_Partner__c);
        	setAccId.add(oppAccId.Service_Provider__c);
        }
        
        System.debug('mapOpptyHouseAccount===>***'+mapOpptyHouseAccount);
        Map<Id,Account> mapaccnt= new Map<Id,Account>([Select Id,EMC_CLASSIFICATION__c,Coverage_Model__c,Customer_Segment__c, Theater1__c,
                                      BillingState,BillingPostalCode, Grouping__c,EMC_Major_Vertical__c, Master_Grouping__c,BillingCountry, CurrencyIsoCode from Account where id in:setAccId]);
		for(Account acc: mapaccnt.values())
	    {
	        if(acc.Id != null)
		    {
		        if(acc.BillingCountry != null) setCountry.add(acc.BillingCountry);
		        if(acc.BillingState != null) setState.add(acc.BillingState);
		        //if(opp.Account.BillingPostalCode != null) setPostalCode.add(opp.Account.BillingPostalCode);
		    }
	    }
	    System.debug('setCountry===>'+setCountry);
	    System.debug('sets'+setCountry+setState);
    	Map<Id,Opportunity_Assignment_Rule__c> MapOarWithOverwriteAccountOwner = new Map<Id,Opportunity_Assignment_Rule__c>([Select o.Zip_Postal_Code_Low_Range__c, o.Zip_Postal_Code_List__c, o.Zip_Postal_Code_High_Range__c, 
   									o.Tier2_PartnerName_DealReg__c, o.Tier1Tier2_Partner_Name__c, o.Technology_Partner_Name__c, o.SystemModstamp, o.Service_Provider__c, o.Resource_Title__c, o.Resource_Sales_Force__c,
   									o.Resource_Opportunity_Sales_Team_Role__c, o.Resource_Name__c, o.Resource_Forecast_Group__c, o.Resource_Active__c, o.ResourceTheatre__c, o.ResourceState__c, o.ResourceRegion__c, 
   									o.ResourceDivision__c, o.ResourceDistrict__c, o.ResourceCountry__c, o.ResourceArea__c, o.ResourceAccountTheater__c, o.Partner_Type__c, o.Partner_Grouping__c, o.OwnerId, o.Overwrite_the_Account_Owner__c, 
   									o.Name_Account_Owner__c,o.EMC_Major_Vertical_Account__c,o.Name, o.Id,  o.Expression_Oar__c, o.EMC_Classification__c,o.Alliance_Partner__c,o.Customer_Segment__c, o.CurrencyIsoCode, o.Coverage_Model__c, o.Copy_Resource_Attributes__c, 
   									o.Assignment_Grouping__c, o.Apply_to_House_Account__c, o.Active__c,(Select Name, OAR_Field_API_Name__c, Opportunity_Assignment_Rule_del__c, Exclusion_Value__c, Partner_Grouping_Excluded__c, 
   									Account_Look_Up__c From OAR_Exclusion_Conditions__r) From Opportunity_Assignment_Rule__c o where
   									o.Overwrite_the_Account_Owner__c=true and o.Apply_to_House_Account__c=true and o.Active__c=true and o.Resource_Active__c!='NO' and ((o.ResourceCountry__c in: setCountry) or (o.ResourceState__c in: setState)) limit 10000]);
		
	
	
		
		System.debug(mapOpptyHouseAccount.values());
		for(Opportunity opp: mapOpptyHouseAccount.values())
		{
			
				//Instantiating the boolean value to false for each opportunity which is House Account Owned to false.
			   System.debug('opp--->'+opp);
			   String mat='';
			   if(mapaccnt.get(opp.Accountid).Theater1__c!=null)
			   {
				mat=mat+'accounttheater'+mapaccnt.get(opp.Accountid).Theater1__c.toLowerCase()+'accounttheater'+',';
			   }
				if(mapaccnt.get(opp.Accountid).BillingCountry!=null)
			   {
				mat=mat+'country'+mapaccnt.get(opp.Accountid).BillingCountry.toLowerCase()+'country'+',';
			   }
			   if(mapaccnt.get(opp.Accountid).BillingState!=null)
			   {
				mat=mat+'state'+mapaccnt.get(opp.Accountid).BillingState.toLowerCase()+'state'+',';
			   }
			   if(mapaccnt.get(opp.Accountid).Coverage_Model__c!=null)
			   {
				mat=mat+'coveragemodel'+mapaccnt.get(opp.Accountid).Coverage_Model__c.toLowerCase()+'coveragemodel'+',';
			   }
			   if(mapaccnt.get(opp.Accountid).Customer_Segment__c!=null)
			   {
				mat=mat+'customersegment'+mapaccnt.get(opp.Accountid).Customer_Segment__c.toLowerCase()+'customersegment'+',';
			   }
			   if(mapaccnt.get(opp.Accountid).EMC_Major_Vertical__c!=null)
	           {
	               mat=mat+'emcmajorvertical'+mapaccnt.get(opp.Accountid).EMC_Major_Vertical__c.toLowerCase()+'emcmajorvertical'+',';
	           }
               if(mapaccnt.get(opp.Accountid).EMC_CLASSIFICATION__c!=null)
			   {
				mat=mat+'classification'+mapaccnt.get(opp.Accountid).EMC_CLASSIFICATION__c.toLowerCase()+'classification'+',';
			   }
			   if(opp.Sales_Force__c!=null)
			   {
				mat=mat+'salesforce'+opp.Sales_Force__c.toLowerCase()+'salesforce'+',';
			   }
			   mat=mat.substring(0, mat.length()-1);
			   //Looping on each OAR
			   for(Opportunity_Assignment_Rule__c oarMatch:MapOarWithOverwriteAccountOwner.values())
			   {
					Boolean ZipCodeFound=false;Boolean expressionMatch=false;
					ExclusionFound=false;
					List<OAR_Exclusion_Condition__c> lstOarExclusion= oarMatch.OAR_Exclusion_Conditions__r;
					System.debug('oarMatch--->'+oarMatch);
					if(lstOarExclusion.size()>0 && lstOarExclusion!=null)
					{
						//opp.account.Theater1__c=mapaccnt.get(opp.Accountid).Theater1__c;
						ExclusionFound=processExclusionFound(lstOarExclusion,opp, mapaccnt.get(opp.Accountid));
						if(ExclusionFound)
						continue;
					}
					if( !(mapSpecial_Forecast_Groups.containskey(oarMatch.Resource_Forecast_Group__c) && mapSpecial_Forecast_Groups.get(oarMatch.Resource_Forecast_Group__c).Ownership_Allowed__c) )
	               {
	                    continue;  	
	               }
			   
					if(oarMatch.Expression_Oar__c!=null)
					{
						Pattern MyPattern = Pattern.compile(oarMatch.Expression_Oar__c);
						Matcher OpptyMatcher= MyPattern.matcher(mat);
						expressionMatch = OpptyMatcher.matches();
						System.debug('mat===>'+mat);
						System.debug('MyPattern===>'+MyPattern);
						System.debug('The Value of match is'+expressionMatch);
						if(expressionMatch==false)continue;
						System.debug('The expressionMatch is===='+expressionMatch+'**mat==='+mat+'**oarMatch.Expression_Oar__c===='+oarMatch.Expression_Oar__c);
					}
					System.debug('expressionMatch==='+expressionMatch);
					System.debug('oarMatch.Partner_Type__c.toLowerCase()==strNamedPartnerType'+oarMatch.Partner_Type__c.toLowerCase()+strNamedPartnerType);
					if(mapaccnt.get(opp.Accountid).BillingPostalCode !=null)
	                {
	                	if(oarMatch.Zip_Postal_Code_List__c !=null)
	                    {
	                        String[] arrZipPostalCodeList = oarMatch.Zip_Postal_Code_List__c.split(',');
	                        for(Integer j=0; j<arrZipPostalCodeList.size(); j++)
	                        {
	                            if(arrZipPostalCodeList[j].contains(mapaccnt.get(opp.Accountid).BillingPostalCode))
	                            {
	                                System.debug('Zip code'+arrZipPostalCodeList[j]+'opp.Account.BillingPostalCode'+mapaccnt.get(opp.Accountid).BillingPostalCode);
	                        		ZipCodeFound=True;
	                            }
	                            
	                        }
	                        
	                        if(!ZipCodeFound)
	                        {
	                            continue;
	                        }
	                        System.debug('ZipCodeFound'+ZipCodeFound+'oarMatch.name'+oarMatch.name);
	                    }
	                    //if list if postal code is not present then search for Range of Postal Code on OAR.
	                    else
	                    {
	                        if(oarMatch.Zip_Postal_Code_Low_Range__c !=null && oarMatch.Zip_Postal_Code_High_Range__c !=null)
	                        {
	                            if( oarMatch.Zip_Postal_Code_Low_Range__c<=mapaccnt.get(opp.Accountid).BillingPostalCode && oarMatch.Zip_Postal_Code_High_Range__c>=mapaccnt.get(opp.Accountid).BillingPostalCode)
	                            {
	                                
	                            }
	                            else
	                            {
	                                continue;
	                            }
	                        }
	                    }
	                }
	                if(oarMatch.Partner_Type__c.toLowerCase()==strNamedPartnerType)
					{
						if(opp.Partner__c!=null && (opp.Partner__c==oarMatch.Tier1Tier2_Partner_Name__c || mapaccnt.get(opp.Partner__c).Master_Grouping__c==oarMatch.Partner_Grouping__c ||mapaccnt.get(opp.Partner__c).Grouping__c==oarMatch.Partner_Grouping__c))
						{}
						else if(opp.Tier_2_Partner__c!=null && (opp.Tier_2_Partner__c==oarMatch.Tier1Tier2_Partner_Name__c || mapaccnt.get(opp.Tier_2_Partner__c).Master_Grouping__c==oarMatch.Partner_Grouping__c ||mapaccnt.get(opp.Tier_2_Partner__c).Grouping__c==oarMatch.Partner_Grouping__c))
						{
						}
						else
						{
							continue;
						}
					}
					System.debug('oarMatch.Partner_Type__c.toLowerCase()===>'+oarMatch.Partner_Type__c.toLowerCase());
					System.debug('strAlliancePartnerType===>'+strAlliancePartnerType);
					if(oarMatch.Partner_Type__c.toLowerCase()==strAlliancePartnerType)
					{
						System.debug('opp.Primary_Alliance_Partner__c====>'+opp.Primary_Alliance_Partner__c+'***oarMatch.Alliance_Partner__c'+oarMatch.Alliance_Partner__c);
						if(opp.Primary_Alliance_Partner__c!=null && (opp.Primary_Alliance_Partner__c==oarMatch.Alliance_Partner__c || mapaccnt.get(opp.Primary_Alliance_Partner__c).Grouping__c==oarMatch.Partner_Grouping__c || mapaccnt.get(opp.Primary_Alliance_Partner__c).Master_Grouping__c==oarMatch.Partner_Grouping__c))
						{}
						else
						{
							if(opp.Secondary_Alliance_Partner__c!=null && (opp.Secondary_Alliance_Partner__c==oarMatch.Alliance_Partner__c || mapaccnt.get(opp.Secondary_Alliance_Partner__c).Master_Grouping__c==oarMatch.Partner_Grouping__c ||mapaccnt.get(opp.Secondary_Alliance_Partner__c).Grouping__c==oarMatch.Partner_Grouping__c))
							{}
							else
							{
								continue;
							}
						}
						
					}
					if(oarMatch.Partner_Type__c.toLowerCase()==strServiceProviderPartnerType)
					{
						if(opp.Service_Provider__c!=null && (opp.Service_Provider__c==oarMatch.Service_Provider__c || mapaccnt.get(opp.Service_Provider__c).Master_Grouping__c==oarMatch.Partner_Grouping__c ||mapaccnt.get(opp.Service_Provider__c).Grouping__c==oarMatch.Partner_Grouping__c))
						{}
						else
						{
							continue;
						}
					}
					if(mapaccnt.get(opp.Accountid).BillingCountry!=null && oarMatch.ResourceCountry__c!=null && oarMatch.ResourceCountry__c.toLowerCase()==mapaccnt.get(opp.Accountid).BillingCountry.toLowerCase())
					{
						KeyValue = opp.id;
						mapCountryOppAssRule.put(KeyValue, oarMatch);
						System.debug('mapCountryOppAssRule--->'+mapCountryOppAssRule);
					}
					if(mapaccnt.get(opp.Accountid).BillingState!=null && oarMatch.ResourceState__c!=null && oarMatch.ResourceState__c.toLowerCase()==mapaccnt.get(opp.Accountid).BillingState.toLowerCase())
					{
						KeyValue = opp.id;
						mapStateOppAssRule.put(KeyValue, oarMatch);
						System.debug('mapStateOppAssRule--->'+mapStateOppAssRule);
					}
					if(mapaccnt.get(opp.Accountid).Theater1__c!=null && oarMatch.ResourceAccountTheater__c!=null && oarMatch.ResourceAccountTheater__c.toLowerCase()==mapaccnt.get(opp.Accountid).Theater1__c.toLowerCase())
					{
						KeyValue = opp.id;
						mapTheaterOppAssRule.put(KeyValue, oarMatch);
						System.debug('mapTheaterOppAssRule--->'+mapTheaterOppAssRule);
					}
					if(mapaccnt.get(opp.Accountid).BillingPostalCode !=null)
					{
						if(oarMatch.Zip_Postal_Code_List__c !=null)
						{
							String[] arrZipPostalCodeList = oarMatch.Zip_Postal_Code_List__c.split(',');
							for(Integer j=0; j<arrZipPostalCodeList.size(); j++)
							{
								if(arrZipPostalCodeList[j].contains(mapaccnt.get(opp.Accountid).BillingPostalCode))
								{
									ZipCodeFound=True;
									KeyValue = opp.id;
									mapZipPostalOppAssRule.put(KeyValue, oarMatch);
									System.debug('Containskey else also entered');
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
							if(oarMatch.Zip_Postal_Code_Low_Range__c !=null && oarMatch.Zip_Postal_Code_High_Range__c !=null)
							{
								if( oarMatch.Zip_Postal_Code_Low_Range__c<=mapaccnt.get(opp.Accountid).BillingPostalCode && oarMatch.Zip_Postal_Code_High_Range__c>=mapaccnt.get(opp.Accountid).BillingPostalCode)
								{
									KeyValue = opp.id;
									mapZipPostalRangeOppAssRule.put(KeyValue, oarMatch);
									System.debug('Containskey else also entered');
								}
								else
								{
									continue;
								}
							}
						}
					}
				}
				if(mapZipPostalRangeOppAssRule.size()>0 && mapZipPostalRangeOppAssRule!=null) 
				{
					mapOppIdResourceId.putAll(mapZipPostalRangeOppAssRule);
					continue;
				}
				else if(mapZipPostalOppAssRule.size()>0 && mapZipPostalOppAssRule!=null)
				{
					mapOppIdResourceId.putAll(mapZipPostalOppAssRule);
					continue;
				}
				else if(mapStateOppAssRule.size()>0 && mapStateOppAssRule!=null)
				{
					mapOppIdResourceId.putAll(mapStateOppAssRule);
					continue;
				}
				else if(mapCountryOppAssRule.size()>0 && mapCountryOppAssRule!=null)
				{
					mapOppIdResourceId.putAll(mapCountryOppAssRule);
					continue;
				}
				else if(mapTheaterOppAssRule.size()>0 && mapTheaterOppAssRule!=null)
				{
					mapOppIdResourceId.putAll(mapTheaterOppAssRule);
					continue;
				}
		}
		return mapOppIdResourceId;
	}
	public static boolean processExclusionFound(List<OAR_Exclusion_Condition__c> lstOarExclusion,Opportunity opp,Account acc) 
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
                        ||lstOarExclusion[k].OAR_Field_API_Name__c =='EMC_CLASSIFICATION__c' ||lstOarExclusion[k].OAR_Field_API_Name__c =='Coverage_Model__c'||lstOarExclusion[k].OAR_Field_API_Name__c =='Customer_Segment__c'
                        )
                    {
                        for(Integer j=0; j<arrExcludedValue.size(); j++)
                        {   
                            If(acc.get(lstOarExclusion[k].OAR_Field_API_Name__c) == arrExcludedValue[j])
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
    
}