/* ===================================================================================================================================
 |  HISTORY 
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION 
 |  19-12-2012      Ganesh Soma     #215660     This class will be used to display Opportunity History on the Case detail page section.                               
 ======================================================================================================================================*/
public class Presales_OppHistory
{
     //Declare variables here
     public ApexPages.StandardController stdCon;
     public Case caseRecord{get;set;}
     public List<OppHistoryBeans> lstOppHistory{get;set;}
        
     
     //Constructor defindition
     public Presales_OppHistory(ApexPages.StandardController stdController){
        stdCon = stdController;
        
        //Add the current detail record to the variable
        this.caseRecord =  (Case)stdController.getRecord();  
        GetCaseDetails();
        system.debug('caseRecord == '+caseRecord);
        GetOppHistoryDetails();
        
    }
    
    //This method gets the required case details 
    private void GetCaseDetails()
    {
      this.caseRecord = [select id,Opportunity_Name__c,Opportunity_Name__r.CurrencyIsoCode from case where id =: caseRecord.ID];
    
    }
    
    //This method gets the opportunity history details
    private void GetOppHistoryDetails()
    {
      //Query on Opportunity History and get the required details
      lstOppHistory = new List<OppHistoryBeans>();
      //lstOppHistory = [select Field, CreatedById, CreatedDate, IsDeleted, NewValue, OldValue, Id, OpportunityId 
      					//from OpportunityFieldHistory 
      					//where OpportunityId =: caseRecord.Opportunity_Name__c];
      OppHistoryBeans objOppHistory;
      					
      for(OpportunityFieldHistory obj : [select Field, CreatedById, CreatedDate, IsDeleted, NewValue, OldValue, Id, OpportunityId,CreatedBy.Name
      									from OpportunityFieldHistory 
      									where OpportunityId =: caseRecord.Opportunity_Name__c and (Field='StageName' or Field='CloseDate' or Field='Amount') order by CreatedDate desc])
	 {
      		objOppHistory = new OppHistoryBeans();      		
      		string fieldName='';      		
      		if(obj.Field == 'StageName')
      		fieldName = 'Forecast Status';
      		else if(obj.Field == 'CloseDate')
      		fieldName = 'Close Date';
      		else if(obj.Field == 'Amount')
      		fieldName = 'Forecast Amount';
      		if(obj.Field == 'CloseDate')
      		{
      			String strLocale = UserInfo.getLocale();
      			if(strLocale == 'en_US')
      				objOppHistory.strAction = 'Changed <b>'+fieldName+'</b> from '+((Datetime)obj.OldValue).formatGmt('MM/dd/yyyy')+' to <b>'+((Datetime)obj.NewValue).formatGmt('MM/dd/yyyy')+'</b>.';
      			else
      				objOppHistory.strAction = 'Changed <b>'+fieldName+'</b> from '+((Datetime)obj.OldValue).formatGmt('dd/MM/yyyy')+' to <b>'+((Datetime)obj.NewValue).formatGmt('dd/MM/yyyy')+'</b>.';
      		}
      		else if(obj.Field == 'Amount')
      		{
      			    List<String> args = new String[]{'0','number','###,###,##0.00'};
      			    String strOldAmount = obj.OldValue == null ? '0' : string.valueof(obj.OldValue);
      			    Decimal decOldAmount = Decimal.valueOf(strOldAmount);
      			    String oldAmount = String.format(decOldAmount.format(), args);
      			    
      			    String strNewAmount = obj.NewValue == null ? '0' : string.valueof(obj.NewValue);
      			    Decimal decNewAmount = Decimal.valueOf(strNewAmount);
					String newAmount = String.format(decNewAmount.format(), args);
					
					if(!oldAmount.contains('.'))
					oldAmount = oldAmount +'.00';
					
					if(!newAmount.contains('.'))
					newAmount = newAmount +'.00';
					
					objOppHistory.strAction = 'Changed <b>'+fieldName+'</b> from '+ caseRecord.Opportunity_Name__r.CurrencyIsoCode+' '+ oldAmount+' to <b>'+caseRecord.Opportunity_Name__r.CurrencyIsoCode+' '+newAmount+'</b>.';
      		}
      		else      		
      		objOppHistory.strAction = 'Changed <b>'+fieldName+'</b> from '+obj.OldValue+' to <b>'+obj.NewValue+'</b>.';
      		
      		
      		objOppHistory.strConnection = '';
      		objOppHistory.dtCreatedDate = obj.CreatedDate;
      		objOppHistory.userID = 	obj.CreatedById;
      		objOppHistory.strUserName = obj.CreatedBy.Name;
      		
      		lstOppHistory.add(objOppHistory);
          	 				
     }
      
    
    }
    
       
    //Create a class with variables
    public class OppHistoryBeans
    {
      public String strAction {get;set;}
      public ID userID {get;set;}
      public User user {get;set;}
      public String strUserName{get;set;}
      public DateTime dtCreatedDate {get;set;}
      public String strConnection{get;set;}
    
    }
    
 
}