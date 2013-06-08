global class KB_Controller {
            
            // ArticleHelper Object is Naming Convention Used in Internal TOC VF Page
            // Upon Which This Solution is Modeled
            
            // While the internal structure of ArticleHelper is unknown, in this implementation it is defined as
            // ArticleHelper
            // ...defines one or more ArticleSections
            // ......defines zero or more ArticleFields
            
             public ArticleHelper articleHelper {get;set;}
             public transient sObject article {get;set;}
             public List<Linked_SR__c> lstLink{get; set;}
             public String articleNo{get;set;}
             public Linked_SR__c linkingObj {get; set;}
             public String articleType;
             public String artType;

            //Fields For Linking
            public String reassignedArticle {get; set;}
            public String outText {get ; set;}
            public String originallyCreated {get; set;}

            //Rendering Fields
            public Boolean reAssign {get; set;}
            public Boolean dupSR {get; set;}
            public Boolean renderLinkTab {get; set;}
            public Boolean renderLinkSection {get; set;}
            public Boolean renderreAssign {get; set;}
            public Boolean renderClone{get; set;}
            public Boolean isPortal{get; set;}
            public Boolean showArticle{get; set;}
            public Boolean hideArticle{get; set;}
            public Boolean isKCS{get; set;}
            public Boolean isInternal{get; set;}
            public Boolean showAttachInternal{get; set;}

            //Rating Fields
              public String artNo{get;set;}
              public Article_Rating__c rateArt {get; set;}
              public String rating{get;set;}
              public boolean insertRating{get; set;}
              public Integer noOfSRs {get; set;}
              public String knowArtID;
              public String knowArtVerID;
              public String artTitle;

            //Clonning Fields

            public String inputTitle {get; set;}
           // public static String artType;
            public static sObject statObj;
            public static String url {get; set;}
            
            //Bug Tracking Fields
            public List<OPT_Bug__c> lstBug {get; set;}
            public OPT_Bug__c bugObj  {get; set;}
            public String bugURL {get; set;}

            //Article-to-Article Linking Fields
            private Boolean bEnableActiveContent;

            //Security Model

            public String audience{get; set;}

            //Legal Section

            public Map<String,KB_Legal_Text__c> mapLegal{get; set;}
            public String legalText{get; set;}
            public Integer totalSR{get; set;}

            // T3 Name

            public String t3Name{get; set;}
            

            
            

            

            
            public Class ArticleField {
                Public String label {get; set;}
                Public Object value {get; set;} // Use of Object type is essential here to simplify
                                                // field rendering in page (no need to convert native datatype)
                
                Public ArticleField (sObject article, Schema.FieldSetMember fieldSetMember, Set<String> setField) {
                    String val = String.valueof(fieldSetMember.getFieldPath());
                    if(setField.contains(val)){
                    label = fieldSetMember.getLabel();
                    value = article.get(fieldSetMember.getFieldPath());
                    }
                    
                }
            }

            public Class ArticleSection {
                Public String label {get; set;}
                Public List <ArticleField> fields {get; set;}

                Public ArticleSection (sObject article, String sectionName, Set<String> setField) {
                    fields = new List <ArticleField>();

                    Map<String, Schema.FieldSet> fieldSetMap = article.getSobjectType().getDescribe().fieldsets.getMap();
                    Schema.FieldSet fieldSet = fieldSetMap.get(sectionName);
                    
                    if (fieldSet != null) {
                        label = fieldSet.getLabel();
                        List <Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
                        
                        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
                            ArticleField articleField = new ArticleField(article, fieldSetMember,setField);
                            if (articleField != null) fields.add(articleField);
                        }
                    } else {
                        label = sectionName; // If section does not have a defined Field Set
                                             // then custom coding is required in VF page
                                             // to render proper contents
                    }            
                }
            }    
            
            Public class ArticleHelper {
                Public List<ArticleSection> sections {get;set;}
                Public Boolean hasMultipleSections {get; set;}
                Public Boolean isPopup {get; set;}
                
                // Declare any fields that you need to reference by name in the VF page here
                Public String title {get;set;}
                
                Public ArticleHelper (sObject article, String sectionList, Set<String> setField) {
                    sections = new List<ArticleSection>();
                    
                    List<String> sectionNames = new List<String>();
                    sectionNames = sectionList.split(',');
                    
                    if (sectionNames.size() > 1) hasMultipleSections = true;
                        else hasMultipleSections = false;
                        
                    String qsPopup = ApexPages.currentPage().getParameters().get('popup');
                    if (qsPopup != null && qsPopup.equalsIgnoreCase('true'))
                         isPopup = true; else isPopup = false;
                    
                    // Method to retrieve field value by name from a generic sObject
                    title = (String)article.get('Title');                

                    for (String sectionName : sectionNames) {  
                        ArticleSection newSection = new ArticleSection(article, sectionName,setField);
                        if(newSection != null) sections.add(newSection);
                    }
                }    
            }
            
            
            //Controller

             public KB_Controller(ApexPages.StandardController controller) {
                         artNo= ApexPages.currentPage().getParameters().get('articleNo');
                         originallyCreated= ApexPages.currentPage().getParameters().get('orgCreate');
                         artTitle = ApexPages.currentPage().getParameters().get('artTitle');
              
                         
                     rateArt = new Article_Rating__c();

              


                }

            
            Public KB_Controller (ApexPages.KnowledgeArticleVersionStandardController controller) {
            
           
             //Security Model
                showArticle = true;
                hideArticle = false;

            //Number OF SRS
                noOfSRs = 0;

            //Show/Hide Internal Attachment
            showAttachInternal = true;

              //Clonning Starts Here
              renderClone = true;
       
            Map<String,KB_Profiles__c> mapCustProfiles = KB_Profiles__c.getall();
            Set<String> setProfile = new Set<String>();

              for(KB_Profiles__c cskProfile:mapCustProfiles.values()){
                setProfile.add(cskProfile.Profile_Name__c);
            }
            //Logic For Clonning Ends Here





              //Logic to hide Reassign SRs button for profiles other than Knowledge KCS User
              //Logic for Knowledge Read only clone button restriction
              //Logic for Partner profile same is used below in constructor in portal section
            Map<Id,Profile> mapProfile = new Map<Id,Profile>([Select Id,name from Profile where Name in:setProfile OR Name like 'System Admin%']);
            Boolean portalUser = false;
            if(mapProfile.containsKey(UserInfo.getProfileId())){
                  
                          
                  if((mapCustProfiles.containsKey(mapProfile.get(UserInfo.getProfileId()).name)) &&  (mapCustProfiles.get(mapProfile.get(UserInfo.getProfileId()).name).RestrictClone__c))
                        renderClone = false;
                  else
                      isKCS = true;
                  if((mapCustProfiles.containsKey(mapProfile.get(UserInfo.getProfileId()).name)) &&  (mapCustProfiles.get(mapProfile.get(UserInfo.getProfileId()).name).Profile_Level__c!=null)){

                        portalUser = true;

                  }
            }


                   
            //Logic For taking Article Type Dynamically 

               String articleId= ApexPages.currentPage().getParameters().get('id');
               system.debug('articleId--->'+articleId);
               Map<String,String> describeMap = new Map<String , String>();
               Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
               Set<String> keySet = gd.keySet();
               
                for (String key : keySet) {
                    Schema.SObjectType objectType = gd.get(key);
                    if (key.endsWith('ka') || key.endsWith('kb')) {
                        describeMap.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getLabel());
                    }
                }

               
                articleId = articleId.substring(0,3);
                Set<String> keySet1 = describeMap.keySet();
                for(String key: keySet1) {
                    if(articleId.equalsIgnoreCase(key)) {
                        articleType = describeMap.get(key);
                        artType = articleType;
                        
                    }
                }

                artType = articleType;

                articleType = articleType.replace(' ','_')+'__kav';
            


                sObject sObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;


                //Logic For taking All the fields related to Article

                    
                 Schema.DescribeSObjectResult dsor = sObj.getSobjectType().getDescribe();
                 Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
                 List<String> lstFields = new List<String>();
                 Set<String> setField = new Set<String>();
                 List<String> lstRTAFields = new List<String>();
              

                 // Enable dynamic Article-to-Article Links
                 bEnableActiveContent = true;
                    
                     for(Schema.SObjectField field : objectFields.values()){
                         Schema.DescribeFieldResult fieldResult = field.getDescribe();
                    
                        if(fieldResult.isAccessible()){
                            System.debug('Field--------->'+fieldResult.getName());
                            setField.add(fieldResult.getName());
                            lstFields.add(fieldResult.getName());
                         if (((fieldResult.getType() == Schema.DisplayType.TEXTAREA)&& (fieldResult.isHtmlFormatted())) || (fieldResult.getName()).equalsIgnoreCase('Related_Articles__c')) {
                        lstRTAFields.add(fieldResult.getName());
                        System.debug('RTA Check - fieldResult.getName()--->'+fieldResult.getName());
                        
                         }
                        }
                        }

        //Dynamic Logic Ends Here
              
                   
                    if (!Test.isRunningTest()){
                     controller.addFields(lstFields);
                    }
                     article = controller.getRecord();
                    // statObj = article.clone();
                     articleNo = (String)article.get('ArticleNumber');

                    
                     knowArtID = (String)article.get('KnowledgeArticleId');
                      knowArtVerID = (String)article.get('id');
                     if(setField.contains('Originally_Created_By__c')){
                     originallyCreated = (String)article.get('CreatedById');
                     }
                      if(setField.contains('Audience__c')){
                     audience= (String)article.get('Audience__c');
                      }
                     System.debug('etaObj12345------>'+audience);

                
                   
                // Start logic for active content transformation (Article-to-Article Links)
                if (bEnableActiveContent) {
                    for (String strRTAFieldName : lstRTAFields) {
                        String strRTAFieldValue = (String)article.get(strRTAFieldName);
                                                 
                        if (strRTAFieldValue != null && strRTAFieldValue.length() >= 10) {

                            Integer nArticleLinkStartTag = 0;
                            Integer nArticleLinkEndTag = 0;                            
                            Integer nArticleLinkNumberTag = 0;
                            Integer nArticleLinkUrlNameTag = 0;  
                            Integer nArticleLinkTokenTag = 0;                             
                            
                            String sQuery = '';
                            String strArticleNumber = '';
                            String strArticleUrlName = '';
                            String strArticleType = '';
                            String strArticleUrl = '';
                            String strArticleTitle = '';
                            String strUrlName = '';
                            String strTransformedRelatedArticles = '';
                            
                            Boolean bValidParameter = false;                              
                            
                            nArticleLinkStartTag = strRTAFieldValue.indexOf('[ArticleLink');
                           
                            while (nArticleLinkStartTag >= 0) {
                                nArticleLinkUrlNameTag = strRTAFieldValue.indexOf('UrlName=',nArticleLinkStartTag+12);
                                nArticleLinkNumberTag  = strRTAFieldValue.indexOf('Number=',nArticleLinkStartTag+12);  
                                nArticleLinkEndTag     = strRTAFieldValue.indexOf(']',nArticleLinkStartTag+12);                              
                                bValidParameter = false; 
                                                     
                                // Validate token existence and relationship to tag closing bracket
                                nArticleLinkTokenTag = 0;
                                strUrlName = '';
                                strArticleNumber = '';
                                
                                if (nArticleLinkUrlNameTag > 0 && nArticleLinkUrlNameTag < nArticleLinkEndTag) {
                                    nArticleLinkTokenTag = nArticleLinkUrlNameTag + 8;
                                    strUrlName = strRTAFieldValue.substring(nArticleLinkTokenTag, nArticleLinkEndTag).trim();
                                    
                                    sQuery = '';
                                    sQuery = sQuery + 'SELECT UrlName, ArticleType, Title ';
                                    sQuery = sQuery + ' FROM KnowledgeArticleVersion ' ;
                                    sQuery = sQuery + ' WHERE UrlName = :strUrlName AND PublishStatus = \'online\' AND Language = \'en_US\' ';                        
                                    
                                    bValidParameter = true; 
                                }
                                if (nArticleLinkNumberTag  > 0 && nArticleLinkNumberTag  < nArticleLinkEndTag) {
                                    nArticleLinkTokenTag = nArticleLinkNumberTag + 7;
                                    strArticleNumber = '000000000'+strRTAFieldValue.substring(nArticleLinkTokenTag, nArticleLinkEndTag).trim();
                                    strArticleNumber = strArticleNumber.right(9);

                                    sQuery = '';
                                    sQuery = sQuery + 'SELECT UrlName, ArticleType, Title ';
                                    sQuery = sQuery + ' FROM KnowledgeArticleVersion ' ;
                                    sQuery = sQuery + ' WHERE ArticleNumber = :strArticleNumber AND PublishStatus = \'online\' AND Language = \'en_US\' ';                        

                                    bValidParameter = true;                                
                                }
                                if (bValidParameter) {
                                    List <KnowledgeArticleVersion> listKAV = Database.query(sQuery);
                                    if (listKAV != null && listKAV.size() == 1) {
                                        KnowledgeArticleVersion articleKAV = listKAV[0];
                                        strArticleUrlName = articleKAV.UrlName;
                                        strArticleType = articleKAV.ArticleType.replace('__kav','');
                                        strArticleTitle = articleKAV.Title;
                                        strArticleUrl = '<a href=\'/articles/'+strArticleType+'/'+strArticleUrlName+'\' target=\'_blank\' ><u>'+strArticleTitle+'</u></a>';
                                        
                                            strTransformedRelatedArticles = strRTAFieldValue.substring(0,nArticleLinkStartTag)
                                                + strArticleUrl + strRTAFieldValue.substring(nArticleLinkEndTag+1);
                                            article.put(strRTAFieldName, strTransformedRelatedArticles ); 
                                    } else {
                                        // Article UrlName/Number is either invalid or not published
                                        // For now, replace link with warning message
                                        if (strUrlName != '') {
                                            strArticleUrl = '[Link Error:UrlName "'+strUrlName+'" not found]';
                                        }
                                        if (strArticleNumber != '') {
                                            strArticleUrl = '[Link Error:Article Number '+strArticleNumber+' not found]';
                                        }                                        
    
                                        strTransformedRelatedArticles = strRTAFieldValue.substring(0,nArticleLinkStartTag)
                                            + strArticleUrl + strRTAFieldValue.substring(nArticleLinkEndTag+1);
                                        article.put(strRTAFieldName, strTransformedRelatedArticles); 
                                    }
                                } else {
                                    // Error in syntax, modify markup to flag as such
                                    strTransformedRelatedArticles = strRTAFieldValue.substring(0,nArticleLinkStartTag) + '[Syntax Error:ArticleLink'
                                        + strRTAFieldValue.substring(nArticleLinkStartTag+12);
                                    article.put(strRTAFieldName, strTransformedRelatedArticles ); 
                                }

                                // Move past the current [ArticleLink tag (which has already been transformed) and start looking for another
                                strRTAFieldValue = strTransformedRelatedArticles;                               
                                nArticleLinkStartTag = strRTAFieldValue.indexOf('[ArticleLink');                          
                            }
                        }
                    }
                }
                // End custom logic for active content transformation (Article-to-Article Links)

                //Bug Tracking Number
                    bugObj = new OPT_Bug__c();
                    try{
                  bugObj = [Select Bug_Tracking_Number__c,Bug_Tracking_URL__c from OPT_Bug__c where Article_Number__c =:articleNo limit 1];
                //  bugURL = bugObj.Bug_Tracking_URL__c;
                    }catch(Exception ex){
                        //bugURL='';
                    }

                //End Of Bug Tracking Number

                   //Logic for Linking

                        lstLink = new List<Linked_SR__c>();


                        
                          linkingObj = new Linked_SR__c();

                    
                 lstLink = [Select Article_Number__c,Name,SR_Number__c,Linked__c,Article_Solved_My_Problem__c,Linking_User__c,Linked_Date_Time__c from Linked_SR__c where Article_Number__c =:articleNo order by LastModifiedDate desc limit 10];
                
                 totalSR = [Select count() from Linked_SR__c where Article_Number__c =:articleNo limit 5000 ];

            
                    if(lstLink.size()==0){
                     renderLinkTab = false;
                     renderLinkSection = true;
                    }

                    else{
                      renderLinkTab = true;
                     renderLinkSection = false;
                     noOfSRs = lstLink.size();
                    }

                    //End of Linking Section

                            
                
                    // Portal User Logic Security Model and TOC sections
                    Boolean hideSr = false;

                    if(portalUser){
                        System.debug('inside ifffffffff---->' +mapCustProfiles.get(mapProfile.get(UserInfo.getProfileId()).name).Profile_Level__c);
                        if(audience!=null){
                                if(mapCustProfiles.get(mapProfile.get(UserInfo.getProfileId()).name).Profile_Level__c==1 &&(audience==Label.CSK_Level10)){
                                    System.debug('inside 1---->');
                                    showArticle = true;
                                    hideArticle = false;
                                    hideSr = true;
                                    isPortal = true;
                                    showAttachInternal = false;
                                    
                                }
                                else if(mapCustProfiles.get(mapProfile.get(UserInfo.getProfileId()).name).Profile_Level__c==2 &&(audience==Label.CSK_Level10 ||audience==Label.CSK_Level20)){
                                    System.debug('inside 2---->');
                                    showArticle = true;
                                    hideArticle = false;
                                    hideSr = true;
                                    isPortal = true;
                                    showAttachInternal= false;

                                }
                                else if(mapCustProfiles.get(mapProfile.get(UserInfo.getProfileId()).name).Profile_Level__c==3 &&(audience==Label.CSK_Level10 ||audience==Label.CSK_Level20 || audience==Label.CSK_Level30)){
                                    System.debug('inside 3---->');
                                    showArticle = true;
                                    hideArticle = false;
                                    hideSr = true;
                                    isPortal = true;
                                    showAttachInternal = false;

                                }
                                else if(mapCustProfiles.get(mapProfile.get(UserInfo.getProfileId()).name).Profile_Level__c==4 &&(audience==Label.CSK_Level10 ||audience==Label.CSK_Level20 || audience==Label.CSK_Level30)){
                                    System.debug('inside 4---->');
                                    showArticle = true;
                                    hideArticle = false;
                                    hideSr = true;
                                    isPortal = true;
                                    showAttachInternal = false;

                                }
                                else if(mapCustProfiles.get(mapProfile.get(UserInfo.getProfileId()).name).Profile_Level__c==5 &&(audience==Label.CSK_Level10 ||audience==Label.CSK_Level20 || audience==Label.CSK_Level30 || audience==Label.CSK_Level40 )){
                                    System.debug('inside 5---->');
                                    showArticle = true;
                                    hideArticle = false;
                                    isPortal = false;
                                    showAttachInternal = true;

                                }
                                else if(mapCustProfiles.get(mapProfile.get(UserInfo.getProfileId()).name).Profile_Level__c==6){
                                    System.debug('inside 6---->');
                                    showArticle = true;
                                    hideArticle = false;
                                    isPortal = false;
                                    showAttachInternal = true;

                                }
                                //Need to check on this logic
                                else {
                                    System.debug('inside else---->');
                                    showArticle = false;
                                    hideArticle = true;
                                    isPortal = false;
    
                                }

                        }

                        
                        if(artType.equalsIgnoreCase('ETA') || artType.equalsIgnoreCase('ESA')){
                                if(artType.equalsIgnoreCase('ETA')){
                                    
                                    isInternal = false;
                                }
                                if(hideSr){
                                String sectionNames = 'Knowledge_Statement,Attachments,Article_Metadata,Legal Information';
                                articleHelper = new ArticleHelper(article, sectionNames ,setField);
                                } 
                                else{
                                String sectionNames = 'Knowledge_Statement,Attachments,Article_Metadata,SR Linking,Legal Information';
                                articleHelper = new ArticleHelper(article, sectionNames ,setField);
                                } 
                        }
                        else{
                                if(hideSr){
                                String sectionNames = 'Knowledge_Statement,Attachments,Article_Metadata';
                                articleHelper = new ArticleHelper(article, sectionNames ,setField);
                                } 
                                else{
                                String sectionNames = 'Knowledge_Statement,Attachments,Article_Metadata,SR Linking';
                                articleHelper = new ArticleHelper(article, sectionNames ,setField);
                                }
                        }
                    }

                    //Portal User Logic Ends

                // Internal User Logic

                    else{
                    isPortal = true;
                    System.debug('article type--------->'+artType);
                    if(artType.equalsIgnoreCase('ETA') || artType.equalsIgnoreCase('ESA')){
                    String sectionNames = 'Authoring_Notes,Knowledge_Statement,Attachments,Article_Metadata,SR Linking,Legal Information';
                    articleHelper = new ArticleHelper(article, sectionNames ,setField);
                        if(artType.equalsIgnoreCase('ETA')){
                            
                              isInternal = true;
                             
                        }
                     
                    }

                    else{
                    String sectionNames = 'Authoring_Notes,Knowledge_Statement,Attachments,Article_Metadata,SR Linking';
                    articleHelper = new ArticleHelper(article, sectionNames ,setField);

                    }
                    }
                    // Internal User Logic Ends

                    //Logic For Taking T3 Name at runtime 

                        String description =  '';
                       String t3ID =  '';
                       String  prod = '';
                         List<String> descLst = new List<String>();
                         List<String> t3idLst = new List<String>();
                         List<String> prodLst = new List<String>();


                     System.debug('setField----------->'+setField);
                     if(setField.contains('T3_Product__c') && setField.contains('T3_Categories__c') && setField.contains('T3_Version__c')){

                        description = (String)article.get('T3_Product__c');
                        t3ID =  (String)article.get('T3_Categories__c');
                        prod = (String)article.get('T3_Version__c'); 
                    
                     }
            System.debug('article type---->'+article);
            System.debug('description---->'+description);
        
                     if(description!=null && t3ID!=null && prod!=null ){
            descLst = description.split(',');
            t3idLst = t3ID.split(',');
            prodLst = prod.split(',');

            System.debug('t3idLst---->'+t3idLst);

            Integer totalProd = t3idLst.size();

        
            for (Integer i=0;i<totalProd ; i++ )
            {
                prod = prod+t3idLst[i]+'-'+descLst[i]+'-'+prodLst[i] + ',';
            //  prod = prod+t33obj.T3_ID__c+'-'+t33obj.name+',';

            }
            }
            else{
                prod = '';

            }

            t3Name = '';

            Map<String,List<T3_Categories__c>> mapFirstT3 = new Map<String,List<T3_Categories__c>>();
            Map<String,T3_Categories__c> mapSecondT3 = new Map<String,T3_Categories__c>();
            Map<String,T3_Categories__c> mapThirdT3 = new Map<String,T3_Categories__c>();
                
            List<T3_Categories__c> lstT3ids1 =[Select id,Term_Type__c,Parent_T3_ID__c,name,T3_ID__c from T3_Categories__c where T3_ID__c in :t3idLst];
        


            for(T3_Categories__c obj1 :lstT3ids1){
                    
                    if(mapFirstT3.containskey(obj1.Parent_T3_ID__c)){
                        mapFirstT3.get(obj1.Parent_T3_ID__c).add(obj1);

                    }
                    else{
                        List<T3_Categories__c> lstT3= new List<T3_Categories__c>();
                        lstT3.add(obj1);
                        mapFirstT3.put(obj1.Parent_T3_ID__c , lstT3);


                    }

                    

            }

            List<T3_Categories__c> lstT3ids2 =  [Select id,Term_Type__c,Parent_T3_ID__c,name,T3_ID__c from T3_Categories__c where T3_ID__c in :mapFirstT3.keyset()];
            Set<String> setParent = new Set<String>();

                for(T3_Categories__c obj2 :lstT3ids2){
                    
                    mapSecondT3.put(obj2.T3_ID__c , obj2);
                    setParent.add(obj2.Parent_T3_ID__c);
                    
                    

            }

            


            List<T3_Categories__c> lstT3ids3 =  [Select id,Term_Type__c,Parent_T3_ID__c,name,T3_ID__c from T3_Categories__c where T3_ID__c in :setParent];
            
            

            for(T3_Categories__c obj3 :lstT3ids3){
                    
                    mapThirdT3.put(obj3.T3_ID__c , obj3);

                    

            }

            

            for(String keyParent : mapFirstT3.keyset()){

            for(T3_Categories__c t3Obj : mapFirstT3.get(keyParent)){

                    if(t3Obj.Term_Type__c=='Product'){
                            t3Name = t3Name+t3Obj.name+',';

                    }

                    else{
                        if(mapSecondT3.get(t3Obj.Parent_T3_ID__c).Term_Type__c=='Product'){

                            t3Name = t3Name+ mapSecondT3.get(t3Obj.Parent_T3_ID__c).name+' '+t3Obj.name +',';

                        }
                        else{
                            t3Name = t3Name +  mapThirdT3.get(mapSecondT3.get(t3Obj.Parent_T3_ID__c).Parent_T3_ID__c).name +' ' + t3Obj.name +',';

                        }
                        
                    }

                
            }
            }
            t3Name = t3Name.removeend(',');
            System.debug('displayedProduct---->'+t3Name);
              
            // End of T3 at Runtime
            
            }


         //Logic  for SR linking Starts Here  

        public PageReference saveSR(){
              // KnowledgeArticleVersion x = [SELECT id,ArticleNumber, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' and Language = 'en_US' and KnowledgeArticleId=:articleid ];
                List<Linked_SR__c> srList = new List<Linked_SR__c>();
                dupSR = false;
                reAssign=false;

                Boolean solvedChk = linkingObj.Article_Solved_My_Problem__c;
                
                
                
                srList = [Select Article_Number__c,Name,SR_Number__c,Linked__c,Article_Solved_My_Problem__c,Linking_User__c,Linked_Date_Time__c from Linked_SR__c where Article_Number__c =:articleNo and SR_Number__c=:linkingObj.SR_Number__c];

                if(linkingObj.SR_Number__c==null){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'SR Number cannot be left blank' );
                    ApexPages.addmessage(myMsg);
                    dupSR = true;
                    return null;
                }

                if(srList.size()>0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'SR Number Already Exist' );
                    ApexPages.addmessage(myMsg);
                    dupSR = true;
                    reAssign=false;
                    return null;
                }

                else if(solvedChk){
                    srList.clear();
                    srList = [Select Article_Number__c,Name,SR_Number__c,Linked__c,Article_Solved_My_Problem__c,Linking_User__c,Linked_Date_Time__c from Linked_SR__c where SR_Number__c=:linkingObj.SR_Number__c and Article_Solved_My_Problem__c=true];
                    if(srList.size()>0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'SR Number ' +linkingObj.SR_Number__c+ ' is Already Marked as Solved in Article '+srList[0].Article_Number__c  );
                    ApexPages.addmessage(myMsg);
                    dupSR = true;
                    reAssign = false;
                    return null;
                }

                }
   
            Linked_SR__c srLink = new Linked_SR__c();
            srLink.Article_Solved_My_Problem__c = linkingObj.Article_Solved_My_Problem__c;
            srLink.SR_Number__c = linkingObj.SR_Number__c;
            srLink.Article_Number__c = articleNo;
            srLink.Article_Solved_My_Problem__c = linkingObj.Article_Solved_My_Problem__c;
            srLink.Originally_Created_By__c = originallyCreated;
            srLink.Article_ID__c = knowArtID;
            srLink.Article_Version_ID__c = knowArtVerID;
            try{
            insert srLink;
                 lstLink = [Select Article_Number__c,Name,SR_Number__c,Linked__c,Article_Solved_My_Problem__c,Linking_User__c,Linked_Date_Time__c from Linked_SR__c where Article_Number__c =:articleNo order by LastModifiedDate desc limit 10];
                 totalSR = [Select count() from Linked_SR__c where Article_Number__c =:articleNo limit 5000 ];

                 noOfSRs = lstLink.size();
                 renderLinkTab = true;
                 renderLinkSection = false;

                    
            }

            catch(DMLException ex){


            }

                    return null;
        }


        public PageReference editSR(){
            
            String srID  = ApexPages.currentPage().getParameters().get('selectedId');   
            PageReference pg = new PageReference('/'+srID+'/e');
            return pg;
        }

        public PageReference reassingArticle(){
             dupSR = false;
                  reAssign = false;

                  Set<Integer> srAvailable = new Set<Integer>(); 
                   
                       List<Linked_SR__c> updateList = new List<Linked_SR__c>();

                String srNumber = String.valueof(linkingObj.Article_Number__c);
                if(srNumber!=null){
                srNumber = srNumber.leftPad(9);
                srNumber = srNumber.Replace(' ','0');
                }
                reassignedArticle = srNumber;
              List<KnowledgeArticleVersion> artList = [SELECT id,ArticleNumber, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' and Language = 'en_US' and ArticleNumber=:srNumber];

              if(artList.size()==0){

                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'Enter a Valid Article Number');
                  ApexPages.addmessage(myMsg);
                  dupSR = false;
                  reAssign = true;
                  return null;

              }

                List<Linked_SR__c> reassingLst = [Select Article_Number__c,Name,SR_Number__c,Linked__c,Article_Solved_My_Problem__c,Linking_User__c,Linked_Date_Time__c from Linked_SR__c where Article_Number__c =:articleNo order by LastModifiedDate desc limit 5000];
                List<Linked_SR__c> newSRLst = [Select Article_Number__c,Name,SR_Number__c,Linked__c,Article_Solved_My_Problem__c,Linking_User__c,Linked_Date_Time__c from Linked_SR__c where Article_Number__c =:srNumber order by LastModifiedDate desc limit 5000];

                for(Linked_SR__c newlnkObj : newSRLst){

                    srAvailable.add(Integer.valueof(newlnkObj.SR_Number__c));

                }





              for(Linked_SR__c lnkObj : reassingLst){

                    if(!srAvailable.contains(Integer.valueof(lnkObj.SR_Number__c))){
                     lnkObj.Article_Number__c =srNumber;
                                updateList.add(lnkObj );

                    }


                  }
                        update updateList;
                        renderreAssign = true;
                        renderLinkTab = false;
                        renderLinkSection = true;
                        outText = 'SR Is Successfully Linked To Article :'+srNumber;
                        noOfSRs = 0;
                        totalSR = 0;



                 //lstLink = [Select Article_Number__c,Name,SR_Number__c,Linked__c,Article_Solved_My_Problem__c,Linking_User__c,Linked_Date_Time__c from Linked_SR__c where Article_Number__c =:articleNo order by LastModifiedDate desc limit 10];
            
                                
                    return null;
                    }

        //Logic for SR Linking Ends here

        //Logic For Article Rating
        //Article Rating
    public PageReference rateArticle(){

        Article_Rating__c rateObj = new Article_Rating__c();
        rateObj.Article_Number__c = artNo;
        rateObj.Raters_Email_Address__c = rateArt.Raters_Email_Address__c;
        rateObj.Comments__c = rateArt.Comments__c;
        rateObj.Rating__c = rateArt.Rating__c;
        rateObj.Solved_My_Problem__c= rateArt.Solved_My_Problem__c;
        rateObj.Originally_Created_By__c = originallyCreated;
        rateObj.Article_Title__c = artTitle;

        try{
        insert rateObj;
         insertRating = true;
       
        }
        catch(Exception ex){
        
        }
        return null;
        
       
    }
        //Logic Ends for Article Rating

        //Logic for Clonning

     @RemoteAction
         global  static Pagereference insertArticle (String title , String articleId){

                     String query = 'Select ';
                     String queryOnline = '';
                     String queryDraft = '';
                     articleId = articleId.trim();
                     system.debug('articleId--->'+articleId);
                     String artcId = '';

            //Getting Article Type Dynamic Apex

                     Map<String,String> describeMap = new Map<String , String>();

             
                    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();


                    Set<String> keySet = gd.keySet();
                    for (String key : keySet) {
                        Schema.SObjectType objectType = gd.get(key);
                        if (key.endsWith('ka') || key.endsWith('kb')) {
                            describeMap.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getLabel());
                        }
                    }

                    String articlePrefix = articleId.substring(0,3);
                    String articleType= '';
                    Set<String> keySet1 = describeMap.keySet();
                    for(String key: keySet1) {
                        if(articlePrefix.equalsIgnoreCase(key)) {
                            articleType = describeMap.get(key);
                            
                        }
                    }


                articleType = articleType.replace(' ','_')+'__kav';

                System.debug('articleType---->'+articleType);


                sObject sourceObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;
                sObject destinationObj =Schema.getGlobalDescribe().get(articleType).newSObject() ; 

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
                                            queryOnline = query + ' from ' +articleType+ ' where PublishStatus=\'Online\' and Language = \'en_US\' and Id =\'' +articleId+'\'';
                                            queryDraft =  query + ' from ' +articleType+ ' where PublishStatus=\'Draft\' and Language = \'en_US\' and Id =\'' +articleId+'\'';
                                        }

                                }

                                System.debug('queryDraft------>'+queryDraft);
                                System.debug('queryOnline------>'+queryOnline);        
                        try{
                        sourceObj = Database.query(queryOnline);
                        }
                        catch(Exception e){
                            System.debug('e--->'+e);
                        }
                        try{
                        sourceObj = Database.query(queryDraft);
                        }
                        catch(Exception e){
                            System.debug('e--->'+e);
                        }
                        system.debug('sourceObj--->'+sourceObj);
                        if(title.startsWith('- ')){
                            title = (title.removeStart('- ')).replace(',','');
                        }

                        else{
                            title = (title.removeStart('-')).replace(',','');
                        }



                        String urlName = title.replaceAll('[{}\\[\\].\\//+!@#$%&*()?"=<>`~^_;:\\-\'\"]','');
                            urlName = urlName.trim();
                             System.debug('UrlName------>'+urlName);

                            urlName = urlName.replace(' ','-');
                            
                            if(urlName.startsWith('- ')){
                            urlName = urlName.removeStart('- ');
                            urlName = urlName.removeEnd('- ');
                            }

                            else{
                                urlName = urlName.removeStart('-');
                                urlName = urlName.removeEnd('-');

                            }
                            
                        
                        destinationObj.put('Title' , title);
                        destinationObj.put('UrlName' , urlName);
                        destinationObj.put('Cause__c' , (String)sourceObj.get('Cause__c'));
                        destinationObj.put('Cause_Internal__c' , (String)sourceObj.get('Cause_Internal__c'));
                        destinationObj.put('Change__c' , (String)sourceObj.get('Change__c'));
                        destinationObj.put('Change_Internal__c' , (String)sourceObj.get('Change_Internal__c'));
                        destinationObj.put('Environment__c' , (String)sourceObj.get('Environment__c'));
                        destinationObj.put('Environment_Internal__c' , (String)sourceObj.get('Environment_Internal__c'));

                        destinationObj.put('Impact__c' , (String)sourceObj.get('Impact__c'));
                        destinationObj.put('Impact_Internal__c' , (String)sourceObj.get('Impact_Internal__c'));
                        destinationObj.put('Issue__c' , (String)sourceObj.get('Issue__c'));
                        destinationObj.put('Issue_Internal__c' , (String)sourceObj.get('Issue_Internal__c'));
                        destinationObj.put('Notes__c' , (String)sourceObj.get('Notes__c'));
                        destinationObj.put('Notes_Internal__c' , (String)sourceObj.get('Notes_Internal__c'));
                        destinationObj.put('Notes_Restricted__c' , (String)sourceObj.get('Notes_Restricted__c'));
                        destinationObj.put('Resolution__c' , (String)sourceObj.get('Resolution__c'));
                        destinationObj.put('Resolution_Internal__c' , (String)sourceObj.get('Resolution_Internal__c'));
                        destinationObj.put('Cloned_From_Article_Number__c', (String)sourceObj.get('ArticleNumber'));

                         System.debug('Title------>'+title);
                        

                        insert destinationObj;

                
                        artcId  = destinationObj.id;
       
                         KnowledgeArticleVersion x=[SELECT id, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'Draft' and Language = 'en_US' and id=:artcId ];

                
                        url ='/knowledge/publishing/articleEdit.apexp?id='+x.KnowledgeArticleId;

                        System.debug('url------>'+url);

                          PageReference pg = new PageReference(url);
                          pg.setredirect(true);
                          return pg;
        }
        

    }