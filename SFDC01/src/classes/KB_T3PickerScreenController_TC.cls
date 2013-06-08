@isTest
private class KB_T3PickerScreenController_TC{
static testMethod  void pickerScreen(){

    Test.startTest();
    
    List<Id> idList= new List<Id>();
    Break_Fix__kav breakfix = new Break_Fix__kav();
    breakfix.Title='Test Class Break Fix';
    breakfix.UrlName ='Test-Class-Breakfix';
    breakfix.Language ='en_US';
     breakfix.T3_Categories__c ='1111,2222';
    
    insert breakfix;
    idList.add(breakfix.id);
    System.debug('BF_PublishStatus----->'+breakfix.PublishStatus);
    
    How_To__kav howTo = new How_To__kav();
    howTo.Title='Test Class How To';
    howTo.UrlName ='Test-Class-howto';
    howTo.Language ='en_US';
    howTo.T3_Product__c='abcdefghijklmn';
    howTo.T3_Version__c='asdkjhkjfhjhgihr';
    insert howTo;

    ESA__kav esaArt = new ESA__kav();
    esaArt.Title='Test Class ESA';
    esaArt.UrlName ='Test-Class-ESA';
    esaArt.Language ='en_US';
    insert esaArt;

    TSA__kav tsaArt = new TSA__kav();
    tsaArt.Title='Test Class TSA';
    tsaArt.UrlName ='Test-Class-tsa';
    tsaArt.Language ='en_US';
    insert tsaArt;

    ETA__kav etaArt = new ETA__kav();
    etaArt.Title='Test Class ETA';
    etaArt.UrlName ='Test-Class-eta';
    etaArt.Language ='en_US';
    insert etaArt;

    Restricted__kav restArt = new Restricted__kav();
    restArt.Title='Test Class REST';
    restArt.UrlName ='Test-Class-rest';
    restArt.Language ='en_US';
    insert restArt;

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
    

    ApexPages.currentPage().getParameters().put('aId',breakfix.id);
    ApexPages.currentPage().getParameters().put('aType','Break Fix');
    

    KB_T3PickerScreenController pickerObj = new KB_T3PickerScreenController();
    KB_T3PickerScreenController.currentArticleInfo innerObj = new KB_T3PickerScreenController.currentArticleInfo('id','title','number');
    pickerObj.parentRecordId = '1111';
    pickerObj.showChildren();
    pickerObj.allDescriptions = lstT3[0].Name+','+lstT3[1].Name;
    pickerObj.allNames=lstT3[0].T3_ID__c+','+lstT3[1].T3_ID__c;
    pickerObj.allProducts=t3Parent.Name+lstT3[0].Name+','+t3Parent.Name+lstT3[1].Name;
    pickerObj.updateArticle();
    pickerObj.quickSaveArticle();
 
    ApexPages.currentPage().getParameters().put('aId',breakfix.id);
    ApexPages.currentPage().getParameters().put('aType','Break Fix');
    KB_T3PickerScreenController pickerObj1 = new KB_T3PickerScreenController();
    
    Test.stopTest();
    
}
}