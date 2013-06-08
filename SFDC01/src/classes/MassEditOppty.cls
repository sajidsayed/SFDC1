/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  15.12.2010      Shipra Misra    153590      Initial Creation.  Creating this class to resolve Opportunity Inline editing tool 
 |                                                                                              not triggering Integration properly.
 | 
 |  16.02.2011      Devi Prasad Bal 149408      Make IIG Sales Stage field available for inline editing in all CMA views
 |  17.05.2011      Shipra Misra    163358      Updated the Inline Edit functionality so that it allows the user to commit the saves
 |                                              on the records that are error free.Also Display the result of update.
 |  02.06.2011      Shipra Misra    166262      Add Alliance fields to the Opportunity Inline Editing
 |  21.07.2011      Srinivas N      168752      Added two filed to the query 'Competitor_Product__c', 'Competitor_Lost_To__c'
 |  09.09.2011      Srinivas N      173116      Add UIG Engagement field to in-line editing     
 |  11.10.2011      Shipra Misra    173965      November Release.Updated Alliance functionality on the Opportunity.      
 |  03.06.2013      Sneha Jain      259802      Made fields 'Renewals_Close_Details__c' & 'Closed_Reason_Action__c' available for inline editing
 |                                              and added in query.
 +========================================================================================================================*/

public class MassEditOppty
{
    //Hold List Of Oppty's coming from Inline edit.
    public List<Opportunity> lstOppty;
    //Hold List of Oppty records coming from inlineEditWrapper.
    public List<inlineEditWrapper> lstWrapper{ get; set;}  
    //Hold Page Reference on Custom save click.
    public PageReference pagerefs;
    //Hold the Count of records errored out on update.
    public Integer intCountError;
    //Hold the Count of records saved successfully on update.
    public Integer intCountSaved;
    //Holds value for the checkbox, which decides whether the IIG Sales Stage field be displayed. Devi:WR#149408
    public Boolean blnSalesStage{get; set;}
    //Holds value for the Custom Button Save, which should set to true if there is any record selected on List View for Update through InlineEdit. Shipra
    public Boolean blnRecordPresent{get; set;}
    //Holds value for the checkbox, which decides whether the Renewal Close Details & Renewal Closed Reason Action field be displayed. WR-259802
    public Boolean blnRenewals{get; set;}
    
    //***Constructor.***//
    public MassEditOppty(ApexPages.StandardSetController controller)
    {
        //Initializing the inlineEditWrapper.
        lstWrapper = new List<inlineEditWrapper>();
        //Getting the selected values(Records) in List.
        lstOppty = controller.getSelected();
        //Check if there  are any record selected for update.
        if(lstOppty!=null && lstOppty.size()>0)
        {
            //Setting blnRecordPresent to true , Save button show's of the VF page.
            blnRecordPresent=true;
            //Hold set of Id of records selected for update
            Set<id> setopptyId = new Set<Id>();
            //Loop on records to add Id to set.
            for(Opportunity oppty: lstOppty)
            {
                setopptyId.add(oppty.id);
            }
            //Query opportunity for fields used in Inline Edit.
            //Added Renewals Sales Stage to the list of fields for inline edit on Opportunity.
            lstOppty = new List<Opportunity>([Select name,id,stageName,account.name,IIG_Sales_Stage__c,Amount,Quote_Amount__c,
                                              Update_Forecast_Amount_from_Quote__c,Closed_Reason__c,CloseDate,Close_Comments__c,
                                              Next_Steps__c,Competitor__c,Product_Model__c,Secondary_Alliance_Partner__c,
                                              Primary_Alliance_Partner__c, Competitor_Product__c, Competitor_Lost_To__c,UIG_Engagement__c,Renewals_Sales_Stage__c,Renewals_Close_Details__c,Closed_Reason_Action__c from Opportunity where id in:setopptyId ]);
            
            //Loop on Queried Oppty's and add it to List Wrapper.
            for(Opportunity opptyWC: lstOppty)
            {
                inlineEditWrapper inlineWrap = new inlineEditWrapper(opptyWC,'');
                lstWrapper.add(inlineWrap); 
            }
        }
    }
    
