/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  06.10.09   Shipra Misra            Initial Creation.  Procedures for Creating Quote for Opportunity.               
 |                                    
 |  01.02.10   Shipra Misra            Updated query for Addition of Update from Quote Amount to Forecast field.  
 |	14.09.10   Shipra Misra			   Updated Code for cleaning Developer script exception.   
 | 	17-Sep-10  Shipra Misra				Cleaned code for Developer Script exception. WR:146082         
 +===========================================================================*/
 
public with sharing class Opp_CreateQuote 
{

  //Declaring class variables.
   public Opportunity  objOppy {get;set;}
   //Opportunity objOppy= new Opportunity();
   public Opportunity Opp{get;set;}
   public Boolean showAccess{get;set;}
   public Boolean showOpportunityNumError{get;set;}
   public Boolean showNextValidation{get;set;}
   public Boolean showIntegrationError{get;set;}
   public Boolean showQuoteAlreadyTriggered{get;set;}
   public Boolean showSave {get; set;}//Boolean value displaying whether record has been saved or not.//
   public Boolean showOkButton {get; set;}//Boolean value to display OK button.//
   public Boolean showCreateQuote {get; set;}//Boolean value to display Create Quote pop-up.//
   public String CurrentUserProfile= [Select Profile.Name,ProfileId, Id From User u where id=:UserInfo.getUserId()].Profile.Name;
   public Boolean showUserAccess {get; set;}
   //Constructor//
   public Opp_CreateQuote(ApexPages.StandardController controller)
   {
       this.Opp=(Opportunity)controller.getRecord();
       try
       {
           
           if(Opp.Id!=null)
           {
              String OpportId=Opp.id+''; 
              if(opportId.subString(0,3)=='006')
              {
                   objOppy = [select Id, Edit_Access__c ,Quote_Operating_Unit__c,Sell_Relationship__c,Update_Forecast_Amount_from_Quote__c,Opportunity_Number__c,
                                        Quote_Cart_Number__c,Integration_Error_Message__c from Opportunity where id =: Opp.Id];
               }
           }
              
       }
       catch(QueryException e)
       {
            System.debug('the exception is' +e);
       }
    }
    public void validate()
    {
        
        if(checkUserProfile()&& checkOpportunityAccess()&& checkSynergyNumberPresent()&& checkRequestRaised()&& checkErrorMessagePresent())
        {
            
        }
    }
    //method to Check Profile of user//
    public Boolean checkUserProfile()
    {
       
        if(CurrentUserProfile!='Marketing Standard User')
        {
           return true;        
        }
        else
        {
            showUserAccess=true;
            showOkButton = True;
            return false;
        }
        
    }
 
    //method to Check Opportunity Access//          
    public Boolean checkOpportunityAccess()
    {
       	//Code Updated on 17-10-10 Developer Script Excetion cleanup.Added Try Catch Block//
       if(Opp.Id!=null)
       {
        try
        {
              //Select u.Profile_Name__c, u.ProfileId, u.Id From User u
              
              objOppy.Edit_Access__c ='test Access';
              //DML to update Opportunity Edit_Access__c field to verify rep/user has read/write access to record.//            
            update objOppy;
            return true; 
        }
        catch (System.DmlException ex1) 
        {
           if((ex1.getmessage()).indexof('INSUFFICIENT_ACCESS_OR_READONLY')!=-1)
           {
               showAccess=true; 
               showOkButton = True;
               System.debug('Oppty access exception----->'+ex1);   
               return false;  
              
           }
          
          else
          if(!((ex1.getmessage()).indexof('INSUFFICIENT_ACCESS_OR_READONLY')!=-1))
          {
            Integer i=ex1.getMessage().indexof(',');
            System.debug(ex1.getMessage());
            Integer j=ex1.getMessage().lastindexof(':');
            String Message= ex1.getMessage().substring(i+1);
            String Message2= ex1.getMessage().substring(j);
            String Message3=ex1.getMessage().substring(i+1,j);

            String Message4=ex1.getMessage().substring(j+1,ex1.getMessage().length());
            System.debug('****'+Message4+'****');
            if(Message4==' []'){                           
                System.debug('the value of message is ?* '+Message+'   the next message is  ********* '+Message2+'   ddd '+Message3);
                ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.Error, Message3);
                System.debug('****#### The Validation Error is **** '+myMsg2);
                ApexPages.addMessage(myMsg2);
            }  
            showOkButton = True;
            return false; 
           }
            System.debug('the exception is' +ex1);
            return false; 
        }
    } 
    else{
    	return false;
    }
    }
        
    //method to check Synergy opp Number present.//     
    public Boolean  checkSynergyNumberPresent()
    {
        try
        {
            //Condition to find out whether Synergy_Opportunity_Number__c in null.//
            if(objOppy.Opportunity_Number__c == null)
            {
                //quote can not be created for this opportunity until an opportunity number is present.//             
                showOpportunityNumError=true;
                showOkButton = True;
                return false;
                
            }
            else
            {
                // If the above condition is not fulfilled then checkErrorMessagePresent validation will be called.//               
                return true;
            }  
        }
        catch (QueryException e)
        { 
            System.debug('the exception is' +e);
            showOkButton = True;
            return false;
        }
                
            
    }
      
    //method when the quote details are not been updated to synergy for some reason and user tries to create quote where details are already populated.// 
    public Boolean checkRequestRaised()
    {
        try
        {
            //Condition to find out whether Sell_Relationship__c and Quote_Operating_Unit__c is null or blank.//
            if(objOppy.Sell_Relationship__c != null && objOppy.Sell_Relationship__c != '' && objOppy.Quote_Operating_Unit__c != null && objOppy.Quote_Operating_Unit__c != '')
            {
                //quote can not be created for this opportunity until an condition is met.//
                //The Error message is tracked and if it matches up with following error then error message is displayed.//
                return true;
            }
            //If Sell Relationship and quote opportunity is null and no error message, displaythe create quote pop-up.//
            else
            {
                if(objOppy.Integration_Error_Message__c!=null)
                {
                   //If the above condition is not fullfilled then Create quote pop up window will generate.//
                    showIntegrationError=true;
                    showCreateQuote = True;
                    return false;
                }
                else
                {
                    showCreateQuote = True;
                    return false;
                }
            }   
         }
         catch (QueryException e)
         {
            System.debug('the exception is' +e);
            showOkButton = True;
            return false;
         }
    } 
    public Boolean checkErrorMessagePresent()
    {
        try
        {
                //quote can not be created for this opportunity until an condition is met.//
                //The Error message is tracked and if it matches up with following error then error message is displayed.//
                //if(displayOpp.Integration_Error_Message__c!=null && displayOpp.Integration_Error_Message__c.equals('Quote Creation Failed')) 
                if(objOppy.Integration_Error_Message__c!=null)
                {
                    //Error message comes back from integration and is populated in opportunity.User again clicks create quote button.
                    showIntegrationError=true;
                    showCreateQuote = True;
                    //showOkButton = True;
                    return false;
                    //showCreateQuote = True;     
                }
                else
                {
                    //User tries to click button again, but is given an error after Create Quote is alredy triggered.
                    showQuoteAlreadyTriggered=true;
                    showOkButton = True;
                    return false;
                } 
         }
         catch (QueryException e)
         {
           System.debug('the exception is' +e);
            showOkButton = True;
            return false;
         }
    } 
  
  //Function to save the record fcreateQuotesaveor quote generation against the partucular opportunity.//
    public PageReference createQuotesave()
    {
         try
         {
             //DML statement to update the quote fields against the existing opportunity.//     
              objOppy.Integration_Error_Message__c='';
              System.debug('the value of checked isobjOppy.Update_Forecast_Amount_from_Quote__c '+objOppy.Update_Forecast_Amount_from_Quote__c );
              update objOppy;
              
         }
         catch(DMLException e)
         {
               System.debug('the exception is' +e);
               Integer i=e.getMessage().indexof(',');
               Integer j=e.getMessage().lastindexof(':');
               String Message= e.getMessage().substring(i+1);
               String Message2= e.getMessage().substring(j);
               String Message3=e.getMessage().substring(i+1,j);
               System.debug('the value of message is ?* '+Message+'   the next message is  ********* '+Message2+'   ddd '+Message3);
               ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.Error, Message3);
               System.debug('****#### ;;;;The Validation Error is **** '+myMsg2);
               ApexPages.addMessage(myMsg2);
               showCreateQuote = false;
               showIntegrationError=false;
               showOkButton = True;
               return null;
         }
              showIntegrationError=false;
              showCreateQuote = False;
              showSave = True;
              showOkButton = True;
              return null;
    }
    
    //method to take the controll on the same opportunity page after Ok button is clicked.//
    public PageReference Ok()
    {
              return null;
    }
}//end of class.//