public without sharing class AH_DuplicateInfo_WithoutSharing {

    // function to retrieve the count of accounts that match a specified DUNS
    public static Integer getDuplicateCount(String DUNS) {
        System.debug('Received DUNS: ' + DUNS);
        return [select count() from Account where Site_DUNS_Entity__c = :DUNS];
    }

    // function to retrieve the accounts that match a specified DUNS
    public static List <Account> getDuplicates(String DUNS) {
        System.debug('Received DUNS: ' + DUNS);
        return [select Id, Name, Party_ID__c, Party_Number__c, EMC_Classification__c,
            BillingStreet, BillingCity, BillingState, BillingPostalCode from Account where Site_DUNS_Entity__c = :DUNS];
    }
 }