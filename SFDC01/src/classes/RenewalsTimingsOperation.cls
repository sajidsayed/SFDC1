/**

Created By : Rajeev Satapathy
Created Date : 11 Spet 2012
Purpose : To calculate the RenewalsTimings field value on opportunity based on the Close Date and Primary Contract Start Date.
WR :  207264     
WR: 230704 -  Created and Udpated the renewals Logic and Country Theatre Mapping for the field Renewals Area
**/

public class RenewalsTimingsOperation {

        public  void calculateRenewals(Opportunity opty){

    /*opty.HW_TLA_Start_Date__c refers to the Primary Contract Start Date (PCSD)
    opty.CloseDate refers to the Opportunity Close Date
    getQuarter is a function that takes in the Date values and returns the Quarter to which the Date belongs*/
    
    /* WR #258057- 6/6/13- Mudassir Ali. 
     * Updating code to implement today's date instead of CloseDate                           
     */
            Date todayDate = System.today();
            
    // If Both Close Date and Primary Contract Start Date (PCSD) are populated on Opportunity record        
            if(opty.HW_TLA_Start_Date__c !=  Null && todayDate != Null)
            {
                
    // Determining the Quarters for both PCSD and Close Date
                Integer primnaryContractQrtr= getQuarter(opty.HW_TLA_Start_Date__c - 1);
                Integer todayDateQrtr = getQuarter(todayDate);
                
    //Determining the year to which both PCSD and Close Date belong 
                Integer Pyear =  (opty.HW_TLA_Start_Date__c - 1).year();
                Integer Cyear =  todayDate.year();
                
    // If there is a difference between PCSD and Close Date and both PCSD and Close Date belong to the SAME YEAR
                if(((opty.HW_TLA_Start_Date__c - 1).daysBetween(todayDate))> 0)
                {
                    if(Cyear == Pyear)
                    {
                        //Mudassir: Not given case for >2
                        /*if((todayDateQrtr - primnaryContractQrtr > 2))
                        {
                            opty.Renewals_Timing__c = 'Extreme Expired';
                        }*/
                        
                        //If PCSD is  one Quarter behind of the Current Quarter, then Renewals Timing = Expired
                        if((todayDateQrtr - primnaryContractQrtr == 1))
                        {
                            opty.Renewals_Timing__c = 'Expired';
                        }

    //If PCSD is 2 Quarters Behind Close Date
   //If PCSD is  2 Quarters behind of the Current Quarter, then Renewals Timing = Extreme Expired
                        else if((todayDateQrtr - primnaryContractQrtr == 2 ))//Mudassir: Should this be >==
                        {
                            opty.Renewals_Timing__c = 'Extreme Expired';
                        }

    //If PCSD is in the same Quarter as the Current Quarter, then Renewals Timing = Current
                        else if(todayDateQrtr - primnaryContractQrtr == 0)
                        {
                            opty.Renewals_Timing__c = 'Current';
                        }
                    }

    //If PCSD is one year before than Close Date
                  if(Cyear - Pyear == 1)
                  {         
                      //If PCSD is  one Quarter behind of the Current Quarter, then renewals timing =Expired
                      if((todayDateQrtr - primnaryContractQrtr == -3))
                      {
                          opty.Renewals_Timing__c = 'Expired';
                      }

    //Updated the code as part of the ERFC - 12/12/12 - Work Request - #222754 ,230704
                      else if(
                              (todayDateQrtr - primnaryContractQrtr == 1)||
                              (todayDateQrtr - primnaryContractQrtr == 2)||
                              (todayDateQrtr - primnaryContractQrtr == 3)||
                              (todayDateQrtr - primnaryContractQrtr == -1)||
                              (todayDateQrtr - primnaryContractQrtr == 0)||
                              (todayDateQrtr - primnaryContractQrtr == -2))// moved this because considered extreme expired and not expired
                      {
                          opty.Renewals_Timing__c = 'Extreme Expired';
                      }
                  }
                  
                  if(Cyear - Pyear >= 2)
                  {
                      opty.Renewals_Timing__c = 'Extreme Expired';
                  }
                  
                }
                
    //
                if(((todayDate).daysBetween(opty.HW_TLA_Start_Date__c - 1))> 0)
                {
                    if(Cyear == Pyear)
                    {
                        //If PCSD is  2 Quarters ahead of the Current Quarter, then renewals timing =Extreme Future
                        if((primnaryContractQrtr - todayDateQrtr == 2))
                        {
                            opty.Renewals_Timing__c = 'Extreme Future';
                        }
                        else if((primnaryContractQrtr - todayDateQrtr == 1))
                        {
                            opty.Renewals_Timing__c = 'Future';
                        }
                        //Mudassir: Were not given the case of greater than 2
                        /*else if((primnaryContractQrtr - todayDateQrtr > 2))
                        {
                            opty.Renewals_Timing__c = 'Extreme Future';
                        }*/
                        else if(primnaryContractQrtr - todayDateQrtr == 0)
                        {
                            opty.Renewals_Timing__c = 'Current';
                        }
                    }

                    if(Pyear - Cyear == 1)
                    {
                        //Mudassir: If PCSD is  one Quarter ahead of the Current Quarter, then Renewals Timing = Future
                        if((primnaryContractQrtr - todayDateQrtr == -3))
                        {
                          opty.Renewals_Timing__c = 'Future';
                        }
    //Updated the code as part of the ERFC - 12/12/12 - Work Request - #222754,#230704
                        else if(
                                (primnaryContractQrtr - todayDateQrtr == 1)||
                                (primnaryContractQrtr - todayDateQrtr == 2)||
                                (primnaryContractQrtr- todayDateQrtr == 3)||
                                (primnaryContractQrtr - todayDateQrtr == -1)||
                                (primnaryContractQrtr - todayDateQrtr == 0)||
                                (primnaryContractQrtr - todayDateQrtr == -2)//Mudassir://If PCSD is  2 Quarters ahead of the Current Quarter, then Renewals Timing = Extreme Future
                                )
                        {
                            opty.Renewals_Timing__c = 'Extreme Future';
                        }
                    }
                  
                    if(Pyear - Cyear >=2)
                    {
                        opty.Renewals_Timing__c = 'Extreme Future';         
                    }
               }
      //Updated the code as part of the ERFC - 12/12/12 - Work Request - #222754
               if(todayDate == opty.HW_TLA_Start_Date__c - 1)
               {
                   opty.Renewals_Timing__c = 'Current';
               }
          }  
       }
       
