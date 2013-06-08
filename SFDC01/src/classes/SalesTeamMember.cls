/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     DESCRIPTION                               
 |  ====       =========     =========== 
 | 
    16-Feb-10 Saravanan C    Added SplitRow variable - WR 123622
    
    28-Apr-10 Karthik S      Changed the variable SplitRow to splitExceeding -WR-131541 / Defect 635
    15-Dec-10 Srinivas N     Added new string variable for WR 151992, Used in AddTeamsAddProducts vf page
    
 +===========================================================================*/
public class SalesTeamMember {

    public Boolean splitExceeding {get; set;} // Added by Karthik S - WR 131541
    
    public String Owner_Eligible {get; set;}{Owner_Eligible = 'No';}  // Addes by Srinivas N - WR 151992. Used in AddTeamsAddProducts vf Page.
    
    public Boolean selected {get; set;}

    public OpportunityTeamMember opptyTeamMember {get; set;}

    public Detail_Line__c detailSplit {get; set;}

    public Boolean ProductForecast{get;set;}
    
    public SalesTeamMember(Boolean selected,OpportunityTeamMember mbr){

        this(selected,mbr,null);

    } 
	
	
    public SalesTeamMember(Boolean selected,OpportunityTeamMember mbr,Detail_Line__c split){

        this.selected=selected;

        this.opptyTeamMember=mbr;

        this.detailSplit=split;

    } 

}