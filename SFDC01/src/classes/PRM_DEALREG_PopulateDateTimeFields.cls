/*============================================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR          DESCRIPTION                               

 |  ====          =========                ===          =========== 

 |  18 Aug 2011    Arif               3671,3672,3669   This class will be used to populate Related_Account_Populated_Date_Time__c,
                                                       Approved_to_Closed_Expired_Date_Time__c,Passed_to_Partner_Date_Time__c on Lead
 |  8 Sep 2011     Arif                3759            Updated code to include a method clearDealRegDateTimeFields to Blank All the Date
                                                       fields for Deal Registration Resubmission.
 |  13 Sep 2011    Arif                3626            Updated code to include a method updateClosedlostDR to set the value of Deal Status
                                                       to Closed-Lost when Partner Status is set to Deal-Lost
 |  23 Nov 2011    Anirudh             178742          Updated code to populate calculated days field for EMC internal Reporting.               
    27 June 2012   Arif                194177          When a lead is getting converted to DR via 'EMC Convert to DR' checkbox,Passed tp Partner date/time
                                                       field should be populated    
 |  Vivek	      17 Dec 2012          WR# 206404 and WR# 207171 Lead Pull Back and Deal Reg Pull   
 |  Vivek	      15 May 2013          WR# 252201      Lead Status Workflow move to the Trigger.                                                                                                                                                                                                              
+========================================================================================================================================*/
public class PRM_DEALREG_PopulateDateTimeFields {
    
     public static Datetime calculateddate1;
     public void populateDateTimeFieldsOnUpdate(map<Id,Lead> mapOldLead,map<Id,Lead> mapNewLead){
        for(Lead lead:mapNewLead.values()){
            if(lead.Related_Account__c != null && lead.Related_Account__c != mapOldLead.get(lead.Id).Related_Account__c){
                lead.Related_Account_Populated_Date_Time__c = SYSTEM.NOW();
            }
            if(mapOldLead.get(lead.Id).DealReg_Deal_Registration_Status__c == 'Approved'){
                if((lead.DealReg_Deal_Registration_Status__c == 'Closed-Won' || lead.DealReg_Deal_Registration_Status__c == 'Expired')
                     && lead.DealReg_Deal_Registration_Status__c != mapOldLead.get(lead.Id).DealReg_Deal_Registration_Status__c){
                    lead.Approved_to_Closed_Expired_Date_Time__c = SYSTEM.NOW();
                }
            }           
          
            //added for 194177    
            if(lead.Passed_to_Partner__c == true && lead.Passed_to_Partner__c != mapOldLead.get(lead.Id).Passed_to_Partner__c){               
              // && (lead.DealReg_Deal_Registration__c == false || lead.EMC_Convert_To_Deal_Reg__c)){
                lead.Passed_to_Partner_Date_Time__c = SYSTEM.NOW();
                if(lead.Passed_to_Partner_Date_Time__c!=null){
                lead.Days_to_Send_to_Partner__c =  lead.CreatedDate.date().daysbetween(lead.Passed_to_Partner_Date_Time__c.date());
                }
            }    
                   
         
            if(lead.Accept_Lead__c == true && lead.Date_Accepted__c != mapOldLead.get(lead.Id).Date_Accepted__c && lead.Date_Accepted__c != null 
               && lead.DealReg_Deal_Registration__c == false && lead.Passed_to_Partner_Date_Time__c !=null){                
                lead.Days_for_Partner_to_Accept__c =  lead.Passed_to_Partner_Date_Time__c.date().daysbetween(lead.Date_Accepted__c.date());                
                                  
            }
            
             if(mapOldLead.get(lead.Id).DealReg_Deal_Registration_Status__c == 'Approved'){
                if((lead.DealReg_Deal_Registration_Status__c == 'Closed-Won' || lead.DealReg_Deal_Registration_Status__c == 'Closed-Lost')
                     && lead.DealReg_Deal_Registration_Status__c != mapOldLead.get(lead.Id).DealReg_Deal_Registration_Status__c
                     && lead.DealReg_Deal_Registration__c == true && lead.DealReg_PSC_Approval_Rejection_Date_Time__c !=null){
                    lead.Deal_Reg_to_close__c = lead.DealReg_PSC_Approval_Rejection_Date_Time__c.date().daysbetween(System.Now().date());
                }
            }
           
            if((lead.status == 'Closed' || lead.Status == 'Converted to Opportunity')
                && lead.Status != mapOldLead.get(lead.Id).Status && lead.DealReg_Deal_Registration__c == false
                && lead.Date_Accepted__c !=null && lead.Accept_Lead__c == true ){
                lead.Lead_Accepted_to_Closed_Converted__c = lead.Date_Accepted__c.date().daysbetween(System.Now().date());
            }
            
        }
    }
    
