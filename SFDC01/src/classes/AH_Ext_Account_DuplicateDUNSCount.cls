public class AH_Ext_Account_DuplicateDUNSCount {
    
    // declare class vars
    private final Account acct;
    private String DUNS = '';
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public AH_Ext_Account_DuplicateDUNSCount (ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
        DUNS = [select Site_DUNS_Entity__c from Account where id = :acct.id].Site_DUNS_Entity__c;
    }
    
    // function to return a formatted string indicating the total number of 
    // matches in the application
    public String getTotalMatchCount() {
        Integer totalMatchCt = AH_DuplicateInfo_WithoutSharing.getDuplicateCount(this.DUNS);
        return 'There are <b>' + String.valueOf(totalMatchCt) + ' duplicates</b> present, of which ';
    }
    
    // function to return a formatted string indicating the total number of 
    // matches in the application the running user can see
    public String getMyMatchCount() {
        Integer myMatchCt = AH_DuplicateInfo_WithSharing.getDuplicateCount(this.DUNS);
        return '<b>you have access to ' + String.valueOf(myMatchCt) + '</b>';
    }
    
    // function to return the URL to the detail view of the available duplicates
    public String getMatchViewURL() {    
        PageReference pageRef = Page.AH_ViewDuplicateDUNS;
        pageRef.getParameters().put('duns',this.DUNS); 
        return pageRef.getUrl();
    }
    
    

}