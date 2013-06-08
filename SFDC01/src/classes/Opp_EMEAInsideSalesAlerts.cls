/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      ===========          
 |  14.02.2011      Shipraa M                   This Class is called whenever there is Stage change on the opportunity, 
 |                                              to find out if there exist any rep on Opportunity Team Member with department
 |                                              as "EMEA Inside Sales".WR-187056 (SFA - EMEA email alert changes)
+=========================================================================================================================*/
 
public class Opp_EMEAInsideSalesAlerts 
{
    public Map<ID, List<OpportunityTeamMember>> otmMap = new Map<ID, List<OpportunityTeamMember>>();
    public void updateEmailNotificationRecords(Map<Id,Opportunity> mapNewOpp,Map<id,Opportunity> mapOldOpp)
    {
        for(OpportunityTeamMember otm : [Select UserId,User.managerId, OpportunityId, OpportunityAccessLevel, IsDeleted, Id From OpportunityTeamMember where opportunityId in : mapNewOpp.keySet() and User.Department=:'EMEA inside Sales']) 
        {
             List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
             if(otmMap.containsKey(otm.OpportunityId)) 
             {
                 otmList = otmMap.get(otm.OpportunityId).deepClone();
             }
             otmList.add(otm);
             otmMap.put(otm.OpportunityId, otmList);
        }
        System.debug('otmMap'+otmMap);
        if(mapNewOpp!=null && mapNewOpp.size()>0)
        {
            List<OAR_Member_Added__c> lstEMEAMailRecipient= new List<OAR_Member_Added__c>(); 
            for(Opportunity oppNewEmea:mapNewOpp.values())
            {
                Opportunity oppOldEmea=mapOldOpp.get(oppNewEmea.id);
                String OpportunityAlert='';
                //For Closed Opportunity with Closed reason not as Competition.
                if(oppNewEmea.StageName=='Closed' && oppOldEmea.StageName!='Closed' && oppNewEmea.Closed_Reason__c!='Competition' && oppNewEmea.Dollar_Amount__c>15000 && oppNewEmea.Current_Quarter__c==oppNewEmea.Close_Date_Quarter__c && oppNewEmea.chkSalesTeam__c)
                {
                    OpportunityAlert='Opportunity Closed';
                    lstEMEAMailRecipient.addAll(repWithDepartmentAsInsideSalesTeam(OpportunityAlert,otmMap.get(oppNewEmea.id),oppNewEmea));
                }
                //Opportunity moved from Commit to Strong Upside.
                if(oppOldEmea.StageName=='Commit' && oppNewEmea.StageName=='Strong Upside'&& oppNewEmea.Dollar_Amount__c>15000 && oppNewEmea.Current_Quarter__c==oppNewEmea.Close_Date_Quarter__c && oppNewEmea.chkSalesTeam__c)
                {
                    OpportunityAlert='Opportunity moved from Commit to Strong Upsided';
                    lstEMEAMailRecipient.addAll(repWithDepartmentAsInsideSalesTeam(OpportunityAlert,otmMap.get(oppNewEmea.id),oppNewEmea));
                }
                //Opportunity moved from Commit to Upside.
                if(oppOldEmea.StageName=='Commit' && oppNewEmea.StageName=='Upside'&& oppNewEmea.Dollar_Amount__c>15000 && oppNewEmea.Current_Quarter__c==oppNewEmea.Close_Date_Quarter__c && oppNewEmea.chkSalesTeam__c)
                {
                    OpportunityAlert='Opportunity moved from Commit to Upside';
                    lstEMEAMailRecipient.addAll(repWithDepartmentAsInsideSalesTeam(OpportunityAlert,otmMap.get(oppNewEmea.id),oppNewEmea));
                }
                
                //Opportunity moved from Strong Upside to Upside.
                if(oppOldEmea.StageName=='Strong Upside' && oppNewEmea.StageName=='Upside'&& oppNewEmea.Dollar_Amount__c>15000 && oppNewEmea.Current_Quarter__c==oppNewEmea.Close_Date_Quarter__c && oppNewEmea.chkSalesTeam__c)
                {
                    OpportunityAlert='Opportunity moved from Strong Upside to Upside';
                    lstEMEAMailRecipient.addAll(repWithDepartmentAsInsideSalesTeam(OpportunityAlert,otmMap.get(oppNewEmea.id),oppNewEmea));
                }
                //Opportunity moved from Commit to Strong Upside.
                if((oppNewEmea.CloseDate!=oppOldEmea.CloseDate) && (oppNewEmea.StageName=='Commit' || oppNewEmea.StageName=='Strong Upside'||oppNewEmea.StageName=='Upside') &&  oppNewEmea.Dollar_Amount__c>15000 &&  oppNewEmea.chkSalesTeam__c)
                {   
                    Boolean blnDateinFutureQuarter=calculateCloseDateInFuture(oppNewEmea.CloseDate,oppOldEmea.CloseDate);
                    if(blnDateinFutureQuarter)
                    {
                        System.debug('Entered future quater');
                        OpportunityAlert='Opportunity Close Date Moved to Future Quarter';
                        lstEMEAMailRecipient.addAll(repWithDepartmentAsInsideSalesTeam(OpportunityAlert,otmMap.get(oppNewEmea.id),oppNewEmea));
                    }
                    
                }
                //For Closed Opportunity with Closed reason as Competition.
                if(oppNewEmea.StageName=='Closed' && oppOldEmea.StageName!='Closed' && oppNewEmea.Closed_Reason__c=='Competition'  && oppNewEmea.chkSalesTeam__c && oppNewEmea.Current_Quarter__c==oppNewEmea.Close_Date_Quarter__c)
                {
                    OpportunityAlert='Opportunity Closed to Competition';
                    lstEMEAMailRecipient.addAll(repWithDepartmentAsInsideSalesTeam(OpportunityAlert,otmMap.get(oppNewEmea.id),oppNewEmea));
                }
                
            }
            if(lstEMEAMailRecipient!=null && lstEMEAMailRecipient.size()>0)
            {
                Enterprise_Under_Pen_Email_Notification.insertEmailMemberAlertRecords(lstEMEAMailRecipient);
            }
        }
    }
    //Method to find eligible EMEA Inside sales rep on Opportunity.
    public List<OAR_Member_Added__c>repWithDepartmentAsInsideSalesTeam(String EmeaAlert,List<OpportunityTeamMember> lstOtmrecord,Opportunity opp)
    {
        List<OAR_Member_Added__c> lstteam=new List<OAR_Member_Added__c>();
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        //Create OAR Member Added records for Emea Inside Sales Rep 
        Map<Opportunity,Set<Id>> mapOppToRepIds= new Map<Opportunity,Set<Id>>();
        Set<Id> setUserId= new Set<Id>();
        for(OpportunityTeamMember optm:lstOtmrecord)
        {
            setUserId.add(optm.User.managerId);
            setUserId.add(optm.UserId);
        }
        if(EmeaAlert=='Opportunity Closed')
        {
            CustomSettingDataValueMap__c alertOpptyClosed = DataValueMap.get('EMEA Inside Sales Opportunity Closed');
            String[] datavalue=alertOpptyClosed.DataValue__c.split(',');
            if(datavalue!=null && datavalue.size()>0)
            for(Integer i=0;i<datavalue.size();i++)
            {
                setUserId.add(datavalue[i]);
            }
            
        }
        if(EmeaAlert=='Opportunity Close Date Moved to Future Quarter')
        {
            CustomSettingDataValueMap__c alertOpptyClosedtmovedToFutureQuater = DataValueMap.get('EMEA Inside Sls Clsd dt mvd to Ftr Qtr');
            String[] datavalue=alertOpptyClosedtmovedToFutureQuater.DataValue__c.split(',');
            System.debug('Datavalue'+datavalue);
            if(datavalue!=null && datavalue.size()>0)
            for(Integer i=0;i<datavalue.size();i++)
            {
               setUserId.add(datavalue[i]);
            }
            
        }
        if(EmeaAlert=='Opportunity Closed to Competition')
        {
            CustomSettingDataValueMap__c alertOpptyClosedtoCompetition = DataValueMap.get('EMEA Inside Sls Clsd to Comptetion');
            String[] datavalue=alertOpptyClosedtoCompetition.DataValue__c.split(',');
            if(datavalue!=null && datavalue.size()>0)
            for(Integer i=0;i<datavalue.size();i++)
            {
               setUserId.add(datavalue[i]);
            }
        }
        if(EmeaAlert=='Opportunity moved from Commit to Strong Upsided')
        {
            CustomSettingDataValueMap__c alertOpptyCommitToStrongUpside = DataValueMap.get('EMEA Inside Sls Commit to Strg Upside');
            String[] datavalue=alertOpptyCommitToStrongUpside.DataValue__c.split(',');
            if(datavalue!=null && datavalue.size()>0)
            for(Integer i=0;i<datavalue.size();i++)
            {
                setUserId.add(datavalue[i]);
            }
            
        }
        if(EmeaAlert=='Opportunity moved from Commit to Upside')
        {
            CustomSettingDataValueMap__c alertOpptyCommitToUpside = DataValueMap.get('EMEA Inside Sls Commit to Upside');
            String[] datavalue=alertOpptyCommitToUpside.DataValue__c.split(',');
            if(datavalue!=null && datavalue.size()>0)
            for(Integer i=0;i<datavalue.size();i++)
            {
                setUserId.add(datavalue[i]);
            }
            
        }
        if(EmeaAlert=='Opportunity moved from Strong Upside to Upside')
        {
            CustomSettingDataValueMap__c alertOpptyStrongUpsideToUpside = DataValueMap.get('EMEA Inside Sls Strg Upside to Upside');
            String[] datavalue=alertOpptyStrongUpsideToUpside.DataValue__c.split(',');
            if(datavalue!=null && datavalue.size()>0)
            for(Integer i=0;i<datavalue.size();i++)
            {
               setUserId.add(datavalue[i]);
            }
            
        }
        if(setUserId!=null && setUserId.size()>0 )
        {
        	for(Id userId:setUserId)
        	{
        		OAR_Member_Added__c oppMemAdd= new OAR_Member_Added__c();
				oppMemAdd.Text_1__c=opp.Id;
				oppMemAdd.Text_2__c=opp.Name;
				oppMemAdd.Text_3__c=opp.Opportunity_Number__c;
				oppMemAdd.Text_4__c=opp.Account_Name1__c;
				oppMemAdd.Text_5__c=opp.StageName;
				oppMemAdd.Text_6__c=opp.Initial_Forecast_Quarter__c;
				oppMemAdd.Text_7__c=opp.Country__c;
				oppMemAdd.Text_8__c=opp.Closed_Reason__c;
				oppMemAdd.Text_9__c=opp.Competitor_Lost_To__c;
				oppMemAdd.Text_10__c=opp.Competitor_Product__c;
				oppMemAdd.Number_1__c=opp.Amount;
				oppMemAdd.Number_2__c=opp.Dollar_Amount__c;
				oppMemAdd.Account_1__c=opp.Partner__c;
				oppMemAdd.Account_2__c=opp.Tier_2_Partner__c;
				oppMemAdd.Condition__c=EmeaAlert;
				oppMemAdd.User_1__c=opp.Opportunity_Owner__c;
				oppMemAdd.Team_Member_Added__c=userId;
				oppMemAdd.Date_1__c=opp.CloseDate;
				lstteam.add(oppMemAdd);
        	}
        	
        }
        
        return lstteam; 
    }
    
