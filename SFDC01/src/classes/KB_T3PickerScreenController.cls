public class KB_T3PickerScreenController  {
    public string articleId {get;set;}
    public List<T3_Categories__c> FamProdProdSub {get;set;}
    public List<T3_Categories__c> fppsSelects {get;set;}
    public List<T3_Categories__c> fppsSelects2 {get;set;}
    public String parentRecordId {get;set;}
     public String parentName {get;set;}
    public List<T3_Categories__c> childRecords {get;set;}
    public String allNames {get;set;}
    public String allDescriptions {get;set;}
    public String allProducts {get;set;}

    public List<Break_Fix__kav> primusArtList {get;set;}
    public List<How_To__kav> howtoArtList {get;set;}
    public List<Break_Fix__kav> breakArtList {get;set;}
    public List<ETA__kav> etaArtList {get;set;}


     public List<How_To__kav> howArt {get;set;}
    public List<TSA__kav> webtopArtList {get;set;}
    public string NoVers {get;set;}
    public List<currentArticleInfo> cAI {get;set;}
    public String articleType {get; set;}
    public String query{get; set;}
    public String description{get; set;}
    public String t3ID{get; set;}
     public String prod{get; set;}
    public Boolean noDraft {get; set;}
    public String sourceArtTypw = '';

    //Fields For Showing Attached product on load

    public List<String> descLst = new List<String>();
    public List<String> t3idLst = new List<String>();
    public List<String> prodLst = new List<String>();

    public String displayedProduct {get; set;}
    


    Set<String> setProd = new Set<String>();

    //Genric SObject

    public sObject sObj{get; set;}
    
    public KB_T3PickerScreenController(){   
         query = 'Select ';
        howtoArtList  = new List<How_To__kav>();
        breakArtList = new List<Break_Fix__kav>();
        etaArtList = new List<ETA__kav>();

        NoVers = '';    
        parentRecordId = '';
        fppsSelects = new List<T3_Categories__c>();
        fppsSelects2 = new List<T3_Categories__c>();
        howArt = new List<How_To__kav>();
        articleId = ApexPages.currentpage().getParameters().get('aId');
        articleType = ApexPages.currentpage().getParameters().get('aType');
        sourceArtTypw = articleType;
        cAI = new List<currentArticleInfo>();

        articleType = articleType.replace(' ','_')+'__kav';
        sObj = Schema.getGlobalDescribe().get(articleType).newSObject() ;

        

        
          Schema.DescribeSObjectResult dsor = sObj.getSObjectType().getDescribe();
                Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
                List<String> lstFields = new List<String>();
                
                    for(String field : objectFields.keyset()){
                            lstFields.add(field);
                        }
                        
                         Integer counter = lstFields.size();
                         for(String s :lstFields){
                                if(!s.startsWithIgnoreCase('Attachment')){
                                    if(counter==lstFields.size())
                                        query = query+' '+s;

                                    else
                                        query = query+','+s;
                                     }

                                    counter--;
                                    if(counter ==0)
                                        {
                                            query = query + ' from ' +articleType+ ' where PublishStatus=\'Draft\' and Language = \'en_US\' and id =\'' +articleId+'\'';
                                            
                                        }
                               

                                }

                                System.debug('query------>'+query);
        
                        try{
                         sObj = Database.query(query);
                        }
                        catch (Exception ex){

                            System.debug('ex-------->'+ex.getMessage());
                            noDraft = true;

                        }

                        description = (String)sObj.get('T3_Product__c');
                        //displayedProduct = description;
                        t3ID = (String)sObj.get('T3_Categories__c');
                        prod = (String)sObj.get('T3_Version__c');

                    
            if(description!=null && t3ID!=null && prod!=null ){
            descLst = description.split(',');
            t3idLst = t3ID.split(',');
            prodLst = prod.split(',');

            System.debug('t3idLst---->'+t3idLst);

            Integer totalProd = t3idLst.size();

            prod = '';
            for (Integer i=0;i<totalProd ; i++ )
            {
                prod = prod+t3idLst[i]+'-'+descLst[i]+'-'+prodLst[i] + ',';
            //  prod = prod+t33obj.T3_ID__c+'-'+t33obj.name+',';

            }
            }
            else{
                prod = '';

            }
            displayedProduct= '';

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
                            displayedProduct = displayedProduct+t3Obj.name+',';

                    }

                    else{
                        if(mapSecondT3.get(t3Obj.Parent_T3_ID__c).Term_Type__c=='Product'){

                            displayedProduct = displayedProduct+ mapSecondT3.get(t3Obj.Parent_T3_ID__c).name+' '+t3Obj.name +',';

                        }
                        else{
                            displayedProduct = displayedProduct +  mapThirdT3.get(mapSecondT3.get(t3Obj.Parent_T3_ID__c).Parent_T3_ID__c).name +' ' + t3Obj.name +',';

                        }
                        
                    }

                System.debug('displayedProduct---->'+displayedProduct);
            }
            }
            displayedProduct = displayedProduct.removeend(',');


        
        

    
            System.debug('prod---->'+prod);
   
        
        FamProdProdSub = [Select t.Term_Type__c, t.SystemModstamp, t.Parent_T3__c,t.Parent_T3_ID__c,t.T3_ID__c, t.OwnerId, 
                                  t.Name, t.LastModifiedDate, t.LastModifiedById, t.IsDeleted, t.Id, 
                                 t.CreatedDate, t.CreatedById From T3_Categories__c t Where t.Term_Type__c = 'Product'];
        
        for(T3_Categories__c t: FamProdProdSub ){
            if(fppsSelects.size() < 1000){
                fppsSelects.add(t);   
            }
            else{
                fppsSelects2.add(t);
            }
        } 
    }
    
    public class currentArticleInfo{
        public string curEmcId {get;set;}
        public string curTitle {get;set;}
        public string curNumber {get;set;}
        
        public currentArticleInfo(string cEmc, string cTitle, string cNum){
            curEmcId = cEmc;
            curTitle = cTitle;
            curNumber = cNum;
        } 
    }
    
    public void showChildren(){
        System.debug('parentName------------>'+parentName);
        Set<String> partentSet = new Set<String>();
        List<T3_Categories__c> lstT3 = new List<T3_Categories__c>();
        childRecords = new List<T3_Categories__c>();
        lstT3 = [select id, name,T3_ID__c  from T3_Categories__c where Parent_T3_ID__c =: parentRecordId AND Term_Type__c = 'Version' order by name];
        for(T3_Categories__c t3catObj : lstT3){

            partentSet.add(t3catObj.T3_ID__c);
            //t3catObj.name = parentName+' '+t3catObj.name;
            childRecords.add(t3catObj);

        }

        lstT3.clear();
        lstT3 = [select id, name,T3_ID__c  from T3_Categories__c where Parent_T3_ID__c in : partentSet AND Term_Type__c = 'Version' order by name ];

        for(T3_Categories__c t3Child : lstT3){

        //  t3Child.name = parentName+' '+t3Child.name;
            childRecords.add(t3Child);

        } 



        if(childRecords.size() == 0){
            NoVers = 'No Versions Available';
        }
        else{
            NoVers = '';
        }
    }
    
    public pageReference updateArticle(){

               String descriptionT3 = '';
           String names = '';
           String product = '';


            allDescriptions =  allDescriptions.trim();
            
            
         for(String descs :allDescriptions.split(',')){
            
             descs = descs.trim();
                    if(descs.length()>0 &&!descriptionT3.containsIgnoreCase(descs)){

                        
                         descriptionT3 = descriptionT3+descs+',';
                        
                    }
         }
         descriptionT3 = descriptionT3.removeEnd(',');
          System.debug('descriptionT3--->'+descriptionT3);
        

          for(String nam :allNames.split(',')){

             nam = nam.trim();
                    if(nam.length()>0 && !names.containsIgnoreCase(nam)){

                        names = names+nam+',';
                        
                        
                    }

         }
          names = names.removeEnd(',');
         System.debug('names--->'+names);

        
          for(String ver :allProducts.split(',')){

             ver = ver.trim();
                    if(ver.length()>0 ){

                        
                        product = product+ver+',';
                        
                        
                    }

         }
         product = product.removeEnd(',');
         System.debug('product--->'+product);

         sObj.put('T3_Categories__c',names);
         sObj.put('T3_Product__c',descriptionT3);
         sObj.put('T3_Version__c',product);

         update sObj;


        return new pageReference('/apex/KB_T3_Assign');
    } 
    
     public pageReference quickSaveArticle(){

           String descriptionT3 = '';
           String names = '';
           String product = '';

            allDescriptions =  allDescriptions.trim();

             System.debug('allDescriptions--->'+allDescriptions);

            
         for(String descs :allDescriptions.split(',')){
            
             descs = descs.trim();
                    if(descs.length()>0 &&!descriptionT3.containsIgnoreCase(descs)){

                        
                         descriptionT3 = descriptionT3+descs+',';
                        
                    }

                    

         }
        

                
        
         descriptionT3 = descriptionT3.removeEnd(',');
          System.debug('descriptionT3--->'+descriptionT3);
        

          for(String nam :allNames.split(',')){

             nam = nam.trim();
                    if(nam.length()>0 && !names.containsIgnoreCase(nam)){

                        names = names+nam+',';
                        
                        
                    }

         }
          names = names.removeEnd(',');
         System.debug('names--->'+names);

        
          for(String ver :allProducts.split(',')){

             ver = ver.trim();
                    if(ver.length()>0 ){

                        
                        product = product+ver+',';
                        
                        
                    }

         }
         product = product.removeEnd(',');
         System.debug('product--->'+product);

         sObj.put('T3_Categories__c',names);
         sObj.put('T3_Product__c',descriptionT3);
         sObj.put('T3_Version__c',product);

         update sObj;

            descLst.clear();
            t3idLst.clear();
            prodLst.clear();

         descLst = descriptionT3.split(',');
            t3idLst = names.split(',');
            prodLst = product.split(',');

            Integer totalProd = t3idLst.size();

            prod = '';
            for (Integer i=0;i<totalProd ; i++ )
            {
                prod = prod+t3idLst[i]+'-'+descLst[i]+'-'+prodLst[i] + ',';

            }

            displayedProduct= '';

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

            System.debug('mapFirstT3--->'+mapFirstT3.keyset());

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
                            displayedProduct = displayedProduct+t3Obj.name+',';

                    }

                    else{
                        if(mapSecondT3.get(t3Obj.Parent_T3_ID__c).Term_Type__c=='Product'){

                            displayedProduct = displayedProduct+ mapSecondT3.get(t3Obj.Parent_T3_ID__c).name+' '+t3Obj.name +',';

                        }
                        else{
                            displayedProduct = displayedProduct +  mapThirdT3.get(mapSecondT3.get(t3Obj.Parent_T3_ID__c).Parent_T3_ID__c).name +' ' + t3Obj.name +',';

                        }
                        
                    }

                System.debug('displayedProduct11111---->'+displayedProduct);
            }
            }
            displayedProduct = displayedProduct.removeend(',');

        String url = '/apex/KB_T3PickerScreen?aId='+articleId+'&aType='+sourceArtTypw;
        System.debug('url-------->'+url);
         PageReference pg = new PageReference(url);

         return pg;
       
    }    
}