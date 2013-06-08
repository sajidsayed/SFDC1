@isTest (SeeAllData=true)
private class KB_Controller_TC {

    static testMethod  void kbController(){
        
        test.startTest();
                     
        Map<String,Id> idMap = new Map<String,Id>();
        Map<id,Id> idMap1 = new Map<id,Id>();
        List<Id> idList = new List<Id>();
        List<Linked_SR__C> listlinkedSR= new List<Linked_SR__C>();
        
        //ESA__kav breakfix = new ESA__kav();
        Break_Fix__kav breakfix = new Break_Fix__kav();
        breakfix.Title = 'Test Class Break Fix';
        breakfix.UrlName = 'Test-Class-Breakfix'; 
        breakfix.Language = 'en_US';
        breakfix.ValidationStatus = 'Work In Progress'; 
        breakfix.Audience__c ='Level 10 = Public';
        breakfix.Related_Articles__c='[ArticleLink Number=123456hhjhhhggkjghhjgghjg UrlName=abcdehjg]fghijjhfdzghzkdfgjhjhjhfjgklmno';       
        breakfix.Notes__c='][ArticleLink6hhjhhhggkjghhjgghjg UrlName=abcdehjgfghijjhfdzghzkdfgjhjhjhfjgklmno';  
         
     /////////////////////////////////////////////////////////////////////
        T3_Categories__c t3Parent = new T3_Categories__c();
        t3Parent.T3_ID__c='1111';
        t3Parent.Term_Type__c = 'Product';
        t3Parent .Parent_T3_ID__c = '1';
        
        insert t3Parent;
    
    
        List<T3_Categories__c> lstT3 = new List<T3_Categories__c>();
    
        for(Integer i=1 ; i<=2 ; i++){
        T3_Categories__c t3version = new T3_Categories__c();
        t3version.T3_ID__c = '1111'+i;
        //String.valueof(i);
        t3version.Term_Type__c = 'Version';
        t3version.Name = 'Testing Version'+i;  
        t3version.Parent_T3_ID__c=  t3Parent.T3_ID__c;
        
        lstT3.add(t3version);
    
        }
        insert lstT3;
        List<T3_Categories__c> lstT3New = new List<T3_Categories__c>();
    
        for(Integer i=1 ; i<=2 ; i++){
        T3_Categories__c t3versionNew = new T3_Categories__c();
        t3versionNew.T3_ID__c = '11112'+i;
        //String.valueof(i);
        t3versionNew.Term_Type__c = 'Version';
        t3versionNew.Name = 'Testing Version'+i;  
        t3versionNew.Parent_T3_ID__c= lstT3[1].T3_ID__C;
        
        lstT3New.add(t3versionNew);
    
        }
        insert lstT3New;
        
        
        breakfix.T3_Categories__c=lstT3[0].T3_ID__c+','+lstT3[1].T3_ID__c;
        breakfix.T3_Product__c=lstT3[0].Name+','+lstT3[1].Name;
        breakfix.T3_Version__c=t3Parent.Name+lstT3[0].Name+','+t3Parent.Name+lstT3[1].Name;
        
    
    /////////////////////////////////////////////////////////////////////
                
        insert breakfix;
        
        idMap.put('Break Fix',breakfix.id);
        idList.add(breakfix.id); 
                
        ETA__kav eta = new ETA__kav();
        eta.Title = 'Test Class eta_Controller';
        eta.UrlName = 'Test-Class-eta';
        eta.Language = 'en_US'  ;
        eta.Audience__c = 'Level 10 = Public'; 
        eta.Related_Articles__c='UrlName=abcdefghijjhfdzghzkdfgjhjhjhfjgklmno';       
        eta.Notes__c='[ArticleLink Number=12345]';
        eta.Environment__c = '[Art Number=22]';
        eta.Article_Metadata_Link__c= '[ArticleLink Number=12345]';
        eta.T3_Categories__c=lstT3[0].T3_ID__c+','+lstT3[1].T3_ID__c;
        eta.T3_Product__c=lstT3[0].Name+','+lstT3[1].Name;
        eta.T3_Version__c=t3Parent.Name+lstT3[0].Name+','+t3Parent.Name+lstT3[1].Name;
        insert eta;

        idMap.put('ETA',eta.id);
        idList.add(eta.id);
        
       /*
        How_To__kav glas = new How_To__kav();
        glas.Title = 'Test Class glas_Controller';
        glas.UrlName = 'Test-Class-glas';
        glas.Language = 'en_US'  ;
        breakfix.Audience__c = null;
        eta.Audience__c=null; 
        glas.Related_Articles__c='UrlName=abcdefghijjhfdzghzkdfgjhjhjhfjgklmno';       
        glas.Notes__c='[ArticleLink Number=12345]';
        glas.Environment__c = '[Art Number=22]';
        glas.T3_Categories__c=lstT3[0].T3_ID__c+','+lstT3[1].T3_ID__c;
        glas.T3_Product__c=lstT3[0].Name+','+lstT3[1].Name;
        glas.T3_Version__c=t3Parent.Name+lstT3[0].Name+','+t3Parent.Name+lstT3[1].Name;
        glas.Article_Metadata_Link__c= '[ArticleLink Number=12345]';
        
        insert glas;

        idMap.put('GLAS',glas.id);
        idList.add(glas.id);        
        */
        List<KnowledgeArticleVersion> kav= [SELECT id,ArticleType, KnowledgeArticleId,ArticleNumber,PublishStatus FROM KnowledgeArticleVersion WHERE  id in :idList  AND Language = 'en_US'];

        KbManagement.PublishingService.publishArticle(kav[0].KnowledgeArticleId, true);
        KbManagement.PublishingService.publishArticle(kav[1].KnowledgeArticleId, true);
        //KbManagement.PublishingService.publishArticle(kav[2].KnowledgeArticleId, true);


        eta = [Select KnowledgeArticleId,Originally_Created_By__c,T3_Categories__c, T3_Product__c,T3_Version__c,CreatedById,Title,UrlName,Language,Audience__c,Related_Articles__c,Notes__c,Environment__c,Article_Metadata_Link__c,ArticleNumber from ETA__kav where  id=:eta.id AND PublishStatus = 'online' AND Language = 'en_US'];
        breakfix = [Select KnowledgeArticleId,Originally_Created_By__c,T3_Categories__c, T3_Product__c,T3_Version__c,CreatedById,Title,UrlName,Language,Audience__c,Related_Articles__c,Notes__c,Environment__c,Article_Metadata_Link__c,ArticleNumber from Break_Fix__kav where  id=:breakfix.id AND PublishStatus = 'online' AND Language = 'en_US'];
        //glas=[Select KnowledgeArticleId,Originally_Created_By__c,CreatedById,T3_Categories__c, T3_Product__c,T3_Version__c,Title,UrlName,Language,Audience__c,Related_Articles__c,Notes__c,Environment__c,Article_Metadata_Link__c,ArticleNumber from How_to__kav where  id=:glas.id AND PublishStatus = 'online' AND Language = 'en_US'];
        System.debug('Audience__c--------->'+breakfix.Audience__c);
        Linked_SR__c linkedSR1= new Linked_SR__c();
        linkedSR1.Article_Number__c=kav[1].ArticleNumber;
        linkedSR1.Article_Solved_My_Problem__c=true;        
        linkedSR1.SR_Number__c=1234567;
        linkedSR1.Linking_User__c=UserInfo.getUserId();
        listlinkedSR.add(linkedSR1);
       insert linkedSR1;
     
       
        ApexPages.StandardController controllerstandard= new ApexPages.StandardController(eta);
        KB_Controller kbcontrollerstandard= new KB_Controller(controllerstandard);
        
        ApexPages.currentpage().getParameters().put('Id',kav[1].KnowledgeArticleId);
        
        ApexPages.KnowledgeArticleVersionStandardController controller = new ApexPages.KnowledgeArticleVersionStandardController(eta);  
        KB_Controller hwToObj1= new KB_Controller(controller);
      

    
        hwToObj1.linkingObj.SR_Number__c=1234567;
        hwToObj1.linkingObj.Article_Number__c=kav[1].ArticleNumber;
        hwToObj1.linkingObj.Article_Solved_My_Problem__c=true;
        hwToObj1.editSR();
        hwToObj1.saveSR(); 
        
        Article_Rating__c rateArttemp=new Article_Rating__c();
        rateArttemp.Raters_Email_Address__c='abcd@abcd.abcd';
        rateArttemp.Comments__c=  'ashdhsiahefhk';
        rateArttemp.Rating__c=15;
        rateArttemp.Solved_My_Problem__c=true;
        hwToObj1.rateArt=rateArttemp;
        
                          
       hwToObj1.rateArticle();
      // hwToObj1.saveSR();
        
        hwToObj1.linkingObj.Article_Number__c = breakfix.ArticleNumber;
        hwToObj1.reassingArticle();

        hwToObj1.linkingObj.SR_Number__c=999999999;
         hwToObj1.linkingObj.Article_Number__c=kav[1].ArticleNumber;

        hwToObj1.linkingObj.Article_Solved_My_Problem__c=true;
              hwToObj1.saveSR(); 

        hwToObj1.linkingObj.Article_Number__c = '999999999';
        hwToObj1.reassingArticle();
        
       hwToObj1.linkingObj.SR_Number__c=1234567;
       hwToObj1.linkingObj.Article_Number__c=kav[1].ArticleNumber;
            hwToObj1.linkingObj.Article_Solved_My_Problem__c=true;

      hwToObj1.saveSR(); 
     

        hwToObj1.linkingObj.SR_Number__c=null;
      hwToObj1.saveSR(); 
    
    //For Trigger Update
      linkedSR1.Linked__c = false;
      update linkedSR1;
        
         
   KB_Controller.insertArticle('Testing Clone eta',eta.id); 
        KB_Controller.insertArticle('- Testing Clone_eta',eta.id); 
        
        //Portal User Knowledge EMC Internal Portal User
        
        ID profileID_Emcinternal = [ Select id from Profile where name = 'Knowledge EMC Internal Portal User'].id;
        ID profileID_customerPortal = [ Select id from Profile where name = 'Knowledge Customer Portal User'].id;
        ID profileID_litePortal = [ Select id from Profile where name = 'Knowledge Lite Portal User'].id;
        ID profileID_partnerPortal = [ Select id from Profile where name = 'Knowledge Partner Portal User'].id;
        ID profileID_public = [ Select id from Profile where name = 'Knowledge Public User'].id;
        ID profileID_SEP = [ Select id from Profile where name = 'Knowledge Service Enabled Partner User'].id;
        
        
        Account A1 = new Account(Name = 'Test Account');
        insert A1;

                List<Contact> lstCont = new List<Contact>();

            for(Integer i=0;i<=5;i++){

             Contact contObj = new Contact();
             contObj.AccountID = A1.id;
              contObj.FirstName = 'TestFirst'+i;
              contObj.LastName = 'TestLast'+i; 
                contObj.email = 'sep.contact'+i+'@fakeemail.com';
            lstCont.add(contObj);

            }

            insert lstCont;
    
        //EMC Internal Portal
        User internalPortal_user = new User( email='test-user@fakeemail.com', contactid = lstCont[0].id, profileid = profileID_Emcinternal, UserName='test-user@fakeemail.com', alias='tuser1', CommunityNickName='tuser1', 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User' );
        insert internalPortal_user;
        
        
        System.runas(internalPortal_user){
        ApexPages.StandardController controllerstandard1= new ApexPages.StandardController(breakfix);
        KB_Controller kbcontrollerstandard1= new KB_Controller(controllerstandard);      
        ApexPages.KnowledgeArticleVersionStandardController controller1 = new ApexPages.KnowledgeArticleVersionStandardController(eta);  
        System.debug('Controller-------->'+controller1);
        KB_Controller hwToObj11= new KB_Controller(controller1); 
        }
        //End Of Internal Portal

        User customerPortal_user = new User( email='customer.contact@fakeemail.com', contactid = lstCont[1].id, profileid = profileID_customerPortal, UserName='customer.contact@fakeemail.com', alias='custuser', CommunityNickName='custuser', 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Customer', LastName = 'User' );
        insert customerPortal_user;
        
        
        System.runas(customerPortal_user){
        ApexPages.StandardController customerPortal_std= new ApexPages.StandardController(breakfix);
        KB_Controller controller_customerPortal= new KB_Controller(customerPortal_std);      
        ApexPages.KnowledgeArticleVersionStandardController customerPortal_kavController = new ApexPages.KnowledgeArticleVersionStandardController(eta);  
        KB_Controller hwToObj11= new KB_Controller(customerPortal_kavController); 

           
        ApexPages.currentpage().getParameters().put('Id',breakfix.KnowledgeArticleId);

        ApexPages.KnowledgeArticleVersionStandardController controller_break11 = new ApexPages.KnowledgeArticleVersionStandardController(breakfix);  
        KB_Controller kbController11= new KB_Controller(controller_break11);

        }
        //End Of Customer Portal


    
        User litePortal_user = new User( email='lite.contact@fakeemail.com', contactid = lstCont[2].id, profileid = profileID_litePortal, UserName='lite.contact@fakeemail.com', alias='liteuser', CommunityNickName='liteuser', 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Lite', LastName = 'User' );
        insert litePortal_user;
        
        
        System.runas(litePortal_user){
        ApexPages.StandardController litePortal_std= new ApexPages.StandardController(breakfix);
        KB_Controller controller_litePortal= new KB_Controller(litePortal_std);      
        ApexPages.KnowledgeArticleVersionStandardController litePortal_kavController = new ApexPages.KnowledgeArticleVersionStandardController(eta);  
        KB_Controller hwToObj11= new KB_Controller(litePortal_kavController); 

        }
        //Lite Portal

    
        User partnerPortal_user = new User( email='partner.contact@fakeemail.com', contactid = lstCont[3].id, profileid = profileID_partnerPortal, UserName='partner.contact@fakeemail.com', alias='partuser', CommunityNickName='partuser', 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Partner', LastName = 'User' );
        insert partnerPortal_user;
        
        
        System.runas(partnerPortal_user){
        ApexPages.StandardController litePortal_std= new ApexPages.StandardController(breakfix);
        KB_Controller controller_litePortal= new KB_Controller(litePortal_std);      
        //ApexPages.KnowledgeArticleVersionStandardController litePortal_kavController = new ApexPages.KnowledgeArticleVersionStandardController(eta);  
        //KB_Controller hwToObj11= new KB_Controller(litePortal_kavController); 

        }
        //Partner Portal

    
        User publicPortal_user = new User( email='public.contact@fakeemail.com', contactid = lstCont[4].id, profileid = profileID_public, UserName='public.contact@fakeemail.com', alias='pubuser', CommunityNickName='pubuser', 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Public', LastName = 'User' );
        insert publicPortal_user;
        
        
        System.runas(publicPortal_user){
        ApexPages.StandardController litePortal_std= new ApexPages.StandardController(breakfix);
        KB_Controller controller_litePortal= new KB_Controller(litePortal_std);      
        //ApexPages.KnowledgeArticleVersionStandardController litePortal_kavController = new ApexPages.KnowledgeArticleVersionStandardController(eta);  
        //KB_Controller hwToObj11= new KB_Controller(litePortal_kavController); 

        }
        //Public Portal

        
        User SEPPortal_user = new User( email='sep.contact@fakeemail.com', contactid = lstCont[5].id, profileid = profileID_SEP, UserName='sep.contact@fakeemail.com', alias='sepuser', CommunityNickName='sepuser', 
        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
        LanguageLocaleKey='en_US', FirstName = 'Public', LastName = 'User' );
        insert SEPPortal_user;
        
        
        System.runas(SEPPortal_user){
        ApexPages.StandardController litePortal_std= new ApexPages.StandardController(breakfix);
        KB_Controller controller_litePortal= new KB_Controller(litePortal_std);      
    //    ApexPages.KnowledgeArticleVersionStandardController litePortal_kavController = new ApexPages.KnowledgeArticleVersionStandardController(eta);  
    //    KB_Controller hwToObj11= new KB_Controller(litePortal_kavController); 

        }
        //SEP Portal
        
        //Portal User Knowledge EMC Internal Portal User ends here
       
       
        
        
        
        test.stopTest();
        
        }
        
}