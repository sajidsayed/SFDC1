/*
Author:     Sunil Arora
Created on: 8-april-2010
Description: This page is used to show Session Presenter Edit Page.
This class is controller for Page(s): EBC_SessionPresenter
Modified by: Sunil Arora
Modified on: 13-April-2010
Reason: Modified based on further inputs from the business
*/
public class EBC_SessionPresenter
{
    public EBC_Session_Presenter__c objSPresenter {get;set;}
    public Id sessionId= System.currentPageReference().getParameters().get('sessId');
    public Id spId= System.currentPageReference().getParameters().get('Id');
    public String guestPresenter= System.currentPageReference().getParameters().get('guestPresenter');
    public String topicName{get; set;}
    public String topicPresenterId {get; set;}
    public string topicPresenterName{get; set;}
    public Boolean result=false;
    public boolean getresult()
    {
       return this.result;
    }
    public void setresult(Boolean s)
    {
       this.result = s;
    }
    public Id topicPresenter{get; set;}
    
    //Constructor
    public EBC_SessionPresenter(ApexPages.StandardController stdController)
    {
             
             if(sessionId!=null)
             {
                objSPresenter = (EBC_Session_Presenter__c)stdController.getSubject();
             }
             else if(spId!=null)
             {
                objSPresenter = [Select Topic__c, Topic_Presenters__c,Topic_Presenters__r.Name, Session__c, Presenter__c, OwnerId, Name,
                                        Is_the_Presenter_Confirmed__c, IsDeleted, Id, Guest_Presenter_Last_Name__c,
                                        Guest_Presenter_First_Name__c, Guest_Presenter_Email__c, Guest_Presenter_EBC_Title__c,
                                         Discussion_Leader_Rating__c, Guest_Company__c,
                                        Discussion_Leader_Notes__c, CurrencyIsoCode,Guest_Presenter__c
                                 From EBC_Session_Presenter__c where Id=:spId Limit 1];

                sessionId=objSPresenter.Session__c;
             }
             topicPresenterId=objSPresenter.Id;
             result=objSPresenter.Guest_Presenter__c;
             EBC_Session__c session=[Select Id,Topic__c,Topic__r.Name from EBC_Session__c where Id=:sessionId Limit 1];
             topicName=session.Topic__r.Name;
             objSPresenter.Session__c=sessionId;
             objSPresenter.Name=topicName;
             if(guestPresenter!=null)
             {
                if(guestPresenter=='1')
                {
                    result=true;
                    objSPresenter.Guest_Presenter__c=true;
                }
                else
                {
                    result=false;
                    objSPresenter.Guest_Presenter__c=false;
                }
             }
             else
             {
                if(objSPresenter.Guest_Presenter__c==true)
                {
                    result=true;
                }
                else
                {
                    result=false;
                                        topicPresenterId=objSPresenter.Topic_Presenters__c;
                    topicPresenterName=objSPresenter.Topic_Presenters__r.Name;
                }
             }
    
    }
    
    //This method is used here to save Record
    public pageReference saveRecord()
    {
        try
        {
        	if(topicPresenterName==null || topicPresenterName=='')
	        {
	        	topicPresenterId=null;
	        }
	        
	    
	        if(topicPresenterId==null  && objSPresenter.Guest_Presenter__c==false)
	        {
	          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , System.Label.EBC_Topic_Presenter_Error));
	           return null;
	        }
	        else
	        {
	        	if(objSPresenter.Guest_Presenter__c==false)
		        {
		            objSPresenter.Topic_Presenters__c=topicPresenterId;
		        }
	        	if(spId==null)
		        {
		            insert objSPresenter;
		        }
		        else
		        {
		            update objSPresenter;
		        }
		    PageReference pageRef = new PageReference('/' + sessionId);
	        pageRef.setRedirect(true);
	        return pageRef;
	        }
        }
        catch(Exception e)
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,e+''));
        	return null;
        }    
    }
    
       public pageReference doCancel()
	   {
	        PageReference pageRef = new PageReference('/' + sessionId);
	        pageRef.setRedirect(true);
	        return pageRef;
	   }
}