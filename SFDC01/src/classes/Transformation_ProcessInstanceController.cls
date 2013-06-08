public class Transformation_ProcessInstanceController{

    public String processId;
    public Static String parId;
    public ProcessInstance objProcessInstance;
    public Pricing_Requests__c objPAR{get; set;}
    public Static string comments;
    public PageReference redirectPage;
    
    public Transformation_ProcessInstanceController(){
        parId = ApexPages.currentPage().getParameters().get('id');
        system.debug('parId--->'+parId);
        objPAR= [select Id,Name,Owner.Name,Recall_Comments__c,Recalled_Flag__c from Pricing_Requests__c where id =:parId ];
        if(objPAR != null){
            comments=objPAR.Recall_Comments__c;
        }
        redirectPage = new PageReference('/'+parId );
    }


    public PageReference recall(){
    	
       objPAR.Recalled_Flag__c=true;
       update objPAR;
        parId = ApexPages.currentPage().getParameters().get('id');
       redirectPage = new PageReference('/'+parId );
       System.debug('redirectPage-->'+redirectPage);
      return redirectPage ;
       
   }
    
     public PageReference Cancel(){
     	 parId = ApexPages.currentPage().getParameters().get('id');
       redirectPage = new PageReference('/'+parId );
     return redirectPage ;
    }
}