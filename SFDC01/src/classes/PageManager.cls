/*    
Type Name: Apex Class  - PageManager
Author: Anand Sharma
Created Date: 5/03/2011
Reason:
    This is a Apex Class which manages variables and functions for the component "Paginator".
    To use the component "Paginator", you need to instantiate this PageManager in the VF page Controller
    and provide it to the component. When you instantiate this, you can provide the number of rows to display per page.
    If you don't provide the number, this will use the default value (10).
    In your controller, you are supposed to provide a list of row values for the table to paginate.
    When you query the data, you need to count the total number of the rows and set it in PageManager.numberOfRows.
    To create the list for the table list, you need to select only rows with the following index i:
        PageManager.startIndex <= i < PageManager.endIndex
    This startIndex and endIndex are calculated when you set a value in PageManager.numberOfRows.
    
    When user clicks page link or Next/Privious, the component just change the page number and
    refresh the table list. The list you provide will prepare for the list for the table list based on 
    the new page number and the page will display the new page.
    (Make sure that you specify a component which includes both of the table list and the paginator itself
    in reRenderComponent attribute in the paginator. The paginator component itself needs to be reRender.)
    
    Example:
    [VF Page]
    <apex:pageBlock id="pb_products">
	    <c:paginator id="page_products" pageManager="{!pmOffering}" onComplete="selectDefaultProduct();" 
	     reRenderComponent="{!$Component.pb_products}" statusComponent="{!$Component.status_products}"/>
	    <apex:pageBlockTable value="{!offferings}">
	    ...
    
    [Controller]
    public PageManager pmOffering {get; set;}
    public List<Offering> offeringsAll {get; set;}
    
    public TheController(){
        pmOffering = new PageManager(5);
        loadOfferings();
    }
    
    private void loadOfferings(){
        // Load all offerings in the cache
        offeringsAll = ...
        // Set numberOfRows
        pmOffering.numberOfRows = offeringsAll.size();
    }
    
    public List<Offering> getOfferings(){
        List<Offering> data = new List<Offering>();
        for(integer i=pmOffering.startIndex;i<pmOffering.endIndex&&i<offeringsAll.size();i++){
            data.add(offeringsAll.get(i));
        }
        return data;
    }
*/

public class PageManager {
	
	/********** Constatns **********/
	// Default value for numberOfRowsPerPage
	private static final integer DEFAULT_NUMBER_OF_ROWS_PER_PAGE = 25;
	
	/********** Public Properties / Variables **********/
	// Number of rows to display per page (provided by the constructor or default value)
	public integer numberOfRowsPerPage {get;set;}
	// Page Number (0-based index (display is 1-based))
    public integer page {get;set;}
    // a list of Page Numbers (1-based index as displayed). Updated when numberOfRows is set
    public List<integer> pageList {get;set;}
    // the number of the entire rows. Once this is set, this can calculate pageList and start/endIndex
    public integer numberOfRows {get; 
    	set{
    		numberOfRows = value;
	        integer nop = 0;
	        if(numberOfRowsPerPage > 0){
	           nop = (Math.ceil(
	                decimal.valueOf(value).doubleValue() 
	                    / decimal.valueOf(numberOfRowsPerPage).doubleValue())).intValue();
	        }
	        pageList.clear();
	        for(integer i=1;i<=nop;i++) pageList.add(i);	        
	        // Even there is no record, it should show Page 1.
	        if(pageList.size() == 0) pageList.add(1);
	        //page = 0;
        }
    }
    // The array index in the entire rows for the first row in the page (included)
    public integer startIndex {
        get {
            return page * numberOfRowsPerPage;
        }
    }
    // The array index in the entire rows for the last row in the page (excluded),
    // which means that this index is not included in the page
    // (this will be for the first row of the next page)
    public integer endIndex {
        get {
            return Math.min(numberOfRows, (page+1)*numberOfRowsPerPage);
        }
    }

    // In case that the component needs a picklist for pageList
    public List<SelectOption> pageOptions {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for(integer i=0;i<pageList.size();i++) options.add(new SelectOption(''+(pageList[i]-1), ''+(pageList[i])));
            return options;
        }
    }    

    /********** Constructors **********/

    /*
    Type Name: Constructor
    Input/Output
    Author: Anand Sharma
    Created Date: 5/03/2011
    Reason:
        This is a constructor for PageManager.
    */
    public PageManager(){
    	init();
    }

    /*
    Type Name: Constructor
    Input/Output
       Input: integer numberOfRowsPerPage - The number of the rows to display per page 
    Author: Anand Sharma
    Created Date: 5/03/2011
    Reason:
        This is a constructor for PageManager with numberOfRowsPerPage.
    */
    public PageManager(integer numberOfRowsPerPage){
		init();
		this.numberOfRowsPerPage = numberOfRowsPerPage;
    }

    
    /********** Private Methods  **********/

    /*
    Type Name: Private Method - init
    Input/Output
    Author: Anand Sharma
    Created Date: 5/03/2011
    Reason:
        This is a method to initialize variables. This is called from the constructors.
    */
    private void init(){
        page = 0;
        pageList = new List<integer>();
        this.numberOfRowsPerPage = DEFAULT_NUMBER_OF_ROWS_PER_PAGE;
        this.numberOfRows = 0;
    }
    
    
}