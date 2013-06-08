/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER        DESCRIPTION                               

 |  ====          =========        =========== 

 |  15/11/2011   Shalabh Sharma    This class is used to map case attachments to related opportunity on case closure.   
 |  15/02/2012   Shalabh Sharma    Added method techDrawingDocsToAccount for req 5011
 |  22/02/2011   Shalabh Sharma    Updated the method caseAttachmentToOpportunity to post the case attachments on opportunity chatter.
 |  05/06/2012   Shalabh Sharma    Added query on FeedItem to fetch chattered attachments on Case
 +==================================================================================================================*/
public class Presales_CaseToOpportunityAttachment {
    static Boolean isAttached = false;
    static Boolean isPosted = false;
 /* @Method <This method execute is used to map case attachments to related opportunity on case closure>
@param <This method takes Map<Id,Case> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/  
    public void caseAttachmentToOpportunity(Map<Id,Case> mapCase){
        if(isAttached == false){
            Map<Id,Id> mapCaseOpportunity = new Map<Id,Id>();
            List<Attachment> lstAttachments = new List<Attachment>();
            List<FeedItem> lstChatteredAttachments = new List<FeedItem>();
            Map<Id,List<Attachment>> mapCaseAttachment = new Map<Id,List<Attachment>>();
            List<FeedItem> lstAttachmentOnOpportunity = new List<FeedItem>();
            List<Attachment> lstAttachmentToinsert = new List<Attachment>();
            List<Case> lstCase = new List<Case>();
            /*for(Case caseLoop:mapCase.values()){
                mapCaseOpportunity.put(caseLoop.Id,caseLoop.Opportunity_Name__c);   
            }*/
            //List<Case> caseLst = [Select id,Presales_Case_to_oppty_attachment__c from case where id in :mapCaseOpportunity.keyset()];
            for(Case cs :mapCase.values()){
                    cs.Presales_Case_to_oppty_attachment__c = true;
                    lstCase.add(cs);
                    
            }
            //system.debug('Presales_Case_to_oppty_attachment__c--->'+caseLst);            
            //system.debug('mapCaseOpportunity--->'+mapCaseOpportunity);
            if(mapCase!=null && mapCase.size()>0){
                lstAttachments = [select Id,Name,Body,ParentId from Attachment where ParentId in :mapCase.keyset()];
                lstChatteredAttachments = [Select Id,ContentData,ContentFileName,Body,ParentId from FeedItem where ParentId in :mapCase.keyset() AND Type ='ContentPost'];
                system.debug('lstAttachments--->'+lstAttachments);  
                system.debug('lstChatteredAttachments --->'+lstChatteredAttachments );
            }
            if(lstAttachments!=null && lstAttachments.size()>0){
                for(Attachment attachment:lstAttachments){
                    if(mapCaseAttachment.containsKey(attachment.ParentId)){
                        mapCaseAttachment.get(attachment.ParentId).add(attachment);
                    }
                    else{
                        List<Attachment> lstAttmt = new List<Attachment>();
                        lstAttmt.add(attachment);
                        mapCaseAttachment.put(attachment.ParentId,lstAttmt);    
                    }   
                }
                system.debug('mapCaseAttachment--->'+mapCaseAttachment);
            }
            if(mapCaseAttachment!=null && mapCaseAttachment.size()>0 || lstChatteredAttachments.size()>0){
                for(Id caseId:mapCaseAttachment.keyset()){
                    /*Attachment attach = new Attachment();         
                    attach.Body = mapCaseAttachment.get(caseId).Body;
                    attach.Name = mapCaseAttachment.get(caseId).Name;
                    attach.ParentId = mapCaseOpportunity.get(caseId);
                    system.debug('attach--->'+attach);
                    lstAttachmentToinsert.add(attach);*/
                    lstAttachmentToinsert = (mapCaseAttachment.get(caseId));
                    if(lstAttachmentToinsert.size()>0){
                        for(Attachment attmt:lstAttachmentToinsert){
                            FeedItem feed = new FeedItem();
                            feed.ContentData = attmt.Body;
                            feed.ParentId = mapCase.get(attmt.ParentId).Opportunity_Name__c;
                            feed.ContentFileName = attmt.Name;
                            //feed.Body= attmt.Name;
                            /*attach.Body = attmt.Body;
                            attach.Name = attmt.Name;*/
                            lstAttachmentOnOpportunity.add(feed);
                        }
                    }    
                }
                for(FeedItem feed:lstChatteredAttachments){
                    FeedItem feed1 = new FeedItem();
                    feed1.ContentData = feed.ContentData;
                    feed1.ParentId = mapCase.get(feed.ParentId).Opportunity_Name__c;
                    feed1.ContentFileName = feed.ContentFileName ; 
                    //feed1.Body= feed.Body;
                    lstAttachmentOnOpportunity.add(feed1);                   
                }
                 
            }
            system.debug('lstAttachmentToinsert--->'+lstAttachmentToinsert);
            system.debug('lstAttachmentOnOpportunity--->'+lstAttachmentOnOpportunity);
            
