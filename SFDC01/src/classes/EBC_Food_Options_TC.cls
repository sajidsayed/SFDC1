/*
Author:     Devi Prasad Bal
Created on: 09-May-2010
Description: This class contains test method for EBC_Food_Options.cls

Modified by:	Avinash K
Modified on: 	22 May 2012
Reason:
*/

@isTest
private class EBC_Food_Options_TC {
    	static testMethod void validateFoodOptions() {
			
			Date sd = date.today();
			EBC_Briefing_Event__c beRecord = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open', Start_Date__c=sd);
    		insert beRecord;
    		
    		Briefing_Food_Options__c bfoRecord = new Briefing_Food_Options__c(Name='Naam', Briefing_Event__c=beRecord.Id);
    		
    		ApexPages.StandardController ctController=new ApexPages.StandardController(bfoRecord);
    		ApexPages.currentPage().getParameters().put('retURL',beRecord.id);
    		ApexPages.currentPage().getParameters().put('Id',null);
    		
    		EBC_Food_Options foodOption = new EBC_Food_Options(ctController);
		    foodOption.bfoSave();
		    foodOption.pageRedirect(); 
		    
		    
		    Briefing_Food_Options__c bfoRecord2 = new Briefing_Food_Options__c(Name='Naam', Briefing_Event__c=beRecord.Id);
    		insert bfoRecord2;
    		
    		ApexPages.StandardController ctController2=new ApexPages.StandardController(bfoRecord2);
    		ApexPages.currentPage().getParameters().put('retURL',beRecord.id);
    		ApexPages.currentPage().getParameters().put('Id',bfoRecord2.id);
    		
    		EBC_Food_Options foodOption2 = new EBC_Food_Options(ctController2);
		    foodOption2.bfoSave();
		    foodOption2.pageRedirect();
		    
		    
		    
//Avinash's code begins...
		    ApexPages.currentPage().getParameters().put('Id',bfoRecord2.id);
		    delete bfoRecord2;
		    EBC_Food_Options foodOption3 = new EBC_Food_Options(ctController2);
		    foodOption3.bfoSave();
		    
		    Date startDate = date.newinstance(1960, 2, 17);
		    Date myDate = date.newinstance(1960, 2, 18);
		    Date endDate = date.newinstance(1960, 2, 19);
		    
		    beRecord.Start_Date__c = startDate;
		    beRecord.End_Date__c = endDate;
		    update beRecord;
		    
		    bfoRecord2 = new Briefing_Food_Options__c(Name='Naam', Briefing_Event__c=beRecord.Id, Date__c = myDate);
		    insert bfoRecord2;
		    
		    ApexPages.currentPage().getParameters().put('Id',bfoRecord2.id);
		    
		    Briefing_Food_Options__c bfo = new Briefing_Food_Options__c(Name='Naam', Briefing_Event__c=beRecord.Id, Date__c = myDate);
		    insert bfo;
		    
		    EBC_Food_Options foodOption4 = new EBC_Food_Options(ctController2);
		    foodOption4.bfoSave();
		    
		    
    		
//Avinash's Code ends.
    	}
}