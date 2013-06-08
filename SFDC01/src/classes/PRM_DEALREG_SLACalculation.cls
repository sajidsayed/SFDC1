/*================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

|  13/6/2011        Arif                         This class is used for calculating SLA for Deal Registration.
|  26/6/2011        Prasad                       Fixed Defect #617 - format('yyyy') on date light savings calcuation method
|  03 Oct 2011      Arif                         Updated getDayLightSaving and calculateShiftOfTimeZone method
|  06 Oct 2011      Prasad                       Fixed the defect for Field SLA - changed lastmoditied to system.now()
|  14 Oct 2011      Suman B						 Added Nullpointer check in convertSubmissionTimeIntoLocalZone.    
+================================================================================================*/
public class PRM_DEALREG_SLACalculation {
      
     // Initialized Class Level Variables 
    map<string,DEALREG_Approvers_SLA__c> mapTheaterStatusAndAppoversSLA = new map<string,DEALREG_Approvers_SLA__c>();    
    map<Id,string> mapTheater = new map<Id,string>();   
    map<Id,string> mapApprovalStatus = new map<Id,string>();    
    map<Id,Lead> mapLeadToProcess = new map<Id,Lead>();   
    map<Id,DateTime> mapModifiedDateTime = new map<Id,DateTime>(); 
    map<Id,string> mapCountry = new map<Id,String>();
    map<Id,Extension_Request__c> mapExtensionRequestToProcess = new map<Id,Extension_Request__c>();

/*@Method <This method initiate the process of SLA calculation and 
            all the other methods will be called from this one>
@param <This method take two maps,map of new lead record and map of old lead record>
 Leads From Trigger -- <which contains the new and old lead record>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    public void slaCalculation(map<Id,Lead> mapNewLeadRecordTrigger,map<Id,Lead> mapOldLeadRecordTrigger){
    
        mapLeadToProcess = getLeadRecordToProcess(mapNewLeadRecordTrigger,mapOldLeadRecordTrigger);
        
        if(mapLeadToProcess.size()>0){
            // Initialized Method level variables
                   
            map<Id,string> mapTimeZone = new map<Id,String>();        
                   
            map<Id,DateTime> mapTimeInLocalZone = new map<Id,DateTime>();        
            map<Id,Decimal> mapExpirationHours = new map<Id,Decimal>();        
            map<Id,string> mapSubmissionDay = new map<Id,string>();      
            map<string,set<string>> mapTheaterWiseWorkingDays = new map<string,set<string>>();       
            map<Id,DateTime> mapExpirationDateTime = new map<Id,Datetime>();        
            map<Id,DateTime> mapExpirationDateTimeInGMT = new map<Id,DateTime>();
            
            for(Lead leadRecord: mapLeadToProcess.values()){
                mapTheater.put(leadRecord.Id,leadRecord.DealReg_Theater__c);
                mapApprovalStatus.put(leadRecord.Id,leadRecord.Approval_Status__c);
                mapCountry.put(leadRecord.Id,leadRecord.Country__c);
                if(mapTheaterStatusAndAppoversSLA.get(leadRecord.DealReg_Theater__c + leadRecord.Approval_Status__c).Field_used_for_SLA_calculation__c != null){
                    mapModifiedDateTime.put(leadRecord.Id,(datetime)leadRecord.get(mapTheaterStatusAndAppoversSLA.get(leadRecord.DealReg_Theater__c + leadRecord.Approval_Status__c).Field_used_for_SLA_calculation__c));   
                }
                else{
                   // mapModifiedDateTime.put(leadRecord.Id,leadRecord.LastModifiedDate);
                   mapModifiedDateTime.put(leadRecord.Id,System.now());
                }   
            }
             system.debug('mapModifiedDateTime--------->' +mapModifiedDateTime);
            if(mapTheater.size()>0 && mapApprovalStatus.size()>0 && mapCountry.size()>0){
                mapTimeZone = getTimeZone(mapCountry);
                system.debug('mapTimeZone--------->' +mapTimeZone);
                mapExpirationHours = getDealExpirationHours();
                system.debug('mapExpirationHours--------->' +mapExpirationHours);
                mapTheaterWiseWorkingDays = getWorkingDays();
                system.debug('mapTheaterWiseWorkingDays--------->' +mapTheaterWiseWorkingDays);
            }
            if(mapModifiedDateTime.size()>0 && mapTimeZone.size()>0){
                mapTimeInLocalZone = convertSubmissionTimeIntoLocalZone(mapModifiedDateTime,mapTimeZone);   
                system.debug('mapTimeInLocalZone--------->' +mapTimeInLocalZone);
            }
            /*if(mapTimeInLocalZone.size()>0){          
                
                list<string> lstSubmissionDay = new list<string>();
                lstSubmissionDay = getSubmissionDay(mapTimeInLocalZone.values());       
                mapSubmissionDay
            }*/
            if(mapTheaterWiseWorkingDays.size()>0 && mapTimeInLocalZone.size()>0 && mapExpirationHours.size()>0){
                mapExpirationDateTime = getSLAExpirationTime(mapTimeInLocalZone,mapExpirationHours,mapTheaterWiseWorkingDays);
                system.debug('mapExpirationDateTime--------->' +mapExpirationDateTime);
            }
            if(mapExpirationDateTime.size()>0){
                mapExpirationDateTimeInGMT = getExpirationDateInGMT(mapExpirationDateTime,mapTimeZone);
                system.debug('mapExpirationDateTimeInGMT--------->' +mapExpirationDateTimeInGMT);
            }
            if(mapExpirationDateTimeInGMT.size()>0){
                updateExpirationDateTimeOnDealReg(mapLeadToProcess,mapExpirationDateTimeInGMT);
            }
        }
    }
 