            if(lstAttachmentOnOpportunity!=null && lstAttachmentOnOpportunity.size()>0){
                insert lstAttachmentOnOpportunity;
                //update lstCase;
            }
        }
        isAttached = true;  
    }
 /* @Method <This method execute is used to map tech drawing case attachments to related account on case closure>
@param <This method takes Map<Id,Case> as parameter>
@return <void> - <Not returning anything>
@throws exception - <No Exception>
*/
    public void techDrawingDocsToAccount(Map<Id,Case> mapClosedCase){
        if(isPosted == false){
            Map<Id,Case> mapTechDrawingCase = new Map<Id,Case>();
            List<Attachment> lstAttachment = new List<Attachment>();
            List<FeedItem> lstChatteredAttachments = new List<FeedItem>();
            List<Attachment> lstAttachmentToinsert = new List<Attachment>();
            Map<Id,List<Attachment>> mapCaseAttachment = new Map<Id,List<Attachment>>();
            List<FeedItem> feedOnOppty = new List<FeedItem>();
            String recordTypeName = System.Label.Presales_TechnicalDrawing;
            Map<Id,RecordType> mapRecordType = new Map<Id,RecordType>([select id,Name from RecordType where sObjectType='Case' and Name = :recordTypeName]);
            for(Case caseRecord:mapClosedCase.values()){
                if(mapRecordType.containsKey(caseRecord.RecordTypeId)){
                    mapTechDrawingCase.put(caseRecord.Id,caseRecord);
                }   
            }
            if(mapTechDrawingCase.size()>0){
                
                for(Case caseRecord:mapTechDrawingCase.values()){
                    if(caseRecord.Customer_Account_Name__c==null && caseRecord.Opportunity_Name__r.AccountId ==null){
                        caseRecord.Is_Related_Account_null__c = true;   
                    } 
                    else {
                        caseRecord.Is_Related_Account_null__c = false;
                        
                        lstAttachment = [Select Id,Name,Body,ParentId from Attachment where ParentId in:mapTechDrawingCase.keyset()];
                        lstChatteredAttachments = [Select Id,ContentData,ContentFileName,Body,ParentId from FeedItem where ParentId in :mapTechDrawingCase.keyset() AND Type ='ContentPost'];
                    }  
                }
                if(lstAttachment.size()>0){
                    for(Attachment attachment:lstAttachment){
                        if(mapCaseAttachment.containsKey(attachment.ParentId)){
                            mapCaseAttachment.get(attachment.ParentId).add(attachment);
                        }
                        else{
                            List<Attachment> lstAttmt = new List<Attachment>();
                            lstAttmt.add(attachment);
                            mapCaseAttachment.put(attachment.ParentId,lstAttmt);    
                        }   
                    }
                    system.debug('mapCaseAttachment--->'+mapCaseAttachment);    
                }   
            }
            if(mapCaseAttachment.size()>0 || lstChatteredAttachments.size()>0){
                for(Id caseId:mapCaseAttachment.keyset()){
                    lstAttachmentToinsert = (mapCaseAttachment.get(caseId));
                    if(lstAttachmentToinsert.size()>0){
                        for(Attachment attmt:lstAttachmentToinsert){
                            if(attmt.Name.contains('TechD.')){
                                FeedItem feed = new FeedItem();
                                feed.ContentData = attmt.Body;
                                feed.ParentId = mapTechDrawingCase.get(attmt.ParentId).Customer_Account_Name__c;
                                //system.debug('attmt.Name.contains(techD)--->'+attmt.Name.contains(techD));
                                system.debug('attmt.Name--->'+attmt.Name);
                                feed.ContentFileName = attmt.Name;
                                mapTechDrawingCase.get(attmt.ParentId).Case_to_Account__c = true;
                                feedOnOppty.add(feed);
                            } 
                        }  
                    }   
                }
                for(FeedItem feed:lstChatteredAttachments){
                    if(feed.ContentFileName.contains('TechD.')){
                        FeedItem feed1 = new FeedItem();
                        feed1.ContentData = feed.ContentData;
                        feed1.ParentId = mapTechDrawingCase.get(feed.ParentId).Customer_Account_Name__c;
                        feed1.ContentFileName = feed.ContentFileName ; 
                        feedOnOppty.add(feed1); 
                    }                     
                }   
            }
            if(feedOnOppty.size()>0 && feedOnOppty!=null){
                insert feedOnOppty; 
            }
        }
        isPosted = true;        
    }
}