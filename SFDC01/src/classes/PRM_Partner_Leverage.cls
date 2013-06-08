/*=====================================================================================================================================

History 
17th Nov  11  Kaustav Debnath     Added the code for PRM Partner leverage functionality
                                  This class is used to rate partner by recording SE Skills and sales ratings for Partner SEs,
                                  record District to Partner SE mapping and capture partner performance ratings
                                  
6th Dec 11   Anand Sharma         updated method groupingAccountsRatingEligible to handle more that 10000record for of opportunity 
7th Dec 11   Kaustav Debnath      change the query for recordtype for rating eligible false method for opps
7th Dec 11   Kaustav Debnath      udpated the district manager update for district create/edit
13th Dec 11  Kaustav Debnath      commented the existing method called updateRatingsEnteredAndDateFieldsOnInsert and
                                  used the method updateRatingsEnteredAndDateFieldsOnUpdate for both insert and update
                                  trigger records based on condition checks
19th Dec 11  Kaustav Debnath      commented the code for groupingAccountsRatingEligibleNotTrue and updateOpportunityRecordTypeToOld
                                  and incorporated the same in the methods groupingAccountsRatingEligible 
                                  and updateOpportunityRecordType
2nd  Jan 12  Kaustav Debnath      commented the code for rating eligible updation for non profiled accounts 
2nd  Jan 12  Kaustav Debnath      updated the opportunity rec type future method to incorporate records after 1000 limit 
14th Dec 11  Kaustav Debnath      updated the calculate average method to use custom settings
15th Dec 11  Kaustav Debnath      added code for partner leverage factor calculation
23rd Jan 12  Kaustav Debnath      as part of WR 184063 added code for partner se skill validation rule to check creation of duplicate 
                                  unvalidated records
23rd Jan 12  Kaustav Debnath      commented the code for bookedOppRecordtypeFlip   method
25th Jan 12  Kaustav Debnath      added the code to display rated deals as per defect number 734 in method calculateEngagementValues
25 Jan 12    Arif                 Changed relationship name to Partner_SE_Skill_Sales_Acumen_Ratings__r 
30th Jan 12  Kaustav Debnath      Added code to calculate partner lev factor only if sales acumen rating records are present
31st Jan 12  Kaustav Debnath      updated the query to include latest_modified_skill_rating__c in the partner se skill and sales acumen rating
31st Jan 12  Kaustav Debnath      # engagements code updated
3rd  Feb 12  Kaustav Debnath      Added code to nullify partner leverage fields on account when rating eligible flag is unchecked
3rd  Feb 12  Anand Sharma         Revert to previous version
7th  Feb 12  Kaustav Debnath      Added a new method notificationPartnerPerfRatingDirectUser as per WR184353 to send notifications to 
                                  direct reps to create partner performance rating records
23rd Feb 12  Kaustav Debnath      Updated the query for EMC business rules to add the recordtype condition into the query to fetch BRs 
                                  related to only Partner Leverage rules
5 March 12   Arif                 NULL Check
14-March-12  Anil Sure            Populating Direct Rep1,Direct Rep2,Direct Rep3 with related opprtunity Team Members Email Ids when the Status is Booked
26-June-12   Kaustav Debnath      Commented the updatedirectrepfields and the notificationPartnerPerfRatingDirectUser method for Direct Rep email id population
02-Aug-12   Ganesh                Reverted Multiple Theaters functionality of EMCBusinessRule
19-Sep-12   Anirudh Singh         Updated contactPartnerLevFactorCalculation() method and put a null check for the failing test classes.
15/11/2012  vivek kodi            wr 197607(To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs).
02/05/2013  Nimai Meher			  Commented PRM_PL_has_BRS_Accreditation__c field as part of WR - 256428 (Contact simplification) for June Release .	 
======================================================================================================================================*/
public class PRM_Partner_Leverage{

public Static boolean PRM_Partner_Leverage_flag=false;  

    /* @Method <This method is written to flip the recordtype of an opportunity to 
                booked w/ partner perf rating when the forecast status is booked and
                one of the Distributor/Direct Reseller or Distributor VAR partner accounts 
                are rating eligible>.
       @param  <This method takes a list of opportunity records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */

public void bookedOppRecordtypeFlip(List<Opportunity> lstOpportunity)
    {
        PRM_Partner_Leverage_flag=true;
        
   
        List<Id> lstOppPartnerAccountIds=new List<Id>();
        
        //Map<Id,Account> mapOppPartnerAccount=new Map<Id,Account>();
        //Recordtype recOpptyBooked=new Recordtype();
        //recOpptyBooked=[select id,name from Recordtype where sobjecttype='Opportunity' and name='Booked w/ Partner Perf Rating Record Type' limit 1];
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c OpptyRecordTypes = (mapCustomSettingDataValueMap.get('Booked_Part_Perf_Rating_Opp_RecType'));           
        String strRecType = OpptyRecordTypes.DataValue__c;
        /*Wrote this query to include the distribution var and distributor/direct reseller fields in the query for Partner Leverage*/
        if(lstOpportunity!=null && lstOpportunity.size()>0)
        {
            for(Opportunity oppObj:lstOpportunity)
            {
                oppObj.recordtypeid=strRecType;
            }
            
            
        }
    }
/*end of method bookedOppRecordtypeFlip*/

/* @Method <This method is written to flip the recordtype of an opportunity to 
                booked w/ partner perf rating when the forecast status is booked and
                one of the Distributor/Direct Reseller or Distributor VAR partner accounts 
                are rating eligible>.
       @param  <This method takes a list of opportunity records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */

/* Commented this method
public static void notificationPartnerPerfRatingDirectUser(Set<Id> setBookedWithPartnerPerfOpportunityIds)
    {
        PRM_Partner_Leverage_flag=true;
        System.debug('### in partner leverage class');
        Map<Id,List<Id>> mapOppWithDirectRepIds=new Map<Id,List<Id>>();
        Map<Id,List<String>> mapOppWithDirectRepEmailIDs=new Map<Id,List<String>>();
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c TemplateCustomSetting = mapCustomSettingDataValueMap.get('PRM_PL_Part_Perf_Email_Notify'); 
        String TemplateId = TemplateCustomSetting.DataValue__c;
        List<OpportunityTeamMember> lstDirectSalesTeamMembers=[SELECT OpportunityId, Id,opportunity.ownerid,opportunity.Opportunity_Owner__c, TeamMemberRole, UserId,user.forecast_group__c,user.email, OpportunityAccessLevel FROM OpportunityTeamMember where opportunityid in :setBookedWithPartnerPerfOpportunityIds and user.forecast_group__c='Direct' and user.isactive=true order by OpportunityId];
        List<Id> lstOppSalesTeamTargetIds=new List<Id>();
        if(lstDirectSalesTeamMembers!=null && lstDirectSalesTeamMembers.size()>0)
        {
            for(OpportunityTeamMember salesTeam:lstDirectSalesTeamMembers)
            {
                List<String> lstOppSalesTeamEmailIds;
                List<Id> lstDirectRepIds;
                lstDirectRepIds=mapOppWithDirectRepIds.get(salesTeam.opportunityid);
                if(lstDirectRepIds==null)
                {
                    lstDirectRepIds=new List<Id>();
                }
                //String []emailIds;
                lstOppSalesTeamEmailIds=mapOppWithDirectRepEmailIDs.get(salesTeam.opportunityid);
                if(lstOppSalesTeamEmailIds==null)
                {
                    lstOppSalesTeamEmailIds=new List<String>();
                }
                lstOppSalesTeamEmailIds.add(salesTeam.user.email);
                lstDirectRepIds.ADD(salesTeam.userid);
                mapOppWithDirectRepIds.put(salesTeam.opportunityid,lstDirectRepIds);
                mapOppWithDirectRepEmailIDs.put(salesTeam.opportunityid,lstOppSalesTeamEmailIds);
            }
            
        }
        System.debug('#### mapOppWithDirectRepEmailIDs=>'+mapOppWithDirectRepEmailIDs);
        if(mapOppWithDirectRepEmailIDs.size()>0)
        {
            
            //EmailTemplate Template = [Select e.Body,e.Name, e.Subject From EmailTemplate e where id=:TemplateId];
            //List<String> toAddresses = new List<String>();            
            for(Id oppId:mapOppWithDirectRepEmailIDs.keyset())
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(mapOppWithDirectRepEmailIDs.get(oppId));
                System.debug('### mapOppWithDirectRepIds.get(oppid)=>'+mapOppWithDirectRepIds.get(oppid));
                mail.setTargetObjectId(mapOppWithDirectRepIds.get(oppid)[0]);
                //mail.setPlainTextBody(Template.body); 
                //mail.setHtmlBody(Template.body);
                mail.setSaveAsActivity(false);
                mail.setTemplateId(TemplateId);
                mail.setWhatId(oppId);
                System.debug('#### mail=>'+mail);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail }); 
            }
        }
    }*/
/*end of method bookedOppRecordtypeFlip*/

    /* @Method <This method is written to make a copy of the SE Skill and Acumen 
                record when it is validated by the Core TC>.
       @param  <This is taking a list of Partner SE Skill Sales Acument records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */

public static void partnerSEAcumenCopy(List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstToMakeCopy)
    {
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c PartnerSESkillRecordTypes = (mapCustomSettingDataValueMap.get('SE Skill & Sales Acumen Rating Edit'));           
        String strRecType = PartnerSESkillRecordTypes.DataValue__c;
            
        List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSESkillToInsert =new List<Partner_SE_Skill_Sales_Acumen_Rating__c>();
        for(Partner_SE_Skill_Sales_Acumen_Rating__c seObj:lstToMakeCopy)
        {
            Partner_SE_Skill_Sales_Acumen_Rating__c sObj=new Partner_SE_Skill_Sales_Acumen_Rating__c();
            
            sObj=seObj.clone();
            
            sObj.Ratings_Entered_by_PTC__c=null;
            System.debug('### sObj.Ratings_Entered_by_PTC__c=>'+sObj.Ratings_Entered_by_PTC__c);
            sObj.Rating_Date__c=null;
            System.debug('### sObj.Rating_Date__c=>'+sObj.Rating_Date__c);
            sObj.Core_TC_to_Validate__c=null;
            sObj.Ratings_Validated_by_Core_TC__c=false;
            sObj.Validated_By__c=null;
            sObj.Validation_Date__c=null;
            sObj.Parent_Partner_SE_Skill_Sales_Acumen__c=seObj.id;
            
            sObj.recordtypeid=strRecType;
            lstSESkillToInsert.add(sObj);
        }
        if(lstSESkillToInsert!=null && lstSESkillToInsert.size()>0)
        {
            //System.debug('##### lstSESkillToInsert=>'+lstSESkillToInsert);
            
            insert lstSESkillToInsert;
        }
    }
/*end of method partnerSEAcumenCopy*/

