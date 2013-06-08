/*==============================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  21 Sep 2010   Arif      148781  Calling 'populateCompetitorLogicFormulaField'
 |                                  method from class populateCompetitorLogicFormula     
 |  10 Dec 2010   Srinivas  151217  Uncheck 'Update Forecast Amt from Quote' when no Quote attached on Oppty                                                  
 |  08 Mar 2011   Srinivas  161482  Changed Logic for  'Update Forecast Amt from Quote'
 |  18 Jun 2011   Srinivas  163357  Update/Delete SP Tracking date when "Service Provider" Added/Deleted
 |  24-Aug-2011   Srinivas  174234  Fix "Insufficent Privileges" error on Opportunity. When User lost access to some Account record 
                                    which they previously might be having and they select same account on opportunity (may be form recently viewed items),
                                    they strat receiving 'Insifficent priviledges' error.
| 10-Sep-2011     Shipra M  172224  Oppty OAR: Trigger OAR when Account Owner changes from any House Account to a real user.
| 22-Sep-2011     Shipra M  173667  Place Account Theater on the Opportunity into a Text Field 
| 18-nov-2011     Shipra M  173965  New Alliance Fields.Channel visibilty.
| 18-Nov-2011     Kaustav D  NA     PRM Partner Leverage flag checker
| 05-Dec-2011     Shipra M  173965  Added 2 maps to store old & new onwer Id against updated opportunity. 
| 23-Dec-2011    Shipra M   182949  Fix developer script  exception.
  22/01/2011      Accenture         Updated trigger to incorporate ByPass Logic
|                                   NOTE: Please write all the code after BYPASS Logic
| 14/02/2012     Shipra M   187056  Emea Inside sales email alert.
| 29-Mar-2013    Uday A     246616  Updating Initial_Forecast_Quarter__c on Opportunity when ever opportunity is created and deactivated the workflow.
                                    Also created a new helper class in EMC_ConvertLead to get the theater from a query which was there already. If it hasn't querired then query for theater.
 +=============================================================================*/
trigger PopulateOpportunityOwner on Opportunity (before insert, before update )
   
