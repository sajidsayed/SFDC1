/*===========================================================================+
 |  Created History                                                                  
                                                                 
 |  DATE       DEVELOPER  WORK REQUEST    DESCRIPTION                               
 |  ====       =========  ============    =========== 
 |  13-Sep-2011  Deshpande, Medhavi         This class is used to populate SLA time in case object 
                                          based on the case priority
 |  
 |  20-Feb-2012  Leonard Victor           Updated the code to as per SFDC team comments 
 +===========================================================================*/



public class Presales_SLA_Class{
private static boolean chkFlag  = false;
private static boolean chkSlaFlag  = false;
public boolean findSlaFlag=false;

// Static method to maintain new value throughout the duration of the request

public static boolean hasAlreadyChanged() {
    return chkFlag  ;
}

// By setting the variable to true, it maintains this new value throughout the duration of the request

public static void setAlreadyChanged() {
    chkFlag   = true;
 }
 
 
public static boolean slaChanged() {
    return chkSlaFlag  ;
}

// By setting the variable to true, it maintains this new value throughout the duration of the request

public static void setslaChanged() {
    chkSlaFlag  = true;
 }

//Method to populate Case Resolution time

public void presalesStdCaseTime(List<Case> lstCase,string chkType){
 
 List<Id> caseIds = new List<Id>();
 List<string> caseRecordType = new List<string>();
 List<string> casePriority = new List<string>();
 List<string> caseGeography = new List<string>();
 List<string> caseCountry = new List<string>();
 List<Presales_SLA__c> sla_master =new List<Presales_SLA__c>();
 List<Case> caseList = new List<Case>();
 Map <Id,string> caseRecordtypeMap =new  Map <Id,string>();
  Map <Id,string> caseRtypeMap =new  Map <Id,string>();

system.debug('lstCase in SLA--->'+lstCase);
//Iterating the list of cases based on the list from trigger

/* for (Case cases:lstCase){
            caseIds.add(cases.Id);
        }*/

// Changed to execute the SOQL outside the for loop 

 caseList= [Select id, Priority,Theatre__c,RecordTypeId,Recordtype.Name,Country__c 
                      FROM Case where id IN :lstCase];  

 for (Case cs:caseList)
{
    
    caseRtypeMap.put(cs.id , cs.Recordtype.Name);
    
}

system.debug('caseRtypeMap--->'+caseRtypeMap);


// Commented the if else logic to remove unwanted codes

//SOQL to take out the record type name for each caseid from previous iteration

/*if(chkType == 'Insert'){
        system.debug('chkType--->'+chkType);
 //caseList= [Select id, Priority,Theatre__c,RecordTypeId,Recordtype.Name,Country__c 
   //                   FROM Case where id IN :caseIds];  
}*/
/*else if(chkType == 'Update'){
    system.debug('chkType--->'+chkType + '<--->'+lstCase);
    //caseList = lstCase;
system.debug('caseList--->'+chkType + '<--->'+caseList);
}*/
//Iterating the list of cases attained from previous SOQL and filling the priority,geograpy,country list
 for (Case cases:lstCase){
     if(chkType == 'Update'){
         //Commented the SOQL inside the FOR loop and executing the same outside 
        // Recordtype r = [select name from recordtype where id =: cases.RecordTypeId];
              caseRecordType.add(caseRtypeMap.get(cases.id));
                caseRecordtypeMap.put(cases.Id,caseRtypeMap.get(cases.id));
                
     }
     else
    {
          caseRecordType.add(caseRtypeMap.get(cases.id));
          caseRecordtypeMap.put(cases.Id,caseRtypeMap.get(cases.id));
    }
        

        casePriority.add(cases.Priority);
        if(cases.Theatre__C!=null){        
        caseGeography.add(cases.Theatre__c);
        }
        if(cases.Country__C!=null){
        caseCountry.add(cases.Country__c);
        }
    }

//SOQL for Presales SLA based on list filled up in previous case iteration 
/* sla_master = [Select id, Name, Case_Record_Type__c, Priority__c, Time_to_resolution__c, Theater__c,Country__c
                from Presales_SLA__c where Case_Record_Type__c IN: caseRecordType 
                and (Theater__c IN: caseGeography or Country__c IN: caseCountry) and Priority__c in:casePriority];*/
                
 System.debug('caseCountry---->'+caseCountry);
 System.debug('caseGeography---->'+caseGeography.size());
 system.debug('casePriority--->'+casePriority);
 system.debug('caseRecordType--->'+caseRecordType);
if(caseCountry.size()>0 ){

 sla_master = [Select id, Name, Case_Record_Type__c, Priority__c, Time_to_resolution__c, Theater__c,Country__c
                from Presales_SLA__c where Case_Record_Type__c IN: caseRecordType 
                and Country__c IN: caseCountry and Priority__c in:casePriority];
                
                System.debug('INSIDE IFFFFFFFFFFFFFFF'  +sla_master.size());
                
 }

if(((caseCountry.size()>0 && caseGeography.size()>0) || (caseCountry.size()==0  && caseGeography.size()>0))&& sla_master.size()==0 ){



 sla_master = [Select id, Name, Case_Record_Type__c, Priority__c, Time_to_resolution__c, Theater__c,Country__c
                from Presales_SLA__c where Case_Record_Type__c IN: caseRecordType 
                and Theater__c IN: caseGeography and Country__c = null  and Priority__c in:casePriority];
                
                 System.debug('INSIDE elseeeeeIFFFFFFFFFFFFFFF');

}


System.debug('sla_master--->'+sla_master.size());

 if(chkType == 'Insert'){
if(sla_master.size()==0){
  for(Case c:caseList){
  c.Case_Resolution_Time__c = 0;
  findSlaFlag=false;
   System.debug('Fourth--->'+ c.Case_Resolution_Time__c);
  }

}
 }

 if(chkType == 'Update'){
if(sla_master.size()==0){
  for(Case c:lstCase){
  c.Case_Resolution_Time__c = 0;
  findSlaFlag=false;
   System.debug('Fourth--->'+ c.Case_Resolution_Time__c);
  }

}
 }

if(chkType == 'Insert'){
  for(Presales_SLA__c sm :sla_master){
if(findSlaFlag == false){
  for(Case c:caseList){
      //If SLA exists for the criteria
System.debug('country--->'+c.country__c +'rec--->'+caseRecordtypeMap.get(c.Id) +'---'+c.Priority);
 System.debug('Theatre--->'+ c.Theatre__c +'<--->'+ 
                 sm.Theater__c +'<--->'+ c.Recordtype.Name +'<--->'+
                 sm.Case_Record_Type__c +'<--->'+
                 c.Priority +'<--->'+ sm.Priority__c+'------Country------'+sm.Country__c);
//Based on SLA Country

    if(sm.Country__c!= null && c.Country__c == sm.Country__c && caseRecordtypeMap.get(c.Id) == sm.Case_Record_Type__c 
         && c.Priority == sm.Priority__c ){
         c.Case_Resolution_Time__c = sm.Time_to_resolution__c;
          findSlaFlag=true;
          System.debug('first-->'+sm.Time_to_resolution__c);
    }

//Based on SLA Theater

                 
    else if(sm.Theater__c != null && c.Theatre__c == sm.Theater__c && caseRecordtypeMap.get(c.Id) == sm.Case_Record_Type__c 
         && c.Priority == sm.Priority__c){
            c.Case_Resolution_Time__c = sm.Time_to_resolution__c;
            findSlaFlag=true;
            System.debug('Second--->'+sm.Time_to_resolution__c);
     }
 
 //Other SLA conditions 
 
     else {
            c.Case_Resolution_Time__c = 0;
            findSlaFlag=false;
            System.debug('Third--->'+sm.Time_to_resolution__c);
           }

     
  }//End of inner for
}//If end 
}//End of outer for
}

if (chkType == 'Update')
{
     for(Presales_SLA__c sm :sla_master){
if(findSlaFlag == false){
  for(Case c:lstCase){
      //If SLA exists for the criteria
System.debug('country--->'+c.country__c +'rec--->'+caseRecordtypeMap.get(c.Id) +'---'+c.Priority);
 System.debug('Theatre--->'+ c.Theatre__c +'<--->'+ 
                 sm.Theater__c +'<--->'+ c.Recordtype.Name +'<--->'+
                 sm.Case_Record_Type__c +'<--->'+
                 c.Priority +'<--->'+ sm.Priority__c+'------Country------'+sm.Country__c);
//Based on SLA Country

    if(sm.Country__c!= null && c.Country__c == sm.Country__c && caseRecordtypeMap.get(c.Id) == sm.Case_Record_Type__c 
         && c.Priority == sm.Priority__c ){
         c.Case_Resolution_Time__c = sm.Time_to_resolution__c;
          findSlaFlag=true;
          System.debug('first-->'+sm.Time_to_resolution__c);
    }

//Based on SLA Theater

                 
    else if(sm.Theater__c != null && c.Theatre__c == sm.Theater__c && caseRecordtypeMap.get(c.Id) == sm.Case_Record_Type__c 
         && c.Priority == sm.Priority__c){
            c.Case_Resolution_Time__c = sm.Time_to_resolution__c;
            findSlaFlag=true;
            System.debug('Second--->'+sm.Time_to_resolution__c);
     }
 
 //Other SLA conditions 
 
     else {
            c.Case_Resolution_Time__c = 0;
            findSlaFlag=false;
            System.debug('Third--->'+sm.Time_to_resolution__c);
           }

     
  }//End of inner for
}//If end 
}//End of outer for
}
  
  
//Try catch block to update the case Object with Resolution time  

 try{
      System.debug('Case--->'+ caseList +'-----'+chkFlag   );
        setAlreadyChanged();
        system.debug('chkType--->'+chkType);
        if(chkType == 'Insert'){
            List<Database.SaveResult> uResults = Database.update(caseList,false);
        }
      // update lstCase;
       System.debug('chkFlag--->'+chkFlag);
    }
    catch(DMLException ex){
        throw ex;
    }


 //update caseList;
}



//Method To chk SLA unique validation
public boolean chkUniqueSLAValidation(List<Presales_SLA__c> slaLst,string triggerType){
List<string> priority = new List<string>();
List<string> Record_Type = new List<string>();
List<string> Geography = new List<string>();
List<string> Country = new List<string>();

List<Presales_SLA__c> sla_master = new List<Presales_SLA__c>();
boolean chkValidFlag = false;

//Iteration for Presales SLA list from trigger and filling up the record,country,geography list

 for (Presales_SLA__c PS:slaLst){
      priority.add(PS.Priority__c);
      Record_Type.add(PS.Case_Record_Type__c);
    
      if(PS.Theater__c != null){
        Geography.add(PS.Theater__c);
      }
      if(PS.Country__c != null){
          Country.add(PS.Country__c);
      }
    }

System.debug('P-->'+ priority +'<--R-->'+ Record_Type + '<-G->'+ Geography+'<-C->'+ Country);

//SOQL for fetching Presales SLA based on the list values filled above

if(Country.size()==0){

  sla_master = [Select id, Name, Case_Record_Type__c, Priority__c, Time_to_resolution__c, Theater__c,Country__c
                from Presales_SLA__c where Case_Record_Type__c  IN : Record_Type 
                and(Theater__c IN: Geography and Country__c  = null)
                and  Priority__c  IN :priority ];
               }
else if(Country.size()>0){


  sla_master = [Select id, Name, Case_Record_Type__c, Priority__c, Time_to_resolution__c, Theater__c,Country__c
                from Presales_SLA__c where Case_Record_Type__c  IN : Record_Type 
                and(Theater__c IN: Geography and Country__c  in :Country)
                and  Priority__c  IN :priority ];
                
}


system.debug('sla_master--->'+sla_master);

//Based on the trigger type boolean value is returned
  
  if(sla_master.size()>0)
   {

     System.debug('triggerType--->'+triggerType);
     if(triggerType == 'Update'){
    /*for (Presales_SLA__c PS:sla_master){
            System.debug('PS--->'+PS);
               for(Presales_SLA__c SM : slaLst){
               System.debug('SM--->'+SM);
                    if(PS.Priority__c != SM.Priority__c ||
                    PS.Case_Record_Type__c != SM.Case_Record_Type__c ||
                        PS.Theater__c != SM.Theater__c){
                        System.debug('--->'+ PS.Priority__c +'----->'+ SM.Priority__c + '----->'+ PS.Case_Record_Type__c+ '----->'+ SM.Case_Record_Type__c + '----->'+ PS.Theater__c  + '----->'+  SM.Theater__c);
                            chkValidFlag = true;
                        }
                }
                               }*/
       chkValidFlag = true;
     }
     else if(triggerType=='Insert'){
         chkValidFlag = true;
     }
  }
System.debug('chkValidFlag --->'+chkValidFlag );

//Returning boolean value based on trigger type

return chkValidFlag ;
}


//Check for Case vefore SLA deletion.
public boolean chkSLABeforeDelete(List<Presales_SLA__c> slaLst){
List<string> priority = new List<string>();
List<string> Record_Type = new List<string>();
List<string> Geography = new List<string>();
List<string> Country = new List<string>();
List<Presales_SLA__c> sla_master = new List<Presales_SLA__c>();
boolean chkDeleteValid=false;
boolean chkValidFlag = false;

//Iteration for Presales SLA list from trigger and filling up the record,country,geography list

 for (Presales_SLA__c PS:slaLst){
      priority.add(PS.Priority__c);
      Record_Type.add(PS.Case_Record_Type__c);
      Geography.add(PS.Theater__c);
      Country.add(PS.Country__c);
    }
//SOQL for fetching the record type values based in Presales SLA record type
    RecordType r= [select id,name from RecordType where SobjectType=: 'case' and Name IN : Record_Type];

//SOQL for fetching the case values based on record type and returning boolean value if the case list is returned

    List<case> caseLst =[select id,Case_Resolution_Time__c from case where
        RecordTypeId =:r.Id and (Theatre__c  IN :Geography or Country__c IN: Country )and Priority IN :priority];

    System.debug('slaoldlist---->'+slaLst +'---->'+caseLst);
    if(caseLst.size() > 0){
     chkDeleteValid = true;
    }

//Returning boolean value based on Case List obtained from above SOQL 
    
 return chkDeleteValid;
}


//Methos to populate Child data 

public void populateChildData(List<Case> caseLst,List<Case> caseOldLst){
    System.debug('caseLst--->'+caseLst);
    System.debug('caseoldLst--->'+caseOldLst);
    List<Presales_Case_SLA_Tracking__c> lstSLATrack = new List<Presales_Case_SLA_Tracking__c>();
    List<ID> caseIDs = new List<ID>();
    if(caseOldLst != null){
    //Iteration of Old map case values from trigger
    for(Case cID : caseOldLst){
        caseIDs.add(cID.Id);
    }

//SOQL to fetch SLA records based on caseid

    lstSLATrack = [select id,Case_End_Time__c from Presales_Case_SLA_Tracking__c where Case__c IN:caseIDs 
        and Case_End_Time__c =null];
    System.debug('lstSLATrack --->'+lstSLATrack);
//Iterating SLA list to get Case End time

if(lstSLATrack.size()>0){
    for(Integer i=0; i < lstSLATrack.size();i++){
        System.debug('old end date--->'+caseLst[0].LastModifiedDate);
        lstSLATrack[i].Case_End_Time__c = caseLst[0].LastModifiedDate;
    }
  }
 }
 
    //Iteration of new case values from trigger and based on the case status Start time is filled
    
    for(Case caseNew : caseLst){

        Presales_Case_SLA_Tracking__c slaTrack = new Presales_Case_SLA_Tracking__c();
        slaTrack.Case__c = caseNew.Id;
        slaTrack.Case_Status__c = caseNew.status;
        if(caseNew.status =='New'){
            slaTrack.Case_Start_Date__c= caseNew.CreatedDate;
            System.debug('Inside Iffffffffffff');
        }
        
        //Other Case Status other than New
        
        else{
            slaTrack.Case_Start_Date__c= caseNew.LastModifiedDate;

            System.debug('old end date--->'+caseNew.LastModifiedDate);
                        System.debug('Inside ELSEeeeeee');
        }

        lstSLATrack.add(slaTrack);
    //Case_Duration__c
    }

    System.debug('lstSLATrack---->'+lstSLATrack);
    //Try Catch block to update or insert SLA records
    try{
        setslaChanged();
        List<Database.upsertResult> uResults = Database.upsert(lstSLATrack,false);
        System.debug('uResults88888********'+uResults);
    }
    catch(DMLException ex){
        throw ex;
    }


}



   }//end of class