/*@Method <This method is used to filtered the record for which SLA 
            has to be calculated>
@param <This method take two maps,map of new lead record and map of old lead record>
@return <map<Id,Lead>> - <This method returns the map of lead which will be processed for SLA calculation>
@throws exception - <No Exception>
*/

    public map<Id,Lead> getLeadRecordToProcess(map<Id,Lead> mapNewLeadRecordTrigger,map<Id,Lead> mapOldLeadRecordTrigger){
        map<Id,Lead> mapLeadToReturn = new map<Id,Lead>();
        mapTheaterStatusAndAppoversSLA = getWorkHoursAndApproversSLAInformation();
        for (Lead leadRecord :mapNewLeadRecordTrigger.values()){
            if(leadRecord.Approval_Status__c !=null && leadRecord.DealReg_Theater__c!=null && leadRecord.Related_Account__c!=null){
                if(mapOldLeadRecordTrigger.get(leadRecord.Id).Related_Account__c != leadRecord.Related_Account__c){
                        string strTheaterAndApprovalStatus = leadRecord.DealReg_Theater__c + leadRecord.Approval_Status__c;
                        
                        if(mapTheaterStatusAndAppoversSLA.size()>0){
                            if(mapTheaterStatusAndAppoversSLA.containsKey(strTheaterAndApprovalStatus)){
                                mapLeadToReturn.put(leadRecord.Id,leadRecord);
                            }
                        }
                    }
                
                else{
                    if(leadRecord.Approval_Status__c != mapOldLeadRecordTrigger.get(leadRecord.Id).Approval_Status__c){
                        string strTheaterAndApprovalStatus = leadRecord.DealReg_Theater__c + leadRecord.Approval_Status__c;
                        // mapTheaterStatusAndAppoversSLA = getWorkHoursAndApproversSLAInformation();
                            if(mapTheaterStatusAndAppoversSLA.size()>0){
                                if(mapTheaterStatusAndAppoversSLA.containsKey(strTheaterAndApprovalStatus)){
                                    mapLeadToReturn.put(leadRecord.Id,leadRecord);
                                }
                            }                                           
                        }
                } 
            }   
        }       
        return mapLeadToReturn;
        
    }   
    public map<Id,string> getTimeZone(map<Id,string> mapCountry){
        map<Id,string> mapTimeZone = new map<Id,string>();
        //map<string,DEALREG_Approvers_SLA__c> mapTheaterStatusAndAppoversSLA = new map<string,DEALREG_Approvers_SLA__c>();
       // mapTheaterStatusAndAppoversSLA = getWorkHoursAndApproversSLAInformation();
        if(mapTheaterStatusAndAppoversSLA.size()>0){
            for(id leadId :mapTheater.keyset()){            
                    if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) +mapApprovalStatus.get(leadId)).Region__r.Time_Zone__c != null){
                        mapTimeZone.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) +mapApprovalStatus.get(leadId)).Region__r.Time_Zone__c);
                    }
                    else if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) +mapApprovalStatus.get(leadId)).Region__r.Country_State__c.contains(mapCountry.get(leadId))){
                        map<string,DEALREG_Custom_Setting_Country_TimeZone__c> mapCustomSetting = DEALREG_Custom_Setting_Country_TimeZone__c.getAll();
                        mapTimeZone.put(leadId,mapCustomSetting.get(mapCountry.get(leadId)).Time_Zone__c);
                    }               
            }
        }
        mapTimeZone = shiftTimeZoneForDaylightSaving(mapTimeZone);
        return mapTimeZone;                                                          
    }
    
    public map<Id,Datetime> convertSubmissionTimeIntoLocalZone(map<Id,Datetime> mapModifiedDateTime,map<Id,string> mapTimeZone){
        map<Id,Datetime> mapTimeInLocalZone = new map<Id,Datetime>();
        boolean blnIsAdd;
        Datetime dtTimeInLocalZone;
        for(id leadId :mapModifiedDateTime.keyset()){
        	 // Added condition for Nullpointer exception.
           if(mapTimeZone.get(leadId) != null) {	  
             blnIsAdd = mapTimeZone.get(leadId).contains('+');
             string strHours,strMinutes;
             if(blnIsAdd){
                strHours = mapTimeZone.get(leadId).trim().substring(4,6);
                system.debug('strHoursIF--------->' +strHours);
                strMinutes = mapTimeZone.get(leadId).trim().substring(7);
                system.debug('strMinutesIF--------->' +strMinutes);
                dtTimeInLocalZone = mapModifiedDateTime.get(leadId).addHours(integer.valueOf(strHours));
                system.debug('dtTimeInLocalZoneIF1--------->' +dtTimeInLocalZone);
                dtTimeInLocalZone = dtTimeInLocalZone.addMinutes(integer.valueOf(strMinutes));
                system.debug('dtTimeInLocalZoneIF2--------->' +dtTimeInLocalZone);
             }
             else{
                strHours = mapTimeZone.get(leadId).trim().substring(4,6);
                system.debug('strHoursELSE--------->' +strHours);
                strMinutes = mapTimeZone.get(leadId).trim().substring(7);
                system.debug('strMinutesELSE--------->' +strMinutes);
                dtTimeInLocalZone = mapModifiedDateTime.get(leadId).addHours(-integer.valueOf(strHours));
                 system.debug('dtTimeInLocalZoneELSE1--------->' +dtTimeInLocalZone);
                dtTimeInLocalZone = dtTimeInLocalZone.addMinutes(-integer.valueOf(strMinutes));
                system.debug('dtTimeInLocalZoneELSE2--------->' +dtTimeInLocalZone);
             }
             mapTimeInLocalZone.put(leadId,dtTimeInLocalZone);
           } // added condition for Nullpointer check.
        }
        return mapTimeInLocalZone;
    }

    public map<string,DEALREG_Approvers_SLA__c> getWorkHoursAndApproversSLAInformation(){
        map<string,DEALREG_Approvers_SLA__c> mapTheaterStatusAndAppoversSLA = new map<string,DEALREG_Approvers_SLA__c>();
        map<Id,DEALREG_Approvers_SLA__c> mapApproversSLAAndWorkHours = new map<Id,DEALREG_Approvers_SLA__c>([Select id,Business_Hours_For_All_Accounts__c,
                                                                                                             Business_Hours_For_Enterprise_Account__c,Region__c,
                                                                                                             Business_Hours_For_NonEnterprise_Account__c,SLA_Type__c,Field_To_Stamp_On_Lead__c,
                                                                                                             Starts_On__c,Region__r.Business_Hours_in_1_Working_Day__c,Field_used_for_SLA_calculation__c,
                                                                                                             Region__r.Business_Hrs_Ends_At__c,Region__r.Business_Hours_Starts_At__c,
                                                                                                             Region__r.Country_State__c,Region__r.Friday__c,Region__r.Monday__c,
                                                                                                             Region__r.Mid_East_Not__c,Region__r.Saturday__c,Region__r.Sunday__c,
                                                                                                             Region__r.Theater__c,Region__r.Thursday__c,Region__r.Time_Zone__c,
                                                                                                             Region__r.Daylight_Saving_Ending_Day__c,Region__r.Daylight_Saving_Ending_Month__c,
                                                                                                             Region__r.Daylight_Saving_Ends_On__c,Region__r.Daylight_Saving_Hours_Adjustment__c,
                                                                                                             Region__r.Daylight_Saving_Starting_Day__c,Region__r.Daylight_Saving_Starting_Month__c,
                                                                                                             Region__r.Daylight_Saving_Starts_On__c,
                                                                                                             Region__r.Tuesday__c,Region__r.Wednesday__c from DEALREG_Approvers_SLA__c]);
        if(mapApproversSLAAndWorkHours != null){
            for(DEALREG_Approvers_SLA__c approverSLARecord: mapApproversSLAAndWorkHours.values()){
                string strTheaterApproverStatus;
                strTheaterApproverStatus = approverSLARecord.Region__r.Theater__c + approverSLARecord.Starts_On__c;
                mapTheaterStatusAndAppoversSLA.put(strTheaterApproverStatus,approverSLARecord);
            }
        }
        return mapTheaterStatusAndAppoversSLA;
    }
    
    public map<Id,Decimal> getDealExpirationHours(){
        //map<string,DEALREG_Approvers_SLA__c> mapTheaterStatusAndAppoversSLA = new map<string,DEALREG_Approvers_SLA__c>();
        map<Id,Decimal> mapExpirationHours = new map<Id,Decimal>();
        //mapTheaterStatusAndAppoversSLA = getWorkHoursAndApproversSLAInformation(lstTheater,lstApprovalStatus);
        if(mapTheaterStatusAndAppoversSLA.size()>0){
            for(id leadId :mapTheater.keyset()){        
                    if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+ mapApprovalStatus.get(leadId)).Business_Hours_For_All_Accounts__c != null){
                        mapExpirationHours.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+ mapApprovalStatus.get(leadId)).Business_Hours_For_All_Accounts__c);
                    }
                    else{
                         if(mapLeadToProcess.get(leadId).DealReg_Enterprise_Non_Enterprise__c=='ENTERPRISE'){
                            mapExpirationHours.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+ mapApprovalStatus.get(leadId)).Business_Hours_For_Enterprise_Account__c);
                         }
                         else{
                            mapExpirationHours.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+ mapApprovalStatus.get(leadId)).Business_Hours_For_NonEnterprise_Account__c);
                         }
                    }            
            }
        }
        return mapExpirationHours;  
    }
    
