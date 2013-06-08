// Created the Test Class for the Renewal Timing Operation Class  - WR#207264, WR #230704
// WR - 230704 -  Updated the test calss for new conditiohs
@isTest(SeeAllData=true) 
//shipraa
private class RenewalsTimingsOperationTest {

//Updated the test class -  Logic to validate the Renewal Timing operation class -  Rajeev

static testMethod void RTtest() 
{

    Account acc = testclassUtils.getAccount() ;  
     insert acc ;
    Opportunity Opp= testclassUtils.getOppty ();
     insert Opp;

//Quarter Calculation
 Date myDate1 = date.newinstance(2010, 2, 17);
  Integer i = RenewalsTimingsOperation.getQuarter(myDate1);
 Date myDate2 = date.newinstance(2010, 5, 17);
  Integer i1 = RenewalsTimingsOperation.getQuarter(myDate2);
 Date myDate3 = date.newinstance(2010, 8, 17);
  Integer i2 = RenewalsTimingsOperation.getQuarter(myDate3);
 Date myDate4 = date.newinstance(2010, 12, 17);
  Integer i3 = RenewalsTimingsOperation.getQuarter(myDate4);

 RenewalsTimingsOperation newInstance = new RenewalsTimingsOperation();
             newInstance.calculateRenewals(opp);
             
//Logic Calculation

//Extreme Expired
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 2, 17);
 opp.CloseDate = date.newinstance(2012, 11, 17);

   RenewalsTimingsOperation newInstance1 = new RenewalsTimingsOperation();
             newInstance1.calculateRenewals(opp); // Same Year - Diffrence of # quarters

 opp.HW_TLA_Start_Date__c = date.newinstance(2011, 9, 17);
 opp.CloseDate = date.newinstance(2012, 5, 17); 

  RenewalsTimingsOperation newInstance2 = new RenewalsTimingsOperation();
             newInstance2.calculateRenewals(opp);// Diffrence = -1
 
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 12, 17);
 opp.CloseDate = date.newinstance(2013, 12, 17);

  RenewalsTimingsOperation newInstance14 = new RenewalsTimingsOperation();
             newInstance2.calculateRenewals(opp);// Difference = 0
    
 opp.HW_TLA_Start_Date__c = date.newinstance(2011, 12, 17);
 opp.CloseDate = date.newinstance(2013, 7, 17);

  RenewalsTimingsOperation newInstance15 = new RenewalsTimingsOperation();
             newInstance15.calculateRenewals(opp); //Difference = 3       
             
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 5, 17);
 opp.CloseDate = date.newinstance(2013, 12, 17);

  RenewalsTimingsOperation newInstance16 = new RenewalsTimingsOperation();
             newInstance16.calculateRenewals(opp); //Difference = 2
 
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 5, 17);
 opp.CloseDate = date.newinstance(2013, 7, 17);

  RenewalsTimingsOperation newInstance17 = new RenewalsTimingsOperation();
             newInstance17.calculateRenewals(opp); //Difference = 1
             
opp.HW_TLA_Start_Date__c = date.newinstance(2011, 12, 17);
 opp.CloseDate = date.newinstance(2013, 7, 17);

  RenewalsTimingsOperation newInstance18 = new RenewalsTimingsOperation();
             newInstance18.calculateRenewals(opp); //Difference =  2years
             
//Expired
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 5, 18);
 opp.CloseDate = date.newinstance(2012, 8, 18);

  RenewalsTimingsOperation newInstance3 = new RenewalsTimingsOperation();
             newInstance3.calculateRenewals(opp); //Difference  = Same Year = 1 Qtr

 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 5, 19);
 opp.CloseDate = date.newinstance(2012, 11, 20);

RenewalsTimingsOperation newInstance4 = new RenewalsTimingsOperation();
             newInstance4.calculateRenewals(opp); //Difference = Same Year =  2 Qtrs 
             
opp.HW_TLA_Start_Date__c = date.newinstance(2012, 12, 19);
 opp.CloseDate = date.newinstance(2013, 1, 20);

RenewalsTimingsOperation newInstance19 = new RenewalsTimingsOperation();
             newInstance19.calculateRenewals(opp); //Difference = 1 Year = 1Qtr
             
opp.HW_TLA_Start_Date__c = date.newinstance(2012, 12, 19);
 opp.CloseDate = date.newinstance(2013, 5, 20);

RenewalsTimingsOperation newInstance20 = new RenewalsTimingsOperation();
             newInstance20.calculateRenewals(opp);  //Difference  = 1 year =  2 qtrs         
             
