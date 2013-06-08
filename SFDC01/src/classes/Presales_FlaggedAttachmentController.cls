/*===========================================================================+
 |  Created History                                                                  
                                                                 
 |  DATE       DEVELOPER  WORK REQUEST    DESCRIPTION                               
 |  ====       =========  ============    =========== 
 | 05-Oct-11   Deshpande, Medhavi         This controller is used to set RPQ Wiki Attachment on case object.
 |  
 |
 +===========================================================================*/

public with sharing class Presales_FlaggedAttachmentController{
//Our collection of the class/wrapper objects cAttachment
private final Case cas;
public List<cAttachment> AttachmentList {get; set;}
public map<Id, Id> processedAttachIds= new map<Id, Id>();
public map<Id, Boolean> processedWikis= new map<Id, Boolean>();
private list<RPQ_Wiki_Attachments__c> toBeProcessAttachList = new list<RPQ_Wiki_Attachments__c>();
public boolean chkFlag{get;set;}
//Constructor with parameter as Apex Standard Controller
public Presales_FlaggedAttachmentController(ApexPages.StandardController stdController) {
    this.cas = (Case)stdController.getRecord();
    chkFlag=false;
}

//This method uses a simple SOQL query to return a List of Attachments


public List<cAttachment> getAttachments() {
if(AttachmentList == null) {
    AttachmentList = new List<cAttachment>();
    //Iteration for RPQ wiki attachment object and adding those values in map
    for (RPQ_Wiki_Attachments__c p : [select Id, Attachment_Id__c,
         Case__c,Send_to_Wiki__c,Is_Processed__c from RPQ_Wiki_Attachments__c where Case__c = :cas.Id 
         and Send_to_Wiki__c =true limit 50]){
                processedAttachIds.put((ID)p.Attachment_Id__c,p.Id);
                processedWikis.put((ID)p.Attachment_Id__c,p.Is_Processed__c);
            }
 //Iteration for Attachment object and adding those values in cAttachment Object
for(Attachment c : [select Id, Name, ParentId, Description, ContentType 
                    from Attachment where ParentId = :cas.Id limit 50]) {

// As each Attachment is processed we create a new cAttachment object and add it to the AttachmentList
        cAttachment wAtt = new cAttachment(c);
        chkFlag=true;

// check if Attachment has already been processed

System.debug('Id--->'+processedAttachIds.get(c.Id) +'----'+c.Id);

    if(processedAttachIds.get(c.Id) != null){
        wAtt.WikiId = processedAttachIds.get(c.Id);
        wAtt.needsToBeProcessed = false;
        wAtt.selected=true;
        wAtt.Is_Processed=processedWikis.get(c.Id);
    }
    else{//wAtt.needsToBeProcessed = true;
    //   wAtt.selected=false;
        //wAtt.Is_Processed=true;
    }
        AttachmentList.add(wAtt);
  }
}
return AttachmentList;
}



//This method uses a simple SOQL query to return a List of Attachments
public List<cAttachment> getProcessedAttachments() {
    if(AttachmentList == null) {
        AttachmentList = new List<cAttachment>();
        for(Attachment c : [select Id, Name, ParentId, Description, ContentType from Attachment limit 50]) {
            // As each Attachment is processed we create a new cAttachmentobject and add it to the AttachmentList
            AttachmentList.add(new cAttachment(c));
            }
        }
    return AttachmentList;
}

public PageReference processSelected() {
    //We create a new list of Attachments that we be populated only with Attachments if they are selected
    List<Attachment> selectedAttachments = new List<Attachment>();
    //We will cycle through our list of cAttachments and will check to see if the selected property is set to true, if it is we add the Attachment to the selectedAttachments list
        for(cAttachment cAtt : getAttachments()) {
        
            if(cAtt.selected == true && cAtt.WikiId == null) {
                selectedAttachments.add(cAtt.att);
            }
            System.debug('cAtt.WikiId--->'+cAtt.WikiId +'---' +cAtt.selected);
        }

        System.debug('selectedAttachments--->'+selectedAttachments );
// Now we have our list of selected Attachments and can perform any type of logic we want, sending emails, updating a field on the Attachment, etc

    System.debug('These are the selected Attachments...');

    list<RPQ_Wiki_Attachments__c> rwaInsertList = new list<RPQ_Wiki_Attachments__c>();
    //Iteration for cAttachment returned from getAttachments method
    for(Attachment att : selectedAttachments) {
        system.debug(att);
        rwaInsertList.add(new
        RPQ_Wiki_Attachments__c(Attachment_Id__c=att.id, Case__c=att.parentId,
            Is_Processed__c=false,send_to_wiki__c=true));
    }
    if (!rwaInsertList.isEmpty()){
    try{
    //Updating or Inserting value in to RPQWiki and adding message to the Apex page
        upsert rwaInsertList;
        ApexPages.addmessage(new
        ApexPages.message(ApexPages.severity.Info,'Attachment have been uploaded to RPQ Wiki.'));
    }
    catch (DMLException e){
        throw e;
    } 
}
  //Creating a Redirect URL with case ID and redirecting the page URL to the new URL
  String RedirectUrl = '/' + cas.Id; 
System.debug('Case UTL--->'+RedirectUrl );
    PageReference newPage = new PageReference(RedirectUrl); 
    newPage.setRedirect(true);     
    return newPage;  
        
}


//Back to Case detail page
public PageReference cancelCase() {
    String RedirectUrl = '/' + cas.Id; 
    System.debug('Case UTL--->'+RedirectUrl );
    PageReference newPage = new PageReference(RedirectUrl); 
    newPage.setRedirect(true);     
    return newPage;  
}


// This is our wrapper/container class. A container class is a class, a data structure, or an abstract data type whose instances are collections of other objects. In this example a wrapper
//class contains both the standard salesforce object Attachment and a Boolean value

public class cAttachment {
public Attachment att {get; set;}
public Boolean needsToBeProcessed {get; set;}
public Boolean selected {get; set;}
public Boolean Is_Processed {get;set;}
public Id WikiId{get;set;}
//This is the contructor method. When we create a new cAttachment object we pass a Attachment that is set to the con property. We also set the selected value to false
public cAttachment(Attachment a) {
    att = a;
    selected = false;
  }
}

}