/*  public date getSubmissionDate(Datetime dtSubmissionDate){
        Datetime dateTimetemp = dtSubmissionDate;
        Date dateTemp = Date.newInstance(dateTimetemp.year(),dateTimetemp.month(),dateTimetemp.day());
        return dateTemp;
    }  */
    
    public list<string> getSubmissionDay(list<Datetime> lstSubmittedDate){
        list<string> lstSubmittedDay = new list<string>();
        for(Datetime submittedDate: lstSubmittedDate){          
            String strDay = submittedDate.formatGmt('EEE');
            lstSubmittedDay.add(strDay);
        }
        System.debug('lstSubmittedDay----------------->' +lstSubmittedDay);
        return lstSubmittedDay;
    }
    
    public map<string,set<string>> getWorkingDays(){
        set<string> lstWorkingDays = new set<string>();
        map<string,set<string>> mapTheaterWiseWorkingDays = new map<string,set<string>>();
        //map<string,DEALREG_Approvers_SLA__c> mapTheaterStatusAndAppoversSLA = new map<string,DEALREG_Approvers_SLA__c>();
        //mapTheaterStatusAndAppoversSLA = getWorkHoursAndApproversSLAInformation(lstTheater,lstApprovalStatus);
        if(mapTheaterStatusAndAppoversSLA != null){
            for(Id leadId :mapTheater.keyset()){
                if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Sunday__c == true){
                    lstWorkingDays.add('Sun');
                }
                if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Monday__c == true){
                    lstWorkingDays.add('Mon');
                }
                if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Tuesday__c == true){
                    lstWorkingDays.add('Tue');
                }
                if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Wednesday__c == true){
                    lstWorkingDays.add('Wed');
                }
                if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Thursday__c == true){
                    lstWorkingDays.add('Thu');
                }
                if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Friday__c == true){
                    lstWorkingDays.add('Fri');
                }
                if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Saturday__c == true){
                    lstWorkingDays.add('Sat');
                }
                mapTheaterWiseWorkingDays.put(mapTheater.get(leadId),lstWorkingDays);           
            }
        }
        return mapTheaterWiseWorkingDays;
    }
    
    public map<Id,Datetime> getSLAExpirationTime(map<Id,Datetime> mapTimeInLocalZone,map<Id,Decimal> mapExpirationHours,map<string,set<string>> mapTheaterWiseWorkingDays){
        Datetime dtExpirationTime;
        Datetime dtStartDateTime;
        map<Id,Decimal> mapBusinessHrsStartsAt = new map<Id,Decimal>();
        map<Id,Decimal> mapBusinessHrsEndsAt = new map<Id,Decimal>();
        map<Id,Decimal> mapBusinessHrsInASingleDay = new map<Id,Decimal>();
        map<Id,Datetime> mapExpirationDateTime = new map<Id,Datetime>();
    //  map<string,DEALREG_Approvers_SLA__c> mapTheaterStatusAndAppoversSLA = new map<string,DEALREG_Approvers_SLA__c>();
    //  mapTheaterStatusAndAppoversSLA = getWorkHoursAndApproversSLAInformation(lstTheater,lstApprovalStatus);
        if(mapTheaterStatusAndAppoversSLA.size()>0){
            for(Id leadId :mapTheater.keyset()){
                mapBusinessHrsStartsAt.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Business_Hours_Starts_At__c);
                system.debug('mapBusinessHrsStartsAt----------------->' +mapBusinessHrsStartsAt);
                mapBusinessHrsEndsAt.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Business_Hrs_Ends_At__c);
                system.debug('mapBusinessHrsEndsAt----------------->' +mapBusinessHrsEndsAt);
                mapBusinessHrsInASingleDay.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Region__r.Business_Hours_in_1_Working_Day__c);
                system.debug('mapBusinessHrsInASingleDay----------------->' +mapBusinessHrsInASingleDay);
            }
            for(Id localZoneLeadId :mapTimeInLocalZone.keyset()){
                dtStartDateTime = getNextWorkingDateTime(mapTimeInLocalZone.get(localZoneLeadId),mapTheaterWiseWorkingDays.get(mapTheater.get(localZoneLeadId)),mapBusinessHrsStartsAt.get(localZoneLeadId),mapBusinessHrsEndsAt.get(localZoneLeadId));
                 system.debug('dtStartDateTime----------------->' +dtStartDateTime);
                if(mapBusinessHrsInASingleDay.get(localZoneLeadId) <= mapExpirationHours.get(localZoneLeadId)){         
                    dtExpirationTime = getExpirationDateIfGreaterThanWorkingHour(mapExpirationHours.get(localZoneLeadId),mapBusinessHrsInASingleDay.get(localZoneLeadId),dtStartDateTime,mapTheaterWiseWorkingDays.get(mapTheater.get(localZoneLeadId)),mapBusinessHrsStartsAt.get(localZoneLeadId),mapBusinessHrsEndsAt.get(localZoneLeadId));
                    system.debug('dtExpirationTimeIF----------------->' +dtExpirationTime);
                } 
                else{
                    dtExpirationTime = getExpirationDateIfLessThanWorkingHour(mapExpirationHours.get(localZoneLeadId),mapBusinessHrsInASingleDay.get(localZoneLeadId),dtStartDateTime,mapTheaterWiseWorkingDays.get(mapTheater.get(localZoneLeadId)),mapBusinessHrsStartsAt.get(localZoneLeadId),mapBusinessHrsEndsAt.get(localZoneLeadId));
                    system.debug('dtExpirationTimeELSE----------------->' +dtExpirationTime);
                }   
                mapExpirationDateTime.put(localZoneLeadId,dtExpirationTime);        
            }
        }
        return mapExpirationDateTime;
    }
    
    public boolean getNextWorkingDay(Datetime dtWorkingDate,set<string> lstWorkingDays){
        list<Datetime> lstWorkingDate = new list<Datetime>();
        lstWorkingDate.add(dtWorkingDate);
        list<string> lstCurrentDay = getSubmissionDay(lstWorkingDate);
        boolean status = lstWorkingDays.contains(lstCurrentDay[0]);
        return status;
    }   
    
    public Datetime getExpirationDateIfGreaterThanWorkingHour(Decimal dmlExpirationHours,Decimal dmlWorkingHours,Datetime dtTimeInLocalZone,set<string> lstWorkingDays,decimal dmlWorkStartTime,decimal dmlWorkStopTime){
        decimal dmlNumOfSLADays = dmlExpirationHours/dmlWorkingHours;
        System.Debug('CheckdmlNumOfSLADays--->' +dmlNumOfSLADays);
        decimal dmlRemainderSLAHoursToAdd = dmlExpirationHours- dmlNumOfSLADays.intvalue()*dmlWorkingHours;
        System.Debug('CheckdmlRemainderSLAHoursToAdd--->' +dmlRemainderSLAHoursToAdd);
        System.Debug('CheckinggetDecimalPartdmlExpirationHours--->' +getDecimalPart(dmlExpirationHours));
        datetime SLAExpirationDate;
        integer intRemainderSLAMinutesToAdd = dmlRemainderSLAHoursToAdd.intvalue()*60 + (getDecimalPart(dmlRemainderSLAHoursToAdd)*6)/10;
        System.Debug('CheckdmlRemainderSLAHoursToAddInMinutes--->' +dmlRemainderSLAHoursToAdd.intvalue()*60);
        System.Debug('CheckdmlRemainderSLAMinutestoAddFinally--->' +(getDecimalPart(dmlRemainderSLAHoursToAdd)*6)/10);
        System.Debug('CheckdmlRemainderSLAMinutestoAddFinally--->' +(getDecimalPart(dmlRemainderSLAHoursToAdd)*6)/10);
        System.Debug('intRemainderSLAMinutesToAdd--->' + intRemainderSLAMinutesToAdd);
        if(dtTimeInLocalZone.hourgmt()==dmlWorkStartTime.intvalue() && dtTimeInLocalZone.minutegmt() ==getDecimalPart(dmlWorkStartTime) ){                  
            SLAExpirationDate = getExpirationDateForIteration (dmlNumOfSLADays,dtTimeInLocalZone,lstWorkingDays);                                   
            if(dmlRemainderSLAHoursToAdd==0){
                integer j = 1;
                while(j<=3){
                    SLAExpirationDate = SLAExpirationDate.adddays(-1);
                    Boolean blnStatus = getNextWorkingDay(SLAExpirationDate,lstWorkingDays); 
                    if(blnStatus){
                        break;
                    }
                    j++;
                }                   
                SLAExpirationDate = SLAExpirationDate.addhours(dmlWorkingHours.intvalue()).addminutes((getDecimalPart(dmlWorkingHours)*6)/10);
            }
            else{
                 SLAExpirationDate = SLAExpirationDate.addminutes(intRemainderSLAMinutesToAdd);
            }               
        }
        else{
             SLAExpirationDate = getExpirationDateForIteration (dmlNumOfSLADays,dtTimeInLocalZone,lstWorkingDays);
             System.Debug('GReaterElseSLAExpirationDate--->' +SLAExpirationDate);
             System.Debug('IfcalculationValue--->' + (((dmlWorkStopTime.intValue() * 60) + getDecimalPart(dmlWorkStopTime)) - 
                ((dtTimeInLocalZone.hourGmt() * 60) + dtTimeInLocalZone.minuteGmt()) > intRemainderSLAMinutesToAdd));
             if(((dmlWorkStopTime.intValue() * 60) + getDecimalPart(dmlWorkStopTime)) - 
                ((dtTimeInLocalZone.hourGmt() * 60) + dtTimeInLocalZone.minuteGmt()) > intRemainderSLAMinutesToAdd 
               ){
                  System.Debug('intRemainderSLAMinutesToAdd000--->' +intRemainderSLAMinutesToAdd);
                 SLAExpirationDate = SLAExpirationDate.addminutes(intRemainderSLAMinutesToAdd);
            }
            else{
                 integer intRemainingTimeofWrkingDay = ((dmlWorkStopTime.intValue() * 60) + getDecimalPart(dmlWorkStopTime)) - 
                                                       ((dtTimeInLocalZone.hourGmt() * 60) + dtTimeInLocalZone.minuteGmt());
                 System.Debug('ElseGreaterintRemainingTimeofWrkingDay--->' +intRemainingTimeofWrkingDay);                                      
                 integer intMinutesToAddInNextDay = intRemainderSLAMinutesToAdd - intRemainingTimeofWrkingDay;
                 System.Debug('ElseGreaterintMinutesToAddInNextDay--->' +intMinutesToAddInNextDay); 
                 SLAExpirationDate = getNextWorkingDate(SLAExpirationDate,lstWorkingDays);
                 SLAExpirationDate = getStartDateTime(SLAExpirationDate,dmlWorkStartTime);                      
                 SLAExpirationDate = SLAExpirationDate.addminutes(intMinutesToAddInNextDay);
                 System.Debug('ElseGreaterintSLAExpirationDate-0------->' +SLAExpirationDate);  
            }    
        }
        return SLAExpirationDate;
    }
    public Datetime getExpirationDateForIteration(decimal intLoopVariable,datetime dtTimeInLocalZone,set<string> lstWorkingDays ){
        System.Debug('IterationdmlintLoopVariable--->' +intLoopVariable);
        System.Debug('IterationdtTimeInLocalZone--->' +dtTimeInLocalZone);
        System.Debug('IterationlstWorkingDays--->' +lstWorkingDays);
        datetime NxtWorkingExpirationDate;
        integer i = 1;
        while(i <=intLoopVariable.intValue()){
              
              NxtWorkingExpirationDate = dtTimeInLocalZone.addDays(1);
              System.Debug('IterationNxtWorkingExpirationDate--->' +NxtWorkingExpirationDate);
               System.Debug('IterationdtTimeInLocalZoneIn--->' +dtTimeInLocalZone);
              Boolean blnStatus = getNextWorkingDay(NxtWorkingExpirationDate,lstWorkingDays);  
               System.Debug('IterationblnStatus--->' +blnStatus);                         
                  if(blnStatus == false){
                     i=i;              
                     System.Debug('Iterationif--->' +i); 
                  }
                  if(blnStatus == true){
                       i++;
                       System.Debug('Iterationelse--->' +i); 
                  }
                
              dtTimeInLocalZone =  NxtWorkingExpirationDate;
        }   
        System.Debug('IterationdtTimeInLocalZone--->' +dtTimeInLocalZone);
        return NxtWorkingExpirationDate;
    }       
  public Datetime getExpirationDateIfLessThanWorkingHour(Decimal dmlExpirationHours,Decimal dmlWorkingHours,Datetime dtTimeInLocalZone,set<string> lstWorkingDays,decimal dmlWorkStartTime,decimal dmlWorkStopTime){
    Datetime dtTimeToReturn,dtNextBusinessDay;
    integer intMinutesAddedToNextWorkingDay;
    if(
        ((dmlWorkStopTime.intValue() * 60) + getDecimalPart(dmlWorkStopTime)) - 
        ((dtTimeInLocalZone.hourGmt() * 60) + dtTimeInLocalZone.minuteGmt()) > 
        ((dmlExpirationHours.intValue() * 60) + ((getDecimalPart(dmlExpirationHours) * 6)/10))
    ){
        dtTimeToReturn = dtTimeInLocalZone.addHours(dmlExpirationHours.intValue());
        system.debug('LTdateTimeToReturnHrs----------------->' +dtTimeToReturn);
        dtTimeToReturn = dtTimeToReturn.addMinutes(((getDecimalPart(dmlExpirationHours) * 6)/10));
        system.debug('LTdateTimeToReturnMins----------------->' +dtTimeToReturn);

     }
     else{
        intMinutesAddedToNextWorkingDay = ((dmlExpirationHours.intValue() * 60) + ((getDecimalPart(dmlExpirationHours) * 6)/10)) - 
                                          (((dmlWorkStopTime.intValue() * 60) + getDecimalPart(dmlWorkStopTime)) - 
                                          ((dtTimeInLocalZone.hourGmt() * 60) + dtTimeInLocalZone.minuteGmt()));
                    
        system.debug('LTintMinutesAddedToNextWorkingDay----------------->' +intMinutesAddedToNextWorkingDay);
        dtNextBusinessDay = getNextWorkingDate(dtTimeInLocalZone,lstWorkingDays); 
        system.debug('LTdtNextBusinessDay----------------->' +dtNextBusinessDay);
        string DateValueofNextBusinessDay = string.Valueof(dtNextBusinessDay).substring(0,10);
        system.debug('LTDateValueofNextBusinessDay---------------->' +DateValueofNextBusinessDay);
        string DateValuewithTime = DateValueofNextBusinessDay +' ' + string.valueOf(dmlWorkStartTime.intValue()) + ':' + getDecimalPart(dmlWorkStartTime) + ':' + '00';
        system.debug('LTDateValuewithTime---------------->' +DateValuewithTime);
        dtTimeToReturn = datetime.valueofGmt(DateValuewithTime).addMinutes(intMinutesAddedToNextWorkingDay);
     }
     system.debug('LTdtTimeToReturn---------------->' +dtTimeToReturn);
    return  dtTimeToReturn;
 }
    
    
    public Datetime getNextWorkingDateTime(Datetime dtCurrentDate,set<string> lstWorkingDays,decimal dmlWorkStartTime,decimal dmlWorkEndTime){
        system.debug('NWDdtCurrentDate----------------->' +dtCurrentDate);
         system.debug('NWDdmlWorkStartTime----------------->' +dmlWorkStartTime);
          system.debug('NWDdmlWorkEndTime----------------->' +dmlWorkEndTime);
        boolean blnIsWorkingDay = getNextWorkingDay(dtCurrentDate,lstWorkingDays);  
        system.debug('blnIsWorkingDay----------------->' +blnIsWorkingDay); 
        datetime dtNextBusinessDay;
        string strCurrentTime;
        datetime dtTimeToReturn;
        if(blnIsWorkingDay){
            strCurrentTime = dtCurrentDate.hour()+'.'+dtCurrentDate.minute(); 
            system.debug('dtCurrentDate.hour()----------------->' +dtCurrentDate.hourGmt());    
            system.debug('dtCurrentDate.minute()----------------->' +dtCurrentDate.minuteGmt());      
             
              system.debug('dtCurrentDate.hour()*60----------------->' +dtCurrentDate.hourGmt()*60);
              system.debug('getDecimalPart(dmlWorkStartTime)----------------->' +getDecimalPart(dmlWorkStartTime)); 
              system.debug('getDecimalPart(dmlWorkEndTime)----------------->' +getDecimalPart(dmlWorkEndTime)); 
            boolean blnIsWorkingTime = ((dtCurrentDate.hourGmt()*60+dtCurrentDate.minuteGmt() >= (dmlWorkStartTime).intvalue()*60+getDecimalPart(dmlWorkStartTime)) && 
                                        (dtCurrentDate.hourGmt()*60+dtCurrentDate.minuteGmt() <= (dmlWorkEndTime).intvalue()*60+getDecimalPart(dmlWorkEndTime)));
            system.debug('dtCurrentDate.hour()*60+dtCurrentDate.minute()----------------->' +dtCurrentDate.hourGmt()*60+dtCurrentDate.minuteGmt());
             system.debug('(dmlWorkStartTime).intvalue()*60+getDecimalPart(dmlWorkStartTime)' +(dmlWorkStartTime).intvalue()*60+getDecimalPart(dmlWorkStartTime));
              system.debug('(dmlWorkEndTime).intvalue()*60+getDecimalPart(dmlWorkEndTime)----------------->' +(dmlWorkEndTime).intvalue()*60+getDecimalPart(dmlWorkEndTime));
            system.debug('blnIsWorkingTime----------------->' +blnIsWorkingTime);                               
            
            if(blnIsWorkingTime){
                dtTimeToReturn = dtCurrentDate;
                system.debug('IFdtTimeToReturn----------------->' +dtTimeToReturn);
            }
            else{
                if(dtCurrentDate.hourGmt()*60+dtCurrentDate.minuteGmt() < (dmlWorkStartTime).intvalue()*60+getDecimalPart(dmlWorkStartTime)){
                    dtTimeToReturn = getStartDateTime(dtCurrentDate,dmlWorkStartTime);
                     system.debug('ELSEIF1dtTimeToReturn----------------->' +dtTimeToReturn);
                }
                if(dtCurrentDate.hourGmt()*60+dtCurrentDate.minuteGmt() > (dmlWorkEndTime).intvalue()*60+getDecimalPart(dmlWorkEndTime)){
                    dtNextBusinessDay = getNextWorkingDate(dtCurrentDate,lstWorkingDays);
                    system.debug('ELSEIF2dtNextBusinessDay----------------->' +dtNextBusinessDay);
                    dtTimeToReturn = getStartDateTime(dtNextBusinessDay,dmlWorkStartTime);
                    system.debug('ELSEIF2dtTimeToReturnelse----------------->' +dtTimeToReturn);
                }
            }
            
        }
        else{
            
            dtNextBusinessDay = getNextWorkingDate(dtCurrentDate,lstWorkingDays);
             system.debug('ELSE2dtNextBusinessDay----------------->' +dtNextBusinessDay);
            dtTimeToReturn = getStartDateTime(dtNextBusinessDay,dmlWorkStartTime);
             system.debug('ELSE2dtTimeToReturn----------------->' +dtTimeToReturn);
        }
        system.debug('FINALTimeToReturn----------------->' +dtTimeToReturn);
        return dtTimeToReturn;
    }
    
    public datetime getStartDateTime(datetime dtDateTime,decimal dmlTime){
        datetime dtStartTime;
        system.debug('getstartdtDateTime----------------->' +dtDateTime);
        system.debug('getstartdmlTime----------------->' +dmlTime);
        string strSubPartOfDateTime = string.ValueofGmt(dtDateTime).substring(0,10);
        system.debug('getstartstrSubPartOfDateTimee----------------->' +strSubPartOfDateTime);
        string strTime = string.valueOf(dmlTime);
        system.debug('getstartstrTimee----------------->' +strTime);
        string strHours,strMinutes;
        if(strTime.length()==4){
            strHours = strTime.substring(0,1);
            strMinutes = strTime.substring(2);
        }
        if(strTime.length()==5){
            strHours = strTime.substring(0,2);
            strMinutes = strTime.substring(3);
        }
        string strStartDateTime = strSubPartOfDateTime +' ' + strHours + ':' + strMinutes + ':' + '00';
        system.debug('getstartstrStartDateTime----------------->' +strStartDateTime);
        dtStartTime = datetime.valueOfGmt(strStartDateTime);
        system.debug('getstartdtStartTime----------------->' +dtStartTime);
        return dtStartTime;
    }
    
    public dateTime getNextWorkingDate(Datetime dtCurrentDate,set<string> lstWorkingDays){
        datetime dtNextBusinessDay;
        system.debug('nxtdtCurrentDate----------------->' +dtCurrentDate);
        integer i = 1;
        while(i <= 3){
            dtNextBusinessDay = dtCurrentDate.addDays(1);
            Boolean blnStatus = getNextWorkingDay(dtNextBusinessDay,lstWorkingDays);
             system.debug('nxtblnStatus----------------->' +blnStatus);
            if(blnStatus == false){
                i++;
            }
            else{
                break;
            }
            dtCurrentDate = dtNextBusinessDay;
        }
         system.debug('nxtdtNextBusinessDay----------------->' +dtNextBusinessDay);
        return dtNextBusinessDay;
         
    }
    
    public map<Id,Datetime> getExpirationDateInGMT(map<Id,datetime> mapTimeInLocalZone,map<Id,string> mapTimeZone){
        system.debug('INGTMTmapTimeInLocalZone----------------->' +mapTimeInLocalZone);
        system.debug('INGMTmapTimeZone----------------->' +mapTimeZone);
        map<Id,datetime> mapTimeInGMT = new map<Id,datetime>();
        boolean blnIsAdd;
        Datetime dtTimeInGMT;
        for(Id leadId :mapTimeInLocalZone.keyset()){
             blnIsAdd = mapTimeZone.get(leadId).contains('+');
             system.debug('INGMTblnIsAdd----------------->' +blnIsAdd);
             string strHours,strMinutes;
             if(blnIsAdd){
                strHours = mapTimeZone.get(leadId).trim().substring(4,6);
                system.debug('IFINGMTstrHours----------------->' +strHours);
                strMinutes = mapTimeZone.get(leadId).trim().substring(7);
                system.debug('IFINGMTstrMinutes----------------->' +strMinutes);
                dtTimeInGMT = mapTimeInLocalZone.get(leadId).addHours(-integer.valueOf(strHours));
                
                dtTimeInGMT = dtTimeInGMT.addMinutes(-integer.valueOf(strMinutes));
                 system.debug('IFINGMTdtTimeInGMT----------------->' +dtTimeInGMT);
             }
             else{
                strHours = mapTimeZone.get(leadId).trim().substring(4,6);
                system.debug('elseINGMTstrHours----------------->' +strHours);
                strMinutes = mapTimeZone.get(leadId).trim().substring(7);
                 system.debug('elseINGMTstrMinutes----------------->' +strMinutes);
                dtTimeInGMT = mapTimeInLocalZone.get(leadId).addHours(integer.valueOf(strHours));
                dtTimeInGMT = dtTimeInGMT.addMinutes(integer.valueOf(strMinutes));
                 system.debug('elseINGMTdtTimeInGMT----------------->' +dtTimeInGMT);
             }
             mapTimeInGMT.put(leadId,dtTimeInGMT);
        }
         system.debug('FINALMAPINGMTmapTimeInGMT----------------->' +mapTimeInGMT);
        return mapTimeInGMT;
    }
    
    public void updateExpirationDateTimeOnDealReg(map<Id,lead> mapLeadRecord,map<Id,datetime> mapExpirationDateTimeInGMT){
        map<Id,lead> mapLeadToBeUpdate = new map<Id,lead>();
        list<lead> lstLeadToUpdate = new list<lead>();
        map<Id,string> mapFieldToStampOnLead = getFieldToStampOnLead();
        for(Id leadId :mapLeadRecord.keyset()){
            string fieldToUpdate = mapFieldToStampOnLead.get(leadId);
            mapLeadRecord.get(leadId).put(mapFieldToStampOnLead.get(leadId),mapExpirationDateTimeInGMT.get(leadId));
           // lstLeadToUpdate.add(mapLeadRecord.get(leadId));
        }
        /*for(Id leadIdUpdate: mapLeadRecord.keyset()){
            mapLeadToBeUpdate.put(leadIdUpdate,mapLeadRecord.get(leadIdUpdate));
        }
        if(lstLeadToUpdate.size()>0){
            update lstLeadToUpdate;
        }*/
    } 
    
   
    public integer getDecimalPart(decimal dmlNumber){
        integer intNumber = dmlnumber.intValue();
        dmlNumber  = dmlNumber - intNumber;
        return ((dmlNumber*100).intValue());
    } 
    public Map<Id,String> getFieldToStampOnLead (){
        map<Id,String> mapFieldToStamp = new map<Id,string>();
        for(Id leadId :mapTheater.keyset()){
            mapFieldToStamp.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+mapApprovalStatus.get(leadId)).Field_To_Stamp_On_Lead__c);                
        }
        return mapFieldToStamp;
    }
    
    public map<Id,string> shiftTimeZoneForDaylightSaving(map<Id,String> mapTimeZone){
        string strTimeZone;
        integer i = 0;
        map<Id,string> mapTimeZoneToReturn = new map<Id,string>();
        for(Id leadId: mapTimeZone.keyset()){
            if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Ending_Day__c != null &&
               mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Ending_Month__c != null &&
               mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Ends_On__c != null &&
               mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Hours_Adjustment__c != null &&
               mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Starting_Day__c != null &&
               mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Starting_Month__c != null &&
               mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Starts_On__c != null){
               system.debug('FIRST-----------');
               i=1;
               system.debug('1----->' +mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Ending_Day__c);
               system.debug('2----->' +mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Ending_Month__c);
               system.debug('3----->' +mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Ends_On__c);
               system.debug('4----->' +mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Hours_Adjustment__c);
               system.debug('5----->' +mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Starting_Day__c);
               system.debug('6----->' +mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Starting_Month__c);
               system.debug('7----->' +mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Starts_On__c);
               system.debug('8----->' +mapTimeZone.get(leadId));
               system.debug('9----->' +mapModifiedDateTime.get(leadId));
               
                strTimeZone =  calculateShiftingOfTimeZone(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Ending_Day__c,
                                                           mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Ending_Month__c,
                                                           mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Ends_On__c,
                                                           mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Hours_Adjustment__c,
                                                           mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Starting_Day__c,
                                                           mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Starting_Month__c,
                                                           mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) + mapApprovalStatus.get(leadId)).Region__r.Daylight_Saving_Starts_On__c,
                                                           mapTimeZone.get(leadId),mapModifiedDateTime.get(leadId));
                
                mapTimeZoneToReturn.put(leadId,strTimeZone);
                system.debug('mapTimeZoneToReturn----------->' +mapTimeZoneToReturn);
            }
             else if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId) +mapApprovalStatus.get(leadId)).Region__r.Country_State__c.contains(mapCountry.get(leadId))){
                map<string,DEALREG_Custom_Setting_Country_TimeZone__c> mapCustomSetting = DEALREG_Custom_Setting_Country_TimeZone__c.getAll();
                if(mapCustomSetting.containsKey(mapCountry.get(leadId))){
                    if(mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Ending_Day__c != null&&
                       mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Ending_Month__c != null&&
                       mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Ends_On__c != null &&
                       mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Hours_Adjustment__c != null &&
                       mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Starting_Day__c != null &&
                       mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Starting_Month__c != null &&
                       mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Starts_On__c != null ){
                        system.debug('SECOND--------');
                        i=2;
                        strTimeZone =  calculateShiftingOfTimeZone(mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Ending_Day__c,
                                                                   mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Ending_Month__c,
                                                                   mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Ends_On__c,
                                                                   mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Hours_Adjustment__c,
                                                                   mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Starting_Day__c,
                                                                   mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Starting_Month__c,
                                                                   mapCustomSetting.get(mapCountry.get(leadId)).Daylight_Saving_Starts_On__c,
                                                                   mapTimeZone.get(leadId),mapModifiedDateTime.get(leadId));
                        
                        mapTimeZoneToReturn.put(leadId,strTimeZone);
                    }
                }
            }
            if(i==0){
                system.debug('THIRD---------');
                mapTimeZoneToReturn.put(leadId,mapTimeZone.get(leadId));
            }
            }
        system.debug('mapTimeZoneToReturnshiftTimeZoneForDaylightSaving----------->' +mapTimeZoneToReturn);
        
        return mapTimeZoneToReturn;
    }
    
    public string calculateShiftingOfTimeZone(string strDSEndingDay,string strDSEndingMonth,string strDSEndsOn,string strDSHours,string strDSStartDay,
                                              string strDSStartMonth,string strDSStartsOn,string strTimeZone,datetime dtModifiedDate){
        system.debug('strDSEndingDay----->' +strDSEndingDay);
        system.debug('strDSEndingMonth----->' +strDSEndingMonth);
        system.debug('strDSEndsOn----->' +strDSEndsOn);
        system.debug('strDSHours----->' +strDSHours);
        system.debug('strDSStartDay----->' +strDSStartDay);
        system.debug('strDSStartMonth----->' +strDSStartMonth);
        system.debug('strDSStartsOn----->' +strDSStartsOn);
        system.debug('strTimeZone----->' +strTimeZone);
        
        Datetime dtStartDate = getDaylightSavingDate(strDSStartMonth,strDSStartDay,strDSStartsOn,dtModifiedDate,true);
        system.debug('dtStartDatecalculateShiftingOfTimeZone----------->' +dtStartDate);
        Datetime dtEndDate = getDaylightSavingDate(strDSEndingMonth,strDSEndingDay,strDSEndsOn,dtModifiedDate,false);
        system.debug('dtEndDatecalculateShiftingOfTimeZone----------->' +dtEndDate);
        string strTimeZoneToReturn;
        system.debug('dtModifiedDate.month' +dtModifiedDate.month());
        system.debug('dtStartDate.month' +dtStartDate.month());
        system.debug('dtEndDate.month()' +dtEndDate.month());
         system.debug('dtModifiedDate.dayOfYear()' +dtModifiedDate.dayOfYear());
          system.debug('dtStartDate.dayOfYear()' +dtStartDate.dayOfYear());
          system.debug('dtEndDate.dayOfYear()' +dtEndDate.dayOfYear());
        
        if(dtModifiedDate.month() >= dtStartDate.month() && dtModifiedDate.month() <= dtEndDate.month()){
            if(dtModifiedDate.dayOfYear() >= dtStartDate.dayOfYear() && dtModifiedDate.dayOfYear() <= dtEndDate.dayOfYear()){
                 system.debug('step 1');
                 Boolean blnIsAdd = strDSHours.contains('+');
                 Boolean blnIsAddTZ = strTimeZone.contains('+');
                 string strHours,strMinutes,strTZHours,strTZMinutes;
                 integer intHours,intMinutes,intTotalInMinutes;
                 if(strDSHours.length()==5){
                 system.debug('step 2');
                     strHours = strDSHours.substring(1,2);
                     strMinutes = strDSHours.substring(3);
                      system.debug('strHours---->' +strHours);
                      system.debug('strMinutes---->' +strMinutes);
                      system.debug('blnIsAdd---->' +blnIsAdd);
                      system.debug('blnIsAddTZ---->' +blnIsAddTZ);
                 }
                 if(strDSHours.length()==6){
                     system.debug('step 3');
                     strHours = strDSHours.substring(1,3);
                     strMinutes = strDSHours.substring(4);
                 }
                 strTZHours = strTimeZone.trim().substring(4,6);
                 strTZMinutes = strTimeZone.trim().substring(7,9);
                 if(blnIsAdd){
                 system.debug('step 4');      
                    if(blnIsAddTZ){   
                    system.debug('step 5');     
                        intHours = integer.valueOf(strHours) + integer.valueOf(strTZHours);
                        intMinutes = integer.valueOf(strMinutes) + integer.valueOf(strTZMinutes);
                        if(intHours<=9){
                            system.debug('step 6');
                            strTimeZoneToReturn = 'GMT+'+'0'+intHours.format()+':'+intMinutes.format();
                        }
                        else{
                            system.debug('step 7');
                            strTimeZoneToReturn = 'GMT+'+intHours.format()+':'+intMinutes.format();
                        }
                        system.debug('strTimeZoneToReturnABC------->' +strTimeZoneToReturn);
                    }
                    else{
                        system.debug('step 8');
                        if(integer.valueOf(strHours) >= integer.valueOf(strTZHours)){                   
                            intTotalInMinutes = ((integer.valueOf(strHours)*60)+ integer.valueOf(strMinutes))- 
                                                ((integer.valueOf(strTZHours)*60)+ integer.valueOf(strTZMinutes));
                            strTimeZoneToReturn = 'GMT+'+'00'+':'+intTotalInMinutes.format();
                        }
                        else{
                        system.debug('step 9');
                            intTotalInMinutes = ((integer.valueOf(strTZHours)*60)+ integer.valueOf(strTZMinutes))- 
                                                ((integer.valueOf(strHours)*60)+ integer.valueOf(strMinutes));
                            strTimeZoneToReturn = 'GMT-'+'00'+':'+intTotalInMinutes.format();
                        }
                    }
                 }
                 else{
                     system.debug('step 10');
                    if(blnIsAddTZ){
                        system.debug('step 11');
                        if(integer.valueOf(strTZHours) >= integer.valueOf(strHours)){
                            intTotalInMinutes = ((integer.valueOf(strTZHours)*60)+ integer.valueOf(strTZMinutes))- 
                                                ((integer.valueOf(strHours)*60)+ integer.valueOf(strMinutes));
                            strTimeZoneToReturn = 'GMT+'+'00'+':'+intTotalInMinutes.format();
                        }
                        else{
                            system.debug('step 12');
                            intTotalInMinutes = ((integer.valueOf(strHours)*60)+ integer.valueOf(strMinutes))- 
                                                ((integer.valueOf(strTZHours)*60)+ integer.valueOf(strTZMinutes));
                            strTimeZoneToReturn = 'GMT-'+'00'+':'+intTotalInMinutes.format();
                        }
                    }
                    else{
                        system.debug('step 13');
                        intHours = integer.valueOf(strHours) + integer.valueOf(strTZHours);
                        intMinutes = integer.valueOf(strMinutes) + integer.valueOf(strTZMinutes);
                        if(intHours<=9){
                            strTimeZoneToReturn = 'GMT-'+'0'+intHours.format()+':'+intMinutes.format();
                        }
                        else{
                            system.debug('step 14');
                            strTimeZoneToReturn = 'GMT-'+intHours.format()+':'+intMinutes.format();
                        }
                    }                   
                 }
             }
              else{
                  system.debug('step 15');
                  strTimeZoneToReturn = strTimeZone;
              }         
            
        }
        else{
            system.debug('step 16');
            strTimeZoneToReturn = strTimeZone;
        }
        system.debug('strTimeZoneToReturn----------->'+strTimeZoneToReturn);
        return strTimeZoneToReturn;
   }
   
   public datetime getDaylightSavingDate(string strMonth,string strDay,string strOn,datetime dtModifiedDate,Boolean blnStart){
    //  string strDays,strMonth;
        Datetime dtreturn;
        list<Datetime> lstDate = new list<Datetime>();
        integer intNoOfDays,intNoOfTimes,intActualNoOfTimes=1;
        list<Datetime> dtDateToReturn = new List<Datetime>();
        list<string> lstDay = new list<string>();
        if(strMonth == '01'||strMonth == '03'||strMonth == '05'||strMonth == '07'||strMonth == '08'||strMonth == '10'||strMonth == '12'){
            intNoOfDays = 31;
        }
        if(strMonth == '02'){
            if(date.isLeapYear(dtModifiedDate.year())){
                intNoOfDays = 29;
            }
            else{
                intNoOfDays = 28;
            }                                         
        }
        if(strMonth == '04'||strMonth == '06'||strMonth == '09'||strMonth == '11'){
            intNoOfDays = 30;
        }
    /*    if(strOn == 'FIRST'){
            intNoOfTimes = 1;
        }
        if(strOn == 'SECOND'){
            intNoOfTimes = 2;
        }
        if(strOn == 'THIRD'){
            intNoOfTimes = 3;
        }
        if(strOn == 'FOURTH'){
            intNoOfTimes = 4;
        }
        if(strOn == 'LAST'){
            intNoOfTimes = 5;
        }   */
        for(integer i=1;i<=intNoOfDays;i++){
            if(blnStart){
                dtDateToReturn.clear();
                if(i<=9){
                    dtDateToReturn.add(Datetime.valueOfGmt(dtModifiedDate.format('yyyy') + '-'+strMonth+'-'+'0'+i.format()+' '+'00'+':'+'00'+':'+'00'));
                }
                else{
                    dtDateToReturn.add(Datetime.valueOfGmt(dtModifiedDate.format('yyyy') + '-'+strMonth+'-'+i.format()+' '+'00'+':'+'00'+':'+'00'));
                }
                
                lstDay = getSubmissionDay(dtDateToReturn);
                if(lstDay[0]==strDay){
                    lstDate.add(dtDateToReturn[0]);  
                }
            }
            else{
                 dtDateToReturn.clear();
                if(i<=9){
                    dtDateToReturn.add(Datetime.valueOfGmt(dtModifiedDate.format('yyyy')+ '-'+strMonth+'-'+'0'+i.format()+' '+'23'+':'+'59'+':'+'59'));
                }
                else{
                    dtDateToReturn.add(Datetime.valueOfGmt(dtModifiedDate.format('yyyy')+ '-'+strMonth+'-'+i.format()+' '+'23'+':'+'59'+':'+'59'));
                }
                lstDay = getSubmissionDay(dtDateToReturn);
                if(lstDay[0]==strDay){
                    lstDate.add(dtDateToReturn[0]);
                }
            }       
        }
        if(lstDate != null && lstDate.size()>0){
            if(strOn == 'FIRST'){
                dtreturn = lstDate[0];
            }  
            if(strOn == 'SECOND'){
                dtreturn = lstDate[1];
            }   
            if(strOn == 'THIRD'){
                dtreturn = lstDate[2];
            }  
            if(strOn == 'FOURTH'){
                dtreturn = lstDate[3];
            } 
            if(strOn == 'LAST'){
                if(lstDate.size() == 4){
                    dtreturn = lstDate[3];
                }
                if(lstDate.size() == 5){
                    dtreturn = lstDate[4];
                }   
            } 
         }   

        system.debug('dtDateToReturngetDaylightSavingDate----------->'+dtreturn);
        return dtreturn;   
   }
  /*  public void insertSLAExpirationRecord(List<Lead> lstAfterUpdateLead){
        List<Deal_Reg_SLA_Expiration__c> lstExpirationDeals = new List<Deal_Reg_SLA_Expiration__c>();
        for(Lead leadobj :lstAfterUpdateLead){
            if(leadobj.DealReg_PSC_SLA_Expire_On__c!=null ||leadobj.DealReg_Field_SLA_Expire_on__c != null){
                Deal_Reg_SLA_Expiration__c SLADeal = new Deal_Reg_SLA_Expiration__c();
                SLADeal.Deal_Registration_Record__c = leadobj.Id;
                if(leadobj.DealReg_PSC_SLA_Expire_On__c!=null){
                    SLADeal.SLA_PSC_Expiration_Date_Time__c = leadobj.DealReg_PSC_SLA_Expire_On__c;             
                }
                if(leadobj.DealReg_Field_SLA_Expire_on__c!=null){
                    SLADeal.SLA_Field_Expiration_Date_Time__c = leadobj.DealReg_Field_SLA_Expire_on__c;                 
                }
                lstExpirationDeals.add(SLADeal);
            }
        }
        if(lstExpirationDeals.size()>0){
            insert lstExpirationDeals;
        } 
    }
    public void updateSLARelatedDealRegistration(Map<Id,Deal_Reg_SLA_Expiration__c> mapAfterUpdate){
        set<string> setDealRegIds = new set<string>();
        List<Lead> lstLeadToUpdate = new list<lead>();
        map<string,Deal_Reg_SLA_Expiration__c> mapLeadIdAndExpirationObjectRecord = new map<string,Deal_Reg_SLA_Expiration__c>();
        for(Deal_Reg_SLA_Expiration__c slaObj :mapAfterUpdate.values()){
            setDealRegIds.add(slaObj.Deal_Registration_Record__c);
            mapLeadIdAndExpirationObjectRecord.put(slaObj.Deal_Registration_Record__c,slaObj);
        }
        lstLeadToUpdate = [Select Id,DealReg_PSC_SLA_Expire_On__c,DealReg_Field_SLA_Expire_on__c from Lead where id in :setDealRegIds];
        for(Lead leadobj :lstLeadToUpdate){
            if(mapLeadIdAndExpirationObjectRecord.get(leadobj.Id).Field_SLA_Expired__c == true){
                leadobj.DealReg_Field_SLA_Expired__c = True;
            }
            if(mapLeadIdAndExpirationObjectRecord.get(leadobj.Id).PSC_SLA_Expired__c == true){
                leadobj.DealReg_PSC_SLA_Expired__c = True;
            }
        }
        
        update lstLeadToUpdate;
    }  */     
    