    //#Method To find out if close date lies in future Quarter.//
    public static Boolean calculateCloseDateInFuture(date dtNewCloseDate,date dtOldCloseDate)
    {
       Date dtlastDateOfPresentQuarter;
       Date dtFirstDateofPresentQuarter;
       System.debug('dtCloseDate-->'+dtNewCloseDate);
       Date dtTodayDate = System.today();      
       if(dtTodayDate.month() ==1 || dtTodayDate.month() ==2 || dtTodayDate.month() ==3)
       {
            dtlastDateOfPresentQuarter = date.newinstance(dtTodayDate.year(), 3, 31);
            dtFirstDateofPresentQuarter= date.newinstance(dtTodayDate.year(), 1, 1);
       }else if(dtTodayDate.month() ==4 || dtTodayDate.month() ==5 || dtTodayDate.month() ==6)
       {
            dtlastDateOfPresentQuarter = date.newinstance(dtTodayDate.year(), 6, 30);
            dtFirstDateofPresentQuarter = date.newinstance(dtTodayDate.year(), 4, 1);
       }else if(dtTodayDate.month() ==7 || dtTodayDate.month() ==8 || dtTodayDate.month() ==9)
       {
            dtlastDateOfPresentQuarter = date.newinstance(dtTodayDate.year(), 9, 30);
            dtFirstDateofPresentQuarter = date.newinstance(dtTodayDate.year(), 7, 1);
       }else if(dtTodayDate.month() ==10 || dtTodayDate.month() ==11 || dtTodayDate.month() ==12)
       {
            dtlastDateOfPresentQuarter = date.newinstance(dtTodayDate.year(), 12, 31);
            dtFirstDateofPresentQuarter = date.newinstance(dtTodayDate.year(), 10, 1);
       }
       System.debug('dtlastDateOfPresentQuarter-->'+dtlastDateOfPresentQuarter);
       System.debug('dtFirstDateofPresentQuarter-->'+dtFirstDateofPresentQuarter);
       System.debug('dtNewCloseDate-->'+dtNewCloseDate);
       System.debug('dtOldCloseDate-->'+dtOldCloseDate);
       if((dtOldCloseDate>dtlastDateOfPresentQuarter && dtNewCloseDate<dtlastDateOfPresentQuarter) || (dtNewCloseDate>dtlastDateOfPresentQuarter && dtOldCloseDate>dtFirstDateofPresentQuarter && dtOldCloseDate<dtlastDateOfPresentQuarter))
       {
        return true;    
       }
       else
       {
        return false;
       }
     }
}