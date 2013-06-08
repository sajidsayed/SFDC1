/*
Author:     Devi Prasad Bal
Created on: 05-April-2010
Description: This class acts as controller for the visualforce page EBC_Send_FBP. 
			 On click of the 'Send FBP Email' a new window opens up wherein the To and From addresses are pre-populated.
			 'Additional To' field can contain additional email ids to whom the mail would be sent to.
			 
Modified by: 
Modified on: 
Reason: 
*/ 


public class EBC_Send_FBP
{
    public string body; // to hold the body of the mail
    public string additionalEmailIds; // free text area to hold additional email ids
    public static Boolean mailSent; 
    public EBC_Briefing_Event__c briefingEvent {get; set;}
    public EBC_Invitees__c[] inviteeList;
    String subject;
    String briefingEventId='';    
    List<String> toAddresses = new List<String>();
    Boolean renderAddRecepient=false;
    public class MailException extends Exception {}
    Boolean mailSend=false;
    Integer countOfActualRecipients;
    Boolean BA_Present; // to check if there is a Briefing Advisor for the Briefing Event


    /*Getters and Setters used*/

	public String getAdditionalEmailIds()
	{
	    return additionalEmailIds ;
	}
	public void setAdditionalEmailIds(String mailAdditionalEmailIds)
	{
	    this.additionalEmailIds =mailAdditionalEmailIds;
	}         
	public String getBody()
	{
	    return body ;
	}
	public void setBody(String mailBody)
	{
	    this.body =mailBody;
	}
	public Boolean getMailSent()
	{
	    return EBC_Send_FBP.mailSent;
	}
	public String getSubject()
	{
	    return subject;
	}
	public boolean getMailSend()
	 {
	     return mailSend;
	 }
	public List<String> getToAddresses()
	{
	    return toAddresses;
	}
	public boolean getBA_Present()
	{
	    return BA_Present;
	}
	public boolean setBA_Present()
	{
	    return BA_Present;
	}
	
	/*
	public String additionalEmailIds(){get; set;}         
	public String Body(){get; set;}
	public Boolean MailSent(){get; set;}
	public String Subject(){get; set;}
	public boolean MailSend(){get; set;}
	public List<String> ToAddresses(){get; set;}
	public boolean BA_Present(){get; set;}
	*/   
   
    /*Send Mail Constructor
	Invocation Point- On invocation of the link.
	Description- Constuctor is used to initialize the merge fields.
	*/       
    public EBC_Send_FBP()
    {  
        briefingEventId=ApexPages.currentPage().getParameters().get('id'); // id of the parent Briefing Event Object
        briefingEvent = [Select id, Name, Briefing_Advisor__c, Briefing_Advisor__r.Name , Briefing_Advisor__r.Email, Start_Date__c, End_Date__c from EBC_Briefing_Event__c where id =:briefingEventId];
        EBC_Send_FBP.mailSent=false;
        BA_Present=true;
        
        // throw error if the Briefing Advisor is null. the Send mail button is also not rendered in absence of a Brifing Advisor
        if(briefingEvent.Briefing_Advisor__c==NULL)
        {
        	BA_Present = false;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'There are no Briefing Advisor for the Briefing Event. So, a mail cannot be sent.' ));
        }
        
        body = ' '; //String body initialized to a blank value
        // the block of code below is to get the start date and end date in date formats from the Start_Date__c and End_Date__c date/time fields
        Integer stYear=briefingEvent.Start_Date__c.year();
        Integer stMonth=briefingEvent.Start_Date__c.month();
        Integer stDay=briefingEvent.Start_Date__c.day();
                
        Integer endYear=briefingEvent.End_Date__c.year();
        Integer endMonth=briefingEvent.End_Date__c.month();
        Integer endDay=briefingEvent.End_Date__c.day();

        Date startDate=Date.newInstance(stYear,stMonth,stDay);
        Date endDate=Date.newInstance(endYear,endMonth,endDay);
        String startD = startDate.format();
        String endD = endDate.format();
        subject = startD + ' to ' + endD + ' ' + briefingEvent.Name + '- Final Briefing Package';
        
        // retrieve the list of invitees to whom the mail needs to be sent
        inviteeList = [Select Attendee_Email__c, Send_FBP__c from EBC_Invitees__c where Briefing_Event__c =:briefingEventId AND Send_FBP__c =: true];
        
        // add the email ids of the invitees to the toAddress lists
        for(integer i=0;i<inviteeList.size();i++)
        {
                toAddresses.add(inviteeList[i].Attendee_Email__c);
        }
        countOfActualRecipients = toAddresses.size();            
        
    }
    
    /*Send Mail Method
	Invocation Point- Send Mail Button on Send Mail Page
	Description- This method creates and sends a mail.
	*/
	public PageReference sendMail() 
	{
		String[] mailId;
		String pString = ',';
		//split the email ids separated by commas and add to toAddress 
		mailId = additionalEmailIds.split(pString);
		if(mailId[0] != '') 
		{
	        for(integer i=0; i<mailId.size(); i++)
	        {
	                toAddresses.add(mailId[i]);     
	        }
		}
	
		Messaging.SendEmailResult[] result=null;
		try
		{
			EBC_Send_FBP.mailSent=true;
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();      
			mail.setToAddresses(toAddresses); // toAddresses to be added to the mail 'To' address
			System.debug('toAddresses  '+toAddresses);
			if( toAddresses.size()==0 ){
			    throw new MailException('Recipient Email Address Required');
			}
			
			mail.setPlainTextBody(body);
			mail.setSubject(subject); 
			mail.setBccSender(false);
			mail.setReplyTo(briefingEvent.Briefing_Advisor__r.Email); // the mail reply will be received by the Briefing Advisor
			mail.setSenderDisplayName(briefingEvent.Briefing_Advisor__r.Name); // the sender name is that of the Briefing Advisor
			result=Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		catch(Exception ex )
		{
			ApexPages.addMessages(ex);
			if(mailId[0] != '') 
			{
				// if there had been an error thrown then remove the email ids from toAddresses
		        for(integer i=countOfActualRecipients; i<toAddresses.size(); i++)
		        {
		        	toAddresses.remove(i);  
		        } 
			}
		}
		       
		if ( result!=null)
		{
			if(result[0].isSuccess())
			{
				mailSend=true;
			}
			else
			{
				// in case the mail couldn't be sent throw an error
				ApexPages.addMessages(new MailException(System.Label.Mail_Send_Failed) ); 
			}
		}
		return null;
		}
}