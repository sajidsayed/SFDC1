@isTest
private class KB_AssignT3Controller3_TC{
static testMethod  void assignT3Controller3(){

    Test.startTest();
    
    Break_Fix__kav breakfix = new Break_Fix__kav();
    breakfix.Title='Test Class Break Fix';
    breakfix.UrlName ='Test-Class-Breakfix';
    breakfix.Language ='en_US';
    insert breakfix;
    
    How_To__kav howTo = new How_To__kav();
    howTo.Title='Test Class How To';
    howTo.UrlName ='Test-Class-howto';
    howTo.Language ='en_US';
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
 
    KnowledgeArticleVersion kav= new KnowledgeArticleVersion();
    KB_AssignT3Controller3 assigncontroller= new KB_AssignT3Controller3();
    assigncontroller.artSearch = 'Test Class';
    assigncontroller.myartSearch = 'Test Class';

    assigncontroller.getInitialArticleSet();
    assigncontroller.next();
    assigncontroller.previous();
    assigncontroller.searchArt();
    assigncontroller.mysearchArt();
    assigncontroller.clearSearch();
    assigncontroller.myclearSearch();


    Test.stopTest();
    
}
}