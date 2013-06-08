/*==============================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  1 May 2013   Prachi Bhasin           246408      Creation
 +==============================================================================================================*/
trigger ReportingFieldInsideSalesAlerts on Lead(before update) {
    System.debug('Trigger.New'+Trigger.New);
    Map<Id,Lead> leadOldRecordsMap= new Map<Id,Lead>();
    Map<Id,Lead> leadNewRecordsMap= new Map<Id,Lead>();

    List <Id> oldOwnerId= new List <Id>();
    List <Id> newOwnerId= new List <Id>();

                LeadReportingFieldChange reportObj = new LeadReportingFieldChange();

                for(Lead objLead : Trigger.new){

                      if(objLead.OwnerId!=trigger.oldMap.get(objLead.id).OwnerId){

                                 leadNewRecordsMap.put(objLead.id,objLead);

                                 newOwnerId.add(objLead.ownerid);

                                 leadOldRecordsMap.put(objLead.id,trigger.oldMap.get(objLead.id));

                                 oldOwnerId.add(trigger.oldMap.get(objLead.id).ownerid);

                                }

                }

                if(!leadNewRecordsMap.isEmpty() && !leadOldRecordsMap.isEmpty() && !newOwnerId.isEmpty() && !oldOwnerId.isEmpty()){

                             reportObj.updateReportField(leadNewRecordsMap,leadOldRecordsMap,newOwnerId,oldOwnerId);
                }


  
}