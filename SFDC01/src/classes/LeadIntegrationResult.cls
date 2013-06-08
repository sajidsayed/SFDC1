global class LeadIntegrationResult{

Webservice  String   OrigSysRef   {get; set;} 
Webservice  String   SFDCLeadId   {get; set;}
Webservice  Boolean  IsSuccess    {get; set;}
Webservice  String   ErrorMessage {get; set;} 

public LeadIntegrationResult(){}
public LeadIntegrationResult(String osr, String leadid,
                                  Boolean issucs, String ErrMess){
    this.OrigSysRef= osr;
    this.SFDCLeadId =leadid;
    this.IsSuccess=issucs;
    this.ErrorMessage=ErrMess;
}

}