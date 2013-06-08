public class KB_SubmitArticleForApproval {
/*  @Method <This method execute is used to submit article for approval when article has 3 SRs linked>
@param <This method takes List<Linked_SR__c> as parameter>
@returns void- <not returning anything>
@throws exception - <No Exception>
*/
    public void submitArticleForApproval(List<Linked_SR__c> lstLinkedSR){
        Set<String> setArticleId = new Set<String>();
        Set<String> setArticleToApprove = new Set<String>();
        for(Linked_SR__c linkedSR: lstLinkedSR){
            setArticleId.add(linkedSR.Article_Number__c);   
        }
         system.debug('setArticleId--->'+setArticleId);
        List<Linked_SR__c> lstLinkedSRs = new List<Linked_SR__c>();
        Map<String,List<Linked_SR__c>> mapArticleLinkedSR = new Map<String,List<Linked_SR__c>>();
        system.debug('setArticleId---2>'+setArticleId);
        lstLinkedSRs = [Select Id,Name,Article_Number__c from Linked_SR__c where Article_Number__c in :setArticleId limit 100];
        for(Linked_SR__c linkedSR: lstLinkedSRs){
            if(mapArticleLinkedSR.containsKey(linkedSR.Article_Number__c)){
                mapArticleLinkedSR.get(linkedSR.Article_Number__c).add(linkedSR);   
            }
            else{
                List<Linked_SR__c> lstSR = new List<Linked_SR__c>();
                lstSR.add(linkedSR);
                mapArticleLinkedSR.put(linkedSR.Article_Number__c,lstSR);
            }
        }
        system.debug('mapArticleLinkedSR--->'+mapArticleLinkedSR);
        for(Linked_SR__c linkedSR: lstLinkedSR){
            if(mapArticleLinkedSR.containsKey(linkedSR.Article_Number__c) && mapArticleLinkedSR.get(linkedSR.Article_Number__c).size()==3){
                setArticleToApprove.add(linkedSR.Article_Version_ID__c);
            }
        }
        system.debug('setArticleToApprove--->'+setArticleToApprove);
        List<KnowledgeArticleVersion> lstArticleForApproval = new List<KnowledgeArticleVersion>();

        List<KnowledgeArticleVersion> lstDraftArticleVersion = [Select Id,KnowledgeArticleId, Title,ValidationStatus, PublishStatus,ArticleType from KnowledgeArticleVersion where
                                            id in:setArticleToApprove and ValidationStatus ='Work In Progress' and 
                                            PublishStatus = 'Draft' and Language = 'en_US'];

        List<KnowledgeArticleVersion> lstArticleVersion = [Select Id,KnowledgeArticleId, Title,ValidationStatus, PublishStatus,ArticleType from KnowledgeArticleVersion where
                                           id in:setArticleToApprove and ValidationStatus ='Work In Progress' and 
                                            PublishStatus = 'Online' and Language = 'en_US'];
        system.debug('lstArticleVersion--->'+lstArticleVersion);

        List<KB_Clone_Group__c> lstQueue =  KB_Clone_Group__c.getall().values();
        Set<String> setQueue = new Set<String>();
        Id[] setQueueMembers = new Id[]{};
        for(KB_Clone_Group__c clGrp:lstQueue){
            setQueue.add(clGrp.GroupName__c);
        }
        for(Group grpMem :[SELECT Id FROM Group where Name in :setQueue and Type='Queue']){
            setQueueMembers.add(grpMem.id);  
        }
        system.debug('setQueueMembers--->'+setQueueMembers);
        for(KnowledgeArticleVersion knowArtVer: lstArticleVersion){ 
            if(!(knowArtVer.ArticleType=='Restricted__kav')){
                String id = KbManagement.PublishingService.editOnlineArticle (knowArtVer.KnowledgeArticleId, true);
                system.debug('id--->'+id);
                KnowledgeArticleVersion knowArticleVersion = new KnowledgeArticleVersion();
                knowArticleVersion = [Select Id,ValidationStatus,ArticleType,KnowledgeArticleId from KnowledgeArticleVersion where Id=: id and PublishStatus = 'Draft' and Language = 'en_US'];
                          
                sObject sourceObj = getArticleRecord(knowArticleVersion.ArticleType,knowArticleVersion.Id);
                sourceObj.put('ValidationStatus','In Technical Review');
                sourceObj.put('Validation_Status_Updated__c','Yes');
                update sourceObj;

                //KbManagement.PublishingService.publishArticle(knowArticleVersion.KnowledgeArticleId, true);
                system.debug('knowArtVer--->'+knowArtVer);

                if(lstDraftArticleVersion.size()==0){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(knowArticleVersion.Id);
                    req1.setNextApproverIds(setQueueMembers);
                    // Submit the approval request
                    Approval.ProcessResult result = Approval.process(req1);
                }
            }
        }
    }
/* @Method <This method execute is used to fetch article records dynamically>
@param <This method takes Strings as parameter>
@returns sObject- <sObject>
@throws exception - <No Exception>
*/  
    public sObject getArticleRecord(String artType, String artId){
        String query = 'Select';
        String articleId = artId;
        String articleType = artType;
        sObject sourceObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;
        
        Schema.DescribeSObjectResult dsor = sourceObj.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
        List<String> lstFields = new List<String>();                
            for(String field : objectFields.keyset()){
                lstFields.add(field);
            }
            Integer counter = lstFields.size();
            for(String s :lstFields){              
                if(counter==lstFields.size())
                    query = query+' '+s;
                else
                    query = query+','+s;
                    counter--;
                    if(counter ==0)
                    {
                        query = query + ' from ' +articleType+ ' where id =\'' +articleId+'\'';                            
                    }
            }
            System.debug('query------>'+query);                               
            sourceObj = Database.query(query);
            return sourceObj;
    }
}