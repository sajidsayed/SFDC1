/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  06/09/2011    Shalabh Sharma       This class is used to calculate 72 business hours for auto closure of a case.
 |  02/01/2012    Shalabh Sharma       Added where clause in the query on line 60  
 |  22/04/2013    Ganesh Soma   255904 Handling 96hours for Eduction Services Record Type Case auto closure. 
 |                                     Modified the logic to exclude weekends                                   
 +==================================================================================================================**/
public class Presales_Calculate_Closure_Time{
    
	//Ignore this comment
    //public static Boolean isRun = false;
/* @Method <This method execute is used to calculate 72 Business hours for auto closure.>
@param <This method takes Map<Id,Case> as parameter>
@return void - <Not returning anything>
@throws exception - <No Exception>
*/    
    public void calculateClosureTime(Map<Id,Case> newMapCase, Map<id,Case> oldMapCase){

    Boolean flag = false;
    DateTime timeStamp;
    Map<Id,Datetime> caseDateMap = new Map<Id,Datetime>();
    Map<Id,Holiday> holDateMap = new Map<Id,Holiday>();
    List<Holiday> lstHoliday = new List<Holiday>();
    Map<DateTime,Holiday> mapDateHoliday = new Map<DateTime,Holiday>();
    integer counter=0;
    String currentDay;
        //if(!isRun){
            /*Checking if the case status is changed to "Resolved" and taking that Last Modified Date to calculate 72 business hours*/
            for(Case caseRecord: newMapCase.values()){
                system.debug('case record--->'+caseRecord.Status);
                
                if(caseRecord.Status == 'Resolved' && caseRecord.Status != oldMapCase.get(caseRecord.id).Status){
                    //timeStamp = caseRecord.LastModifiedDate;
                    caseDateMap.put(caseRecord.Id,caseRecord.LastModifiedDate);
                    system.debug('time stamp--->'+caseDateMap);   
                }
                /*Resetting time stamp if status changed from resolved to some other value*/
                else if(oldMapCase.get(caseRecord.id).Status== 'Resolved'&& caseRecord.Status != oldMapCase.get(caseRecord.id).Status){
                    timeStamp = null;
                    system.debug('time stamp on else--->'+timeStamp);
                    caseRecord.SLA_Completed__c = null;
                }       
            }        
            /*if(timeStamp!= null){
            timeStamp = timeStamp.addHours(24);
            flag = checkHoliday(timeStamp);
            if(flag == true){
                flag = checkHoliday(timeStamp);
            }
            else{
                timeStamp = timeStamp.addHours(24);
                flag = checkHoliday(timeStamp);
            }
        } */
        /*Quering database for all holidays*/
        if(caseDateMap.size()>0 && caseDateMap!=null){
        lstHoliday = [select id,ActivityDate from Holiday where ActivityDate >= :system.today()];
        system.debug('lst of holiday--->'+lstHoliday);
        
        for(Holiday holidayRecord: lstHoliday){
            mapDateHoliday.put(holidayRecord.ActivityDate,holidayRecord);   
        }
        system.debug('mapDateHoliday--->'+mapDateHoliday);
        }    
            for(Case caseRecord: newMapCase.values()){
                system.debug('case record value--->'+caseRecord.Id);
                system.debug('case record value--->'+caseDateMap.get(caseRecord.Id));
                timeStamp=  caseDateMap.get(caseRecord.Id);
                system.debug('time stamp---->'+timeStamp);
                
             
                //WR#255904/Ganesh - Handling 96hours for Eduction Services Record Type
                Integer NoOfDays = 0;                
               
                System.debug('SFDDEV****caseRecord.Record_Type_Name__c****'+caseRecord.Record_Type_Name__c);                
                if(caseRecord.Record_Type_Name__c == 'Education Services Record Type')
                {
                    NoOfDays = 4;
                }
                else{
                    NoOfDays = 3;  
                }    
                   
                
                if(!(caseDateMap.isEmpty())){        
                    system.debug('case record--->'+newMapCase.values());                    
                    for(;counter<NoOfDays;){                 
                        currentDay = timeStamp.format('EEEE');
                        system.debug('currentDay--->'+currentDay);
                        /*Checking if next day is a holiday*/                        
                        timeStamp= timeStamp.addHours(24);
                        system.debug('timeStamp--->'+timeStamp);
                        currentDay = timeStamp.format('EEEE');                      
                        system.debug('mapDateHoliday--->'+mapDateHoliday);
                            if(mapDateHoliday.size()>0 && mapDateHoliday.containsKey(timeStamp.date())){                            
                                        flag= true;
                                        system.debug('flag1--->'+flag);                            
                            }
                            else if((currentDay == 'Sunday' || currentDay == 'Saturday')){
                                        flag = true;
                                        system.debug('flag2--->'+flag);
                            }
                            else{
                                flag= false;
                            }                   
		                      system.debug('counter --->'+counter);
		                      system.debug('flag--->'+flag);
		                    
		                    // if flag is false then counter is incremented beacause the currentday is not holiday
		                    // if flag is true then counter is not incrmented becuase the currentday is a hoilday 
                            if(flag == false){
                                counter++;
                            }
                    }
                }             
                        system.debug('sla date--->'+timeStamp);
                     if(timeStamp!=null){
                         caseRecord.SLA_Completed__c = timeStamp;
                     }
                     system.debug('sla date--->'+caseRecord.SLA_Completed__c);
            }
   
    }
}