    /* @Method <This Method is added for district creation/updation when user attribute
                record is created/edited depending on conditions>.
       @param  <This is taking a list of User attribute mapping records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
   public void districtCreateEdit(List<User_Attribute_Mapping__c> lstUserAttribute){
   //System.debug('##### inside method');
   Set<Id> lstRoleIds=new Set<Id>();
   List<User> lstActiveUsersBasedOnRoles =new List<User>();
   Map<Id,Id> mapRoleUser=new Map<Id,Id>();
   List<District__c> lstDistrictsFetched=new List<District__c>();
   Map<Id, District__c> mapDistrictstoUpdate= new Map<Id, District__c>();
   List<District__c> lstDistrictstoInsert=new List<District__c>();
   Map<Id,District__C> mapUserMappingDistrictFound=new Map<Id,District__C>();
   Map<Id,District__C> mapUserMappingDistrict=new Map<Id,District__C>();
   Map<Id,User_Attribute_Mapping__c> mapUserMappingDistrictNotFound=new Map<Id,User_Attribute_Mapping__c>();
   
   Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
    Integer iCounter=0;
    String strRoles='';
    Set<String> setCustomSettingKeySet=mapCustomSettingDataValueMap.keyset();
    //System.debug('### setCustomSettingKeySet.size=>'+setCustomSettingKeySet.size());
    for(String strObj:setCustomSettingKeySet)
    {
        if(strObj.contains('User_attribute_Mapping_Sales_Role'))
        {
            System.debug('### inside if=>'+iCounter);
            iCounter++;
        }
    }
    System.debug('### iCounter=>'+iCounter);
    for(integer i=1;i<iCounter+1;i++)
    {
        CustomSettingDataValueMap__c userAttributeSalesRoles = (mapCustomSettingDataValueMap.get('User_attribute_Mapping_Sales_Role_'+i));
        System.debug('### userAttributeSalesRoles.DataValue__c=>'+userAttributeSalesRoles.DataValue__c);
        strRoles=strRoles+userAttributeSalesRoles.DataValue__c+',';
    }
    Set<String> split1 = new Set<String>();
    for(String s: strRoles.Split(',')){
        split1.add(s.toLowerCase());
    }
    //System.debug('### strRoles=>'+strRoles);
    System.debug('### split1=>'+split1);
    
    
       if(lstUserAttribute!=null && lstUserAttribute.size()>0)
       {
            for(User_Attribute_Mapping__c userMapObj:lstUserAttribute)
            {
                /*System.Debug('userMapObj ------>' + userMapObj);
                System.debug('### userMapObj=>'+userMapObj);
                System.Debug('split1 ------>' + split1);*/
                if(userMapObj.Role_Id__c != null && split1.contains(userMapObj.Sales_Role__c.toLowerCase())){
                    
                    //System.debug('### in here split1'+split1);                    
                    Id RoleId = userMapObj.Role_Id__c;
                    lstRoleIds.add(RoleId);
                        
                }  
                
            }
       }
       if(lstRoleIds!=null && lstRoleIds.size()>0)
       {
            lstActiveUsersBasedOnRoles=[select id,isactive,name,userroleid from user where isactive=true and userroleid in :lstRoleIds];
            System.debug('##### lstActiveUsersBasedOnRoles=>'+lstActiveUsersBasedOnRoles);
            if(lstActiveUsersBasedOnRoles!=null && lstActiveUsersBasedOnRoles.size()>0)
            {
                for(User userObj:lstActiveUsersBasedOnRoles)
                {
                    if(!(mapRoleUser.containsKey(userObj.userRoleid)))
                    {
                        mapRoleUser.put(userObj.userRoleId,userObj.id);
                    }
                    
                }
            }
            lstDistrictsFetched=[select Name,District_Manager__c,Area__c,BU__c,Country__c,Division__c,Inactive__c,Forecast_Group__c,Region__c,Role_ID__c,Sales_Role__c,Super_Area__c,Super_Division__c,Theater__c from District__c where role_id__c in :lstRoleIds];
            if(lstDistrictsFetched!=null && lstDistrictsFetched.size()>0)
            {
                for(District__c dist:lstDistrictsFetched)
                {
                    mapUserMappingDistrict.put(dist.Role_ID__c,dist);
                }
                
                //System.debug('##### lstDistrictsFetched=>'+lstDistrictsFetched);
                for(User_Attribute_Mapping__c userMapObj:lstUserAttribute)
                {
                    if(mapUserMappingDistrict.containskey(userMapObj.Role_ID__c))
                    {
                        District__c distObj=mapUserMappingDistrict.get(userMapObj.Role_ID__c);
                        mapUserMappingDistrictFound.put(userMapObj.id,distObj);
                    }
                }
                //System.debug('##### mapUserMappingDistrictFound=>'+mapUserMappingDistrictFound);
            }
            //System.debug('##### lstUserAttribute=>'+lstUserAttribute);
            for(User_Attribute_Mapping__c userMapObj:lstUserAttribute)
            {
                //for(String s: split1)
                //{
                    //System.debug('##### userMapObj=>'+userMapObj);
                    if(userMapObj.Role_Id__c != null && mapUserMappingDistrictFound.containsKey(userMapObj.id))
                    {
                        District__c district=new District__C();
                        
                        district=mapUserMappingDistrictFound.get(userMapObj.id);
                        district.District_Manager__c=null;
                        district.Name=userMapObj.district__c;
                        
                        district.Area__c=userMapObj.area__c;
                        district.BU__c=userMapObj.BU__c;
                        district.Country__c=userMapObj.Country__c;
                        district.Division__c=userMapObj.Division__c;
                        
                        district.Forecast_Group__c=userMapObj.Forecast_Group__c;
                        district.Region__c=userMapObj.Region__c;
                        district.Role_ID__c=userMapObj.Role_ID__c;
                        district.Sales_Role__c=userMapObj.Sales_Role__c;
                        district.Super_Area__c=userMapObj.Super_Area__c;
                        district.Super_Division__c=userMapObj.Super_Division__c;
                        district.Theater__c=userMapObj.Theater__c;
                        district.inactive__c=false;
                        if(mapRoleUser.size()>0)
                        {
                            if(mapRoleUser.get(userMapObj.role_id__c)!=null)
                            {
                                System.debug('#### inside if');
                                district.District_Manager__c=mapRoleUser.get(userMapObj.role_id__c);
                            }
                        }
                        mapDistrictstoUpdate.put(district.Id, district);
                    }
                    
                    else if(userMapObj.Role_Id__c != null && split1.contains(userMapObj.Sales_Role__c.toLowerCase()))
                    {
                        //System.debug('##### userMapObj=>'+userMapObj);
                        System.debug('### in here split1'+split1);  
                        District__c districtToInsert=new District__C();
                        
                        districtToInsert.Name=userMapObj.district__c;
                        
                        districtToInsert.Area__c=userMapObj.area__c;
                        districtToInsert.BU__c=userMapObj.BU__c;
                        districtToInsert.Country__c=userMapObj.Country__c;
                        districtToInsert.Division__c=userMapObj.Division__c;
                        
                        districtToInsert.Forecast_Group__c=userMapObj.Forecast_Group__c;
                        districtToInsert.Region__c=userMapObj.Region__c;
                        districtToInsert.Role_ID__c=userMapObj.Role_ID__c;
                        districtToInsert.Sales_Role__c=userMapObj.Sales_Role__c;
                        districtToInsert.Super_Area__c=userMapObj.Super_Area__c;
                        districtToInsert.Super_Division__c=userMapObj.Super_Division__c;
                        districtToInsert.Theater__c=userMapObj.Theater__c;
                        
                        if(mapRoleUser.size()>0)
                        {
                            if(mapRoleUser.get(userMapObj.role_id__c)!=null)
                            {
                                districtToInsert.District_Manager__c=mapRoleUser.get(userMapObj.role_id__c);
                            }
                        }
                        
                        districtToInsert.Inactive__c=false;

                        lstDistrictstoInsert.add(districtToInsert);
                        System.debug('##### lstDistrictstoInsert=>'+lstDistrictstoInsert);
                    }
                //}
            }
            
       }
       if(lstDistrictstoInsert!=null && lstDistrictstoInsert.size()>0)
       {
            insert lstDistrictstoInsert;
       }
       if(mapDistrictstoUpdate!=null && mapDistrictstoUpdate.size()>0)
       {
            System.debug('### mapDistrictstoUpdate=>'+mapDistrictstoUpdate);
            update mapDistrictstoUpdate.values();
       }
   }
   /*End of Method added for district creation/updation when user attribute
  record is created/edited depending on conditions*/
  
    /* @Method <This Method is added for district inactivation when user attribute
              record is deleted depending on conditions>.
       @param  <This is taking a list of User attribute mapping records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
 
   public void districtUpdateOnUserDelete(List<User_Attribute_Mapping__c> lstUserAttribute){
   //System.debug('##### inside method');
   List<Id> lstRoleIds=new List<Id>();
   //List<User> lstActiveUsersBasedOnRoles =new List<User>();
   List<District__c> lstDistrictsFetched=new List<District__c>();
   List<District__c> lstDistrictstoUpdate=new List<District__c>();
   //List<District__c> lstDistrictstoInsert=new List<District__c>();
   Map<Id,District__C> mapUserMappingDistrict=new Map<Id,District__C>();
   Map<Id,District__C> mapUserMappingDistrictFound=new Map<Id,District__C>();
   Map<Id,User_Attribute_Mapping__c> mapUserMappingDistrictNotFound=new Map<Id,User_Attribute_Mapping__c>();
   
   
    
       if(lstUserAttribute!=null && lstUserAttribute.size()>0)
       {
            for(User_Attribute_Mapping__c userMapObj:lstUserAttribute)
            {
                if(userMapObj.Role_Id__c != null)
                {
                    lstRoleIds.add(userMapObj.Role_ID__c);
                }
            }
       }
       if(lstRoleIds!=null && lstRoleIds.size()>0)
       {
            //lstActiveUsersBasedOnRoles=[select id,isactive,name,userroleid from user where isactive=true and userroleid in :lstRoleIds];
            //System.debug('##### lstActiveUsersBasedOnRoles=>'+lstActiveUsersBasedOnRoles);
            lstDistrictsFetched=[select Name,District_Manager__c,Area__c,BU__c,Country__c,Division__c,Inactive__c,Forecast_Group__c,Region__c,Role_ID__c,Sales_Role__c,Super_Area__c,Super_Division__c,Theater__c from District__c where role_id__c in :lstRoleIds];
            if(lstDistrictsFetched!=null && lstDistrictsFetched.size()>0)
            {
                for(District__c dist:lstDistrictsFetched)
                {
                    mapUserMappingDistrict.put(dist.Role_ID__c,dist);
                }
                //System.debug('##### lstDistrictsFetched=>'+lstDistrictsFetched);
                for(User_Attribute_Mapping__c userMapObj:lstUserAttribute)
                {
                    if(mapUserMappingDistrict.containskey(userMapObj.Role_ID__c))
                    {
                        District__c distObj=mapUserMappingDistrict.get(userMapObj.Role_ID__c);
                        mapUserMappingDistrictFound.put(userMapObj.id,distObj);
                    }
                }
                //System.debug('##### mapUserMappingDistrictFound=>'+mapUserMappingDistrictFound);
            }
            //System.debug('##### lstUserAttribute=>'+lstUserAttribute);
            for(User_Attribute_Mapping__c userMapObj:lstUserAttribute)
            {
                
                //System.debug('##### userMapObj=>'+userMapObj);
                if(mapUserMappingDistrictFound.containsKey(userMapObj.id))
                {
                    District__c district=new District__C();
                    district=mapUserMappingDistrictFound.get(userMapObj.id);
                    district.inactive__c=true;
                    
                    lstDistrictstoUpdate.add(district);
                    //System.debug('##### lstDistrictstoUpdate=>'+lstDistrictstoUpdate);
                }
            }
            
            /*System.debug('##### lstDistrictstoUpdate=>'+lstDistrictstoUpdate);
            System.debug('##### lstDistrictstoUpdate.size=>'+lstDistrictstoUpdate.size());*/
       }
       
       if(lstDistrictstoUpdate!=null && lstDistrictstoUpdate.size()>0)
       {
            Database.update (lstDistrictstoUpdate, false);
       }
   }
   /*End of Method added for district creation/updation when user attribute
  record is created/edited depending on conditions*/
 
  /* @Method <This method is used to update the rating eligible field for all grouping accounts 
                if the profiled account is rating eligible>.
     @param <This is taking a list of profiled accounts as argument>
     @return <void> - <return nothing>
     @throws exception - <No Exception>
  */
    public void groupingAccountsRatingEligible(List<Account> lstProfiledAccounts, Boolean ratingEligibleFlag)
    {
            //System.debug('##### lstProfiledAccounts=>'+lstProfiledAccounts);
            List<Id> lstAccountGroupingIds = new List<Id>();
            Map<Id,Opportunity> mapOpptyToUpdate;
            Map<Id,Opportunity> mapOpptyToUpdate2;
            set<Id> setOpptyIds = new set<Id>();
            Map<id, Account> lstAccountsToUpdate=new Map<Id,Account>();
            List<Account> lstFinalAccountsToUpdate=new List<Account>();
            List<Opportunity> lstBookedOpportunitiesForRecordtypeFlip = new List<Opportunity>();
            List<Opportunity> lstFinalOppsToUpdate = new List<Opportunity>();
            Set<Id> setFinalOppsToUpdate = new Set<Id>();
            Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
            //List<CustomSettingDataValueMap__c> lstDealRegRecordTypes = new List<CustomSettingDataValueMap__c>();        
            CustomSettingDataValueMap__c OpptyRecordTypes = (mapCustomSettingDataValueMap.get('Booked_Part_Perf_Rating_Opp_RecType'));           
            String strRecType = OpptyRecordTypes.DataValue__c;
            CustomSettingDataValueMap__c OpptyNewBookedRecordTypes = (mapCustomSettingDataValueMap.get('New_Booked_Opportunity_Record_Type'));           
            String strNewBookedRecType = OpptyNewBookedRecordTypes.DataValue__c;
            PRM_Partner_Leverage_flag=true;
            //Recordtype recOpptyBooked=new Recordtype();
            //recOpptyBooked=[select id,name from Recordtype where sobjecttype='Opportunity' and name='Booked w/ Partner Perf Rating Opportunity Record Type' limit 1];
            for(Account accObj:lstProfiledAccounts)
            {
                if(accObj.Grouping__c != null){
                    lstAccountGroupingIds.add(accObj.Grouping__c);
                }
            }
            if(lstAccountGroupingIds!=null && lstAccountGroupingIds.size()>0)
            {
                lstAccountsToUpdate= new Map<Id,Account>([select id,name,Rating_Eligible__c,PROFILED_ACCOUNT_FLAG__c,Grouping__c from Account where Grouping__c in :lstAccountGroupingIds]);
            }
            System.debug('##### lstAccountsToUpdate outside=>'+ lstAccountsToUpdate.size() );
            if(lstAccountsToUpdate!=null && lstAccountsToUpdate.size()>0)
            {
                System.debug('##### strRecType =>'+ strRecType );
                System.debug('##### lstAccountsToUpdate.size()=>'+lstAccountsToUpdate.size());
                System.debug('##### lstAccountsToUpdate.keySet =>'+lstAccountsToUpdate.keySet() );
                if(ratingEligibleFlag==true)
                {
                    mapOpptyToUpdate = new Map<Id,Opportunity>([select id,name,stageName,partner__c,Tier_2_Partner__c from opportunity where stageName='Booked' and recordtypeid !=:strRecType and Partner__c in :lstAccountsToUpdate.keySet()]);
                    mapOpptyToUpdate2 = new Map<Id,Opportunity>([select id,name,stageName,partner__c,Tier_2_Partner__c from opportunity where stageName='Booked' and recordtypeid !=:strRecType and Tier_2_Partner__c in :lstAccountsToUpdate.keySet()]);
                }
                else
                {
                    mapOpptyToUpdate = new Map<Id,Opportunity>([select id,name,stageName,partner__c,Tier_2_Partner__c from opportunity where stageName='Booked' and recordtypeid =:strRecType and Partner__c in :lstAccountsToUpdate.keySet()]);
                    mapOpptyToUpdate2 = new Map<Id,Opportunity>([select id,name,stageName,partner__c,Tier_2_Partner__c from opportunity where stageName='Booked' and recordtypeid =:strRecType and Tier_2_Partner__c in :lstAccountsToUpdate.keySet()]);
                }
                System.Debug('Map####'+mapOpptyToUpdate.size());
                /*for(Account accObj:lstAccountsToUpdate.values())
                {
                    if(accObj.PROFILED_ACCOUNT_FLAG__c==false)
                    {
                        if(ratingEligibleFlag==true)
                        accObj.Rating_Eligible__c=true;
                        else
                        accObj.Rating_Eligible__c=false;
                        lstFinalAccountsToUpdate.add(accObj);
                    }
                }*/
            }
            /*if(lstFinalAccountsToUpdate!=null && lstFinalAccountsToUpdate.size()>0)
            {
                System.debug('##### lstFinalAccountsToUpdate.size()=>'+lstFinalAccountsToUpdate.size());
                System.debug('##### lstFinalAccountsToUpdate=>'+lstFinalAccountsToUpdate);
                update lstFinalAccountsToUpdate;
            }*/
            if((mapOpptyToUpdate!=null && mapOpptyToUpdate.size()>0) ||(mapOpptyToUpdate2!=null && mapOpptyToUpdate2.size()>0))
            {
                //System.debug('##### lstBookedOpportunitiesForRecordtypeFlip=>'+lstBookedOpportunitiesForRecordtypeFlip);
                if(mapOpptyToUpdate.size()>0){
                   setOpptyIds.addall(mapOpptyToUpdate.keyset()); 
                }
                if(mapOpptyToUpdate2.size()>0){
                   setOpptyIds.addall(mapOpptyToUpdate2.keyset());
                }
                lstBookedOpportunitiesForRecordtypeFlip=[select id,name,stageName,partner__c,recordtypeid,bypass_validation__c,Tier_2_Partner__c from opportunity where id in:setOpptyIds]; 
                for(Opportunity oppObj:lstBookedOpportunitiesForRecordtypeFlip)
                {
                    if(ratingEligibleFlag==true)
                    oppObj.recordtypeid=strRecType;
                    else
                    oppObj.recordtypeid=strNewBookedRecType;
                    oppObj.bypass_validation__c = true;
                    lstFinalOppsToUpdate.add(oppObj);
                    setFinalOppsToUpdate.add(oppObj.Id);
                    
                }
            }
            if(lstFinalOppsToUpdate!=null && lstFinalOppsToUpdate.size()>0)
            {
                System.debug('##### lstFinalOppsToUpdate.size()=>'+lstFinalOppsToUpdate.size());
                System.debug('##### lstFinalOppsToUpdate=>'+lstFinalOppsToUpdate);
                Set<Id> setOppIdstemp = new set<Id>();
                if(setFinalOppsToUpdate.size() <1000){
                    update lstFinalOppsToUpdate;
                }
                else
                {
                    for(Integer i=0; i<lstFinalOppsToUpdate.size(); i++)
                    {
                        setOppIdstemp.add(lstFinalOppsToUpdate.get(i).Id);
                        if(setOppIdstemp.size() ==10000){
                            updateOpportunityRecordType(setOppIdstemp,ratingEligibleFlag); 
                            setOppIdstemp = new set<Id>(); 
                        }
                    }
                    if(setOppIdstemp.size() >0){
                            updateOpportunityRecordType(setOppIdstemp,ratingEligibleFlag);
                    }                      
                }
                
            }
    }   
    /*end of method groupingAccountsRatingEligible*/
    
    /* @Method <This method is a future method used to update opportunity recordtypes for large number of 
                opportunity records>.
       @param  <This takes a list of opportunity ids to be updated to booked with performance rating record type>
       @return <void> - <return nothing>
       @throws exception - <No Exception>
    */
    @future
    public static void updateOpportunityRecordType(Set<Id> opportunityIds,Boolean ratingEligibleFlag){
        //recOpptyBooked=[select id,name from Recordtype where sobjecttype='Opportunity' and name='Booked w/ Partner Perf Rating Record Type' limit 1];
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c OpptyRecordTypes = (mapCustomSettingDataValueMap.get('Booked_Part_Perf_Rating_Opp_RecType'));           
        String strRecType = OpptyRecordTypes.DataValue__c;
        CustomSettingDataValueMap__c OpptyNewBookedRecordTypes = (mapCustomSettingDataValueMap.get('New_Booked_Opportunity_Record_Type'));           
        String strNewBookedRecType = OpptyNewBookedRecordTypes.DataValue__c;
        List<Opportunity> lstOpportunity = [select id,name,stageName,partner__c,Tier_2_Partner__c, recordtypeid from opportunity where id in:opportunityIds];
        List<Opportunity> lstTempOpportunity = new List<Opportunity>();
        for(Opportunity oppObj: lstOpportunity){
            
            if(ratingEligibleFlag==true)
            oppObj.recordtypeid=strRecType;
            else
            oppObj.recordtypeid=strNewBookedRecType;
            //oppObj.recordtypeid=strRecType;
            oppObj.bypass_validation__c = true;
            lstTempOpportunity.add(oppObj);
            if(lstTempOpportunity.size() == 1000){
                Database.update( lstTempOpportunity, false);
                lstTempOpportunity.clear();
            }
        }
        if(lstTempOpportunity.size()>0)
        {
            Database.update( lstTempOpportunity, false);
        }
    }
    /* @Method <This method is a future method used to update opportunity recordtypes for large number
                of opportunity records>.
       @param <This takes a list of opportunity ids to be updated to new booked opportunity record type>
       @return <void> - <return nothing>
       @throws exception - <No Exception>
    */
    /*@future
    public static void updateOpportunityRecordTypeToOld(Set<Id> opportunityIds){
        //recOpptyBooked=[select id,name from Recordtype where sobjecttype='Opportunity' and name='Booked w/ Partner Perf Rating Record Type' limit 1];
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c OpptyNewBookedRecordTypes = (mapCustomSettingDataValueMap.get('New_Booked_Opportunity_Record_Type'));           
        String strNewBookedRecType = OpptyNewBookedRecordTypes.DataValue__c;
        List<Opportunity> lstOpportunity = [select id,name,stageName,partner__c,Tier_2_Partner__c, recordtypeid from opportunity where id in:opportunityIds];
        List<Opportunity> lstTempOpportunity = new List<Opportunity>();
        for(Opportunity oppObj: lstOpportunity){
            oppObj.recordtypeid=strNewBookedRecType;
            oppObj.bypass_validation__c = true;
            lstTempOpportunity.add(oppObj);
            if(lstTempOpportunity.size() == 1000){
                Database.update( lstTempOpportunity, false);
                lstTempOpportunity.clear();
            }
        }
    }*/
    
    /* @Method <This method is used to update the rating eligible field for all grouping accounts if 
                the profiled account is not rating eligible>.
       @param  <This is taking a list of profiled accounts as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
    
    /*public void groupingAccountsRatingEligibleNotTrue(List<Account> lstProfiledAccounts)
    {
        
            //System.debug('##### lstProfiledAccounts=>'+lstProfiledAccounts);
            List<Id> lstAccountGroupingIds = new List<Id>();
            Map<Id,Account> lstAccountsToUpdate;
            List<Account> lstFinalAccountsToUpdate=new List<Account>();
            Set<Id> setFinalOppsToUpdate = new Set<Id>();
            Map<Id,Opportunity> mapOpptyToUpdate;
            Map<Id,Opportunity> mapOpptyToUpdate2;
            set<Id> setOpptyIds = new set<Id>();
            List<Opportunity> lstBookedOpportunitiesForRecordtypeFlip = new List<Opportunity>();
            List<Opportunity> lstFinalOppsToUpdate = new List<Opportunity>();
            Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
            //List<CustomSettingDataValueMap__c> lstDealRegRecordTypes = new List<CustomSettingDataValueMap__c>();        
            CustomSettingDataValueMap__c OpptyRecordTypes = (mapCustomSettingDataValueMap.get('Booked_Part_Perf_Rating_Opp_RecType'));           
            String strRecType = OpptyRecordTypes.DataValue__c;
            CustomSettingDataValueMap__c OpptyNewBookedRecordTypes = (mapCustomSettingDataValueMap.get('New_Booked_Opportunity_Record_Type'));           
            String strNewBookedRecType = OpptyNewBookedRecordTypes.DataValue__c;
            PRM_Partner_Leverage_flag=true;
            //Recordtype recOpptyBooked=new Recordtype();
            //recOpptyBooked=[select id,name from Recordtype where sobjecttype='Opportunity' and name='Booked w/ Partner Perf Rating Opportunity Record Type' limit 1];
            for(Account accObj:lstProfiledAccounts)
            {
                lstAccountGroupingIds.add(accObj.Grouping__c);
                
            }
            if(lstAccountGroupingIds!=null && lstAccountGroupingIds.size()>0)
            {
                //System.debug('##### lstAccountGroupingIds=>'+lstAccountGroupingIds);
                lstAccountsToUpdate= new Map<Id,Account>([select id,name,Rating_Eligible__c,PROFILED_ACCOUNT_FLAG__c,Grouping__c from Account where Grouping__c in :lstAccountGroupingIds]);
            }
            if(lstAccountsToUpdate!=null && lstAccountsToUpdate.size()>0)
            {
                //System.debug('##### lstAccountsToUpdate=>'+lstAccountsToUpdate);
                //System.debug('##### lstAccountsToUpdate.size()=>'+lstAccountsToUpdate.size());
                //lstBookedOpportunitiesForRecordtypeFlip=[select id,name,stageName,partner__c,Tier_2_Partner__c from opportunity where stageName='Booked' and recordtypeid=:strRecType and (partner__c in :lstAccountsToUpdate or Tier_2_Partner__c in :lstAccountsToUpdate)];
                mapOpptyToUpdate = new Map<Id,Opportunity>([select id,name,stageName,partner__c,Tier_2_Partner__c from opportunity where stageName='Booked' and recordtypeid =:strRecType and Partner__c in :lstAccountsToUpdate.keySet()]);
                mapOpptyToUpdate2 = new Map<Id,Opportunity>([select id,name,stageName,partner__c,Tier_2_Partner__c from opportunity where stageName='Booked' and recordtypeid =:strRecType and Tier_2_Partner__c in :lstAccountsToUpdate.keySet()]);
             
                for(Account accObj:lstAccountsToUpdate.values())
                {
                    if(accObj.PROFILED_ACCOUNT_FLAG__c==false)
                    {
                        accObj.Rating_Eligible__c=false;
                        lstFinalAccountsToUpdate.add(accObj);
                    }
                }
            }
            if(lstFinalAccountsToUpdate!=null && lstFinalAccountsToUpdate.size()>0)
            {
                //System.debug('##### lstFinalAccountsToUpdate=>'+lstFinalAccountsToUpdate);
                update lstFinalAccountsToUpdate;
            }
            if((mapOpptyToUpdate!=null && mapOpptyToUpdate.size()>0) ||(mapOpptyToUpdate2!=null && mapOpptyToUpdate2.size()>0))
            {
                //System.debug('##### lstBookedOpportunitiesForRecordtypeFlip=>'+lstBookedOpportunitiesForRecordtypeFlip);
                if(mapOpptyToUpdate.size()>0){
                   setOpptyIds.addall(mapOpptyToUpdate.keyset()); 
                }
                if(mapOpptyToUpdate2.size()>0){
                   setOpptyIds.addall(mapOpptyToUpdate2.keyset());
                }
                lstBookedOpportunitiesForRecordtypeFlip=[select id,name,stageName,partner__c,recordtypeid,bypass_validation__c,Tier_2_Partner__c from opportunity where id in:setOpptyIds]; 
                
                System.debug('##### lstBookedOpportunitiesForRecordtypeFlip=>'+lstBookedOpportunitiesForRecordtypeFlip);
                for(Opportunity oppObj:lstBookedOpportunitiesForRecordtypeFlip)
                {
                    oppObj.recordtypeid=strNewBookedRecType;
                    oppObj.bypass_validation__c = true;
                    lstFinalOppsToUpdate.add(oppObj);
                    setFinalOppsToUpdate.add(oppObj.Id);
                }
            }
            if(lstFinalOppsToUpdate!=null && lstFinalOppsToUpdate.size()>0)
            {
                System.debug('##### lstFinalOppsToUpdate=>'+lstFinalOppsToUpdate);
                Set<Id> setOppIdstemp = new set<Id>();
                if(setFinalOppsToUpdate.size() <1000){
                    update lstFinalOppsToUpdate;
                }
                else
                {
                    for(Integer i=0; i<lstFinalOppsToUpdate.size(); i++){
                        setOppIdstemp.add(lstFinalOppsToUpdate.get(i).Id);
                        
                        if(setOppIdstemp.size() ==10000){
                            updateOpportunityRecordTypeToOld(setOppIdstemp);  
                            setOppIdstemp = new set<Id>(); 
                            
                        }
                    }
                    if(setOppIdstemp.size() >0){
                            updateOpportunityRecordTypeToOld(setOppIdstemp);
                    }   
                }
            }
    }   */
    /*end of method groupingAccountsRatingEligibleNotTrue*/
    
    /* @Method <This method is written to calculate the rating field values on 
                Partner SE Skill and Acumen object records>.
       @param  <This is taking a list of Partner SE Skill and Acumen object records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
    public  static void calculateAverageRatings(list<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSalesAcumen)
    {
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        //System.debug('###### lstSalesAcumen'+lstSalesAcumen);
        
        CustomSettingDataValueMap__c PRM_PL_Sales_Rating = (mapCustomSettingDataValueMap.get('PRM_PL_SE_Sales_Fields'));
        CustomSettingDataValueMap__c PRM_PL_Skills_Rating = (mapCustomSettingDataValueMap.get('PRM_PL_SE_Skill_Fields'));
        CustomSettingDataValueMap__c PRM_PL_Expertise_Rating = (mapCustomSettingDataValueMap.get('PRM_PL_Expertise_Total_Fields'));
        Set<String> setSalesSplit = new Set<String>();
        Set<String> setSkillsSplit = new Set<String>();
        Set<String> setExpertiseTotalSplit = new Set<String>();
        for(String s: PRM_PL_Sales_Rating.DataValue__c.Split(',')){
            setSalesSplit.add(s);
        }
        for(String s: PRM_PL_Skills_Rating.DataValue__c.Split(',')){
            setSkillsSplit.add(s);
        }
        for(String s: PRM_PL_Expertise_Rating.DataValue__c.Split(',')){
            setExpertiseTotalSplit.add(s);
        }
        //System.debug('### strRoles=>'+strRoles);
        System.debug('### setSalesSplit=>'+setSalesSplit);
        System.debug('### setSkillsSplit=>'+setSkillsSplit);
        for(Partner_SE_Skill_Sales_Acumen_Rating__c salesAcumen:lstSalesAcumen)
        {
            Sobject sObjPartnerSE=(Partner_SE_Skill_Sales_Acumen_Rating__c) salesAcumen;
            Decimal sumOfFields=0;
            Integer countFieldsToAverage=0;
            Decimal sumOfFields2=0;
            Integer countFieldsToAverage2=0;
            Decimal sumOfFields3=0;
            Integer countFieldsToAverage3=0;
            Decimal sumOfFields4=0;
            Integer countFieldsToAverage4=0;
            Decimal sumOfFields5=0;
            Integer countFieldsToAverage5=0;
            /*code to calculate Partner_SE_Overall_Skill_Rating__c*/
            for(String strObj:setSkillsSplit)
            {
                Object obj=sObjPartnerSE.get(strObj);
                if(obj!=null && obj=='N/A')
                {
                    sumOfFields4=sumOfFields4+0;
                    countFieldsToAverage4=countFieldsToAverage4+1;
                }
                else if(obj!=null && obj!='N/A')
                {
                    sumOfFields=sumOfFields+integer.valueof(obj);
                    countFieldsToAverage=countFieldsToAverage+1;
                    sumOfFields4=sumOfFields4+integer.valueof(obj);
                    countFieldsToAverage4=countFieldsToAverage4+1;
                }
            }
            for(String strObj:setSalesSplit)
            {
                Object obj=sObjPartnerSE.get(strObj);
                if(obj!=null && obj=='N/A')
                {
                    sumOfFields3=sumOfFields3+0;
                    countFieldsToAverage3=countFieldsToAverage3+1;
                }
                else if(obj!=null && obj!='N/A')
                {
                    sumOfFields2=sumOfFields2+integer.valueof(obj);
                    countFieldsToAverage2=countFieldsToAverage2+1;
                    sumOfFields3=sumOfFields3+integer.valueof(obj);
                    countFieldsToAverage3=countFieldsToAverage3+1;
                }
            }
            
            for(String strObj:setExpertiseTotalSplit)
            {
                Object obj=sObjPartnerSE.get(strObj);
                if(obj!=null && obj=='Yes')
                {
                    sumOfFields5=sumOfFields5+1;
                }
                
            }
            
            salesAcumen.Partner_SE_Overall_Skill_Rating__c = null;
            salesAcumen.Partner_SE_Overall_Sales_Acumen_Rating__c = null;
            salesAcumen.Partner_Lev_Sales_Acumen_Rating__c = null;
            salesAcumen.Partner_Lev_Skill_Rating__c = null;
            salesAcumen.Partner_Lev_Expertise_Total__c  = null;
            System.debug('##### sumOfFields=>'+sumOfFields);
            System.debug('##### countFieldsToAverage=>'+countFieldsToAverage);
            
            System.debug('##### sumOfFields2=>'+sumOfFields2);
            System.debug('##### countFieldsToAverage2=>'+countFieldsToAverage2);
            if(sumOfFields!=0 && countFieldsToAverage!=0)
            salesAcumen.Partner_SE_Overall_Skill_Rating__c= sumOfFields.divide(countFieldsToAverage, 2, System.RoundingMode.UP);
            System.debug('#### average=>'+salesAcumen.Partner_SE_Overall_Skill_Rating__c);
            
            if(sumOfFields2!=0 && countFieldsToAverage2!=0)
            salesAcumen.Partner_SE_Overall_Sales_Acumen_Rating__c   = sumOfFields2.divide(countFieldsToAverage2, 2, System.RoundingMode.UP);
            System.debug('#### average=>'+salesAcumen.Partner_SE_Overall_Sales_Acumen_Rating__c );
            
            if(sumOfFields3!=0 && countFieldsToAverage3!=0)
            salesAcumen.Partner_Lev_Sales_Acumen_Rating__c  = sumOfFields3.divide(countFieldsToAverage3, 2, System.RoundingMode.UP);
            System.debug('#### average=>'+salesAcumen.Partner_Lev_Sales_Acumen_Rating__c    );
            
            if(sumOfFields4!=0 && countFieldsToAverage4!=0)
            salesAcumen.Partner_Lev_Skill_Rating__c = sumOfFields4.divide(countFieldsToAverage4, 2, System.RoundingMode.UP);
            System.debug('#### average=>'+salesAcumen.Partner_Lev_Skill_Rating__c   );
            
            if(sumOfFields5!=0)
            //salesAcumen.Partner_Lev_Expertise_Total__c    = sumOfFields5.divide(countFieldsToAverage5, 2, System.RoundingMode.UP);
            salesAcumen.Partner_Lev_Expertise_Total__c  = sumOfFields5;
            System.debug('#### average=>'+salesAcumen.Partner_Lev_Expertise_Total__c    );
            
        }
        
    }
    /*end of calculateAverageRatings method*/
    
    
    
    /* @Method <This method is written to update the ratings entered by PTC and the
                rating date fields of the SE Skill Acumen Rating records on update>.
       @param  <This is taking a list of Partner SE Skill and Acumen object records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
    public static void updateRatingsEnteredAndDateFields(list<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSalesAcumen,Boolean isInsert)
    {
        Set<Id> setContactIds=new Set<Id>();
        Map<Id,List<Partner_SE_Skill_Sales_Acumen_Rating__c>> mapContactNewSESkills=new Map<Id,List<Partner_SE_Skill_Sales_Acumen_Rating__c>>();
        Map<Id,List<Partner_SE_Skill_Sales_Acumen_Rating__c>> mapContactOldSESkills=new Map<Id,List<Partner_SE_Skill_Sales_Acumen_Rating__c>>();
        if(isInsert)
        {
            for(Partner_SE_Skill_Sales_Acumen_Rating__c seObj:lstSalesAcumen)
            {
                System.debug('### inside update method=>'+seObj);
                setContactIds.add(seObj.Partner_SE__c);
                 List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstPartnerSESkill; 
                    lstPartnerSESkill= mapContactNewSESkills.get(seObj.Partner_SE__c);
                    if(lstPartnerSESkill==null)
                    {
                        lstPartnerSESkill=new list<Partner_SE_Skill_Sales_Acumen_Rating__c>();   
                    }
                    lstPartnerSESkill.add(seObj);
                    mapContactNewSESkills.put(seObj.Partner_SE__c,lstPartnerSESkill);
                
                    
            }
            List<Contact> lstContact=[select id,name,(select id,Ratings_Validated_by_Core_TC__c from Partner_SE_Skill_Sales_Acumen_Ratings__r where Ratings_Validated_by_Core_TC__c=false) from contact where id in :setContactIds];
            
            for(Contact contObj:lstContact)
            {
                List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstContactOldPartnerSESkills= contObj.Partner_SE_Skill_Sales_Acumen_Ratings__r;
                System.debug('#### lstContactOldPartnerSESkills'+lstContactOldPartnerSESkills);
                if(mapContactNewSESkills.containsKey(contObj.id) && lstContactOldPartnerSESkills.size()>0 && !mapContactOldSESkills.containsKey(contObj.id))
                mapContactOldSESkills.put(contObj.id,lstContactOldPartnerSESkills);
            }
            for(Partner_SE_Skill_Sales_Acumen_Rating__c seObj:lstSalesAcumen)
            {
                if(!mapContactOldSESkills.containsKey(seObj.Partner_SE__c))
                {
                    seObj.Ratings_Entered_by_PTC__c=UserInfo.getUserId();
                    seObj.Rating_Date__c=System.today();
                }
                else
                {
                    seObj.addError(System.Label.PRM_PL_Unvalidated_Acumen_Rating_Error_Message);
                }
            }
        }
        else
        {
            for(Partner_SE_Skill_Sales_Acumen_Rating__c seObj:lstSalesAcumen)
            {
                System.debug('### inside update method=>'+seObj);
                
                seObj.Ratings_Entered_by_PTC__c=UserInfo.getUserId();
                seObj.Rating_Date__c=System.today();
                    
            }
        }
    }
        
    
    
    /* @Method <This method is written to update the validated by, validated date fields and the
                recordtype of the SE Skill Acumen Rating records>.
       @param  <This is taking a list of Partner SE Skill and Acumen object records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
    public static void updateValidationFields(list<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSalesAcumen)
    {
        list<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSalesAcumenToUpdate=new list<Partner_SE_Skill_Sales_Acumen_Rating__c>();
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c SERecordTypes = (mapCustomSettingDataValueMap.get('SE_Skill_Sales_Acumen_Rating_Validated'));           
        String strRecType = SERecordTypes.DataValue__c;
        for(Partner_SE_Skill_Sales_Acumen_Rating__c seObj:lstSalesAcumen)
        {
            seObj.Validated_By__c=UserInfo.getUserId();
            seObj.Validation_Date__c=System.today();
            seObj.recordtypeid=strRecType;
            lstSalesAcumenToUpdate.add(seObj);
        }
        
    }
    
    
    
    /* @Method <This method is written to update the partner leverage factor for all the partner se contacts>.
       @param  <This is taking a list of Contact object records as argument>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
    public static void contactPartnerLevFactorCalculation(list<Contact> lstPartnerSEContacts)
    {
        Map<String,EMC_Business_Rules__c> mapWeightedValues=new Map<String,EMC_Business_Rules__c>();
        Map<String,List<EMC_BR_Education_Group_Record__c>> mapPLWeightingWithEducationGroupRecords=new Map<String,List<EMC_BR_Education_Group_Record__c>>();
        //List<EMC_BR_Education_Group_Record__c> lstTempEduGroupRecords=new List<EMC_BR_Education_Group_Record__c>();
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c maxScoreTarget = (mapCustomSettingDataValueMap.get('PRM_PL_Max_Score_Target'));           
        String strMaxTarget = maxScoreTarget.DataValue__c;
        CustomSettingDataValueMap__c PL_EMC_BR_RecordtypeId = (mapCustomSettingDataValueMap.get('PRM_PL_EMC_BR_PL_Rec_type'));   
        String strPLEMCBRRecordtypeId = PL_EMC_BR_RecordtypeId.DataValue__c;
        
       
        List<EMC_Business_Rules__c> lstPLFactorWeighting=[select id,name,Field_Name__c,Theater__c,weight__c,Maximum_Score__c,unit__c,(SELECT Group__c,Name,Speciality_Rule__c FROM Rule_Groups__r) from EMC_Business_Rules__c where recordtypeid=:strPLEMCBRRecordtypeId order by Theater__c];
        Map<String,Decimal> mapDcMaxTotalTheaterWise=new Map<String,Decimal>();
        
        if(lstPLFactorWeighting!=null && lstPLFactorWeighting.size()>0)
        {
            
            for(EMC_Business_Rules__c plObj:lstPLFactorWeighting)
            {
                List<EMC_BR_Education_Group_Record__c> lstTempEduGroupRecords= plObj.Rule_Groups__r;
                if(!mapWeightedValues.containsKey(plObj.Field_Name__c+'-'+plObj.Theater__c))
                mapWeightedValues.put(plObj.Field_Name__c+'-'+plObj.Theater__c,plObj);
                
                if(!mapPLWeightingWithEducationGroupRecords.containsKey(plObj.Field_Name__c+'-'+plObj.Theater__c))
                    {
                        mapPLWeightingWithEducationGroupRecords.put(plObj.Field_Name__c+'-'+plObj.Theater__c,lstTempEduGroupRecords);
                    }
                Decimal dcMaxTotal=0;
                
                if(mapDcMaxTotalTheaterWise.containsKey(plObj.Theater__c) && mapDcMaxTotalTheaterWise.get(plObj.Theater__c)!=null && plObj.Maximum_Score__c!=null)
                {
                    dcMaxTotal=mapDcMaxTotalTheaterWise.get(plObj.Theater__c)+plObj.Maximum_Score__c;
                    mapDcMaxTotalTheaterWise.put(plObj.Theater__c,dcMaxTotal);
                }
                else
                {
                    mapDcMaxTotalTheaterWise.put(plObj.Theater__c,plObj.Maximum_Score__c);
                }
                
                
            }
        }
        
      
        
        /*
        //Added by Ganesh     
        List<EMC_Business_Rules__c> lstPLFactorWeighting=[select id,name,Field_Name__c,Theater__c,weight__c,Maximum_Score__c,unit__c,(SELECT Group__c,Name,Speciality_Rule__c FROM Rule_Groups__r) from EMC_Business_Rules__c where recordtypeid=:strPLEMCBRRecordtypeId];         
        Map<String,Decimal> mapDcMaxTotalTheaterWise=new Map<String,Decimal>();
         
        String[] arrTheaters = new String[]{};     
        if(lstPLFactorWeighting!=null && lstPLFactorWeighting.size()>0)
        {            
            for(EMC_Business_Rules__c plObj:lstPLFactorWeighting)
            {  
                //split the theater's, if more than one is prestent in Theater__c field     
                if(plObj.Theater__c!=null)              
                arrTheaters =  plObj.Theater__c.split(';');            
                
                if(arrTheaters.size()>0)
                {
                    // Iterate through each theater 
                    for(string theater:arrTheaters)
                    {               
                        List<EMC_BR_Education_Group_Record__c> lstTempEduGroupRecords= plObj.Rule_Groups__r;
                        if(!mapWeightedValues.containsKey(plObj.Field_Name__c+'-'+theater))
                        mapWeightedValues.put(plObj.Field_Name__c+'-'+theater,plObj);
                        
                        if(!mapPLWeightingWithEducationGroupRecords.containsKey(plObj.Field_Name__c+'-'+theater))
                            {
                                mapPLWeightingWithEducationGroupRecords.put(plObj.Field_Name__c+'-'+theater,lstTempEduGroupRecords);
                            }
                        Decimal dcMaxTotal=0;
                        
                        if(mapDcMaxTotalTheaterWise.containsKey(theater) && plObj.Maximum_Score__c!=null)
                        {
                            dcMaxTotal=mapDcMaxTotalTheaterWise.get(theater)+plObj.Maximum_Score__c;
                            mapDcMaxTotalTheaterWise.put(theater,dcMaxTotal);
                        }
                        else
                        {
                            mapDcMaxTotalTheaterWise.put(theater,plObj.Maximum_Score__c);
                        }                
                    }
                }
            }
        }
        */
        
        System.debug('### mapWeightedValues=>'+mapWeightedValues);
        System.debug('### mapDcMaxTotalTheaterWise=>'+mapDcMaxTotalTheaterWise);
        
        String strPicklistValueCertification='Certification';
        String strPicklistValueExpertCertification='Expert Certification';
        String strPicklistValueAccreditation='Accreditation';
        String strCertification='PRM_PL_Certifications__c';
        String strExpertCertification='PRM_PL_Expert_Certifications__c';
        String strSEAccreditation='';
        //Commented as part of WR - 256428 (Contact simplification) for June Release.
        //String strSEBRSAccreditation='PRM_PL_has_BRS_Accreditation__c';
        String strSEConsolidationAccreditation='PRM_PL_has_Consolidation_Accreditation__c';
        String strSEGovernanceArchivedAccreditation='PRM_PL_has_Governance_Archive_Accred__c';
        String strAdjustedSales='PRM_PL_Adjusted_Sales_Acumen_Rating__c';
        String strUnAdjustedSales='PRM_PL_Unadjusted_Sales_Acumen_Rating__c';
        String strAdjustedSkills='PRM_PL_Adjusted_Product_Skill_Rating__c';
        String strUnAdjustedSkills='PRM_PL_Unadjusted_Product_Skill_Rating__c';
        String strOtherExpertise='PRM_PL_Other_Expertise__c';
        String strEMCPreSales='PRM_PL_EMC_Pre_Sales_FTE__c';
        String strEngagements='PRM_PL_Engagements__c';
        

        Set<Id> setContactIds=new Set<Id>();
        
        List<Id> lstTempEducationGroups=new List<Id>();
        //List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstTemp1=new List<Partner_SE_Skill_Sales_Acumen_Rating__c>();
        
        list<Contact> lstContactToUpdate=new list<Contact>();
        List<Education__c> lstEducation=new List<Education__c>();
        
        //Map<Id,Education_Master__c> mapEducationMaster=new Map<Id,Education_Master__c>();
        List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstPartnerSESkill=new List<Partner_SE_Skill_Sales_Acumen_Rating__c>();
        List<Partner_Performance_Rating_by_Field__c> lstPartnerPerfRating=new List<Partner_Performance_Rating_by_Field__c>();
        Map<Id,List<Education__c>> mapEducation=new Map<Id,List<Education__c>>();
        Map<String,List<Education__c>> mapContactEducationWithEducationType=new Map<String,List<Education__c>>();
        Set<Id> setEducationMasterIds=new Set<Id>();
        List<Education_Group_Member__c> lstEducationMasterGroupRecord=new List<Education_Group_Member__c>();
        Map<Id,Id> mapEducationMasterGroupRecord =new Map<Id,Id>();
        Map<Id,Partner_SE_Skill_Sales_Acumen_Rating__c> mapSESkill=new Map<Id,Partner_SE_Skill_Sales_Acumen_Rating__c>();
        Map<Id,List<Partner_Performance_Rating_by_Field__c>> mapPartnerPerfRating=new Map<Id,List<Partner_Performance_Rating_by_Field__c>>();
        Map<Id,Partner_Performance_Rating_by_Field__c> mapOppPerfRating=new Map<Id,Partner_Performance_Rating_by_Field__c>();
        
        List<Education_Group_Member__c> lstEducationMasterEducationGroup=new List<Education_Group_Member__c>();
        Map<Id,List<Id>> mapEducationMasterEducationGroup=new Map<Id,List<Id>>();
        if(lstPartnerSEContacts!=null && mapWeightedValues!=null && lstPartnerSEContacts.size()>0 && mapWeightedValues.size()>0)
        {
            
            for(Contact contObj:lstPartnerSEContacts)
            {
                setContactIds.add(contObj.id);
            }
            lstEducation=[select id,contact__c,type__c,category__c,level__c,Education_Master__c,Education_Master__r.name from education__c where contact__c in :setContactIds order by contact__c,type__c];
            lstPartnerSESkill=[select id,Partner_SE__c,Partner_SE_Overall_Sales_Acumen_Rating__c,latest_modified_skill_rating__c,
                               Partner_Lev_Sales_Acumen_Rating__c,Partner_SE_Overall_Skill_Rating__c,Partner_Lev_Skill_Rating__c,
                               Partner_Lev_Expertise_Total__c,lastmodifieddate from Partner_SE_Skill_Sales_Acumen_Rating__c where 
                               Partner_SE__c in :setContactIds and latest_modified_skill_rating__c=true and Ratings_Validated_by_Core_TC__c=false];
            lstPartnerPerfRating=[select id,opportunity__c,partner_se__c from Partner_Performance_Rating_by_Field__c where partner_se__c
                                  in :setContactIds];
            /*if(lstEducation!=null && lstEducation.size()>0)
            {
                
                for(Education__c eduObj:lstEducation)
                {
                    setEducationIds.add(eduObj.id);
                    List<Education__c> lstTemp;
                    lstTemp=mapEducation.get(eduObj.contact__c);
                    if(lstTemp==null)
                    {
                        lstTemp=new List<Education__c>();
                    }
                    lstTemp.add(eduObj);
                    mapEducation.put(eduObj.contact__c,lstTemp);
                    
                }
                System.debug('##### mapEducation=>'+mapEducation);
                lstEducationEducationGroupMapping=[SELECT id,Contact_Status__c, Name, ContactId__c, Education__c, Education_Group__c,isPartnerSEContact__c FROM Education_EducationGroup_Mapping__c where education__c in :setEducationIds order by education__c];
            }*/
            if(lstEducation!=null && lstEducation.size()>0)
            {
                
                for(Education__c eduObj:lstEducation)
                {
                    setEducationMasterIds.add(eduObj.Education_Master__c);
                    List<Education__c> lstTemp;
                    System.debug('##### eduObj=>'+eduObj);
                    System.debug('##### eduObj.type__c=>'+eduObj.type__c);
                    System.debug('##### eduObj.contact__c=>'+eduObj.contact__c);
                    if(eduObj.type__c=='Certification' && eduObj.level__c!='Expert')
                    {
                        lstTemp=mapContactEducationWithEducationType.get(eduObj.contact__c+'-'+strPicklistValueCertification);
                        System.debug('##### in here in cert');
                        if(lstTemp==null)
                        {
                            lstTemp=new List<Education__c>();
                        }
                        
                    }
                    else if(eduObj.type__c=='Certification' && eduObj.level__c=='Expert')
                    {
                        lstTemp=mapContactEducationWithEducationType.get(eduObj.contact__c+'-'+strPicklistValueExpertCertification);
                        System.debug('##### in here in expert cert');
                        if(lstTemp==null)
                        {
                            lstTemp=new List<Education__c>();
                        }
                        
                    }
                    else if(eduObj.type__c=='Accreditation')
                    {
                        lstTemp=mapContactEducationWithEducationType.get(eduObj.contact__c+'-'+strPicklistValueAccreditation);
                        System.debug('##### in here in accred');
                        if(lstTemp==null)
                        {
                            lstTemp=new List<Education__c>();
                        }                       
                        
                    }
                    if(eduObj.type__c=='Certification' && eduObj.level__c!='Expert')
                    {
                        lstTemp.add(eduObj);
                        System.debug('##### in here in cert');
                        mapContactEducationWithEducationType.put(eduObj.contact__c+'-'+strPicklistValueCertification,lstTemp);
                    }  
                    if(eduObj.type__c=='Certification' && eduObj.level__c=='Expert')
                    {
                        lstTemp.add(eduObj);
                        System.debug('##### in here in expert cert');
                        mapContactEducationWithEducationType.put(eduObj.contact__c+'-'+strPicklistValueExpertCertification,lstTemp);
                    }  
                    if(eduObj.type__c=='Accreditation')
                    {
                        lstTemp.add(eduObj);
                        System.debug('##### in here in accred');
                        mapContactEducationWithEducationType.put(eduObj.contact__c+'-'+strPicklistValueAccreditation,lstTemp);
                    }                    
                }
                System.debug('##### mapContactEducationWithEducationType=>'+mapContactEducationWithEducationType);
                lstEducationMasterEducationGroup=[SELECT id,name,Education_Group__c, Education_Master__c FROM Education_Group_Member__c where Education_Master__c in :setEducationMasterIds order by Education_Master__c];
            }
            if(lstEducationMasterEducationGroup!=null && lstEducationMasterEducationGroup.size()>0)
            {
                for(Education_Group_Member__c eduGroupMemberObj:lstEducationMasterEducationGroup)
                {    
                    List<Id> lstEducationGroupIds; 
                    lstEducationGroupIds= mapEducationMasterEducationGroup.get(eduGroupMemberObj.Education_Master__c);
                    if(lstEducationGroupIds==null)
                    {
                        lstEducationGroupIds=new list<Id>();   
                    }
                    lstEducationGroupIds.add(eduGroupMemberObj.Education_Group__c);
                    mapEducationMasterEducationGroup.put(eduGroupMemberObj.Education_Master__c,lstEducationGroupIds);
                }
                System.debug('#### mapEducationMasterEducationGroup=>'+mapEducationMasterEducationGroup);
            }
            
            if(lstPartnerSESkill!=null && lstPartnerSESkill.size()>0)
            {
                for(Partner_SE_Skill_Sales_Acumen_Rating__c seSkillObj:lstPartnerSESkill)
                {
                    if(!mapSESkill.containsKey(seSkillObj.Partner_SE__c))
                    {
                        mapSESkill.put(seSkillObj.Partner_SE__c,seSkillObj);
                    }
                }
                System.debug('### mapSESkill=>'+mapSESkill);
            }
            if(lstPartnerPerfRating!=null && lstPartnerPerfRating.size()>0)
            {
                System.debug('#### partner perf rating');
                for(Partner_Performance_Rating_by_Field__c partPerfObj:lstPartnerPerfRating)
                {
                    List<Partner_Performance_Rating_by_Field__c> lstTemp2;
                    lstTemp2=mapPartnerPerfRating.get(partPerfObj.partner_se__c);
                    if(lstTemp2==null)
                    lstTemp2=new List<Partner_Performance_Rating_by_Field__c>();
                    lstTemp2.add(partPerfObj);
                    mapPartnerPerfRating.put(partPerfObj.partner_se__c,lstTemp2);
                    System.debug('##### lstTemp2.size()'+lstTemp2.size());
                }
                
                System.debug('##### mapPartnerPerfRating'+mapPartnerPerfRating);
                System.debug('##### mapPartnerPerfRating.size()'+mapPartnerPerfRating.size());
            }
            
            
            for(Contact contObj:lstPartnerSEContacts)
            {
                Decimal dcCertificationValues=0;
                Decimal dcExpertCertificationValues=0;
                Decimal dcSEBRSAccreditation=0;
                Decimal dcSEConsolidationAccreditation=0;
                Decimal dcSEGovernanceArchivedAccreditation=0;
                
                Decimal dcAdjustedSalesAcumenRating=0;
                Decimal dcUnAdjustedSalesAcumenRating=0;
                Decimal dcAdjustedProductSkillRating=0;
                Decimal dcUnAdjustedProductSkillRating=0;
                Decimal dcOtherExpertise=0;
                Decimal dcEMCPreSales=0;
                String strEngagementWeightedAndRatedDeals='';
                Decimal dcRatedDeals=0;
                Decimal dcEngagements=0;
                Decimal dcPartnerLeverageTotal=0;
                Decimal dcMaxScoreTarget=decimal.valueOf(strMaxTarget);
                Decimal dcPartnerLeverageFactor=0;
                
                contObj.PRM_PL_Certifications__c=null;
                contObj.PRM_PL_Expert_Certifications__c=null;
                contObj.PRM_PL_has_Consolidation_Accreditation__c=null;
                contObj.PRM_PL_has_Governance_Archive_Accred__c=null;
                //Commented as part of WR - 256428 (Contact simplification) for June Release.
                //contObj.PRM_PL_has_BRS_Accreditation__c=null;
                contObj.PRM_PL_Adjusted_Sales_Acumen_Rating__c=null;
                contObj.PRM_PL_Unadjusted_Sales_Acumen_Rating__c=null;
                contObj.PRM_PL_Adjusted_Product_Skill_Rating__c=null;
                contObj.PRM_PL_Unadjusted_Product_Skill_Rating__c=null;
                contObj.PRM_PL_Other_Expertise__c=null;
                contObj.PRM_PL_EMC_Pre_Sales_FTE__c=null;
                contObj.PRM_PL_Engagements__c=null;
                contObj.PRM_PL_Factor_Calculated__c =false;
                contObj.Partner_Leverage_Factor__c=null;
                System.debug('#### contObj.Partner_Leverage_Factor__c=>'+contObj.Partner_Leverage_Factor__c);
                if(mapContactEducationWithEducationType.containsKey(contObj.id+'-'+strPicklistValueCertification) && mapWeightedValues.containsKey(strCertification+'-'+contObj.Account_Theater__c))
                {
                    dcCertificationValues=calculateEducationValues(mapContactEducationWithEducationType.get(contObj.id+'-'+strPicklistValueCertification),mapWeightedValues,mapPLWeightingWithEducationGroupRecords,mapEducationMasterEducationGroup,strCertification,contObj.Account_Theater__c,strPicklistValueCertification);
                    if(dcCertificationValues!=0.0)
                    contObj.PRM_PL_Certifications__c=dcCertificationValues;
                }
                if(mapContactEducationWithEducationType.containsKey(contObj.id+'-'+strPicklistValueExpertCertification) && mapWeightedValues.containsKey(strExpertCertification+'-'+contObj.Account_Theater__c))
                {
                    dcExpertCertificationValues=calculateEducationValues(mapContactEducationWithEducationType.get(contObj.id+'-'+strPicklistValueExpertCertification),mapWeightedValues,mapPLWeightingWithEducationGroupRecords,mapEducationMasterEducationGroup,strExpertCertification,contObj.Account_Theater__c,strPicklistValueExpertCertification);
                    if(dcExpertCertificationValues!=0.0)
                    contObj.PRM_PL_Expert_Certifications__c=dcExpertCertificationValues;
                }
                if(mapContactEducationWithEducationType.containsKey(contObj.id+'-'+strPicklistValueAccreditation) && mapWeightedValues.containsKey(strSEConsolidationAccreditation+'-'+contObj.Account_Theater__c))
                {
                    dcSEConsolidationAccreditation=calculateEducationValues(mapContactEducationWithEducationType.get(contObj.id+'-'+strPicklistValueAccreditation),mapWeightedValues,mapPLWeightingWithEducationGroupRecords,mapEducationMasterEducationGroup,strSEConsolidationAccreditation,contObj.Account_Theater__c,strPicklistValueAccreditation);
                    if(dcSEConsolidationAccreditation!=0.0)
                    contObj.PRM_PL_has_Consolidation_Accreditation__c=dcSEConsolidationAccreditation;
                }
                if(mapContactEducationWithEducationType.containsKey(contObj.id+'-'+strPicklistValueAccreditation) && mapWeightedValues.containsKey(strSEGovernanceArchivedAccreditation+'-'+contObj.Account_Theater__c))
                {
                    dcSEGovernanceArchivedAccreditation=calculateEducationValues(mapContactEducationWithEducationType.get(contObj.id+'-'+strPicklistValueAccreditation),mapWeightedValues,mapPLWeightingWithEducationGroupRecords,mapEducationMasterEducationGroup,strSEGovernanceArchivedAccreditation,contObj.Account_Theater__c,strPicklistValueAccreditation);
                    if(dcSEGovernanceArchivedAccreditation!=0.0)
                    contObj.PRM_PL_has_Governance_Archive_Accred__c=dcSEGovernanceArchivedAccreditation;
                }
               /*
               Commented as part of WR - 256428 (Contact simplification) for June Release.
               if(mapContactEducationWithEducationType.containsKey(contObj.id+'-'+strPicklistValueAccreditation) && mapWeightedValues.containsKey(strSEBRSAccreditation+'-'+contObj.Account_Theater__c))
                {
                    dcSEBRSAccreditation=calculateEducationValues(mapContactEducationWithEducationType.get(contObj.id+'-'+strPicklistValueAccreditation),mapWeightedValues,mapPLWeightingWithEducationGroupRecords,mapEducationMasterEducationGroup,strSEBRSAccreditation,contObj.Account_Theater__c,strPicklistValueAccreditation);
                    //if(dcSEBRSAccreditation!=0.0)
                    //contObj.PRM_PL_has_BRS_Accreditation__c=dcSEBRSAccreditation;
                }
                */
                if(mapSESkill.containsKey(contObj.id) && mapWeightedValues.containsKey(strAdjustedSales+'-'+contObj.Account_Theater__c) && mapSESkill.get(contObj.id).Partner_SE_Overall_Sales_Acumen_Rating__c!=null)
                {
                    dcAdjustedSalesAcumenRating=(mapSESkill.get(contObj.id).Partner_SE_Overall_Sales_Acumen_Rating__c / mapWeightedValues.get(strAdjustedSales+'-'+contObj.Account_Theater__c).unit__c) * mapWeightedValues.get(strAdjustedSales+'-'+contObj.Account_Theater__c).weight__c;
                    if(dcAdjustedSalesAcumenRating>mapWeightedValues.get(strAdjustedSales+'-'+contObj.Account_Theater__c).maximum_score__c)
                    dcAdjustedSalesAcumenRating=mapWeightedValues.get(strAdjustedSales+'-'+contObj.Account_Theater__c).maximum_score__c ;
                    contObj.PRM_PL_Adjusted_Sales_Acumen_Rating__c=dcAdjustedSalesAcumenRating;
                }
                if(mapSESkill.containsKey(contObj.id) && mapWeightedValues.containsKey(strUnAdjustedSales+'-'+contObj.Account_Theater__c) && mapSESkill.get(contObj.id).Partner_Lev_Sales_Acumen_Rating__c!=null)
                {
                    dcUnAdjustedSalesAcumenRating=(mapSESkill.get(contObj.id).Partner_Lev_Sales_Acumen_Rating__c / mapWeightedValues.get(strUnAdjustedSales+'-'+contObj.Account_Theater__c).unit__c) * mapWeightedValues.get(strUnAdjustedSales+'-'+contObj.Account_Theater__c).weight__c;
                    if(dcUnAdjustedSalesAcumenRating>mapWeightedValues.get(strUnAdjustedSales+'-'+contObj.Account_Theater__c).maximum_score__c)
                    dcUnAdjustedSalesAcumenRating=mapWeightedValues.get(strUnAdjustedSales+'-'+contObj.Account_Theater__c).maximum_score__c ;
                    contObj.PRM_PL_Unadjusted_Sales_Acumen_Rating__c=dcUnAdjustedSalesAcumenRating;
                }
                if(mapSESkill.containsKey(contObj.id) && mapWeightedValues.containsKey(strAdjustedSkills+'-'+contObj.Account_Theater__c) && mapSESkill.get(contObj.id).Partner_SE_Overall_Skill_Rating__c!=null)
                {
                    dcAdjustedProductSkillRating=(mapSESkill.get(contObj.id).Partner_SE_Overall_Skill_Rating__c / mapWeightedValues.get(strAdjustedSkills+'-'+contObj.Account_Theater__c).unit__c) * mapWeightedValues.get(strAdjustedSkills+'-'+contObj.Account_Theater__c).weight__c;
                    if(dcAdjustedProductSkillRating>mapWeightedValues.get(strAdjustedSkills+'-'+contObj.Account_Theater__c).maximum_score__c)
                    dcAdjustedProductSkillRating=mapWeightedValues.get(strAdjustedSkills+'-'+contObj.Account_Theater__c).maximum_score__c;
                    contObj.PRM_PL_Adjusted_Product_Skill_Rating__c=dcAdjustedProductSkillRating;
                }
                if(mapSESkill.containsKey(contObj.id) && mapWeightedValues.containsKey(strUnAdjustedSkills+'-'+contObj.Account_Theater__c) && mapSESkill.get(contObj.id).Partner_Lev_Skill_Rating__c!=null)
                {
                    dcUnAdjustedProductSkillRating=(mapSESkill.get(contObj.id).Partner_Lev_Skill_Rating__c / mapWeightedValues.get(strUnAdjustedSkills+'-'+contObj.Account_Theater__c).unit__c) * mapWeightedValues.get(strUnAdjustedSkills+'-'+contObj.Account_Theater__c).weight__c;
                    if(dcUnAdjustedProductSkillRating>mapWeightedValues.get(strUnAdjustedSkills+'-'+contObj.Account_Theater__c).maximum_score__c)
                    dcUnAdjustedProductSkillRating=(mapWeightedValues.get(strUnAdjustedSkills+'-'+contObj.Account_Theater__c).maximum_score__c / mapWeightedValues.get(strUnAdjustedSkills+'-'+contObj.Account_Theater__c).unit__c) * mapWeightedValues.get(strUnAdjustedSkills+'-'+contObj.Account_Theater__c).weight__c;
                    contObj.PRM_PL_Unadjusted_Product_Skill_Rating__c=dcUnAdjustedProductSkillRating;
                }
                if(mapSESkill.containsKey(contObj.id) && mapWeightedValues.containsKey(strOtherExpertise+'-'+contObj.Account_Theater__c) && mapSESkill.get(contObj.id).Partner_Lev_Expertise_Total__c!=null)
                {
                    System.debug('### contObj.id=>'+contObj.id);
                    System.debug('#### mapSESkill.get(contObj.id).Partner_Lev_Expertise_Total__c=>'+mapSESkill.get(contObj.id).Partner_Lev_Expertise_Total__c);
                    dcOtherExpertise=(mapSESkill.get(contObj.id).Partner_Lev_Expertise_Total__c / mapWeightedValues.get(strOtherExpertise+'-'+contObj.Account_Theater__c).unit__c) * mapWeightedValues.get(strOtherExpertise+'-'+contObj.Account_Theater__c).weight__c;
                    if(dcOtherExpertise>mapWeightedValues.get(strOtherExpertise+'-'+contObj.Account_Theater__c).maximum_score__c)
                    dcOtherExpertise=mapWeightedValues.get(strOtherExpertise+'-'+contObj.Account_Theater__c).maximum_score__c;
                    contObj.PRM_PL_Other_Expertise__c=dcOtherExpertise;
                }
                System.debug('### contObj.id=>'+contObj.id);
                System.debug('### contObj.EMC_Pre_Sales__c=>'+contObj.EMC_Pre_Sales__c);
                if(contObj.EMC_Pre_Sales__c!=null && mapWeightedValues.containsKey(strEMCPreSales+'-'+contObj.Account_Theater__c))
                {
                    System.debug('### in here');
                    List<String> split1 = new List<String>();
                    for(String s: contObj.EMC_Pre_Sales__c.Split('%')){
                        split1.add(s);
                    }
                    System.debug('#### split1=>'+split1);
                    if(split1!=null && split1.size()>0)
                        dcEMCPreSales=(Decimal.valueof(split1[0]) / mapWeightedValues.get(strEMCPreSales+'-'+contObj.Account_Theater__c).unit__c) * mapWeightedValues.get(strEMCPreSales+'-'+contObj.Account_Theater__c).weight__c;
                    if(dcEMCPreSales>mapWeightedValues.get(strEMCPreSales+'-'+contObj.Account_Theater__c).maximum_score__c)
                        dcEMCPreSales=(mapWeightedValues.get(strEMCPreSales+'-'+contObj.Account_Theater__c).maximum_score__c / mapWeightedValues.get(strEMCPreSales+'-'+contObj.Account_Theater__c).unit__c) * mapWeightedValues.get(strEMCPreSales+'-'+contObj.Account_Theater__c).weight__c;
                    
                    contObj.PRM_PL_EMC_Pre_Sales_FTE__c=dcEMCPreSales;
                }
                if(mapPartnerPerfRating.containsKey(contObj.id) && mapWeightedValues.containsKey(strEngagements+'-'+contObj.Account_Theater__c))
                {
                    
                    strEngagementWeightedAndRatedDeals=calculateEngagementValues(mapPartnerPerfRating.get(contObj.id),mapWeightedValues.get(strEngagements+'-'+contObj.Account_Theater__c).weight__c,mapWeightedValues.get(strEngagements+'-'+contObj.Account_Theater__c).maximum_score__c,mapWeightedValues.get(strEngagements+'-'+contObj.Account_Theater__c).unit__c);
                    List<String> split2 = new List<String>();
                    for(String s: strEngagementWeightedAndRatedDeals.Split('-')){
                        split2.add(s);
                    }
                    contObj.PRM_PL_Engagements__c=Decimal.valueof(split2[0]);
                    dcEngagements=contObj.PRM_PL_Engagements__c;
                    contObj.PRM_PL_Rated_Deals__c=Decimal.valueof(split2[1]);
                }
                System.debug('#### dcCertificationValues'+dcCertificationValues);   
                System.debug('#### dcExpertCertificationValues'+dcExpertCertificationValues);   
                System.debug('#### dcSEConsolidationAccreditation'+dcSEConsolidationAccreditation);   
                System.debug('#### dcSEGovernanceArchivedAccreditation'+dcSEGovernanceArchivedAccreditation);   
                System.debug('#### dcSEBRSAccreditation'+dcSEBRSAccreditation);   
                System.debug('#### dcAdjustedSalesAcumenRating'+dcAdjustedSalesAcumenRating);
                System.debug('#### dcUnAdjustedSalesAcumenRating'+dcUnAdjustedSalesAcumenRating);
                System.debug('#### dcAdjustedProductSkillRating'+dcAdjustedProductSkillRating);
                System.debug('#### dcUnAdjustedProductSkillRating'+dcUnAdjustedProductSkillRating);
                System.debug('#### dcOtherExpertise'+dcOtherExpertise);
                System.debug('#### dcEMCPreSales'+dcEMCPreSales);
                System.debug('#### dcEngagements'+dcEngagements);
                dcPartnerLeverageTotal=dcCertificationValues + dcExpertCertificationValues + dcSEConsolidationAccreditation + dcSEGovernanceArchivedAccreditation +
                                       dcSEBRSAccreditation + dcAdjustedSalesAcumenRating + dcUnAdjustedSalesAcumenRating + dcAdjustedProductSkillRating +
                                       dcUnAdjustedProductSkillRating + dcOtherExpertise + dcEMCPreSales + dcEngagements;
                System.debug('#### dcPartnerLeverageTotal'+dcPartnerLeverageTotal);     
                
                System.debug('#### mapDcMaxTotalTheaterWise.get(contObj.Account_Theater__c)'+mapDcMaxTotalTheaterWise.get(contObj.Account_Theater__c)); 
                
                if(mapDcMaxTotalTheaterWise.containsKey(contObj.Account_Theater__c) && mapSESkill.containsKey(contObj.id))
                {
                    dcPartnerLeverageFactor=dcPartnerLeverageTotal/mapDcMaxTotalTheaterWise.get(contObj.Account_Theater__c) * dcMaxScoreTarget;
                    contObj.Partner_Leverage_Factor__c=dcPartnerLeverageFactor;
                    System.debug('#### dcPartnerLeverageFactor'+dcPartnerLeverageFactor);   
                    if(contObj.Partner_Leverage_Factor__c>0){
                        System.debug('#### contObj.Partner_Leverage_Factor__c=>'+contObj.Partner_Leverage_Factor__c);
                        contObj.PRM_PL_Factor_Calculated__c =true;
                        lstContactToUpdate.add(contObj);
                    }
                }
                else 
                lstContactToUpdate.add(contObj);
                
            }
            if(lstContactToUpdate!=null && lstContactToUpdate.size()>0)
            {
                update lstContactToUpdate;
            }
            
        }
    }
    /*end of contactPartnerLevFactorCalculation method*/
    
    /* @Method <This method is written to calculate the number of education records for a partner se contact>.
       @param  <This is taking a list of education object records,weight and max score as arguments>
       @return void - <return decimal count>  
       @throws exception - <No Exception>
    */
    public static decimal calculateEducationValues(List<Education__c> lstEducation,Map<String,EMC_Business_Rules__c> mapWeightedValues,Map<String,List<EMC_BR_Education_Group_Record__c>> mapPLWeightingWithEducationGroupRecords,Map<Id,List<Id>> mapEducationMasterEducationGroup,String strEducationField,String theater,String strEducationParameterType)
    {
        System.debug('##### mapPLWeightingWithEducationGroupRecords=>'+mapPLWeightingWithEducationGroupRecords);
        Decimal certifications=0;
        Set<Id> setEducationUniqueGroups=new Set<Id>();
        if(lstEducation!=null && lstEducation.size()>0)
        {
            for(Education__c eduObj:lstEducation)
            {
                System.debug('### eduObj.contact__c=>'+eduObj.contact__c);
                System.debug('### eduObj=>'+eduObj);
                System.debug('### mapEducationMasterEducationGroup'+mapEducationMasterEducationGroup);
                if(mapEducationMasterEducationGroup.containsKey(eduObj.Education_Master__c) 
                && mapPLWeightingWithEducationGroupRecords.containsKey(strEducationField+'-'+theater))
                {
                    System.debug('#### inside first if');
                    for(EMC_BR_Education_Group_Record__c eduGroupRecordObj:mapPLWeightingWithEducationGroupRecords.get(strEducationField+'-'+theater))
                    {
                        System.debug('#### inside first for');
                        for(Id educationGroupId:mapEducationMasterEducationGroup.get(eduObj.Education_Master__c))
                        {
                            System.debug('#### inside second for');
                            if(educationGroupId==eduGroupRecordObj.Group__c)
                            {
                                System.debug('#### inside second if');
                                setEducationUniqueGroups.add(educationGroupId);
                            }
                        }
                        
                    }
                }
            }
            if(setEducationUniqueGroups!=null && setEducationUniqueGroups.size()>0)
            {
                System.debug('### setEducationUniqueGroups'+setEducationUniqueGroups);
                certifications=setEducationUniqueGroups.size();
            }
        }    
        if((certifications / mapWeightedValues.get(strEducationField+'-'+theater).unit__c) * mapWeightedValues.get(strEducationField+'-'+theater).weight__c >= mapWeightedValues.get(strEducationField+'-'+theater).maximum_score__c)
        certifications=mapWeightedValues.get(strEducationField+'-'+theater).maximum_score__c;
        else 
        certifications=(certifications / mapWeightedValues.get(strEducationField+'-'+theater).unit__c) * mapWeightedValues.get(strEducationField+'-'+theater).weight__c;
        return certifications;
    }
    /*end of calculateEducationValues method*/
    
    
    
    /* @Method <This method is written to calculate the number of certifications for a partner se contact>.
       @param  <This is taking a list of education object records,weight and max score as arguments>
       @return void - <return decimal count>  
       @throws exception - <No Exception>
    */
    public static string calculateEngagementValues(List<Partner_Performance_Rating_by_Field__c> lstPartPerfRating,Decimal weight,Decimal maxScore,Decimal Range)
    {
        
        Decimal engagements=0;
        Decimal ratedDeals=0;
        Set<Id> setOppIds=new Set<Id>();
        if(lstPartPerfRating!=null && lstPartPerfRating.size()>0)
        {
            for(Partner_Performance_Rating_by_Field__c partPerfObj:lstPartPerfRating)
            {
                setOppIds.add(partPerfObj.opportunity__c);
            }
        }   
        ratedDeals=setOppIds.size();
        String strEngagementWeightedAndRatedDeal='';
        System.debug('#### setOppIds=>'+setOppIds); 
        System.debug('#### Range=>'+Range); 
        System.debug('#### maxScore=>'+maxScore);   
        
        if(setOppIds!=null && setOppIds.size()>0)
        {
            engagements=setOppIds.size();
            if(Math.ceil(engagements.Divide(Range, 2,System.RoundingMode.UP))>maxScore)
            engagements=Math.ceil(maxScore.Divide(Range, 2,System.RoundingMode.UP)) * weight; 
            else if(Math.ceil(engagements.Divide(Range, 2,System.RoundingMode.UP))>0 && Math.ceil(engagements.Divide(Range, 2,System.RoundingMode.UP)) < maxScore)
            engagements=Math.ceil(engagements.Divide(Range, 2,System.RoundingMode.UP)) * weight;
        }
        System.debug('#### engagements=>'+engagements); 
        strEngagementWeightedAndRatedDeal=engagements+'-'+ratedDeals;
        return strEngagementWeightedAndRatedDeal;
    }
    
    /*end of calculateEngagementValues method*/
    
    
    /* @Method <This method is written to calculate the number of certifications for a partner se contact>.
       @param  <This is taking a list of education object records,weight and max score as arguments>
       @return void - <return decimal count>  
       @throws exception - <No Exception>
    */
    public static void accountPartnerLevFactorCalculation(Set<Id> setGroupingIds,String Batchid,List<EMCException> emailerrors)
    {
        Set<Id> setAllAccountsInGrouping=new Set<Id>();
        List<Contact> lstContactsFromGrouping=new List<Contact>();
         Database.SaveResult[] results;
        List <EMCException> errors = new List <EMCException>(); 
       Map<Id,Account> mapAllAccountsFromGrouping=new Map<Id,Account>([select account.id,account.grouping__c,account.PROFILED_ACCOUNT_FLAG__c,
                                                                        account.name,account.rating_eligible__c,account.theater1__c from account where 
                                                                        account.grouping__c in :setGroupingIds order by account.grouping__c]);
        //Map<Id,List<Account>> mapProfiledAccountWithGroupingAccounts=new Map<Id,List<Account>>();
        for(Account accObj:mapAllAccountsFromGrouping.values())
        {
            setAllAccountsInGrouping.add(accObj.id);
        }
        if(setAllAccountsInGrouping!=null && setAllAccountsInGrouping.size()>0)
        {
            lstContactsFromGrouping=[select id,name,accountid,Partner_Leverage_Factor__c from contact
             where accountid in :setAllAccountsInGrouping and partner_se__c=true and Partner_Leverage_Factor__c!=null];
        }
        Map<Id,List<Contact>> mapAccountsWithContacts= new Map<Id,List<Contact>>();
        if(lstContactsFromGrouping!=null && lstContactsFromGrouping.size()>0)
        {
            for(Contact contObj:lstContactsFromGrouping)
            {
                List<Contact> lstTempContact;
                lstTempContact=mapAccountsWithContacts.get(contObj.accountid);
                if(lstTempContact==null)
                {
                    lstTempContact=new List<Contact>();
                }
                lstTempContact.add(contObj);
                mapAccountsWithContacts.put(contObj.accountid,lstTempContact);
                
            }
        }
        Decimal partnerLeverageFactorTotal=0.0;
        Decimal partnerLeverageFactorAverage=0.0;
        map<Id,List<Account>> mapGroupingIdWithAllAccounts=new map<Id,List<Account>>();
        Map<Id,List<Contact>> mapAccountPartnerSEContacts=new Map<Id,List<Contact>>();
        System.debug('#### mapAllAccountsFromGrouping.size()=>'+mapAllAccountsFromGrouping.size());
        System.debug('#### mapAllAccountsFromGrouping=>'+mapAllAccountsFromGrouping);
        if(mapAllAccountsFromGrouping!=null && mapAllAccountsFromGrouping.size()>0)
        {
            for(Account accObj:mapAllAccountsFromGrouping.values())
            {
                /*if(mapAccountsWithContacts.get(accObj.id)!=null)
                {
                    System.debug('#### accObj.name=>'+accObj.name);
                    System.debug('#### accObj.contact=>'+accObj.contacts);
                    mapAccountPartnerSEContacts.put(accObj.id,mapAccountsWithContacts.get(accObj.id));
                }*/
            
                List<Account> lstTemp;
                lstTemp=mapGroupingIdWithAllAccounts.get(accObj.grouping__c);
                if(lstTemp==null)
                {
                    lstTemp=new List<Account>();
                }
                lstTemp.add(accObj);
                mapGroupingIdWithAllAccounts.put(accObj.grouping__c,lstTemp);
            }
        }
        List<Account> lstAccountToUpdate=new List<Account>();
        Id idProfiledAccount;
        if(mapGroupingIdWithAllAccounts!=null && mapGroupingIdWithAllAccounts.size()>0)
        {
            System.debug('#### mapGroupingIdWithAllAccounts=>'+mapGroupingIdWithAllAccounts);
            if(mapAccountsWithContacts!=null && mapAccountsWithContacts.size()>0)
            {
                for(Id groupingId:mapGroupingIdWithAllAccounts.keySet())
                {
                    partnerLeverageFactorTotal=0.0;
                    Integer iCounterContacts=0;
                    if(mapGroupingIdWithAllAccounts.get(groupingId)!=null)
                    {
                        for(Account accObj:mapGroupingIdWithAllAccounts.get(groupingId))
                        {
                            if(mapAccountsWithContacts.get(accObj.id)!=null)
                            {
                                for(Contact contObj:mapAccountsWithContacts.get(accObj.id))
                                {
                                    if(contObj.Partner_Leverage_Factor__c!=null)
                                    partnerLeverageFactorTotal=partnerLeverageFactorTotal+contObj.Partner_Leverage_Factor__c;
                                    iCounterContacts++;
                                }
                            }
                            if(accObj.PROFILED_ACCOUNT_FLAG__c==true && accObj.Rating_Eligible__c==true)
                            {
                                idProfiledAccount=accObj.id;
                            }
                        }
                    }
                    
                    Account acc=new Account();
                    acc=mapAllAccountsFromGrouping.get(idProfiledAccount);
                    if(partnerLeverageFactorTotal!=0.0 && iCounterContacts!=0)
                    {   
                        if(acc!=null){ 
                            partnerLeverageFactorAverage=partnerLeverageFactorTotal/iCounterContacts;
                            acc.Partner_Leverage_Factor_Total__c=partnerLeverageFactorTotal;
                            acc.Partner_Leverage_Factor_Average__c=partnerLeverageFactorAverage;
                            lstAccountToUpdate.add(acc);
                        }
                    }
                    System.debug('#### partnerLeverageFactorTotal=>'+partnerLeverageFactorTotal);
                    System.debug('#### partnerLeverageFactorAverage=>'+partnerLeverageFactorAverage);
                    System.debug('#### lstAccountToUpdate=>'+lstAccountToUpdate);
                }
            }
        }
       if(lstAccountToUpdate!=null && lstAccountToUpdate.size()>0)
        {
            results =database.update(lstAccountToUpdate,false);
              /* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : results) {
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		                // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);
		                errors.add(new EMCException(dataErrs, Batchid, new String [] {sr.getId()}));
		            }
		        }		       
		      // log any errors that occurred
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors);
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors);  
		        }		  
        }
    }
    
    /*end of updatePartnerPerformanceCompleted method*/
    /* @Method <This method is written to update the Partner Performance Rating Completed checkbox on Opportunity>.
       @param  <This is taking a set of opportunity ids and a boolean field to check whether its insert or delete>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
    public static void updatePartnerPerformanceCompleted(Set<Id> setOpportunityIds,Boolean IsInsert)
    {
        Map<Id,Opportunity> mapOpportunityObjRecs; 
        List<Opportunity> lstOpportunityToUpdate=new List<Opportunity>();
        if(IsInsert)
        {
            mapOpportunityObjRecs=new Map<Id,Opportunity>([select id,name,PRM_PL_Perf_Rating_Completed__c from opportunity where id in :setOpportunityIds and PRM_PL_Perf_Rating_Completed__c=false]);
            if(mapOpportunityObjRecs.size()>0)
            {
                for(Opportunity oppObj:mapOpportunityObjRecs.values())
                {
                    oppObj.PRM_PL_Perf_Rating_Completed__c=true;
                    lstOpportunityToUpdate.add(oppObj);
                }
                if(lstOpportunityToUpdate.size()>0)
                {
                    update lstOpportunityToUpdate;
                }
            }
        }
        else
        {
            mapOpportunityObjRecs=new Map<Id,Opportunity>([select id,name,(select id,name,opportunity__c from TC_Offloads__r),PRM_PL_Perf_Rating_Completed__c from opportunity where id in :setOpportunityIds and PRM_PL_Perf_Rating_Completed__c=true]);
            if(mapOpportunityObjRecs.size()>0)
            {
                for(Opportunity oppObj:mapOpportunityObjRecs.values())
                {
                    List<Partner_Performance_Rating_by_Field__c> lstPartnerPerfRecords=mapOpportunityObjRecs.get(oppObj.id).TC_Offloads__r;
                    System.debug('### lstPartnerPerfRecords=>'+lstPartnerPerfRecords);
                    if(lstPartnerPerfRecords.size()==0)
                    {
                        oppObj.PRM_PL_Perf_Rating_Completed__c=false;
                        lstOpportunityToUpdate.add(oppObj);
                    }
                }
                if(lstOpportunityToUpdate.size()>0)
                {
                    update lstOpportunityToUpdate;
                }
            }
        }
        
    }
    
    /*end of updatePartnerPerformanceCompleted method*/
        /* @Method <This method is written to update Diercr Rep Fields with opportunity team member email Ids>.
       @param  <This is taking a Map of opportunity records to update>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
    /* Commented this entire method for direct rep population on opportunity
    public void updatedirectrepfields(Map<Id,Opportunity> mapnewopprecordstoupdate)
    {
        if(mapnewopprecordstoupdate == null){
            return;
        }
        Map<Id,List<String>> mapteammembers=new Map<Id,List<String>>();
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c fieldcounts = DataValueMap.get('Field Count');
        Integer fieldcount = Integer.valueOf(fieldcounts.DataValue__c);
        //System.debug('fieldcount'+fieldcount);
            
        List<OpportunityTeamMember> lstopptyteammebers= [Select OpportunityId,User.EMail,User.Forecast_Group__c from OpportunityTeamMember where OpportunityId in :mapnewopprecordstoupdate.keyset() and User.Forecast_Group__c='Direct' and User.IsActive=true];
        //system.debug('lstopptyteammebers------->' +lstopptyteammebers);
        if(lstopptyteammebers != null && lstopptyteammebers.size()>0){
            for(OpportunityTeamMember Oppty : lstopptyteammebers)
            {
                if(mapteammembers.containsKey(Oppty.OpportunityId)){
                    mapteammembers.get(Oppty.OpportunityId).add(Oppty.User.EMail);
                }else{
                    //System.debug('Direct_Rep__c'+mapteammembers.get(Oppty.OpportunityId));
                    mapteammembers.put(Oppty.OpportunityId,new list<string>()); 
                    mapteammembers.get(Oppty.OpportunityId).add(Oppty.User.EMail);
                }   
                                
            }
            //system.debug('mapteammembers------->' +mapteammembers);
            if(!mapnewopprecordstoupdate.isEmpty()){
                for(Opportunity Opps: mapnewopprecordstoupdate.values()){                     
                     for(Integer i=1;i<=fieldcount;i++){
                        Opps.put('Direct_Rep'+i+'__c','');                            
                     }
            
                    if(mapteammembers.containsKey(Opps.Id) && mapteammembers.get(Opps.Id).size()>0){
                        for(Integer i=1;i<=fieldcount;i++){ 
                            if(mapteammembers.get(Opps.Id) != null && mapteammembers.get(Opps.Id).size() >= i){                             
                                Opps.put('Direct_Rep'+i+'__c',mapteammembers.get(Opps.Id)[i-1]);
                            }
                        }
                    }    
                }
            }    
        } 
    }  */  
        /*end of updatedirectrepfields method*/                  
    
    
}