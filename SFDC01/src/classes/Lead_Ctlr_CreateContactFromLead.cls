/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |  20-JUL-09  S Douglas              Initial Creation - controller for page Lead_CreateContactFromLead
 |  01-SEP-09  S Douglas              Catch any errors which occur during contact writeback to lead and display on page
 |  10-Mar-11  Shipra Misra           WR-158373 Worked on march release.     
 |02/05/2013        Nimai Meher             Commented Title_Type__c & Type__c field as part of WR - 256428 (Contact simplification) for June Release.                         
 +===========================================================================*/
public class Lead_Ctlr_CreateContactFromLead {

    private final Lead theLead;
    private final ID STANDARD_CONTACT_RECTYPE;
    private Boolean dupsExist = false;
    private List<Contact> duplicateContacts = null;
    
    //Constructor - this only really matters if the autoRun function doesn't work right
    public Lead_Ctlr_CreateContactFromLead(ApexPages.StandardController stdController) {
        System.debug('Constructor');
        this.theLead = (Lead)stdController.getRecord();
        
        //Set the STANDARD_CONTACT_RECTYPE variable
        STANDARD_CONTACT_RECTYPE = [SELECT Id,name, description, sobjecttype, isactive from recordtype where Name = 'Standard' and SobjectType = 'Contact'].Id;
    }
    
    //Code to be invoked on page load.  Page Action calls this procedure 
    public PageReference autoRun() {

      String leadId;

      Savepoint sp = Database.setSavepoint();
      // Enclose all code in try/catch block - any validation errors will be caught and displayed on the error page
      try {

        system.debug('In autoRun');
        
        //Reset dupsExist
        this.dupsExist = false;

        String errorMessage = '';
        Boolean errorsExist = false;
        
        Boolean insertError = false;
        
        leadId = apexPages.currentPage().getParameters().get('id');
        Contact newContact;  //will hold created contact so we can redirect to it
        
        if (leadId == null) {
            
            //display the Visualforce page's content if no Id is passed
            errorsExist = true;
            errorMessage = System.Label.Lead_ID_NULL;
            ApexPages.Message missingID = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
            ApexPages.addMessage(missingID);
            return null;
        }
        else {
            
            //Querying for all fields we need, because theLead doesn't seem to have all populated
            /*Lead leadToConvert = [SELECT Id, LastName, FirstName, email, Related_Account__c,
                                    Description, DoNotCall, EmailBouncedDate, EmailBouncedReason, Fax,
                                    HasOptedOutOfEmail, HasOptedOutOfFax,
                                    Department__c, Role__c, related_contact__c,Aprimo_AudMem_ID__c,
                                    LeadSource, MobilePhone, Phone, Salutation, Title, Title_Type__c, Type__c,
                                    accept_lead__c
                                    FROM Lead WHERE id = :leadId ];
            */                        
            Lead leadToConvert = [SELECT Id, LastName, FirstName, email, Related_Account__c,
                                    Description, DoNotCall, EmailBouncedDate, EmailBouncedReason, Fax,
                                    HasOptedOutOfEmail, HasOptedOutOfFax,
                                    Department__c, Role__c, related_contact__c,Aprimo_AudMem_ID__c,
                                    LeadSource, MobilePhone, Phone, Salutation, Title,
                                    accept_lead__c
                                    FROM Lead WHERE id = :leadId ];
            
            //Perform validations
            
            /* Validation error will be caught in outer try/catch block
            //lead must be accepted
            if (!leadToConvert.accept_lead__c) {
                errorsExist = true;
                ApexPages.Message mustAccept = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LEAD_MustAccept);
                ApexPages.addMessage(mustAccept);
            }
            */
            
            //Required field validations
            
            //related account must not be null
            if (leadToConvert.related_account__c == null)
                errorMessage = errorMessage + (errorMessage.length()==0 ? '' : ', ') + Lead.Related_Account__c.getDescribe().getLabel();  

            //email must not be null
            if (leadToConvert.email == null || this.theLead.email.length() == 0)
                errorMessage = errorMessage + (errorMessage.length()==0 ? '' : ', ') + Lead.Email.getDescribe().getLabel(); 
    
            if (errorMessage.length() > 0) {
                errorsExist = true;
                errorMessage = System.Label.LEAD_ReqContactFieldsMissing + '  ' + errorMessage;
                ApexPages.Message fieldsMissing = new ApexPages.Message(ApexPages.Severity.ERROR, ErrorMessage);
                ApexPages.addMessage(fieldsMissing);
            }
            
            //If valications passed, create the contact from the lead 
            if (!errorsExist) {
                newContact = new Contact();
                newContact.RecordTypeId = STANDARD_CONTACT_RECTYPE;
                newContact.LastName = leadToConvert.LastName;
                newContact.FirstName = leadToConvert.FirstName;
                newContact.Email = leadToConvert.Email;
                newContact.AccountId = leadToConvert.related_account__c;
                newContact.active__c = true;
                newContact.Department__c = leadToConvert.Department__c;
                newContact.Description = leadToConvert.Description;
                newContact.DoNotCall = leadToConvert.DoNotCall;
                newContact.Aprimo_AudMem_ID__c = leadToConvert.Aprimo_AudMem_ID__c;
                //newContact.EmailBouncedDate = leadToConvert.EmailBouncedDate;
                //newContact.EmailBouncedReason = leadToConvert.EmailBouncedReason;
                //newContact.Fax = leadToConvert.Fax;
                newContact.HasOptedOutOfEmail = leadToConvert.HasOptedOutOfEmail;
                //newContact.HasOptedOutOfFax = leadToConvert.HasOptedOutOfFax;
                //newContact.LeadSource = leadToConvert.LeadSource;
                newContact.MobilePhone = leadToConvert.MobilePhone;
                newContact.Phone = leadToConvert.Phone;
                newContact.Role__c = leadToConvert.Role__c;
                newContact.Salutation = leadToConvert.Salutation;
                newContact.Title = leadToConvert.Title;
                //newContact.Title_Type__c = leadToConvert.Title_Type__c;
                //newContact.Type__c = leadToConvert.Type__c;
                try {
                    insert newContact;
                } catch (Exception e) {
                    //Don't add a message here because one has already been added due to trigger failure
                    insertError = true;
                }
            }
            
            //If an insert error occurred, retrieve duplicate contacts for display
            if (insertError) {
                duplicateContacts = CTCT_DuplicateInfo_WithSharing.getDuplicateContacts(leadToConvert.Email);
                if (duplicateContacts != null) {
                    if (duplicateContacts.size() > 0) {
                        dupsExist = true;
                    }
                }
            }
            
            //Redirect the user back to the new contact page, or display this page for errors
            if (errorsExist || insertError) {
                //Errors exist, display this page
                return null;
            }
            /* Does not work, because error will not be displayed
            else if (insertError) {
                //Insert errors, redirect to original page
                PageReference pageRef = new PageReference('/' + leadId);
                pageRef.setRedirect(true);
                return pageRef;
            }
            */
            else {
                //Update the related contact on the lead with the new contact id
                leadToConvert.related_contact__c = newContact.id;
                update leadToConvert;
                //No errors, redirect to new contact
                PageReference pageRef = new PageReference('/' + newContact.Id);
                pageRef.setRedirect(true);
                return pageRef;
            }

        } // leadId == null

      } catch (Exception e) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        Database.rollback(sp);
        return null;
      } 

    }
    
    
    public Boolean getDuplicateContactsExist() {
        return dupsExist;
    }
    public List<Contact> getDuplicateContacts() {
        return duplicateContacts;
    }
    
    
    
}