      // Added by Krishna WR# 206404 and WR# 207171
   
    public static Datetime CalculateBusinessdate(Datetime accepteddate, Integer businessdays)
		{
			
			System.debug('passed to partner accepted date'+accepteddate);
			Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        	String  strCalculateBusinessdate = 'true';        	
        	if (DataValueMap.containsKey('FlagForCalculateBusinessdate')){
        		CustomSettingDataValueMap__c FlagForCalculateBusinessdate = DataValueMap.get('FlagForCalculateBusinessdate');
        		strCalculateBusinessdate = FlagForCalculateBusinessdate.DataValue__c;
        	}
        	
			integer j=0;
			 Datetime calculateddate=null;
		if(businessdays>0){
			for(Integer i=1;i<=businessdays; i++)
			{
				calculateddate =accepteddate.addDays(i); 
				calculateddate1 = calculateddate;
			
				if( (strCalculateBusinessdate == 'true') && (calculateddate.format('EEE')=='Sun'||calculateddate.format('EEE')=='Sat'))
				{
					j++;
				}  
				
				
			}
			system.debug('value of j='+j);
			if(j>0)
			{
				integer k = j;
				CalculateBusinessdate(calculateddate, k);
			}
			
			system.debug('calculateddateFinal'+calculateddate1);
		}else{
		     calculateddate1 = accepteddate;
		}
			
			return calculateddate1;
		}   
    
    public void populateDateTimeFieldsOnUpdateOfOpportunity(list<Opportunity> lstOpptyToSync){
        Map<Id,Opportunity> MapOpportunity = New Map<Id,Opportunity>();
        
        for(Opportunity opp:lstOpptyToSync){
            MapOpportunity.put(opp.Id,Opp);            
        }
        Map<Id,Lead> MapLeadToUpdate = New Map<Id,Lead>([Select Id,Deal_Reg_to_link__c,Related_Opportunity__c,DealReg_Deal_Registration__c,Passed_to_Partner_Date_Time__c,Days_for_Partner_to_Close__c,Days_to_Close_loop__c,DealReg_PSC_Approval_Rejection_Date_Time__c,CreatedDate,DealReg_Deal_Registration_Status__c from Lead 
                                                         where Related_Opportunity__c in :MapOpportunity.keyset()]);
        for (Lead leadObj :MapLeadToUpdate.values()){
            if(MapOpportunity.get(leadObj.Related_Opportunity__c).Quote_Cart_Number__c !='' && MapOpportunity.get(leadObj.Related_Opportunity__c).Linked_to_Deal_Registration__c ==true){
               if(leadObj.DealReg_PSC_Approval_Rejection_Date_Time__c != null && leadobj.DealReg_Deal_Registration__c == true){                 
                  leadObj.Deal_Reg_to_link__c=leadObj.DealReg_PSC_Approval_Rejection_Date_Time__c.date().daysbetween(System.Now().date());   
                }
            }
             if((MapOpportunity.get(leadObj.Related_Opportunity__c).StageName == 'Won' || MapOpportunity.get(leadObj.Related_Opportunity__c).StageName == 'Closed') && leadobj.DealReg_Deal_Registration__c == false ){                
                leadObj.Days_to_Close_loop__c = leadObj.CreatedDate.date().daysbetween(System.Now().date());
             }
             if(MapOpportunity.get(leadObj.Related_Opportunity__c).StageName == 'Closed' && leadobj.DealReg_Deal_Registration__c == false &&
                leadObj.Passed_to_Partner_Date_Time__c !=null){
                leadObj.Days_for_Partner_to_Close__c=leadObj.Passed_to_Partner_Date_Time__c.date().daysbetween(System.Now().date());                
             }
        }
        Update  MapLeadToUpdate.values();                                    
    }
     
