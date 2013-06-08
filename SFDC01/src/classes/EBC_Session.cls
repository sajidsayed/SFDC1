/*
*  Created By       :- Sunil Arora
*  Created Date     :- 14/04/2010
*  Last Modified By :- Sunil Arora
*  Description      :- This class will be called by EBC_Session_Form page to show/save session Vf page.
*/
public class EBC_Session 
{
	public Id sessionId= System.currentPageReference().getParameters().get('Id');
	public String bEventId= ApexPages.currentPage().getParameters().get('retURL');
	

	//getter-setters
	public EBC_Session__c objSession {get;set;}
	public String StartHours {get;set;}
	public String EndHours {get;set;}
	public String StartMinutes {get;set;}
	public String EndMinutes {get;set;}
	public Boolean TwntyFourHour {get;set;}
	public Date stDate {get;set;}
	
	public String bEventStartDate {get;set;}
	public String bEventEndDate {get;set;}
		
	 
		  	  
	
	
	//Constructor.
	public EBC_Session(ApexPages.StandardController stdController)
	{
	if(bEventId!=null)
	{
		bEventId=bEventId.replace('/','');
	}
		
		Date bstartDate;
		Date bEndDate;
		if(sessionId==null && bEventId!=null)
        {
            objSession = (EBC_Session__c)stdController.getSubject();
            objSession.Briefing_Event__c=bEventId;
            
            EBC_Briefing_Event__c bEvent=[Select Id,Start_Date__c,End_Date__c from EBC_Briefing_Event__c where Id =:bEventId];
            bstartDate=bEvent.Start_Date__c;
            bEndDate=bEvent.End_Date__c;
            
             
        }
        else
        {
        	objSession=[Select Topic__c, Topic_Override__c,  Session_Topic_Rating__c,Session_End_Date__c,Session_Start_Date__c,Topic__r.Name,
        	                   Session_Topic_Rating_Notes__c, Session_Start_Time__c, Session_End_Time__c, Requester_Notes__c,
        	                   Name,  Are_the_Presenters_Secured__c, IsDeleted, Id,  Can_this_session_be_changed__c,
        	                   Briefing_Event__r.Start_Date__c,Briefing_Event__r.End_Date__c,
        	                   Briefing_Event__c, Briefing_Advisor_Notes__c From EBC_Session__c where Id=:sessionId];
        	                   
        	bstartDate=objSession.Briefing_Event__r.Start_Date__c;
        	bEndDate=objSession.Briefing_Event__r.End_Date__c;                 
        	                   
        	if(objSession.Session_Start_Time__c!=null)
        	{
        		Integer startHr=objSession.Session_Start_Time__c.hour();
	            Integer startMin=objSession.Session_Start_Time__c.minute();
	            StartHours=startHr+'';
	            StartMinutes=startMin+'';
	            
	            String strStdate = objSession.Session_Start_Time__c.format('MM/dd/yyyy');
            	String[] arrStDate = strStdate.split('/');
            	Date sessStartDate= Date.newInstance(integer.valueOf(arrStDate[2]), integer.valueOf(arrStDate[0]), integer.valueOf(arrStDate[1]));
	            objSession.Session_Start_Date__c=sessStartDate;
        	}
        	if(objSession.Session_End_Time__c!=null)
        	{
        		Integer endHr=objSession.Session_End_Time__c.hour();
	            Integer endMin=objSession.Session_End_Time__c.minute();
	            EndHours=endHr+'';
	            EndMinutes=endMin+'';
	            
	            String strEnddate = objSession.Session_End_Time__c.format('MM/dd/yyyy');
            	String[] arrEndDate = strEnddate.split('/');
            	Date sessEndDate= Date.newInstance(integer.valueOf(arrEndDate[2]), integer.valueOf(arrEndDate[0]), integer.valueOf(arrEndDate[1]));
	            objSession.Session_End_Date__c=sessEndDate;
        	}
            
        }
        bEventStartDate=bstartDate.format();
        bEventEndDate=bEndDate.format();
         //Checking whether the User using 24 hour clock or 12 hour clock with AM,PM
         Map<String, User_Locales__c> mcs = User_Locales__c.getAll();
            String userLocale=UserInfo.getLocale();
            if(mcs.containsKey(userLocale))
            {
            	TwntyFourHour=true;
            }
            else
            {
            	TwntyFourHour=false;
            }    
	}
 
 
	//This method will be used to show minute options in picklist
	  public List<SelectOption> getMinuteOptions()
		{		
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('0','00'));
			options.add(new SelectOption('5','05'));
			options.add(new SelectOption('10','10'));
			options.add(new SelectOption('15','15'));
			options.add(new SelectOption('20','20'));
			options.add(new SelectOption('25','25'));
			options.add(new SelectOption('30','30'));
			options.add(new SelectOption('35','35'));
			options.add(new SelectOption('40','40'));
			options.add(new SelectOption('45','45'));
			options.add(new SelectOption('50','50'));
			options.add(new SelectOption('55','55'));
			return options;
		}

	
	
	public List<SelectOption> getHourOptions()
	{
		List<SelectOption> options = new List<SelectOption>();
		if(TwntyFourHour==true)
		{
			options.add(new SelectOption('0','00'));
			options.add(new SelectOption('1','01'));
			options.add(new SelectOption('2','02'));
			options.add(new SelectOption('3','03'));
			options.add(new SelectOption('4','04'));
			options.add(new SelectOption('5','05'));
			options.add(new SelectOption('6','06'));
			options.add(new SelectOption('7','07'));
			options.add(new SelectOption('8','08'));
			options.add(new SelectOption('9','09'));
			options.add(new SelectOption('10','10'));
			options.add(new SelectOption('11','11'));
			options.add(new SelectOption('12','12'));
			options.add(new SelectOption('13','13'));
			options.add(new SelectOption('14','14'));
			options.add(new SelectOption('15','15'));
			options.add(new SelectOption('16','16'));
			options.add(new SelectOption('17','17'));
			options.add(new SelectOption('18','18'));
			options.add(new SelectOption('19','19'));
			options.add(new SelectOption('20','20'));
			options.add(new SelectOption('21','21'));
			options.add(new SelectOption('22','22'));
			options.add(new SelectOption('23','23'));
		}
		else
		{
			options.add(new SelectOption('1','01 AM'));
			options.add(new SelectOption('2','02 AM'));
			options.add(new SelectOption('3','03 AM'));
			options.add(new SelectOption('4','04 AM'));
			options.add(new SelectOption('5','05 AM'));
			options.add(new SelectOption('6','06 AM'));
			options.add(new SelectOption('7','07 AM'));
			options.add(new SelectOption('8','08 AM'));
			options.add(new SelectOption('9','09 AM'));
			options.add(new SelectOption('10','10 AM'));
			options.add(new SelectOption('11','11 AM'));
			options.add(new SelectOption('12','12 PM'));
			options.add(new SelectOption('13','01 PM'));
			options.add(new SelectOption('14','02 PM'));
			options.add(new SelectOption('15','03 PM'));
			options.add(new SelectOption('16','04 PM'));
			options.add(new SelectOption('17','05 PM'));
			options.add(new SelectOption('18','06 PM'));
			options.add(new SelectOption('19','07 PM'));
			options.add(new SelectOption('20','08 PM'));
			options.add(new SelectOption('21','09 PM'));
			options.add(new SelectOption('22','10 PM'));
			options.add(new SelectOption('23','11 PM'));
			options.add(new SelectOption('00','12 AM'));
			
		}
		return options;
	}

	//This method is used here to save session record.
	public pageReference saveRecord()
	{
		try
		{
			saveData();
		    return reDirect();
	
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , system.label.EBC_Session_Exception+' Error: '+e.getMessage()));
			return null;
		}
	}
	
	public pageReference reDirect()
	{
		PageReference pageRef;
		    if(bEventId!=null)
		    {
		    	pageRef = new PageReference('/' + bEventId);
		    }
		    else
		    {
		    	pageRef = new PageReference('/' + objSession.Id);	
		    }
		    pageRef.setRedirect(true);
		    return pageRef;
	}
	 
	 
	 public pageReference doCancel()
	   {
	     return reDirect();
	   }
	 
	 public void saveData()
	 {
	 	if(objSession.Session_Start_Date__c!=null)
			{
				Date StartDateTime=objSession.Session_Start_Date__c;
				Integer stYear=StartDateTime.year();
		        Integer stMonth=StartDateTime.month();
		        Integer stDay=StartDateTime.day();
				Integer stHours = integer.valueOf(StartHours);
				Integer stMinutes = integer.valueOf(StartMinutes);
				
				Datetime stDate =datetime.newInstance(stYear, stMonth, stDay, stHours,stMinutes, 0);
				objSession.Session_Start_Time__c=stDate;
			}
			
			if(objSession.Session_End_Date__c!=null)
			{
				Date EndDateTime=objSession.Session_End_Date__c;
				Integer endYear=EndDateTime.year();
		        Integer endMonth=EndDateTime.month();
		        Integer endDay=EndDateTime.day();
				Integer endHours = integer.valueOf(EndHours);
				Integer endMinutes = integer.valueOf(EndMinutes);
				
				Datetime endDate =datetime.newInstance(endYear, endMonth, endDay, endHours,endMinutes, 0);
				objSession.Session_End_Time__c=endDate;
			}
			if(sessionId==null)
			{
				insert objSession;
			}
			else
			{
				update objSession;
			}
	 }
	 
	   
	 public pagereference SaveAndNew()
	 {
	 	try
		{
			saveData();
			
			bEventId=objSession.Briefing_Event__c;
			
			
		    PageReference pageRef;
		    
		    pageRef = new PageReference('/apex/EBC_Session_Form?retURL=%2F'+bEventId);
		    pageRef.setRedirect(true);
            return pageRef;
	
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , system.label.EBC_Session_Exception+' Error: '+e.getMessage()));
			return null;
		}
	 }
}