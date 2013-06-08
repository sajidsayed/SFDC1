public class KB_AssignT3Controller3 {
    
    public Id userId {get;set;}
    public List<knowledgeArticleVersion> draftArticles {get;set;}
    public List<knowledgeArticleVersion> ownerArticles {get;set;}
  //  public List<Offer__kav> primusArt {get;set;}
   // public List<Promotion__kav> webtopArt {get;set;}
    public List<How_To__kav> howToArt {get;set;}
    // public List<articleTypeWrapper> articleWrapperList {get;set;}
    public string artSearch {get;set;}
    public string myartSearch {get;set;}
    public List<ProcessInstance> processInstances {get;set;}
    public List<ProcessInstanceWorkItem> pInWoI {get;set;}
    public List<processWrapper> processWrapperList {get;set;}
    public List<processWrapper> myProcessWrapperList {get;set;}
    public List<KnowledgeArticleVersion> allArticles {get;set;}

    public Map<String,String> procInstMap {get; set;}

    //Pagenation
     public Integer pageSize{get;set;}
    public Integer noOfPages{get;set;}
    public Integer pageNumber{get;set;}
    private String baseQuery = 'SELECT k.Title, k.PublishStatus, k.OwnerId,k.KnowledgeArticleId, k.ArticleNumber,k.Id,k.ArticleType,k.LastModifiedDate FROM KnowledgeArticleVersion k where PublishStatus=\'Draft\' and Language = \'en_US\' order by LastModifiedDate desc';
    private Integer totalNoOfRecs;


    
    public KB_AssignT3Controller3(){

        procInstMap = new Map<String,String>();
        myProcessWrapperList = new List<processWrapper>();
        processWrapperList = new List<processWrapper>();
         pageSize = 400;
         userId = Userinfo.getUserid();
       // totalNoOfRecs = [SELECT count() FROM KnowledgeArticleVersion where PublishStatus='Draft' and Language ='en_US' limit 50000];
        getInitialArticleSet(); 
    
    
    }

       public PageReference getInitialArticleSet()
    {        
        pageNumber = 0;
       /* noOfPages = totalNoOfRecs/pageSize;
        
        if (Math.mod(totalNoOfRecs, pageSize) > 0)
            noOfPages++;*/
        
      
            draftArticles = Database.query(baseQuery + ' limit '+pageSize);
            allArticles = draftArticles.deepClone();

    
              List<String> daIds = new List<String>();
        for(KnowledgeArticleVersion k : draftArticles){
            daIds.add(k.KnowledgeArticleId);
        }
        
        processInstances = [Select p.TargetObjectId, p.Id
                            From ProcessInstance p
                            Where TargetObjectId IN: daIds];
        
        List<String> piIds = new List<String>();
        for(ProcessInstance p: processInstances){
            piIds.add(p.Id); 
        }
        

        pInWoI = [Select p.ProcessInstanceId, p.Id, p.ActorId 
                    From ProcessInstanceWorkitem p
                    Where ProcessInstanceId IN: processInstances 
                    ];
      
         for(ProcessInstance p1: processInstances){

        for(ProcessInstanceWorkitem p: pInWoI){
                if(p.ProcessInstanceId==p1.id)
                procInstMap.put(p1.TargetObjectId,p.ActorId);

        }
         }

 
                 
             String articleType;

            for(knowledgeArticleVersion kva : draftArticles){
    
                    articleType = kva.ArticleType;

        sObject  sObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;

        
          Schema.DescribeSObjectResult dsor = sObj.getSObjectType().getDescribe();
            

            if(dsor.accessible){
                    articleType = (articleType.removeEnd('__kav')).replace('_',' ');

                 processWrapperList.add(new processWrapper(kva,articleType));

               if(userId==procInstMap.get(kva.KnowledgeArticleId)){

                        myProcessWrapperList.add(new processWrapper(kva,articleType));

                }
            }
            }

        
        return null;  
    }


     public PageReference next(){
        pageNumber++; 
        
        queryArticle();
        return null;
    }

    public PageReference previous(){
        pageNumber--;
        if (pageNumber < 0)
            return null;
        
        queryArticle();
        return null;
    }
    
    private void queryArticle()
    {
        draftArticles.clear();
        myProcessWrapperList.clear();
        processWrapperList.clear();

        Integer offset = pageNumber * pageSize;    
        String query = baseQuery + ' limit '+pageSize +' offset '+ offset;
        System.debug('Query is--->'+query);
            draftArticles = Database.query(query);

                                      
        List<String> daIds = new List<String>();
        for(KnowledgeArticleVersion k : draftArticles){
            daIds.add(k.KnowledgeArticleId);
        }
        
        processInstances = [Select p.TargetObjectId, p.Id
                            From ProcessInstance p
                            Where TargetObjectId IN: daIds];
        
        List<String> piIds = new List<String>();
        for(ProcessInstance p: processInstances){
            piIds.add(p.Id); 
        }
        
        pInWoI = [Select p.ProcessInstanceId, p.Id, p.ActorId 
                    From ProcessInstanceWorkitem p
                    Where ProcessInstanceId IN: piIds 
                    ];
      
         for(ProcessInstance p1: processInstances){

        for(ProcessInstanceWorkitem p: pInWoI){
                if(p.ProcessInstanceId==p1.id)
                procInstMap.put(p1.TargetObjectId,p.ActorId);

        }
         }

        
 
                 
             String articleType;

            for(knowledgeArticleVersion kva : draftArticles){
    
                    articleType = kva.ArticleType;
                        sObject  sObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;

        
          Schema.DescribeSObjectResult dsor = sObj.getSObjectType().getDescribe();
            

            if(dsor.accessible){

                    articleType = (articleType.removeEnd('__kav')).replace('_',' ');

                 processWrapperList.add(new processWrapper(kva,articleType));


               if(userId==procInstMap.get(kva.KnowledgeArticleId)){

                        myProcessWrapperList.add(new processWrapper(kva,articleType));
                }
            }
            }

          
    }
    
    
    public class processWrapper{
                public KnowledgeArticleVersion procKav {get;set;}
                public string procaType {get;set;}


        public processWrapper(KnowledgeArticleVersion k, String artType){

    
            procKav = k;
            procaType = artType;


            
        }
    }
    
    
    
    public void searchArt(){
        processWrapperList.clear();
        List<knowledgeArticleVersion> filteredArt = new List<knowledgeArticleVersion>();
        String articleType = '';
        System.debug('draftArticles----->'+allArticles);
        for(knowledgeArticleVersion kva : allArticles){
            if(kva.Title.toLowerCase().indexOf(artSearch.toLowerCase()) != -1){
                filteredArt.add(kva);
            }
        }
        draftArticles.clear();
        for(knowledgeArticleVersion kva : filteredArt){
    
                    articleType = kva.ArticleType;
                        sObject  sObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;

        
          Schema.DescribeSObjectResult dsor = sObj.getSObjectType().getDescribe();
            

            if(dsor.accessible){

                    articleType = (articleType.removeEnd('__kav')).replace('_',' ');

                 processWrapperList.add(new processWrapper(kva,articleType));
            }

            }

       
    }
    
    public void mysearchArt(){
        myProcessWrapperList.clear();
        processWrapperList.clear();
        List<knowledgeArticleVersion> filteredArt = new List<knowledgeArticleVersion>();
        String articleType = '';

        for(knowledgeArticleVersion kva : allArticles){
            if(kva.Title.toLowerCase().indexOf(myartSearch.toLowerCase()) != -1){
                 articleType = kva.ArticleType;

                    sObject  sObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;

        
          Schema.DescribeSObjectResult dsor = sObj.getSObjectType().getDescribe();
            

            if(dsor.accessible){
                    articleType = (articleType.removeEnd('__kav')).replace('_',' ');

                 if(userId==procInstMap.get(kva.KnowledgeArticleId)){

                        myProcessWrapperList.add(new processWrapper(kva,articleType));

                }
            }

            }
        }
    }
    
    
    public void clearSearch(){
        artSearch = '';
        processWrapperList.clear();
        draftArticles.clear();

            String articleType = '';
              for(knowledgeArticleVersion kva : allArticles){
    
                    articleType = kva.ArticleType;
                        sObject  sObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;

        
          Schema.DescribeSObjectResult dsor = sObj.getSObjectType().getDescribe();
            

            if(dsor.accessible){

                    articleType = (articleType.removeEnd('__kav')).replace('_',' ');

                 processWrapperList.add(new processWrapper(kva,articleType));
            }

            }
        
     
    }
    
    public void myclearSearch(){
        
        myartSearch = '';
        myProcessWrapperList.clear();
        processWrapperList.clear();
        draftArticles.clear();
        String articleType = '';
        System.debug('allArticles---------->'+allArticles);
        for(knowledgeArticleVersion kva : allArticles){

             articleType = kva.ArticleType;

             sObject  sObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;

        
          Schema.DescribeSObjectResult dsor = sObj.getSObjectType().getDescribe();
            

            if(dsor.accessible){


            articleType = (articleType.removeEnd('__kav')).replace('_',' ');
          
                    
                 if(userId==procInstMap.get(kva.KnowledgeArticleId)){

                        myProcessWrapperList.add(new processWrapper(kva,articleType));

                }
            }
        } 
    
        
    }
}