    public void populateDateTimeFieldsOnInsert(list<Lead> lstNewLead){
        for(Lead lead:lstNewLead){
            if(lead.Related_Account__c != null){
                lead.Related_Account_Populated_Date_Time__c = SYSTEM.NOW();        
            }
            if(lead.Passed_to_Partner__c == true){
                lead.Passed_to_Partner_Date_Time__c = SYSTEM.NOW();
                lead.Days_to_Send_to_Partner__c = 0;
            }
        }
    } 
 /* @Method <This method is used to Blank Date/Time Fields on Expired/PSC Declined Deal Registrations>
   @param <This is taking List of Leads from leadBeforeUpdate trigger>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
*/
    public void clearDealRegDateTimeFields(list<Lead> lstLeadsToUpdate){        
        for(Lead lead :lstLeadsToUpdate){
            lead.DealReg_Submission_Date__c=null;
            lead.DealReg_Field_SLA_Expire_on__c=null;
            lead.DealReg_PSC_SLA_Expire_On__c=null;
            lead.Deal_Field_Approval_Rejection_Date_Time__c=null;
            lead.DealReg_PSC_Approval_Rejection_Date_Time__c=null;
        }
    
    }
 /* @Method <This method is used to update DRs status to Closed-lost if the Partner Status is
             set to Deal-Lost>
   @param <This is taking List of Leads from leadBeforeUpdate trigger>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
*/
    public void updateClosedlostDR(list<Lead> lstLeadsToUpdate){ 
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c DealStatusValue = DataValueMap.get('DealRegistrationPartnerVsDealStatus');
        String DealStatus = DealStatusValue.DataValue__c;       
        for(Lead leadobj :lstLeadsToUpdate){
            leadobj.DealReg_Deal_Registration_Status__c = DealStatus;            
        }
    
    }
    
    public void stampTime(List<Opportunity>lstOpp,String fieldname){
        for(Opportunity opp :lstOpp){
            opp.put(fieldname,system.now());
        }
    } 
    /* public Map<id,User> getPartnerUser(List<Lead> setids){
      Set<id> checkids = new Set<id>();
      for(Lead setownerid:setids){
        checkids.add(setownerid.OwnerId);
      }
      Map <id,User> objPartneruser = new Map<id,User>([Select u.id,u.name, u.UserType From User u where u.IsActive=true and u.id in:checkids and u.usertype like '%partner%']);
      return objPartneruser;
    }*/
    
     //WR #206404
    public void populateSLAforPassToPartner(List<Lead> NewRecs, Map<id,User> objPartneruser){      
    	 
        Map<id,User> PartnerCheck = objPartneruser;
        Integer SLAPTPDatetime;
        Integer finalSLAPTPDatetime;
        Integer SLAPTPOwnerchange;      
        PRM_DealReg_Operations objDealReg = new PRM_DealReg_Operations();
         //Populate Theater value on lead
         System.debug('Testing purposessssssssssss');
        objDealReg.populatedTheaterOnLead(NewRecs);        
        //Comparing Theater
       for(Lead leadobj:NewRecs){
       	//if Theater is not available by default//or/Comparing Theater
	     if(leadobj.DealReg_Theater__c != null &&(leadobj.DealReg_Theater__c == 'Americas' || leadobj.DealReg_Theater__c =='EMEA' || leadobj.DealReg_Theater__c=='APJ')){
	     	   Lead_Pull_SLA__c SLADefaults = Lead_Pull_SLA__c.getValues(leadobj.DealReg_Theater__c);
	       	   if(SLADefaults.Lead_Pullback_SLA__c != null){
		       	   SLAPTPDatetime = Integer.valueOf(SLADefaults.Lead_Pullback_SLA__c);
	        	   finalSLAPTPDatetime = Integer.valueOf(SLADefaults.Final_Lead_Pullback_SLA__c);
	        	   SLAPTPOwnerchange = Integer.valueOf(SLADefaults.Lead_Pullback_Change_Owner_SLA__c);
	       	   }
	     }else{
		      Global_Lead_Deal_SLA__c SLADefault = Global_Lead_Deal_SLA__c.getValues('GlobalLead');
		      if(SLADefault.Global_Lead_Deal_Pull_SLA__c !=null){
		          SLAPTPDatetime= Integer.valueOf(SLADefault.Global_Lead_Deal_Pull_SLA__c);
		          finalSLAPTPDatetime =Integer.valueOf(SLADefault.Final_Global_Lead_Deal_Pull_SLA__c);
		          SLAPTPOwnerchange = Integer.valueOf(SLADefault.Global_Lead_Deal_Pull_Change_owner_SLA__c);
		      }
	     }     	
       	 if(PartnerCheck.containsKey(leadobj.OwnerId) && leadobj.Accept_Lead__c == false && SLAPTPDatetime != null && finalSLAPTPDatetime != null && SLAPTPOwnerchange != null){
       	 	     
		     	 leadobj.SLA_For_Passed_to_Partner_date_time__c = CalculateBusinessdate(System.Now(),SLAPTPDatetime);
		     	 leadobj.Final_SLA_For_Passed_to_Partnerdate_time__c = CalculateBusinessdate(System.Now(),finalSLAPTPDatetime);
		     	 leadobj.SLA_For_Passed_to_Partner_Change_Owner__c = CalculateBusinessdate(System.Now(),SLAPTPOwnerchange);
		     	 leadobj.EvaluateFlag__c = true;
		    }
		 
       	}
     }
    
