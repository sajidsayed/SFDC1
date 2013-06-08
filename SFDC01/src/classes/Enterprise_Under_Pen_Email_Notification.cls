/*=====================================================================================================================================

History 

9th Jan 12   Kaustav Debnath    Initial Code creation
                                This class is responsible to populate
                                the email fields on opportunity which 
                                contain the recipient list
14 Feb 12   Shipra Misra        Updated for WR-184402
05 May 12	Shipra Misra		WR-192797. Introduced new field Ammount 
								where rules can be updated for eligible amount for which the alert should fire. 
======================================================================================================================================*/


public class Enterprise_Under_Pen_Email_Notification {

    /* @Method <This method is written to populate the email fields
                on the opportunity based on the members on enterprise
                notification object>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
    public static void updateEmailFieldsForEnterpriseNotification(Map<Id,Opportunity> mapOpportunity)
    {
        Map<String,Enterprise_Email_Win_Notification__c> mapEnterpriseRegionMax= new Map<String,Enterprise_Email_Win_Notification__c> ();
        Map<String,Enterprise_Email_Win_Notification__c> mapEnterpriseRegionMin= new Map<String,Enterprise_Email_Win_Notification__c> ();
        Map<String,Enterprise_Email_Win_Notification__c> mapEnterpriseCountryMax= new Map<String,Enterprise_Email_Win_Notification__c> ();
        Map<String,Enterprise_Email_Win_Notification__c> mapEnterpriseCountryMin= new Map<String,Enterprise_Email_Win_Notification__c> ();
        Map<String,Enterprise_Email_Win_Notification__c> mapDivision= new Map<String,Enterprise_Email_Win_Notification__c> ();
        Map<String,Enterprise_Email_Win_Notification__c> mapSuperArea= new Map<String,Enterprise_Email_Win_Notification__c> ();
        Map<Id,List<Enterprise_Email_Notification_Member__c>> mapEnterpriseMembers=new Map<Id,List<Enterprise_Email_Notification_Member__c>>();
        List<OAR_Member_Added__c> lstEMEAMailRecipient= new List<OAR_Member_Added__c>();
        Set<String> setCountry= new Set<String>(); 
        Set<String> setRegion= new Set<String>(); 
        Set<String> setSuperArea= new Set<String>(); 
        Set<String> setDivision= new Set<String>(); 
        if(mapOpportunity!=null && mapOpportunity.size()>0)
        {
          Map<id,Opportunity> mapopp= new Map<id,Opportunity>([Select area_manager__c,Opportunity_Owner__c,Opportunity_Owner__r.Country__c,Opportunity_Owner__r.Region__c,Opportunity_Owner__r.Division__c,Opportunity_Owner__r.Super_Area__c,area_manager__r.email,district_manager__c,district_manager__r.email from opportunity where id in:mapOpportunity.keySet()]);
          for(Opportunity opp:mapopp.Values())
          {
          	if(opp.Opportunity_Owner__c != null)
            {
                if(opp.Opportunity_Owner__r.Country__c != null) setCountry.add(opp.Opportunity_Owner__r.Country__c );
                if(opp.Opportunity_Owner__r.Region__c != null) setRegion.add(opp.Opportunity_Owner__r.Region__c);
                if(opp.Opportunity_Owner__r.Super_Area__c != null) setSuperArea.add(opp.Opportunity_Owner__r.Super_Area__c);
                if(opp.Opportunity_Owner__r.Division__c != null) setDivision.add(opp.Opportunity_Owner__r.Division__c);
            }
          }
          List<Enterprise_Email_Win_Notification__c> lstEnterprise=[SELECT Id, Region__c,Country__c,Max_Amount__c,Min_Amount__c, 
                                                                      Under_Pen_Account_Type__c,Division__c,Super_Area__c,Active__c, Opportunity_Status__c,Name, 
                                                                     (SELECT Id,Enterprise_Email_Win_Notification__c,Team_Member__c,Team_Member__r.email 
                                                                     FROM Enterprise_Email_Notification__r) FROM Enterprise_Email_Win_Notification__c 
                                                                     where Active__c=true AND ((Country__c in:setCountry OR Country__c = null)
                                                                     AND (Region__c in:setRegion OR Region__c = null)
                                                                     AND (Division__c in:setDivision OR Division__c = null)
                                                                     AND (Super_Area__c in:setSuperArea OR Super_Area__c = null))];
            if(lstEnterprise!=null && lstEnterprise.size()>0)
            {
                for(Enterprise_Email_Win_Notification__c enterObj:lstEnterprise)
                {
                    List<Enterprise_Email_Notification_Member__c> lstEnterpriseMembers=enterObj.Enterprise_Email_Notification__r;
                    if(enterObj.Under_Pen_Account_Type__c!=null && enterObj.Opportunity_Status__c!=null)
                    {
                        if((enterObj.Region__c!=null && enterObj.Region__c!='')&&(!mapEnterpriseRegionMin.containsKey(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-region'+enterObj.Region__c.toLowerCase()+'region-'+enterObj.Opportunity_Status__c.toLowerCase())|| !mapEnterpriseRegionMax.containsKey(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-region'+enterObj.Region__c.toLowerCase()+'region-'+enterObj.Opportunity_Status__c.toLowerCase() )))
                        {
                        	if(enterObj.Max_Amount__c!=null)
                        	{
                        		mapEnterpriseRegionMax.put(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-region'+enterObj.Region__c.toLowerCase()+'region-'+enterObj.Opportunity_Status__c.toLowerCase(),enterObj);
                        	}
                        	else
                        	{
                        		mapEnterpriseRegionMin.put(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-region'+enterObj.Region__c.toLowerCase()+'region-'+enterObj.Opportunity_Status__c.toLowerCase(),enterObj);
                        	}
                        
                        }
                        else if((enterObj.Country__c!=null && enterObj.Country__c!='')&&(!mapEnterpriseCountryMax.containsKey(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-country'+enterObj.Country__c.toLowerCase()+'country-'+enterObj.Opportunity_Status__c.toLowerCase()) || !mapEnterpriseCountryMin.containsKey(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-country'+enterObj.Country__c.toLowerCase()+'country-'+enterObj.Opportunity_Status__c.toLowerCase())))
                        {
                        	if(enterObj.Max_Amount__c!=null)
                        	{
                        		mapEnterpriseCountryMax.put(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-country'+enterObj.Country__c.toLowerCase()+'country-'+enterObj.Opportunity_Status__c.toLowerCase(),enterObj);
                        	}
                        	else
                        	{
                        		mapEnterpriseCountryMin.put(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-country'+enterObj.Country__c.toLowerCase()+'country-'+enterObj.Opportunity_Status__c.toLowerCase(),enterObj);
                        	}
                        
                        }
                        else if((enterObj.Division__c!=null && enterObj.Division__c!='')&&(!mapDivision.containsKey(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-division'+enterObj.Division__c.toLowerCase()+'division-'+enterObj.Opportunity_Status__c.toLowerCase())))
                        {
                        mapDivision.put(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-division'+enterObj.Division__c.toLowerCase()+'division-'+enterObj.Opportunity_Status__c.toLowerCase(),enterObj);
                        }
                        else if((enterObj.Super_Area__c!=null && enterObj.Super_Area__c!='')&&(!mapSuperArea.containsKey(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-superarea'+enterObj.Super_Area__c.toLowerCase()+'superarea-'+enterObj.Opportunity_Status__c.toLowerCase())))
                        {
                        mapSuperArea.put(enterObj.Under_Pen_Account_Type__c.toLowerCase()+'-superarea'+enterObj.Super_Area__c.toLowerCase()+'superarea-'+enterObj.Opportunity_Status__c.toLowerCase(),enterObj);
                        }
                    }
                    if(!mapEnterpriseMembers.containsKey(enterObj.id))
                    {
                        mapEnterpriseMembers.put(enterObj.id,lstEnterpriseMembers);
                    }
                }
            }
            for(Opportunity oppObj:mapOpportunity.values())
            {
                //if(oppObj.Dollar_Amount__c>100000 && oppObj.Quote_Cart_Number__c!=null )
                if(oppObj.Quote_Cart_Number__c!=null )
                {   
                    lstEMEAMailRecipient.addAll(updateEmailFieldsHelper(oppObj,mapEnterpriseRegionMax,mapEnterpriseMembers,mapopp));
                    lstEMEAMailRecipient.addAll(updateEmailFieldsHelper(oppObj,mapEnterpriseRegionMin,mapEnterpriseMembers,mapopp));
                    lstEMEAMailRecipient.addAll(updateEmailFieldsHelper(oppObj,mapEnterpriseCountryMax,mapEnterpriseMembers,mapopp));
                    lstEMEAMailRecipient.addAll(updateEmailFieldsHelper(oppObj,mapEnterpriseCountryMin,mapEnterpriseMembers,mapopp));
                    lstEMEAMailRecipient.addAll(updateEmailFieldsHelper(oppObj,mapDivision,mapEnterpriseMembers,mapopp));
                    lstEMEAMailRecipient.addAll(updateEmailFieldsHelper(oppObj,mapSuperArea,mapEnterpriseMembers,mapopp));
                    
                }
            }
        }
        if(lstEMEAMailRecipient!=null && lstEMEAMailRecipient.size()>0)
        {
            insertEmailMemberAlertRecords(lstEMEAMailRecipient);
        }
    }
    /* @Method <This method is written to populate the email fields
                on the opportunity based on the members on enterprise
                notification object>
       @return void - <return nothing>  
       @throws exception - <No Exception>
    */
    public static List<OAR_Member_Added__c> updateEmailFieldsHelper(Opportunity objOpportunity,Map<String,Enterprise_Email_Win_Notification__c> mapEnterprise,Map<Id,List<Enterprise_Email_Notification_Member__c>> mapEnterpriseMembers ,Map<Id,Opportunity>mapopp)
    {
        Set<String> UniqueOpptyUserRecord= new Set<String>();
        Util.Underpen_EMAIL_Alert_fired =true;
        Integer MaxAmount;
        Integer MinAmount;
        Enterprise_Email_Win_Notification__c enterObj;
        List<OAR_Member_Added__c> lstteam=new List<OAR_Member_Added__c>();
        if(objOpportunity.Account_Owner_Region__c!=null)
        {
            if(objOpportunity.Dollar_Amount__c!=null &&mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-region'+objOpportunity.Account_Owner_Region__c.toLowerCase()+'region-'+objOpportunity.StageName.toLowerCase())!=NULL && objOpportunity.Dollar_Amount__c>mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-region'+objOpportunity.Account_Owner_Region__c.toLowerCase()+'region-'+objOpportunity.StageName.toLowerCase()).Min_Amount__c)
            {
            	if(mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-region'+objOpportunity.Account_Owner_Region__c.toLowerCase()+'region-'+objOpportunity.StageName.toLowerCase()).Max_Amount__c!=null )
            	{
            		if(objOpportunity.Dollar_Amount__c<mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-region'+objOpportunity.Account_Owner_Region__c.toLowerCase()+'region-'+objOpportunity.StageName.toLowerCase()).Max_Amount__c)
            		enterObj=mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-region'+objOpportunity.Account_Owner_Region__c.toLowerCase()+'region-'+objOpportunity.StageName.toLowerCase());
            	}
            	else
            	{
            		enterObj=mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-region'+objOpportunity.Account_Owner_Region__c.toLowerCase()+'region-'+objOpportunity.StageName.toLowerCase());	
            	}
            }
            
        }
        if(enterObj==null && objOpportunity.Account_Owner_Country__c!=null)
        {
            if(objOpportunity.Dollar_Amount__c!=null && mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-country'+objOpportunity.Account_Owner_Country__c.toLowerCase()+'country-'+objOpportunity.StageName.toLowerCase())!=null && objOpportunity.Dollar_Amount__c>mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-country'+objOpportunity.Account_Owner_Country__c.toLowerCase()+'country-'+objOpportunity.StageName.toLowerCase()).Min_Amount__c)
            {
	            if(mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-country'+objOpportunity.Account_Owner_Country__c.toLowerCase()+'country-'+objOpportunity.StageName.toLowerCase()).Max_Amount__c!=null )
	        	{
	        		if(objOpportunity.Dollar_Amount__c<mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-country'+objOpportunity.Account_Owner_Country__c.toLowerCase()+'country-'+objOpportunity.StageName.toLowerCase()).Max_Amount__c)
	        		enterObj=mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-country'+objOpportunity.Account_Owner_Country__c.toLowerCase()+'country-'+objOpportunity.StageName.toLowerCase());
	        	}
	        	else
	        	{
	        		enterObj=mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-country'+objOpportunity.Account_Owner_Country__c.toLowerCase()+'country-'+objOpportunity.StageName.toLowerCase());	
	        	}
            }
        }
        if(enterObj==null && objOpportunity.Account_Owner_Division__c!=null)
        {
            if(objOpportunity.Dollar_Amount__c!=null && mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-division'+objOpportunity.Account_Owner_Division__c.toLowerCase()+'division-'+objOpportunity.StageName.toLowerCase())!=null && objOpportunity.Dollar_Amount__c>mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-division'+objOpportunity.Account_Owner_Division__c.toLowerCase()+'division-'+objOpportunity.StageName.toLowerCase()).Min_Amount__c)
            enterObj=mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-division'+objOpportunity.Account_Owner_Division__c.toLowerCase()+'division-'+objOpportunity.StageName.toLowerCase());
        }
        if( enterObj==null && objOpportunity.Account_Owner_Super_Area__c!=null)
        {
            if(objOpportunity.Dollar_Amount__c!=null && mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-superarea'+objOpportunity.Account_Owner_Super_Area__c.toLowerCase()+'superarea-'+objOpportunity.StageName.toLowerCase())!=null && objOpportunity.Dollar_Amount__c>mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-superarea'+objOpportunity.Account_Owner_Super_Area__c.toLowerCase()+'superarea-'+objOpportunity.StageName.toLowerCase()).Min_Amount__c)
            enterObj=mapEnterprise.get(objOpportunity.Under_Pen_Account_Type__c.toLowerCase()+'-superarea'+objOpportunity.Account_Owner_Super_Area__c.toLowerCase()+'superarea-'+objOpportunity.StageName.toLowerCase());
        }
        
        if(enterObj!=null)
        {
            System.debug('enterObj3===>'+enterObj.id);
            //update this
            List<Enterprise_Email_Notification_Member__c> lstEnterpriseMembers=mapEnterpriseMembers.get(enterObj.id);
            //String[] UnderpenEMeaTeamMember=enterObj.UnderPen_EMEA_Email_GroupId__c.split(',');
            System.debug('lstEnterpriseMembers===='+lstEnterpriseMembers);
            if(lstEnterpriseMembers!=null && lstEnterpriseMembers.size()>0)
            {
                for(Integer i=0;i<lstEnterpriseMembers.size();i++)
                {
                    String strUniqueOpptyUserRecord=objOpportunity.id+'|'+lstEnterpriseMembers[i].Team_Member__c;
                    if(UniqueOpptyUserRecord.contains(strUniqueOpptyUserRecord))continue;
                    OAR_Member_Added__c oppMemAdd= new OAR_Member_Added__c();
                    oppMemAdd.Text_1__c=objOpportunity.Account_Name1__c;
                    oppMemAdd.Text_2__c=objOpportunity.SO_Number__c;
                    oppMemAdd.Text_3__c=objOpportunity.Competitor__c;
                    oppMemAdd.Text_4__c=objOpportunity.Account_Owner_Division__c;
                    oppMemAdd.Text_5__c=objOpportunity.Account_Owner_Region__c;
                    oppMemAdd.Text_6__c=objOpportunity.Account_Owner_Area__c;
                    oppMemAdd.Text_7__c=objOpportunity.Account_Owner_District__c;
                    oppMemAdd.Condition__c='UnderPen Win Email Alert';
                    oppMemAdd.Text_9__c=objOpportunity.Name;
                    oppMemAdd.Text_10__c=objOpportunity.Id;
                    oppMemAdd.Text_11__c=objOpportunity.Under_Pen_Account_Type__c;
                    oppMemAdd.Account_1__c=objOpportunity.Partner__c;
                    oppMemAdd.Account_2__c=objOpportunity.Tier_2_Partner__c;
                    oppMemAdd.User_1__c=objOpportunity.Opportunity_Owner__c;
                    oppMemAdd.Team_Member_Added__c=lstEnterpriseMembers[i].Team_Member__c;
                    oppMemAdd.Number_1__c=objOpportunity.Quote_Amount__c;
                    oppMemAdd.Date_1__c=objOpportunity.CloseDate;
                    UniqueOpptyUserRecord.add(strUniqueOpptyUserRecord);
                    lstteam.add(oppMemAdd);
                    System.debug('Under list'+lstteam);
                }
                
                //for Sending email alert to AM:
                String strUniqueOpptyUserRecordAM=objOpportunity.id+'|'+mapopp.get(objOpportunity.id).Area_Manager__r.id;
                if(!UniqueOpptyUserRecord.contains(strUniqueOpptyUserRecordAM))
                {
                    OAR_Member_Added__c oppMemAdd= new OAR_Member_Added__c();
                    oppMemAdd.Text_1__c=objOpportunity.Account_Name1__c;
                    oppMemAdd.Text_2__c=objOpportunity.SO_Number__c;
                    oppMemAdd.Text_3__c=objOpportunity.Competitor__c;
                    oppMemAdd.Text_4__c=objOpportunity.Account_Owner_Division__c;
                    oppMemAdd.Text_5__c=objOpportunity.Account_Owner_Region__c;
                    oppMemAdd.Text_6__c=objOpportunity.Account_Owner_Area__c;
                    oppMemAdd.Text_7__c=objOpportunity.Account_Owner_District__c;
                    oppMemAdd.Condition__c='UnderPen Win Email Alert';
                    oppMemAdd.Text_9__c=objOpportunity.Name;
                    oppMemAdd.Text_10__c=objOpportunity.Id;
                    oppMemAdd.Text_11__c=objOpportunity.Under_Pen_Account_Type__c;
                    oppMemAdd.Account_1__c=objOpportunity.Partner__c;
                    oppMemAdd.Account_2__c=objOpportunity.Tier_2_Partner__c;                    
                    oppMemAdd.User_1__c=objOpportunity.Opportunity_Owner__c;
                    oppMemAdd.Number_1__c=objOpportunity.Quote_Amount__c;
                    oppMemAdd.Date_1__c=objOpportunity.CloseDate;
                    oppMemAdd.Email_notification_1__c=mapopp.get(objOpportunity.id).Area_Manager__r.email;
                    lstteam.add(oppMemAdd);
                    System.debug('Under am'+lstteam);
                }
                //for Sending email alert to DM:
                String strUniqueOpptyUserRecordDM=objOpportunity.id+'|'+mapopp.get(objOpportunity.id).District_Manager__r.id;
                if(!UniqueOpptyUserRecord.contains(strUniqueOpptyUserRecordDM))
                {
                    OAR_Member_Added__c oppMemAdd= new OAR_Member_Added__c();
                    oppMemAdd.Text_1__c=objOpportunity.Account_Name1__c;
                    oppMemAdd.Text_2__c=objOpportunity.SO_Number__c;
                    oppMemAdd.Text_3__c=objOpportunity.Competitor__c;
                    oppMemAdd.Text_4__c=objOpportunity.Account_Owner_Division__c;
                    oppMemAdd.Text_5__c=objOpportunity.Account_Owner_Region__c;
                    oppMemAdd.Text_6__c=objOpportunity.Account_Owner_Area__c;
                    oppMemAdd.Text_7__c=objOpportunity.Account_Owner_District__c;
                    oppMemAdd.Condition__c='UnderPen Win Email Alert';
                    oppMemAdd.Text_9__c=objOpportunity.Name;
                    oppMemAdd.Text_10__c=objOpportunity.Id;
                    oppMemAdd.Text_11__c=objOpportunity.Under_Pen_Account_Type__c;
                    oppMemAdd.Account_1__c=objOpportunity.Partner__c;
                    oppMemAdd.Account_2__c=objOpportunity.Tier_2_Partner__c;
                    oppMemAdd.User_1__c=objOpportunity.Opportunity_Owner__c;
                    oppMemAdd.Number_1__c=objOpportunity.Quote_Amount__c;
                    oppMemAdd.Date_1__c=objOpportunity.CloseDate;
                    oppMemAdd.Email_notification_1__c=mapopp.get(objOpportunity.id).District_Manager__r.email;
                    lstteam.add(oppMemAdd);
                    System.debug('Under dm'+lstteam);
                }
                
            }
        }
        System.debug('lstteam=='+lstteam);
        return lstteam;
    }
    
    //Reusable method to insert email member added records.
    public static void insertEmailMemberAlertRecords(List<OAR_Member_Added__c> lstMemberAdded)
    {
        try
        {
            if(lstMemberAdded!=null && lstMemberAdded.size()>0)
            {
                insert lstMemberAdded;
            }   
        }
        catch(Exception e)
        {
            System.debug('Exception in Email Member Insertion'+e);
        }
        
    }
        
}