        public static Integer  getQuarter(Date quarterDate)
        {         
            Integer monthValue = quarterDate.month();
            if(monthValue == 1 ||monthValue == 2 || monthValue == 3)
            {
                return 1;
            }
            if(monthValue == 4 ||monthValue == 5 || monthValue == 6)
            {
               return 2;
            }
            if(monthValue == 7 ||monthValue == 8 || monthValue == 9)
            {
                return 3;
            }        
            else
            {
                return 4;
            }
        }
      
      // Method for Renewals Area Calculation  - WR # 230704
        public void populateTheaterFromCountryOnOppty(Opportunity oppObj)
        {
            Map<String,RenewalsAreaMapping__c> DataValueMap = RenewalsAreaMapping__c.getAll();
            String strCountryname = '';
            System.debug('acc.Country__c-->' + oppObj.Country__c);
            
            if(OppObj.Country__c != null)
            {
                strCountryname = oppObj.Country__c;
                System.debug('strCountryname.length()-->' + strCountryname.length());
                if(strCountryname.length() >= 36)
                {
                    strCountryname = strCountryname.substring(0, 36);
                    System.debug('strCountryname trim-->' + strCountryname);
                }                   
                if(DataValueMap.containsKey(strCountryname))
                {
                    oppObj.Renewals_Area__c= DataValueMap.get(strCountryname).Theater__c; 
                    system.debug('DealReg_Theater__c --'+ oppObj.Renewals_Area__c);
                }                   
            }
        }
     
}