public class AH_Ctlr_ViewDuplicateDUNS {

    // class vars
    private String DUNS; 

    // constructor
    public AH_Ctlr_ViewDuplicateDUNS() {
        this.DUNS = ApexPages.currentPage().getParameters().get('duns');
        System.debug('Retrieved DUNS value from query string parms: ' + this.DUNS);
    }

    // this is a function to retrieve the detail records for those accounts that are normally
    // visible by the end user
    public List<Account> getMyDupes() {
        System.debug('Retrieved DUNS value from query string parms: ' + this.DUNS);
        return AH_DuplicateInfo_WithSharing.getDuplicates(DUNS); 
    }
    
    // this is a function to retrieve the detail records for those accounts that are normally
    // hidden to the end user
    public List<Account> getHiddenDupes() {
        
        System.debug('Retrieved DUNS value from query string parms: ' + this.DUNS);
        
        // declare local vars
        List <Account> hiddenAccts = new List <Account>();
        Set <String> visibleAcctIDs = new Set <String>();
        
        // retrieve the collection of visible & hidden
        List <Account> allAccounts = AH_DuplicateInfo_WithoutSharing.getDuplicates(this.DUNS);
        List <Account> visibleAccounts = AH_DuplicateInfo_WithSharing.getDuplicates(this.DUNS);
        
        // add the visible account ids into a data structure for easy retrieval
        for (Account acct : visibleAccounts) {
            visibleAcctIDs.add(acct.Id);
        }
        
        // iterate over the total collection and remove those accounts the user normally has access
        // to.  this leaves the 'hidden' records
        for (Account acct : allAccounts) {
            if (!visibleAcctIDs.contains(acct.Id)) {
                hiddenAccts.add(acct);
            }
        }
        return hiddenAccts;
    }
    
    
     
    

}