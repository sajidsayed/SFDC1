@isTest
private class EBC_PresenterLookup_TC {

    static testMethod void EBC_PresenterLookup() {
        EBC_Topics__c topic =new EBC_Topics__c(Name='topic');
        insert topic;
        ApexPages.currentPage().getParameters().put('Topic','topic');
        EBC_PresenterLookup TP_Lookup=new EBC_PresenterLookup();
        TP_Lookup.searchTopicValue='topic';
        TP_Lookup.getPresenterName();
        TP_Lookup.getsearchTopicName();
        TP_Lookup.setsearchTopicName('topic');
        TP_Lookup.setPresenterName('topic');
        TP_Lookup.gettp();
        TP_Lookup.doSearch();
        // my code
        TP_Lookup.getselected();
        TP_Lookup.setselected(true);
        TP_Lookup.getItems();
        
        // my code
        
        TP_Lookup.PresenterName = '';
        //TP_Lookup.location = '';
        //TP_Lookup.areaOfExpertise = '';
        TP_Lookup.doSearch();
        
        ApexPages.currentPage().getParameters().put('Topic','');
        EBC_PresenterLookup TP_Lookup1 = new EBC_PresenterLookup();
        TP_Lookup1.setPresenterName('topic');
        TP_Lookup1.location = 'Bangalore';
        TP_Lookup1.doSearch();
        
        TP_Lookup1.PresenterName = '';
        TP_Lookup1.doSearch();
        
        TP_Lookup1.areaOfExpertise = 'CallCenter';
        TP_Lookup1.doSearch();
        
        TP_Lookup1.location = '';
        TP_Lookup1.doSearch();
        
        ApexPages.currentPage().getParameters().put('Topic','');
        EBC_PresenterLookup TP_Lookup3 = new EBC_PresenterLookup();
        TP_Lookup3.PresenterName = '';
        TP_Lookup3.location = '';
        TP_Lookup3.areaOfExpertise = '';
        ApexPages.currentPage().getParameters().put('Topic','');
        TP_Lookup3.doSearch();
        
        EBC_PresenterLookup TP_Lookup4 = new EBC_PresenterLookup();
        //the below lines are used for location setting of values in the javascript
        //and does not carry any other significance. Added here to increase code coverage
        TP_Lookup4.getcomponentid();
        TP_Lookup4.setcomponentid('test');
        TP_Lookup4.gettopicpresenterid();
        TP_Lookup4.settopicpresenterid('test');
        TP_Lookup4.getisguestpresenter();
        TP_Lookup4.setisguestpresenter('test');
        TP_Lookup4.getguestfirstname();
        TP_Lookup4.setguestfirstname('test');
        TP_Lookup4.getguestlastname();
        TP_Lookup4.setguestlastname('test');
        TP_Lookup4.getguesttitle();
        TP_Lookup4.setguesttitle('test');
        TP_Lookup4.getguestemail();
        TP_Lookup4.setguestemail('test');
        TP_Lookup4.getguestcompany();
        TP_Lookup4.setguestcompany('test');
        EBC_Session_Presenter__c testp= new EBC_Session_Presenter__c (Name='test3', Is_the_Presenter_Confirmed__c ='No', Guest_Presenter_Last_Name__c = 'testl1', 
                                                Guest_Presenter_First_Name__c = 'testf1', Guest_Presenter_Email__c ='test1@test.com', Guest_Presenter_EBC_Title__c = 'title', Guest_Company__c = 'test', 
                                                Guest_Presenter__c = true);
        ApexPages.currentPage().getParameters().put('presenterid',testp.id);
        TP_Lookup4.getguestdetails();                                       
                                                
    }
}