/*****************Added to calculate Expiration date for Field Reps for Extension Request***************/

/*@Method <This method initiate the process of SLA calculation and 
            all the other methods will be called from this one>
@param <This method take two maps,map of new extension record and map of old lead record>
 Leads From Trigger -- <which contains the new and old lead record>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    public void slaCalculationForExtensionRequest(map<Id,Extension_Request__c> mapNewExtension,map<Id,Extension_Request__c> mapOldExtension){    
        mapExtensionRequestToProcess = getExtensionRecordToProcess(mapNewExtension,mapOldExtension);        
        if(mapExtensionRequestToProcess.size()>0){
            map<Id,string> mapTimeZone = new map<Id,String>();   
            map<Id,DateTime> mapTimeInLocalZone = new map<Id,DateTime>();        
            map<Id,Decimal> mapExpirationHours = new map<Id,Decimal>();        
            map<Id,string> mapSubmissionDay = new map<Id,string>();      
            map<string,set<string>> mapTheaterWiseWorkingDays = new map<string,set<string>>();       
            map<Id,DateTime> mapExpirationDateTime = new map<Id,Datetime>();        
            map<Id,DateTime> mapExpirationDateTimeInGMT = new map<Id,DateTime>();
            
            for(Extension_Request__c extenisonRecord: mapExtensionRequestToProcess.values()){
                mapTheater.put(extenisonRecord.Id,extenisonRecord.DealReg_Theater__c);
                mapApprovalStatus.put(extenisonRecord.Id,extenisonRecord.Approval_Status__c);
                mapCountry.put(extenisonRecord.Id,extenisonRecord.DealReg_Country__c);               
               // mapModifiedDateTime.put(extenisonRecord.Id,extenisonRecord.LastModifiedDate);
                mapModifiedDateTime.put(extenisonRecord.Id,system.now());
            }
            system.debug('mapModifiedDateTime--------->' +mapModifiedDateTime);
            if(mapTheater.size()>0 && mapApprovalStatus.size()>0 && mapCountry.size()>0){
                mapTimeZone = getTimeZone(mapCountry);
                system.debug('mapTimeZone--------->' +mapTimeZone);
                mapExpirationHours = getExtensionExpirationHours();
                system.debug('mapExpirationHours--------->' +mapExpirationHours);
                mapTheaterWiseWorkingDays = getWorkingDays();
                system.debug('mapTheaterWiseWorkingDays--------->' +mapTheaterWiseWorkingDays);
            }
            if(mapModifiedDateTime.size()>0 && mapTimeZone.size()>0){
                mapTimeInLocalZone = convertSubmissionTimeIntoLocalZone(mapModifiedDateTime,mapTimeZone);   
                system.debug('mapTimeInLocalZone--------->' +mapTimeInLocalZone);
            }
            if(mapTheaterWiseWorkingDays.size()>0 && mapTimeInLocalZone.size()>0 && mapExpirationHours.size()>0){
                mapExpirationDateTime = getSLAExpirationTime(mapTimeInLocalZone,mapExpirationHours,mapTheaterWiseWorkingDays);
                system.debug('mapExpirationDateTime--------->' +mapExpirationDateTime);
            }
            if(mapExpirationDateTime.size()>0){
                mapExpirationDateTimeInGMT = getExpirationDateInGMT(mapExpirationDateTime,mapTimeZone);
                system.debug('mapExpirationDateTimeInGMT--------->' +mapExpirationDateTimeInGMT);
            }
            if(mapExpirationDateTimeInGMT.size()>0){
                updateExpirationDateTimeOnExtension(mapExtensionRequestToProcess,mapExpirationDateTimeInGMT);
            }
        }
    }
 
/*@Method <This method is used to filtered the record for which SLA has to be calculated>
@param <This method take two maps,map of new Extension_Request__c record and map of old Extension_Request__c record>
@return <map<Id,Lead>> - <This method returns the map of lead which will be processed for SLA calculation>
@throws exception - <No Exception>
*/

    public map<Id,Extension_Request__c> getExtensionRecordToProcess(map<Id,Extension_Request__c> mapNewExtension,map<Id,Extension_Request__c> mapOldExtension){
        map<Id,Extension_Request__c> mapExtensionToReturn = new map<Id,Extension_Request__c>();
        for (Extension_Request__c extensionRecord :mapNewExtension.values()){
            if(extensionRecord.Approval_Status__c !=null && extensionRecord.DealReg_Theater__c!=null){
                if(extensionRecord.Approval_Status__c != mapOldExtension.get(extensionRecord.Id).Approval_Status__c){
                    string strTheaterAndApprovalStatus = extensionRecord.DealReg_Theater__c + extensionRecord.Approval_Status__c;
                    mapTheaterStatusAndAppoversSLA = getWorkHoursAndApproversSLAInformation();
                    if(mapTheaterStatusAndAppoversSLA.size()>0){
                        if(mapTheaterStatusAndAppoversSLA.containsKey(strTheaterAndApprovalStatus)){
                            mapExtensionToReturn.put(extensionRecord.Id,extensionRecord);
                        }
                    }
                    
                }  
            }    
        } 
        return mapExtensionToReturn;
    }       
    
    public map<Id,Decimal> getExtensionExpirationHours(){
        map<Id,Decimal> mapExpirationHours = new map<Id,Decimal>();
        if(mapTheaterStatusAndAppoversSLA.size()>0){
            for(id leadId :mapTheater.keyset()){        
                    if(mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+ mapApprovalStatus.get(leadId)).Business_Hours_For_All_Accounts__c != null){
                        mapExpirationHours.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+ mapApprovalStatus.get(leadId)).Business_Hours_For_All_Accounts__c);
                    }
                    else{
                         if(mapExtensionRequestToProcess.get(leadId).DealReg_Enterprise_Non_Enterprise__c=='ENTERPRISE'){
                            mapExpirationHours.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+ mapApprovalStatus.get(leadId)).Business_Hours_For_Enterprise_Account__c);
                         }
                         else{
                            mapExpirationHours.put(leadId,mapTheaterStatusAndAppoversSLA.get(mapTheater.get(leadId)+ mapApprovalStatus.get(leadId)).Business_Hours_For_NonEnterprise_Account__c);
                         }
                    }            
            }
        }
        return mapExpirationHours;  
    }        
    
     public void updateExpirationDateTimeOnExtension(map<Id,Extension_Request__c> mapExtensionRecord,map<Id,datetime> mapExpirationDateTimeInGMT){
        map<Id,Extension_Request__c> mapExtensionToBeUpdate = new map<Id,Extension_Request__c>();
        list<Extension_Request__c> lstExtensionToUpdate = new list<Extension_Request__c>();
        map<Id,string> mapFieldToStampOnLead = getFieldToStampOnLead();
        for(Id extensionId :mapExtensionRecord.keyset()){
            string fieldToUpdate = mapFieldToStampOnLead.get(extensionId);
            mapExtensionRecord.get(extensionId).put(mapFieldToStampOnLead.get(extensionId),mapExpirationDateTimeInGMT.get(extensionId));
        }
    }                             
}