    //*** Method called on Save button click.***//
    public PageReference customSave()
    {
        String retPage =ApexPages.currentPage().getUrl();
        intCountSaved=0;
        if(lstOppty != null && lstOppty.size() > 0)
        {
            //Update the records through Database.saveresult (Saving records which are Error free).
            Database.SaveResult[] inlineEdit = Database.update(lstOppty,false);
            //Calling getData method to track result of record update.
            getData(inlineEdit);
            //Calculate the successfully saved records.
            intCountSaved=lstOppty.size()-intCountError;
            //Check if there is no errored records set page reference to list view of oppty.
            if(intCountError<=0)
            {   
                // Setting Page Reference for Custom Save button.This returns to Previous page after Oppty Update. 
                retPage = ApexPages.currentPage().getParameters().get('retURL');
                pagerefs = new PageReference(retPage);
            }
            else
            {
                //if there exist some errored records send Message to VF apge that some records have errored out.
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,intCountSaved+' '+System.label.Inline_Edit_of+' '+lstOppty.size()+' '+System.Label.Inline_Edit_Result);
                //Add the message to VF page.
                ApexPages.addMessage(msg); 
            }
            //Returning the page reference.
            return pagerefs;
        }
        else
        {
            //Set page reference to null if no records are selected for update.
            pagerefs=null;
            return pagerefs;
        }
    }
    
    //*** Method called for tracking the result and adding it on the list wrapper.***//
    public void getData(Database.SaveResult[] inlineEdit)
    {   
        //Clearing out list wrapper.
        lstWrapper.clear();
        //Hold String for return Page url.
        pagerefs=null;
        //Initializing intCountError.
        intCountError=0;
        //Holds Value of error occured.
        String dataErrs = '';
        //Holds Value of Success Save.
        String dataSaves ='';
        //Check if Database.Saveresult has some records.
        if(inlineEdit !=null)
        {
            //Loop on Saveresult records.
            for (integer i = 0; i < inlineEdit.size(); i++) 
            {
                //Initializing dataErrs as blank for each result record.
                dataErrs ='';
                //Initializing dataSaves as blank for each result record.   
                dataSaves ='';
                //if the record has not saved successfully.
                if (!inlineEdit[i].isSuccess()) 
                {
                    //Looping on Database error for ith record.
                    for (Database.Error err : inlineEdit[i].getErrors()) 
                    {
                        //Adding error message in dataErrs.
                        dataErrs += err.getMessage();
                        //incrementing the error count.
                        intCountError = intCountError+1;
                    }
                    // Getting the opportunty record which has errored out.
                    Opportunity opptySuccess = lstOppty.get(i);
                    //Check if record is not null.
                    if(opptySuccess != null)
                    {   
                      //Add opportunity Name along with error message.
                      //dataErrs +=  ' For Opportunity : ' + opptySuccess.Name;
                    }
                    //Add error message along with Opportunity record to list wrapper.
                    lstWrapper.add(new inlineEditWrapper(opptySuccess,dataErrs));
                          
                }else
                {               
                    //if the record has saved successfully, get the saved opportunity record.
                    Opportunity opptySuccess = lstOppty.get(i);
                    //Check if record saved is not null.
                    if(opptySuccess!=null)
                    {
                        //Add Success message on dataSaves for successfully saved record.
                        dataSaves +=System.Label.Inline_Edit_Result_Success;
                    }
                    //Add Success message along with Opportunity record to list wrapper.
                    lstWrapper.add(new inlineEditWrapper(opptySuccess,dataSaves));
                }        
            }
        }
    }
    
    //*** Wrapper Class***//
    public class inlineEditWrapper
    {
        //Holds opportunity record. Defining get,set property.
        public Opportunity objOppty {get; set;}
        //Holds Error String. Defining get,set property.
        public String dmlError {get;set;}
        //Defining method with arguments (Opportunity, success message).
        inlineEditWrapper(Opportunity objOppty, String dmlError)
        {
            this.objOppty = objOppty;
            this.dmlError = dmlError;
        }
    }
}