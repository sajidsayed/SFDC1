/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  20.09.2010      Anand Sharma    #780        Controller for the lead accept/reject page. 
 												This will used to reject lead.           
 +========================================================================================================================*/


public Class PRM_LeadAcceptReject{
    
    /* hold success of lead rejection */
    public Boolean isSuccess {get;set;}
    
    /* Hold message for lead rejection */
    public String msgLeadRejection {get; set;}
    
    /* hold rejection action originator page */
    public Boolean isHomeTabTarget {get;set;}
    
    /* hold value of homePagePage */
    public String homePageTarget{get; set;}
    
    /* hold Lead record */    
    public Lead leadObject {get;set;}
    
    /* constructor of the class */
    public PRM_LeadAcceptReject() {
        /* fetch lead id from url */
        String leadId =ApexPages.currentPage().getParameters().get('Id'); 
            
        /* fetch target page value from url */
        homePageTarget =ApexPages.currentPage().getParameters().get('parent');
        
        /* set lead reject as false */
        isSuccess = false;
        
        /* set target page values */
         if(homePageTarget=='true'){
            isHomeTabTarget = true;
        }else{
            isHomeTabTarget= false;
        }

        /* fetch lead records using id */
        leadObject = [Select Id, Reject_Lead__c,Accept_Lead__c,Rejection_Reason__c from Lead where Id =: leadId ];
        /* set Rejected Lead flag is true */
        leadObject.Reject_Lead__c = true;
    }
    
    
    /* @Method <This method is used to reject lead.>.
        @param <It is not taking any parameters>
        @return <void>
        @throws exception - <No Exception>
    */
    public void Reject(){
        if(leadObject != null){
            /* set accept lead field as false */
            leadObject.Accept_Lead__c = false;
            
            /* set reject lead field as true */
            leadObject.Reject_Lead__c = true;
            try{
                /* update lead with reject values */
                update leadObject;
                
                /* set lead reject as true */
                isSuccess = true;    
                
				/* set message for reject rejection */
				msgLeadRejection = System.Label.Lead_Rejected_Message;
				                        
            }catch(Exception ex){
                /* No need to add error message, apex page message will take care of that */
                System.debug(ex);
            }
                
        }
    }
}