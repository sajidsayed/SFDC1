@isTest (SeeAllData=true)
private class KB_SubmitArticleForApproval_TC {
  
    static testMethod  void submitArticleForApproval(){
        
        List<Id> idList= new List<Id>();
        Test.startTest();

        
        Break_Fix__kav brak = new Break_Fix__kav();
        brak.Title = 'Test Class Break Fix';
        brak.UrlName = 'Test-Class-Breakfix';    
        insert brak;
        idList.add(brak.id);

  
        
        Break_Fix__kav glas = new Break_Fix__kav();
        glas.Title = 'Test Class GLAS';
        glas.UrlName = 'Test-Class-GLAS';  
        glas.ValidationStatus = 'Work In Progress';
        glas.Language = 'en_US';
        insert glas;
        idList.add(glas.id);
        
        
        Break_Fix__kav glas1 = new Break_Fix__kav();
        glas1.Title = 'Test Class GLAS1';
        glas1.UrlName = 'Test-Class-GLAS1';  
        glas1.ValidationStatus = 'Work In Progress';
        glas1.Language = 'en_US';
        insert glas1;
        idList.add(glas1.id);
        

        
        List<Linked_SR__C> listlinkedSR= new List<Linked_SR__C>();
        
        
        KnowledgeArticleVersion kav= [SELECT id,Title,ArticleType,ValidationStatus,Language,KnowledgeArticleId,ArticleNumber,PublishStatus FROM KnowledgeArticleVersion WHERE Title = 'Test Class GLAS' and id in :idList ];
        system.debug('ArticleNumber---->'+kav.ArticleNumber);
        system.debug('ArticlePublishStatus----1>'+kav.PublishStatus);
        
        
        KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
        system.debug('ArticlePublishStatus----2>'+kav.PublishStatus);
        KnowledgeArticleVersion kav1= [SELECT id,Title,ArticleType,ValidationStatus,Language,KnowledgeArticleId,ArticleNumber,PublishStatus FROM KnowledgeArticleVersion WHERE Title = 'Test Class GLAS' and id in :idList ];
        system.debug('Article PublishStatus-----------------3>'+kav1.PublishStatus); 
        system.debug('ArticleNumber-----------------3>'+kav1.ArticleNumber); 
          
        Linked_SR__c linkedSR2= new Linked_SR__c();
        linkedSR2.Article_Number__c=kav1.ArticleNumber;
        linkedSR2.Article_ID__c=kav1.KnowledgeArticleId;
        linkedSR2.Article_Version_ID__c=kav1.id;
        linkedSR2.SR_Number__c=12345;
        
        insert linkedSR2;
        listlinkedSR.add(linkedSR2); 
        
        Linked_SR__c linkedSR5= new Linked_SR__c();
        linkedSR5.Article_Number__c=kav1.ArticleNumber;
        linkedSR5.Article_ID__c=kav1.KnowledgeArticleId;
        linkedSR5.Article_Version_ID__c=kav1.id;
        linkedSR5.SR_Number__c=123455;
        
        insert linkedSR5;
        listlinkedSR.add(linkedSR5);
        
        Linked_SR__c linkedSR6= new Linked_SR__c();
        linkedSR6.Article_Number__c=kav1.ArticleNumber;
        linkedSR6.Article_ID__c=kav1.KnowledgeArticleId;
        linkedSR6.Article_Version_ID__c=kav1.id;
        linkedSR6.SR_Number__c=1234566;
        
        insert linkedSR6;
        listlinkedSR.add(linkedSR6);
     
        KnowledgeArticleVersion kavv= [SELECT id,Title,ArticleType,ValidationStatus,Language,KnowledgeArticleId,ArticleNumber,PublishStatus FROM KnowledgeArticleVersion WHERE Title = 'Test Class GLAS1' and id in :idList ];
        system.debug('ArticleNumber---->'+kavv.ArticleNumber);
        system.debug('ArticlePublishStatus----21>'+kavv.PublishStatus);
        
        
        KbManagement.PublishingService.publishArticle(kavv.KnowledgeArticleId, true);
        system.debug('ArticlePublishStatus----22>'+kavv.PublishStatus);
        KnowledgeArticleVersion kavv1= [SELECT id,Title,ArticleType,ValidationStatus,Language,KnowledgeArticleId,ArticleNumber,PublishStatus FROM KnowledgeArticleVersion WHERE Title = 'Test Class GLAS1' and id in :idList ];
        system.debug('Article PublishStatus-----------------23>'+kavv1.PublishStatus); 
        system.debug('ArticleNumber-----------------23>'+kavv1.ArticleNumber); 
          
        Linked_SR__c linkedSR4= new Linked_SR__c();
        linkedSR4.Article_Number__c=kavv1.ArticleNumber;
        
        linkedSR4.Article_ID__c=kavv1.KnowledgeArticleId;
        linkedSR4.Article_Version_ID__c=kavv1.id;
        linkedSR4.SR_Number__c=12346;
        
        insert linkedSR4;
        listlinkedSR.add(linkedSR4); 
        
        
             
        
        
        
        //KB_SubmitArticleForApproval obj= new KB_SubmitArticleForApproval();
        //obj.submitArticleForApproval(listlinkedSR);
       
        Test.stopTest();

    }
    
    
}