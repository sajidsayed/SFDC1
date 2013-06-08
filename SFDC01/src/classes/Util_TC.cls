@isTest
Private Class Util_TC{
    Private static testMethod void startTest(){
        Configuration__c config01 = new Configuration__c(Key__c = 'abc');
        List<Configuration__c> config02 = new List<Configuration__c>();
        config02.add(config01 );
        
        Set<String> owners01 = new Set<String>();
        Util.getUsers(config02,owners01 );
    }
}