//Current
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 6, 17);
 opp.CloseDate = date.newinstance(2012, 6, 18);

  RenewalsTimingsOperation newInstance5 = new RenewalsTimingsOperation();
             newInstance5.calculateRenewals(opp);
             
opp.HW_TLA_Start_Date__c = date.newinstance(2012, 6, 17);
 opp.CloseDate = date.newinstance(2012, 5, 17);

RenewalsTimingsOperation newInstance13 = new RenewalsTimingsOperation();
             newInstance13.calculateRenewals(opp);

opp.HW_TLA_Start_Date__c = date.newinstance(2013, 1, 1);
 opp.CloseDate = date.newinstance(2012, 12, 31);

RenewalsTimingsOperation newInstance21 = new RenewalsTimingsOperation();
             newInstance21.calculateRenewals(opp); // Same Date          
//Future 
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 8, 18);
 opp.CloseDate = date.newinstance(2012, 5, 18);

  RenewalsTimingsOperation newInstance6 = new RenewalsTimingsOperation();
             newInstance6.calculateRenewals(opp); ////Difference  = Same Year = 1 Qtr
             
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 12, 20);
 opp.CloseDate = date.newinstance(2012, 5, 19);

  RenewalsTimingsOperation newInstance7 = new RenewalsTimingsOperation();
             newInstance7.calculateRenewals(opp);//Difference = Same Year =  2 Qtrs 
             
 opp.HW_TLA_Start_Date__c = date.newinstance(2013, 1, 19);
 opp.CloseDate = date.newinstance(2012, 11, 20);

  RenewalsTimingsOperation newInstance22 = new RenewalsTimingsOperation();
             newInstance22.calculateRenewals(opp);//Difference = 1 Year = 1 qtr     

 opp.HW_TLA_Start_Date__c = date.newinstance(2013, 5, 20);
 opp.CloseDate = date.newinstance(2012, 12, 19);

  RenewalsTimingsOperation newInstance23 = new RenewalsTimingsOperation();
             newInstance23.calculateRenewals(opp);//Difference  = 1 year =  2 qtrs  
             
//Extreme Future
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 11, 17);
 opp.CloseDate = date.newinstance(2012, 1, 17);

RenewalsTimingsOperation newInstance8 = new RenewalsTimingsOperation();
             newInstance8.calculateRenewals(opp);// Same Year - Diffrence of 3 quarters
             
 opp.HW_TLA_Start_Date__c = date.newinstance(2012, 5, 17);
 opp.CloseDate = date.newinstance(2011, 9, 17);

 RenewalsTimingsOperation newInstance9 = new RenewalsTimingsOperation();
             newInstance9.calculateRenewals(opp);// Diffrence = -1
             
opp.HW_TLA_Start_Date__c = date.newinstance(2012, 5, 17);
 opp.CloseDate = date.newinstance(2011, 5, 17);

RenewalsTimingsOperation newInstance10 = new RenewalsTimingsOperation();
             newInstance10.calculateRenewals(opp);// Difference = 0
  
  opp.HW_TLA_Start_Date__c = date.newinstance(2012, 7, 17);
 opp.CloseDate = date.newinstance(2011, 12, 17);

RenewalsTimingsOperation newInstance11 = new RenewalsTimingsOperation();
             newInstance11.calculateRenewals(opp); //Difference = 3   

opp.HW_TLA_Start_Date__c = date.newinstance(2013, 12, 17);
 opp.CloseDate = date.newinstance(2012, 5, 17);

RenewalsTimingsOperation newInstance12 = new RenewalsTimingsOperation();
             newInstance12.calculateRenewals(opp); //Difference = 2
             
opp.HW_TLA_Start_Date__c = date.newinstance(2013, 7, 17);
 opp.CloseDate = date.newinstance(2012, 5, 17);

RenewalsTimingsOperation newInstance24 = new RenewalsTimingsOperation();
             newInstance24.calculateRenewals(opp);  //Difference = 1
             
opp.HW_TLA_Start_Date__c = date.newinstance(2013, 7, 17);
 opp.CloseDate = date.newinstance(2011, 5, 17);

RenewalsTimingsOperation newInstance25 = new RenewalsTimingsOperation();
             newInstance25.calculateRenewals(opp);  //Difference = 2years
 
//WR# 230704 
 opp.Renewals_Area__c = 'APJ';
  String Cname = opp.Country__c;
 
 RenewalsTimingsOperation newInstance26 = new RenewalsTimingsOperation();
     newInstance26.populateTheaterFromCountryOnOppty(opp);
   
   }
   
}