/*
Author : Avinash Kaltari, SFDC Developer, EMC.
Purpose : To get the Old and the New field values after insert and before update of any detail line via an email
Created Date : 02 Mar 2012
*/

trigger DetailLine on Detail_Line__c (before update, after insert) 
{
    List<Detail_Line__c> lstNewDetailLines = new List<Detail_Line__c>();
    List<Detail_Line__c> lstOldDetailLines = new List<Detail_Line__c>();
    List<Detail_Line__c> lstFaultyDetailLines = new List<Detail_Line__c>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String strEmailBody = '';
    String distributionVAR ='';
    String [] toAddresses;
    
    
    Map<String,CustomSettingDataValueMap__c>  datamap =  CustomSettingDataValueMap__c.getall();
    if(datamap.containsKey('SplitIssueEmailAlertEmailIDs'))
    {
    	toAddresses = datamap.get('SplitIssueEmailAlertEmailIDs').DataValue__c.split(',') ;
    }
    
    if (toAddresses == null || toAddresses.size() == 0)
    	toAddresses = new String[] {'avinash.kaltari@emc.com','devi.bal@emc.com','sajeed.sayed@emc.com','Anand.Sharma2@emc.com'};
    	
    for(String str : toAddresses)
    	str = str.trim();
    
    mail.setToAddresses(toAddresses);
    
    if(Trigger.isInsert && Trigger.isAfter)
    {
        lstNewDetailLines = Trigger.New;
        for (Detail_Line__c dl : lstNewDetailLines)
        {
            if(dl.Split__c > 100)
            {    
            	lstFaultyDetailLines.add(dl);
            	strEmailBody = strEmailBody + '\n\n Detail Line ID : '+dl.Id +'\n'+
            							      'Detail Line Name : '+dl.Name +'\n'+
            								  'Detail Line Split : ' + dl.Split__c +'\n'+
            								  'Detail Line Opportunity ID : ' + dl.Opportunity__c +'\n'+
            								  'Detail Line OwnerId : ' + dl.OwnerId +'\n'+
            								  'Detail Line CreatedById : ' + dl.CreatedById +'\n'+
            								  'Detail Line Created Date : ' + dl.CreatedDate +'\n'+
            								  'Detail Line LastModifiedById : ' + dl.LastModifiedById +'\n'+
            								  'Detail Line Last Modified Date : ' + dl.LastModifiedDate +'\n'+
            								  'Detail Line Opportunity Product : ' + dl.Opportunity_Product__c +'\n'+
            								  'Detail Line Opportunity_Access_Level : ' + dl.Opportunity_Access_Level__c +'\n'+
            								  'Detail Line OpportunityTeamMember : ' + dl.OpportunityTeamMember__c +'\n'+
            								  'Detail Line Forecast_Group : ' + dl.Forecast_Group__c;
            }
            								  
        }
        
        if(lstFaultyDetailLines.size() > 0)
        {
        	mail.setSubject(lstFaultyDetailLines.size() + ' Faulty Detail Line(s) Created in SFDC 01 Org');
		    mail.setPlainTextBody('The Faulty Detail Line Record Details are as follows :' + strEmailBody);
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
            
    }
    
    if(Trigger.isUpdate && Trigger.isBefore)
    {
        lstNewDetailLines = Trigger.New;
        lstOldDetailLines = Trigger.Old;
        
        for(Detail_Line__c dl : lstNewDetailLines)
        {
        	if((Trigger.OldMap.get(dl.id).Split__c > 100 || dl.Split__c > 100) && (Trigger.OldMap.get(dl.id).Split__c != dl.Split__c))
        	{
        		lstFaultyDetailLines.add(dl);
            	strEmailBody = strEmailBody + '\n\n Detail Line ID : '+dl.Id +
            							      '\n Detail Line Name : '+dl.Name +
            							      '\n\n OLD Detail Line Split : ' + Trigger.OldMap.get(dl.id).Split__c +'\n'+
            								  'NEW Detail Line Split : ' + dl.Split__c +
            								  '\n\n OLD Detail Line Opportunity ID : ' + Trigger.OldMap.get(dl.id).Opportunity__c +'\n'+
            								  'NEW Detail Line Opportunity ID : ' + dl.Opportunity__c +
            								  
            								  '\n\n OLD Detail Line OwnerId : ' + Trigger.OldMap.get(dl.id).OwnerId + '\n'+
            								  'NEW Detail Line OwnerId : ' + dl.OwnerId +
            								  '\n\n Detail Line CreatedById : ' + Trigger.OldMap.get(dl.id).CreatedById +'\n'+
            								  'Detail Line Created Date : ' + dl.CreatedDate +
            								  '\n\n OLD Detail Line LastModifiedById : ' + Trigger.OldMap.get(dl.id).LastModifiedById +'\n'+
            								  'NEW Detail Line LastModifiedById : ' + dl.LastModifiedById +
            								  '\n\n OLD Detail Line Last Modified Date : ' + Trigger.OldMap.get(dl.id).LastModifiedDate +'\n'+
            								  'NEW Detail Line Last Modified Date : ' + dl.LastModifiedDate +
            								  '\n\n OLD Detail Line Opportunity Product : ' + Trigger.OldMap.get(dl.id).Opportunity_Product__c +'\n'+
            								  'NEW Detail Line Opportunity Product : ' + dl.Opportunity_Product__c +
            								  '\n\n OLD Detail Line Opportunity_Access_Level : ' + Trigger.OldMap.get(dl.id).Opportunity_Access_Level__c +'\n'+
            								  'NEW Detail Line Opportunity_Access_Level : ' + dl.Opportunity_Access_Level__c +
            								  '\n\n OLD Detail Line OpportunityTeamMember : ' + Trigger.OldMap.get(dl.id).OpportunityTeamMember__c +'\n'+
            								  'NEW Detail Line OpportunityTeamMember : ' + dl.OpportunityTeamMember__c +
            								  '\n\n OLD Detail Line Forecast_Group : ' + Trigger.OldMap.get(dl.id).Forecast_Group__c +'\n'+
            								  'NEW Detail Line Forecast_Group : ' + dl.Forecast_Group__c;
        	}
        	if(lstFaultyDetailLines.size() > 0)
	        {
	        	mail.setSubject(lstFaultyDetailLines.size() + ' Faulty Detail Line(s) Updated in SFDC 01 Org');
			    mail.setPlainTextBody('The Faulty Detail Line(s) Record Details are as follows :' + strEmailBody);
			    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	        }
        }
    }
}