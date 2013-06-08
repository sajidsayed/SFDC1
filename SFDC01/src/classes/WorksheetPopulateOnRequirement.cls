Public class WorksheetPopulateOnRequirement{

    List<Application_Requirement__c> reqList = new List<Application_Requirement__c>();
    List<String> reqs = new List<String>();

    public void PopulateDetails(){   
        Worksheet__c objWS;
        for(Integer i=0;Trigger.new.size()>i;i++){
            objWS = (Worksheet__c)Trigger.new[i];
            reqs.add(objWS.Requirement__c);
        }

        //List<Application_Requirement__c> reqList = new List<Application_Requirement__c>();
       // query to get the requirements of inserted / updated worksheets
        reqList = [Select id, Actual_Design__c, Actual_Build_Unit_Test1__c,Actual_SIT__c,Others__c from Application_Requirement__c where Id in : reqs]; 

        for(Integer i=0;Trigger.new.size()>i;i++){
            objWS = (Worksheet__c)Trigger.new[i];
            for(Application_Requirement__c objReq : reqList ){
            if((objReq.Id == objWS.Requirement__c)){           
                   Double workSheetHrsPlanned = 0.0;  
                   Double workSheetHrsUnPlanned = 0.0;

        if (objWS.Actual_Hours_Planned1__c != null ) workSheetHrsPlanned =objWS.Actual_Hours_Planned1__c;
        if (objWS.Actual_Hours_Unplanned1__c != null ) workSheetHrsUnPlanned =objWS.Actual_Hours_Unplanned1__c;

    if(objWS.Work_Category__c=='Design'){  
        if(objReq.Actual_Design__c == null) objReq.Actual_Design__c=0.00;
         System.debug('enter IF Design:' +objReq.Actual_Design__c);//0
         System.debug('Actual Design WS' +workSheetHrsPlanned);
         System.debug('Actual Design Req' +objReq.Actual_Design__c);
         objReq.Actual_Design__c=objReq.Actual_Design__c + workSheetHrsPlanned;
         System.debug('Actual Design' +objReq.Actual_Design__c);
     }

    if(objWS.Work_Category__c=='Build & Unit Test'){
      if(objReq.Actual_Build_Unit_Test1__c == null) objReq.Actual_Build_Unit_Test1__c=0.00;
          System.debug('enter IF build:' +objReq.Actual_Build_Unit_Test1__c);//0
          System.debug('Actual build WS' +workSheetHrsPlanned);
          System.debug('Actual build Req' +objReq.Actual_Build_Unit_Test1__c);
         objReq.Actual_Build_Unit_Test1__c=objReq.Actual_Build_Unit_Test1__c + workSheetHrsPlanned;
          System.debug('Actual build' +objReq.Actual_Build_Unit_Test1__c);
    }
    if(objWS.Work_Category__c=='SIT'){
      if(objReq.Actual_SIT__c == null) objReq.Actual_SIT__c=0.00;
      System.debug('enter IF SIT:' +objReq.Actual_SIT__c);//0
      System.debug('Actual SIT WS' +workSheetHrsPlanned);
      System.debug('Actual SIT Req' +objReq.Actual_SIT__c);
      objReq.Actual_SIT__c=objReq.Actual_SIT__c + workSheetHrsPlanned;
      System.debug('Actual SIT' +objReq.Actual_SIT__c);
    }

   if((objWS.Work_Category__c=='Design'||objWS.Work_Category__c=='Build & Unit Test'||objWS.Work_Category__c=='SIT')&& objWS.Actual_Hours_Unplanned1__c!=0){
    if(objReq.Others__c == null) objReq.Others__c=0.00;
    System.debug('enter IF others:' +objReq.Others__c);
    System.debug('enter IF others:' +workSheetHrsUnPlanned);
    objReq.Others__c=objReq.Others__c + workSheetHrsUnPlanned;
    System.debug('Actual Others' +objReq.Others__c);
  }
}
              System.debug('Actual Design Last: ' +objReq.Actual_Design__c);
              System.debug('Actual build Last: ' +objReq.Actual_Build_Unit_Test1__c);
              System.debug('Actual SIT Last: ' +objReq.Actual_SIT__c);
              System.debug('Actual Others Last: ' +objReq.Others__c);
  }
 }
          
// update the requirements of inserted/updated Worksheets
  update reqList;
  }
}