{
   //Trigger BYPASS Logic 
   if(CustomSettingBypassLogic__c.getInstance()!=null){
      if(CustomSettingBypassLogic__c.getInstance().By_Pass_Opportunity_Triggers__c){
                return;
      }
   }   
    if(!PRM_Partner_Leverage.PRM_Partner_Leverage_flag)
    {
          //Added by Srinivas Nallapati for WR-174234
          AccountUtils acctUtil = new AccountUtils();
          acctUtil.CheckUserAccessForPartnerAccountsOnOpportunity(trigger.new);   
          //end of WR-174234      
          Set<Id> setAccID=new Set<Id>();
          //Added by Srinivas Nallapati for WR-151217
          if(Userinfo.getProfileId() == '00e70000000wRaBAAU')
          {
              system.debug('inside if');
              for(Opportunity oppty: Trigger.New)
              {   
                  
                    if(Trigger.isUpdate) 
                    {
                        Opportunity oldOpp = Trigger.oldMap.get(oppty.Id);
                        if(oppty.Quote_Cart_Number__c == null && oldOpp.Quote_Cart_Number__c != null)
                            oppty.Update_Forecast_Amount_from_Quote__c= false;
                        if(oppty.Quote_Cart_Number__c != null && (oppty.Quote_Cart_Number__c != oldOpp.Quote_Cart_Number__c))
                                oppty.Update_Forecast_Amount_from_Quote__c= true;
                        
                          
                    }
                    if(Trigger.isInsert)
                    { 
                        if(oppty.Quote_Cart_Number__c != null)
                            oppty.Update_Forecast_Amount_from_Quote__c= true;
                    } 
              }     
          }   
          //Update end by Shipra
          //WR 173667
          if(Trigger.isInsert || Trigger.isUpdate)
          {
              if(Util.IsTheaterUpdatedFromAccount!=true)
              {
                  for(Opportunity OpptyAccnt:Trigger.new)
                  {
                    setAccID.add(OpptyAccnt.Accountid);
                  }
                  if(setAccID.size()>0 && setAccID!=null)
                  {
                  	// Uday 246616
                  	 // We have created a new map in EMC_ConvertLead Class and use that map to get the account theater
                        EMC_ConvertLead theaterUtil = new EMC_ConvertLead();
                        Map<id,Account> theater = theaterUtil.theaterhelper(setAccID);
                        // Commented and queried this SOQL from EMC_ConvertLead class
                        // Map<id,Account> mapaccRecord= new Map<id,Account>([Select id,Theater1__c ,BillingCountry from Account where id in:(setAccID)]);
                         for(Opportunity oppTheater:Trigger.new)
                         {
                         	 if(oppTheater.AccountId!=null)
                               {
                                    if(theater != null && theater.size()>0){
                                        oppTheater.Account_TheaterText__c= theater.get(oppTheater.AccountId).Theater1__c;
                                    }
                               }
                         }
                    // Uday 246616
                  }
              }
          }
         //173667.
          //end of WR-151217
         //Added by Srinivas Nallapati for WR-163357
         if (Trigger.isInsert)
         {    
              for(Opportunity oppty: Trigger.New)
                 if(oppty.Service_Provider__c!= null)
                      oppty.SP_Tracking_Date__c = system.now();
         }
         else if(Trigger.isUpdate){
            for(Opportunity oppty: Trigger.New)
            {
                if(oppty.Service_Provider__c != null && trigger.oldMap.get(oppty.id).Service_Provider__c == null)
                    oppty.SP_Tracking_Date__c = system.now();
                else if(oppty.Service_Provider__c == null && trigger.oldMap.get(oppty.id).Service_Provider__c != null)
                         oppty.SP_Tracking_Date__c = null; 
                         
                //change for WR-
                if( (oppty.StageName != trigger.oldMap.get(oppty.id).StageName) && (oppty.StageName=='Submitted' || oppty.StageName=='Booked')){         
                    oppty.IIG_Renewals_Sales_Stage__c = 'Stage-6 Booking & Transitioning';
                }
                //End of change for WR-       
            }
         }
         //Adding this piece of code for Channel vis functionality.
         List<House_Account_For_OAR__c> lstHouseAccnt = House_Account_For_OAR__c.getAll().values();
         Map<id,Opportunity> mapOpptyHouseAccount = new Map<Id,Opportunity>();
         if(Trigger.isInsert || Trigger.isUpdate)
         {
            for(Opportunity opptyHouseAccount:Trigger.New)
            {
                System.debug('The value of owner is'+opptyHouseAccount.ownerId);
                Opportunity oldOpportunity=new Opportunity();
                if(Trigger.isUpdate)
                {
                    oldOpportunity = Trigger.oldMap.get(opptyHouseAccount.Id);
                }
                //ID idOpptyOwner=opptyHouseAccount.Opportunity_Owner__r.id;
                for(House_Account_For_OAR__c objHouseAccnt:lstHouseAccnt)
                {
                    //objHouseAccnt.Name == idOpptyOwner &&
                    System.debug('Tha value of objHouseAccnt.Name is'+objHouseAccnt.Name);
                    if(opptyHouseAccount.OwnerId==objHouseAccnt.Name)
                    {
                        System.Debug('Entered inside House Account Functionality');
                        if(Trigger.isInsert)
                        {
                            if((opptyHouseAccount.Partner__c !=null||opptyHouseAccount.Tier_2_Partner__c!=null ||opptyHouseAccount.Primary_Alliance_Partner__c!=null ||
                                                            opptyHouseAccount.Secondary_Alliance_Partner__c!=null ||opptyHouseAccount.Service_Provider__c!=null))
                            {
                                System.debug('entered the house account condition');                    
                                mapOpptyHouseAccount.put(opptyHouseAccount.id, opptyHouseAccount);
                                break;
                            }
                        }
                        if(Trigger.isUpdate)
                        {
                            if((opptyHouseAccount.Partner__c !=oldOpportunity.Partner__c||opptyHouseAccount.Tier_2_Partner__c!=oldOpportunity.Tier_2_Partner__c ||opptyHouseAccount.Primary_Alliance_Partner__c!=oldOpportunity.Primary_Alliance_Partner__c ||
                                                            opptyHouseAccount.Secondary_Alliance_Partner__c!=oldOpportunity.Secondary_Alliance_Partner__c ||opptyHouseAccount.Service_Provider__c!=oldOpportunity.Service_Provider__c))
                            {
                                System.debug('entered the house account condition');                    
                                mapOpptyHouseAccount.put(opptyHouseAccount.id, opptyHouseAccount);
                                break;
                            }
                        }
                    }
                 }
            }
            if(mapOpptyHouseAccount.size()>0 && mapOpptyHouseAccount!=null)
            {
                Opp_UpdateOwner oppUpdateOwner = new Opp_UpdateOwner();
                map<id,Opportunity_Assignment_Rule__c> mapOppResourceId=new map<id,Opportunity_Assignment_Rule__c>();
                System.debug('Update Owner entered');
                System.debug('mapOpptyHouseAccount'+mapOpptyHouseAccount);
                mapOppResourceId=oppUpdateOwner.updateAccountOwner(mapOpptyHouseAccount,mapOppResourceId);
                //172069***
                List<OAR_Member_Added__c> lstOarMemAdded= new List<OAR_Member_Added__c>();
                Set<String> setCheckOARDuplicate= new Set<String>();
                //172069***
                System.debug('mapOppResourceId--->'+mapOppResourceId);
                for(Opportunity oppty: mapOpptyHouseAccount.values())
                {
                    if(mapOppResourceId.size()>0 && mapOppResourceId != null && mapOppResourceId.keySet().contains(oppty.id))
                    {
                        if(Trigger.isUpdate)
                        {
                            Util.mapOldOpportunityOwner.put(Oppty.id, Oppty.OwnerId);
                        }
                        Oppty.OwnerId=mapOppResourceId.get(Oppty.id).Resource_Name__c;
                        Oppty.Opportunity_Owner__c=mapOppResourceId.get(Oppty.id).Resource_Name__c;
                        //Updated By Shipra to add a record on OAR Member Added.
                        OAR_Member_Added__c OarMemAdded = new OAR_Member_Added__c();
                        String strUserAndOpptyId='';
                        strUserAndOpptyId=mapOppResourceId.get(Oppty.id).id+'|'+Oppty.Id;
                        if(setCheckOARDuplicate.contains(strUserAndOpptyId))continue;
                        setCheckOARDuplicate.add(strUserAndOpptyId);
                        System.debug('THE VALUE OF SET FOR OAR ON OPPORTUNITY IS :::'+setCheckOARDuplicate);
                        OarMemAdded.Team_Member_Added__c =mapOppResourceId.get(Oppty.id).Resource_Name__c;
                        OarMemAdded.Text_1__c =Oppty.Id;
                        OarMemAdded.Text_2__c =Oppty.Name;
                        OarMemAdded.Assignment_Rule__c=mapOppResourceId.get(Oppty.id).id;
                        OarMemAdded.Condition__c='Channel Visibility';
                        OarMemAdded.Text_3__c=Oppty.Opportunity_Number__c;
                        OarMemAdded.Text_4__c=Oppty.Account_Name1__c;
                        lstOarMemAdded.add(OarMemAdded);
                        //end of update by shipra.
                        if(Trigger.isUpdate)
                        {
                            Util.mapNewOpportunityOwner.put(Oppty.id, Oppty.OwnerId);
                        }
                        System.debug('Assign entered');
                    }
                       
                }
                //172069***
                Database.Saveresult[] arrMemberSendMail=Database.insert(lstOarMemAdded,true);
                System.debug('+++After Team member details have been added to OAR Member Added object'+lstOarMemAdded);
                //172069***  
            }
         }
         
         if (Trigger.isInsert)
         {    
              for(Opportunity oppty: Trigger.New)
                 
                  //   oppty.Opportunity_Owner__c=oppty.ownerId;
              {
                oppty.Opportunity_Owner__c=oppty.ownerId;
                // Created by Uday 246616
                if(oppty.closedate != null)
                {                 
                 if(oppty.CloseDate.month() == 1)
                 oppty.Initial_Forecast_Quarter__c = 'Q1'+' '+ oppty.CloseDate.year();
                 else if(oppty.CloseDate.month() == 2)
                 oppty.Initial_Forecast_Quarter__c = 'Q1'+' '+oppty.CloseDate.year(); 
                 else if(oppty.CloseDate.month() == 3)
                 oppty.Initial_Forecast_Quarter__c = 'Q1'+' '+oppty.CloseDate.year(); 
                 else if(oppty.CloseDate.month() == 4)
                 oppty.Initial_Forecast_Quarter__c = 'Q2'+' '+oppty.CloseDate.year(); 
                 else if(oppty.CloseDate.month() == 5)
                 oppty.Initial_Forecast_Quarter__c = 'Q2'+' '+oppty.CloseDate.year();       
                 else if(oppty.CloseDate.month() == 6)
                 oppty.Initial_Forecast_Quarter__c = 'Q2'+' '+oppty.CloseDate.year(); 
                 else if(oppty.CloseDate.month() == 7)
                 oppty.Initial_Forecast_Quarter__c = 'Q3'+' '+oppty.CloseDate.year(); 
                 else if(oppty.CloseDate.month() == 8)
                 oppty.Initial_Forecast_Quarter__c = 'Q3'+' '+oppty.CloseDate.year(); 
                 else if(oppty.CloseDate.month() == 9)
                 oppty.Initial_Forecast_Quarter__c = 'Q3'+' '+oppty.CloseDate.year();
                  else if(oppty.CloseDate.month() == 10)
                 oppty.Initial_Forecast_Quarter__c = 'Q4'+' '+oppty.CloseDate.year(); 
                 else if(oppty.CloseDate.month() == 11)
                 oppty.Initial_Forecast_Quarter__c = 'Q4'+' '+oppty.CloseDate.year(); 
                 else if(oppty.CloseDate.month() == 12)
                 oppty.Initial_Forecast_Quarter__c = 'Q4'+' '+oppty.CloseDate.year(); 
                 else 
                 oppty.Initial_Forecast_Quarter__c = 'Contact Your Admin'+' '+oppty.CloseDate.year();     
                }
               // Uday 246616 
            }
                        
            
         }
         else
         {   
             if(util.CheckOpportunityAccess)
             {   
                for(Id newOppId: Trigger.newMap.keySet())
                {
                    Opportunity newOpportunity = Trigger.newMap.get(newOppId);
                    Opportunity oldOpportunity = Trigger.oldMap.get(newOppId);
                    if(newOpportunity.ownerid!=oldOpportunity.ownerid)
                    {
                         newOpportunity.Opportunity_Owner__c=newOpportunity.ownerid;
                        if(Opp_MassUserReassignment.IsMassReassignChannelVisCalled)
                        {
                            Util.isChannelVisibilityExecuted=false;
                        }
                        System.debug('SUNIL **** NEW OWNER = '+newOpportunity.Opportunity_Owner__c+'   **OLD OWNER ='+oldOpportunity.Opportunity_Owner__c);
                    }                
                    System.debug('oppty.Opportunity_Owner__c && oppty.ownerId'+newOpportunity.ownerId+' *** '+oldOpportunity.ownerId );                    
                }
             }
             //Included this code for S2S Functionality
             EMCBRS_S2S_Utils s2sUtils = new EMCBRS_S2S_Utils();
             s2sUtils.clearBRSOpptyData(trigger.oldMap,trigger.newMap);
             /* Added by Arif 
                WR - 148781    */ 
             // populateCompetitorLogicFormula populateObj = new populateCompetitorLogicFormula();
             //  populateObj.populateCompetitorLogicFormulaField(trigger.new); 
             
             /********************/
             CurrencyConversionHelper converter = new CurrencyConversionHelper(); // initializing the helper class
             for(Opportunity oppty: Trigger.New)
             {
                  Double amount = oppty.Amount; // opportunity amount
                  oppty.Dollar_Amount__c = converter.convertToUSD(amount  , oppty.CurrencyIsoCode);
             }
         }
    }
    if(trigger.isUpdate)
    {
        List<OAR_Member_Added__c> lstteam=new List<OAR_Member_Added__c>();
        Set<String> setCheckOwnerDuplicateRecord= new Set<String>();
        
        for(Id newOppId: Trigger.newMap.keySet())
        {
            Opportunity newOpportunity = Trigger.newMap.get(newOppId);
            Opportunity oldOpportunity = Trigger.oldMap.get(newOppId);
            if(newOpportunity.Opportunity_Owner__c!=oldOpportunity.Opportunity_Owner__c )
            {
                System.debug('entered account owner changes');
                String strUserAndOpptyId='';
                strUserAndOpptyId=newOpportunity.OwnerId+'|'+newOpportunity.Id;
                if(setCheckOwnerDuplicateRecord.contains(strUserAndOpptyId))continue;
                setCheckOwnerDuplicateRecord.add(strUserAndOpptyId);
                OAR_Member_Added__c oppMemAdd= new OAR_Member_Added__c();
                oppMemAdd.Text_1__c=newOpportunity.Id;
                oppMemAdd.Text_2__c=newOpportunity.Name;
                oppMemAdd.Text_3__c=newOpportunity.Opportunity_Number__c;
                oppMemAdd.Text_4__c=newOpportunity.Account_Name1__c;
                oppMemAdd.Text_5__c=newOpportunity.StageName;
                oppMemAdd.Text_6__c=newOpportunity.Initial_Forecast_Quarter__c;
                oppMemAdd.Text_7__c=newOpportunity.Country__c;
                oppMemAdd.Text_8__c=newOpportunity.Closed_Reason__c;
                oppMemAdd.Text_9__c=newOpportunity.Competitor_Lost_To__c;
                oppMemAdd.Text_10__c=newOpportunity.Competitor_Product__c;
                oppMemAdd.Number_1__c=newOpportunity.Amount;
                oppMemAdd.Number_2__c=newOpportunity.Dollar_Amount__c;
                oppMemAdd.Account_1__c=newOpportunity.Partner__c;
                oppMemAdd.Account_2__c=newOpportunity.Tier_2_Partner__c;
                if(newOpportunity.LeadSource==System.Label.Contract_Renewal)
                {
                    oppMemAdd.Condition__c='Send Owner Change for Contract Renewals';
                }
                else
                {
                    oppMemAdd.Condition__c='Send Owner Change Alert';
                }
                oppMemAdd.User_1__c=newOpportunity.Opportunity_Owner__c;
                oppMemAdd.Team_Member_Added__c=newOpportunity.Opportunity_Owner__c;
                oppMemAdd.Date_1__c=newOpportunity.CloseDate;
                lstteam.add(oppMemAdd);
                System.debug('lstteam===>'+lstteam);
                
            }
        }
        if(lstteam!=null && lstteam.size()>0)
        {
            Enterprise_Under_Pen_Email_Notification.insertEmailMemberAlertRecords(lstteam);
        }
    } 
  }   
     
//End of trigger