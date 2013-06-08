/*===================================================================================================================================

History 
20th June 11  Prasad Kothawade           trigger call to update deal regs for Syndergy opportunity number  
29th June 11  Ashwini Gowda              Added Fix for overcoming recursive call. 
29th Sep  11  Anand Sharma               Moved code updateDealStatusFromRelatedOpportunity from this trigger 
                                         to OpportunityAfterUpdate trigger for update deal status on opprotunity    
7th Nov  11   Suman B     IM7246476      Updated the logic for invoking the updateDealStatusFromRelatedOpportunity()
                                         to populate the changed Opportunity Owner Email on related DealReg. 
23 Nov 11     Anirudh     WR178742       Updated code to populate calculated days for Updated Opportunities and populate them on related Lead or Deal.                                                                              
13 Dec 11     Prasad                     Taken out the time stamp logic to lead. Stamping on opp itself in before trigger.
22/01/2011    Accenture                  Updated trigger to incorporate ByPass Logic
|                                        NOTE: Please write all the code after BYPASS Logic
7 Feb 12      Kaustav     WR184353       Added code for Partner Performance rating by field email notification to direct reps
7 Feb 2012    Arif        185037         Added one more condition to call updateDealStatusFromRelatedOpportunity method
19 Feb 2012   Arif        185037         Reverted back the logic as this requirement gets cancelled.
15 Mar 2012   Arif 			             Commented notificationPartnerPerfRatingDirectUser method
01 Oct 2012     Avinash K   MOJO        Added code to call a class to update the Asset's Disposition status
09 Oct 2012     Avinash K   MOJO        Added code to call a class to send an email & post info on chatter based on some criteria 
====================================================================================================================================*/

trigger OpportunityAfterUpdate on Opportunity (after update) {
    //Trigger BYPASS Logic

    if(CustomSettingBypassLogic__c.getInstance().By_Pass_Opportunity_Triggers__c){
            return;
    }
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Set<Id> setBookedWithPartnerPerfOpportunityIds = new Set<Id>();
        
        System.debug('PRM_OpportunityOperations.isDealregUpdated ---> ' + PRM_OpportunityOperations.isDealregUpdated); 
        if(PRM_OpportunityOperations.isDealregUpdated){
            new PRM_OpportunityOperations().updateDealRegs(Trigger.newMap,Trigger.OldMap);               
        }  
        
        // Code to update Deal Status on change of opportunity Status
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c DealrecordType = DataValueMap.get('DealRegOpportunityStage');
        CustomSettingDataValueMap__c OpptyBookedWithPartnerPerfRecordType = DataValueMap.get('Booked_Part_Perf_Rating_Opp_RecType');  
        String strDealrecordType = DealrecordType.DataValue__c;
        String strBookedWithPartnerPerfRatingRecType=OpptyBookedWithPartnerPerfRecordType.DataValue__c;
        for(Id newOppId: Trigger.newMap.keySet()){
            Opportunity newOpportunity = Trigger.newMap.get(newOppId);
            Opportunity oldOpportunity = Trigger.oldMap.get(newOppId);
            
            if( newOpportunity.StageName !=oldOpportunity.StageName ){
                if(newOpportunity.StageName == strDealrecordType){
                    lstOpportunity.add(newOpportunity);
                }
            }
           /* if(newOpportunity.recordtypeid !=oldOpportunity.recordtypeid && newOpportunity.recordtypeid==strBookedWithPartnerPerfRatingRecType)
            {   
                System.debug('### newOpportunity.id'+newOpportunity.id);
                setBookedWithPartnerPerfOpportunityIds.add(newOpportunity.id);
            }           */
            // Added for Opportunity OwnerChange -- IM7246476.  
            if(newOpportunity.OwnerId !=oldOpportunity.OwnerId ){
                    lstOpportunity.add(newOpportunity);             
            }
                        
        }   
       /* if(setBookedWithPartnerPerfOpportunityIds!=null && setBookedWithPartnerPerfOpportunityIds.size()>0)
        {
            PRM_Partner_Leverage.notificationPartnerPerfRatingDirectUser(setBookedWithPartnerPerfOpportunityIds);
        }*/
        if(lstOpportunity.size() >0 ){
            PRM_DEALREG_RegistrationConversion.updateDealStatusFromRelatedOpportunity(lstOpportunity);
        }
    
    
    //End Code

// Code Added by Avinash K begins... 
        if(Trigger.isUpdate && Trigger.isAfter && Trigger.New != null)
        {
            SFA_MOJO_OppAfterUpdateTriggerCode.updateDispositionStatus(Trigger.New, Trigger.OldMap);
            SFA_MOJO_OppAfterUpdateTriggerCode.notifyOnSOUpdate(Trigger.NewMap, Trigger.OldMap);
        }

//Code added by Avinash K ends.
   }