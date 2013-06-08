/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====            =========       ======     =========== 
 |  20.09.2010      Anand Sharma    #779       Controller for the lead inbox page. This will used to display Lead Records 
                                               and accept and reject lead.             
 |  29.09.2010      Anand Sharma               Updated filter criteria , only queue owner of lead will display
 |  
 |  11.10.2010      Ashwini Gowda   #1143      Blank out the EMC Lead Rejected checkbox 
 |                                             after a lead has been accepted by a different user. 
 |  28.12.2010      Anirudh         #1597      Modified SOQL query to fetch originator detail value as well
 |                                             Updated ORDER BY clause to sort on Originator Detail.   
 +=========================================================================================================================*/

public with sharing class PRM_LeadInbox {
        
    /* hold list of lead records */ 
    List<Lead> fullLeadInbox_List = new Lead[0];
    
    /* hold 10 record of lead */
    List<Lead> leadInbox10Only_List {get; set;}       
    
    /* hold height of page */ 
    public Integer Pageheight{get;set;} 
    public Boolean isSuccess{get;set;}
    
    public Boolean isFullLead {get;set;} 
    
    public String successLeadId {get;set;}
    
    public String successMsgLead {get;set;}
           
    private Integer intFullLeadPageSize;
    private Integer int10LeadPageSize;
    private String selectedRow ;
    
    /* constructor of the class */
    public PRM_LeadInbox(){   
        isSuccess = false;      
        /* initialize variable  */
        leadInbox10Only_List = new List<Lead>();
        fullLeadInbox_List = new List<Lead>();
        
        /*  set Page size to zero */
        Pageheight=0;
           
        /* set display full lead flag as false  */
        isFullLead = false;
        
        /* reset values of variable */      
        Integer count =0;
        selectedRow = '';
        successMsgLead = '';
        
        /* set the minimum height */
        int10LeadPageSize= 150;
        intFullLeadPageSize = 150;
        Pageheight = 250;
        //Changed by Anirudh - Req #1597
        /*<Modified query to fetch originator detail field value also
           Updated OrderBy clause to sort on Originator Detail Field>*/
        /* fetch lead records where owner is queue */
        fullLeadInbox_List = [SELECT Id, company,Title, City, toLabel(Industry), CreatedDate, IsConverted, 
                                     IsUnreadByOwner,State, LeadSource, OwnerId, Owner.Type, ConvertedOpportunityId, 
                                     ConvertedOpportunity.Name, Name, Campaign_Event_Name__c, Email, Status ,Originator_Details__c, 
                                     Lead_Originator__c, Previous_Owner__r.Name, Previous_Owner__c,EMC_Lead_Rejected__c 
                              FROM  Lead 
                              Where (Owner.Type='Queue')  
                                  and DealReg_Deal_Registration__c=false                            
                              ORDER BY Originator_Details__c DESC 
                              limit 1000];
        System.debug('+++++++Fetched record ++++++'+fullLeadInbox_List);
        /* if lead record found */
        if(fullLeadInbox_List.size() >0){ 
            
            for(Lead objLead: fullLeadInbox_List){
                                       
                if(count <=5){
                    /* add lead records to lead of only ten lead */
                    leadInbox10Only_List.add(objLead); 
                    /* set height of only 10 leads display */
                    int10LeadPageSize = int10LeadPageSize + 25;                             
                }
                /* set height for all lead display */
                intFullLeadPageSize = intFullLeadPageSize + 25; 
                /* increase counter */
                count ++;                                                                                       
            }
        }        
    }
    
    /* @Method <This method is used to get the lead record display to user. If isFullLead is true, the display all lead otherwise only 10>.
    @param <It is not taking any parameters>
    @return <List<Lead> which contains the leads records>
    @throws exception - <No Exception>
    */
    public List<Lead> getLeadInbox(){
        List<Lead> tempLead_List = new List<Lead>();
        if(fullLeadInbox_List.size() >0){
                /* for display of full lead */
                if(isFullLead){
                    tempLead_List = fullLeadInbox_List;
                    Pageheight = intFullLeadPageSize;
                }else{
                    /* for display of only 10 lead */
                    tempLead_List =leadInbox10Only_List;
                    Pageheight = int10LeadPageSize;
                }       
        }
        return tempLead_List;           
    }
    
    /* @Method <This method is used to get the 10 lead record display to user.>.
        @param <It is not taking any parameters>
        @return  <PageRefrence : null>
        @throws exception - <No Exception>
    */
    public PageReference limitLeadInbox(){
        isFullLead = false;
        getLeadInbox();
        return null;
    } 
    
    /* @Method <This method is used to display all lead record to user.>.
        @param <It is not taking any parameters>
        @return <PageRefrence :null>
        @throws exception - <No Exception>
    */
    public PageReference fullLead(){
        isFullLead = true;
        getLeadInbox();
        return null;
    }
    
    /* @Method <This method is used to accept lead.>.
        @param <It is not taking any parameters>
        @return <PageRefrence :url of lead record>
        @throws exception - <No Exception>
    */ 
    public void accept(){
                
        Lead acceptedLead = new Lead();    
        /* get lead id from page  */  
        selectedRow = System.currentPageReference().getParameters().get('selectedRow');

        /* select lead using lead id  */
        acceptedLead = [select Id, ownerid from Lead where Id=:selectedRow];
        
        /* set owner id of lead as login user  */
        acceptedLead.Ownerid = UserInfo.getUserId();
        
        /* set accepted lead flag true of lead  */
        acceptedLead.Accept_Lead__c = true;
        
        /*Added this as per Req#1143 
        uncheck EMC Lead Rejected when a lead has been accepted*/
        acceptedLead.EMC_Lead_Rejected__c = false;
        
         /* Update lead record */
         try{
            Update acceptedLead;
            isSuccess = true;
            successLeadId = selectedRow;
            successMsgLead = System.Label.Lead_Accepted_Message;
            
         }catch(Exception ex){
            /* No need to add error message, apex page message will take care of that */
            System.debug(ex);
            isSuccess = false;
         }
    }
    
    /* @Method <This method is used to redirect on lead.>.
        @param <It is not taking any parameters>
        @return <PageRefrence :url of lead record>
        @throws exception - <No Exception>
    */
    public PageReference transferToLead(){
        successLeadId = selectedRow;
        PageReference leadPage = new PageReference('/00Q/o');
        leadPage.setRedirect(true);
        return leadPage; 
    }
        
}