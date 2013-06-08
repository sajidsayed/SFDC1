/*********************************************************************************************************************************
 Name               Modified on       Description 
 Anand Sharma       20/05/2011        When the Opportunity Status is updated to  Won , the related Deal Registration status will be 
                                      updated to  Closed-Won     
                                      
 Anand Sharma       17/09/2011        Call method populateProductDetailsOnOpportunity to populate Product details.                                      
 Srinivas N         09.12.2011        172761      Update criteria to send email alerts for EMEA Inside Sales 
 Anand Sharma       29/09/2011                    Moved code updateDealStatusFromRelatedOpportunity from this trigger 
                                                  to OpportunityAfterUpdate trigger                                                                                                                     
 Kaustav Debnath    18/11/2011        PRM Partner leverage flag checker to bypass this trigger for opportunities
 Accenture          22/01/2011                  Updated trigger to incorporate ByPass Logic
|                                     NOTE: Please write all the code after BYPASS Logic
|Anil Sure          14-March-12       Populating Direct Rep1,Direct Rep2,Direct Rep3 with related opprtunity Team Members Email Ids when the Status is Booked
|Kaustav Debnath    26-June-12        Commented the call to updatedirectrepfields method for Direct Rep email id population
|Rajeev Satapathy   03-Oct-12         Added the Renewals logic to upadte newly created fields  for the WR #207264
|Rajeev Satapathy     28-Jan-13       Added the logic to have one time Sync of PCSD date with RQF and update sevetral fields on Opporunity                             
***********************************************************************************************************************************/
trigger beforeUpdateOnOpportunity on Opportunity (before update) {
    //Trigger BYPASS Logic
 if(CustomSettingBypassLogic__c.getInstance().By_Pass_Opportunity_Triggers__c){
        return;
 }
    //List<Opportunity> lstOpportunity = new List<Opportunity>();
    Map<Id,Opportunity> MapOpptysToUpdate = New Map<Id,Opportunity>();
    List<Opportunity> lstCartLinkedOpportunity = new List<Opportunity>();
    List<Opportunity> lstClosedWonOpportunity = new List<Opportunity>();
    List<Opportunity> lstOpportunityClosed = new List<Opportunity>();
    
    for(Id newOppId: Trigger.newMap.keySet()){
        Opportunity newOpportunity = Trigger.newMap.get(newOppId);
        Opportunity oldOpportunity = Trigger.oldMap.get(newOppId);        
        System.Debug('newOpportunity --->' +newOpportunity );
        System.Debug('oldOpportunity --->' +oldOpportunity );
        if(newOpportunity.Product_Count__c !=oldOpportunity.Product_Count__c){
            MapOpptysToUpdate.put(newOpportunity.Id, newOpportunity);
        }
        
        // Added logic for the Contract Renewals phase 2 project  ---  WR #207264  --Rajeev       
       
        if(trigger.isUpdate){
           if((newOpportunity.Renewals_Sales_Stage__c !=oldOpportunity.Renewals_Sales_Stage__c)&& (newOpportunity.Renewals_Sales_Stage__c == '2.Quote sent to customer/partner/account manager')){
                System.Debug('Check whether the time stamp field is updating');
                newOpportunity.Time_Stamp_On_Renewals_Sales_Stage__C = DateTime.now();
                System.Debug('After update ####'+newOpportunity.Time_Stamp_On_Renewals_Sales_Stage__C);
             }
             
            if(newOpportunity.Notification_Sent__c != oldOpportunity.Notification_Sent__c){
                  newOpportunity.Notification_Sent_on__c = DateTime.now();
             }
                       
             RenewalsTimingsOperation newInstance = new RenewalsTimingsOperation();
             newInstance.calculateRenewals(newOpportunity);
             
             RenewalsTimingsOperation newInstance1 = new RenewalsTimingsOperation();
             newInstance1.populateTheaterFromCountryOnOppty(newOpportunity);
             
              // One time Sync of PCSD  --- WR# 230704
                 Map<String,PrimaryContractStartDateUpdate__c> DataMap = PrimaryContractStartDateUpdate__c.getAll();
                  System.Debug('Data Mapping------->'+DataMap);
                  
                  String Profname = UserInfo.getProfileId(); 
                  System.Debug('ProfileID-------->'+Profname);
                if((oldOpportunity.HW_TLA_Start_Date__c != NULL)){
                if(!(DataMap.containsKey(Profname))){
                newOpportunity.HW_TLA_Start_Date__c = oldOpportunity.HW_TLA_Start_Date__c; 
                }     
                } 
                if((oldOpportunity.Renewals_Timing__c != NULL)){
                if(!(DataMap.containsKey(Profname))){
                newOpportunity.Renewals_Timing__c = oldOpportunity.Renewals_Timing__c;
                   }     
                }
                               
             if((newOpportunity.Booking_Status__c == 'Rejected Renewals')||(newOpportunity.Booking_Status__c == 'Rejected MCO'))
              {
               if(newOpportunity.Rejected_Reasons__c == NULL)
               {
               newOpportunity.adderror('Please select rejected reasons when the Booking status is selected as  Rejected MCO or Rejected Renewals'); 
               } 
              }
                      
            if((newOpportunity.StageName=='Booked')||(newOpportunity.StageName=='Submitted')){
            newOpportunity.Booking_Status__c = 'Booked';
        }
  
                       
                       
        if(newOpportunity.Booking_Status__c!=oldOpportunity.Booking_Status__c){
           newOpportunity.Booking_Status_Modified__c = DateTime.now();
        }  
        
       if(newOpportunity.Booking_Comment__c!=oldOpportunity.Booking_Comment__c){
         newOpportunity.Comments_Last_Update__c = DateTime.now();
      }
         
       if((oldOpportunity.Booking_Status__c != 'Submitted RSS')&&(newOpportunity.Renewals_Sales_Stage__c == '7.Submitted for Booking')&&(newOpportunity.Renewals_Sales_Stage__c != oldOpportunity.Renewals_Sales_Stage__c)){
        newOpportunity.Booking_Status__c = 'Submitted RSS';
        newOpportunity.Time_Submitted_for_Booking__c =  DateTime.now();
       }
       }
         
   //End of the logic  ---- Rajeev
        
        if(MapOpptysToUpdate.size() > 0 ){
            PRM_DEALREG_RegistrationConversion.populateProductDetailsOnOpportunity(MapOpptysToUpdate);
        }
        if( newOpportunity.StageName !=oldOpportunity.StageName ){
            if(newOpportunity.StageName == 'Closed' || newOpportunity.StageName =='Won' ){
                lstClosedWonOpportunity.add(newOpportunity);
            }
            
            if(newOpportunity.StageName =='Closed' ){
                lstOpportunityClosed.add(newOpportunity);
            }       
        }
        if( newOpportunity.Quote_Cart_Number__c!=oldOpportunity.Quote_Cart_Number__c ){         
                lstCartLinkedOpportunity.add(newOpportunity);
        }        
    }
    //Change for WR-172761
    if(trigger.isUpdate){
        if(!PRM_Partner_Leverage.PRM_Partner_Leverage_flag)
        {
            set<id> setOpptyID = trigger.newmap.keyset();
            list<OpportunityTeamMember> lstOppTeamMember = new list<OpportunityTeamMember>();
            lstOppTeamMember = [select User.Department, OpportunityID from OpportunityTeamMember where OpportunityId in :setOpptyID];
            
            map<id,list<OpportunityTeamMember>> mapOppid_to_OppTeamMembers = new map<id,list<OpportunityTeamMember>>();
            
            for(OpportunityTeamMember OppTM : lstOppTeamMember){
              if(mapOppid_to_OppTeamMembers.containskey(OppTM.OpportunityID))
                 mapOppid_to_OppTeamMembers.get(OppTM.OpportunityID).add(OppTM);
              else
                 mapOppid_to_OppTeamMembers.put(OppTM.OpportunityID, new OpportunityTeamMember[]{OppTM});   
            }
            
            for(Opportunity opp : trigger.new){
                Boolean chkSalesTeamFlag = false;
                if(mapOppid_to_OppTeamMembers.get(opp.id) != null )
                    for(OpportunityTeamMember OTM : mapOppid_to_OppTeamMembers.get(opp.id)){
                        if(OTM.user.Department=='EMEA Inside Sales'){
                            chkSalesTeamFlag = true;
                            break;
                        }    
                    }
                opp.chkSalesTeam__c = chkSalesTeamFlag;
            } 
        }
        if(lstCartLinkedOpportunity.size() >0 ){
           PRM_DEALREG_PopulateDateTimeFields PopDateTimeFieldsObj = New PRM_DEALREG_PopulateDateTimeFields();
            PopDateTimeFieldsObj.stampTime(lstCartLinkedOpportunity,'Quote_Cart_Linked_Date_Time__c');
        }
        if(lstClosedWonOpportunity.size() >0 ){
           PRM_DEALREG_PopulateDateTimeFields PopDateTimeFieldsObj = New PRM_DEALREG_PopulateDateTimeFields();
            PopDateTimeFieldsObj.stampTime(lstClosedWonOpportunity,'Opportunity_Closed_Won_Date__c');
        }
        if(lstOpportunityClosed.size() >0 ){
           PRM_DEALREG_PopulateDateTimeFields PopDateTimeFieldsObj = New PRM_DEALREG_PopulateDateTimeFields();
            PopDateTimeFieldsObj.stampTime(lstClosedWonOpportunity,'Opportunity_Closed_Date__c');
        }
       //Added By Anil
        /* Commented this code
        for(Id newOppId: Trigger.newMap.keySet()){
        Opportunity newopportunityrecords = Trigger.newMap.get(newOppId);
        Opportunity oldopportunityrecords = Trigger.oldMap.get(newOppId);        
       
            if(newopportunityrecords.StageName == 'Booked' && (newopportunityrecords.StageName !=oldopportunityrecords.StageName)){
                MapOpptysToUpdate.put(newopportunityrecords.Id, newopportunityrecords);
            }
            if(MapOpptysToUpdate.size() > 0 )
            {               
                System.debug('##### booked opps to send email to direct reps'+MapOpptysToUpdate);
                PRM_Partner_Leverage obj = new PRM_Partner_Leverage();
                obj.updatedirectrepfields(MapOpptysToUpdate);
            }
        }*/
    }
    
    //End of Change for WR-172761
  }