    //#WR 207171 AcceptedLead Not Registered
    public void populateSLAforAcceptedLead(List<Lead> LeadOwner, Map<id,User> objPartneruser)
    {
  	 Map<id,User> PartnerCheck = objPartneruser;
  	 Integer RegisterLeadSLA;
     Integer FinalRegisterLeadSLA;
     Integer RegisterLeadChangeOwnerSLA;
  	  PRM_DealReg_Operations objDealReg = new PRM_DealReg_Operations();
      //Populate Theater value on lead
      objDealReg.populatedTheaterOnLead(LeadOwner); 
  	     for(Lead leadobj: LeadOwner){
	     	system.debug('leadobjleadobj'+leadobj);
	     	if(leadobj.DealReg_Theater__c !=null){
	     	   Register_Lead_SLA__c getTheaters = Register_Lead_SLA__c.getValues(leadobj.DealReg_Theater__c);
	     	   if(getTheaters.Register_Lead_SLA__c != null && getTheaters.Final_Register_Lead_SLA__c != null && getTheaters.Register_Lead_Change_Owner_SLA__c !=null){
	     	   RegisterLeadSLA =  Integer.valueOf(getTheaters.Register_Lead_SLA__c);
	     	   FinalRegisterLeadSLA=Integer.valueOf(getTheaters.Final_Register_Lead_SLA__c);
	     	   RegisterLeadChangeOwnerSLA=Integer.valueOf(getTheaters.Register_Lead_Change_Owner_SLA__c);
	     	   }
	     	}else{
	     	  Global_Lead_Deal_SLA__c SLADefault = Global_Lead_Deal_SLA__c.getValues('GlobalDeal');
	     	  if(SLADefault.Global_Lead_Deal_Pull_SLA__c != null && SLADefault.Final_Global_Lead_Deal_Pull_SLA__c!=null && SLADefault.Global_Lead_Deal_Pull_Change_owner_SLA__c!=null){
	          RegisterLeadSLA= Integer.valueOf(SLADefault.Global_Lead_Deal_Pull_SLA__c);
	          FinalRegisterLeadSLA =Integer.valueOf(SLADefault.Final_Global_Lead_Deal_Pull_SLA__c);
	          RegisterLeadChangeOwnerSLA = Integer.valueOf(SLADefault.Global_Lead_Deal_Pull_Change_owner_SLA__c);
	     	  }
	     	}
		     if(PartnerCheck.containsKey(leadobj.OwnerId) && leadobj.Passed_to_Partner__c == true && leadobj.Accept_Lead__c == true &&
		     	 leadobj.DealReg_Deal_Registration__c == false && leadobj.Last_EMC_Owner__c != null && leadobj.EvaluateFlag__c == true && RegisterLeadChangeOwnerSLA !=null && RegisterLeadSLA !=null && FinalRegisterLeadSLA !=null){
		     	 	system.debug('DealReg_Deal_Registration__cDealReg_Deal_Registration__ccheckkingngngg');
		     	 	leadobj.SLA_For_Accepted_Change_Owner_date_time__c = CalculateBusinessdate(System.Now(),RegisterLeadChangeOwnerSLA);
		     	 	leadobj.SLA_For_Accepted_date_time__c = CalculateBusinessdate(System.Now(),RegisterLeadSLA);
		     	 	leadobj.Final_SLA_For_Accepted_date_time__c = CalculateBusinessdate(System.Now(),FinalRegisterLeadSLA);
		     	 	leadobj.Evaluate__c = true;
		     }      
	     }
   }
   
   //WR #252201
   public void UpdateLeadStatus(List<Lead> lstLeads){	
   	  RecordType objrecordtype = [select id, name,sObjecttype from RecordType where name ='Closed/Converted Lead Record Type' and sObjecttype ='Lead'];	
		for(Lead lstCheck:lstLeads)
		{						
			if(lstCheck.Related_Opportunity__c !=null && lstCheck.Status !='Converted to Opportunity' && lstCheck.DealReg_Deal_Registration__c == false){
			   lstCheck.S_Control_Converted__C = true;			  
			   lstCheck.Status = 'Converted to Opportunity';
			   lstCheck.Date_Closed_Converted__c = System.Now();
			   lstCheck.isConverted__c = true;	
			   lstCheck.RecordType = objrecordtype;
			   			   		
			} 
		}
   }

   
   
   
   
             
}