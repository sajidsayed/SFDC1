global class IntegrationResult{

webservice Boolean IsSuccess;

webservice String ErrorMessage;

webservice String SFDCOpportunityId;

webservice String SynergyOpportunityId;

webservice String Warning;



public IntegrationResult(Boolean issucs,String ErrMess,String sfdcoppid,String SynoppId){

this.IsSuccess=issucs;

this.ErrorMessage=ErrMess;

this.SFDCOpportunityId=sfdcoppid;

this.SynergyOpportunityId=SynoppId;

}

public IntegrationResult(){}

 global Boolean getIsSuccess(){

 return this.IsSuccess;

 }

 global String getErrorMessage(){

 return this.ErrorMessage;

 }

 global String getSFDCOpportunityId(){

 return this.SFDCOpportunityId;

 }

 global String getSynergyOpportunityId(){

 return this.SynergyOpportunityId;

 }

 //Setter

 global void setIsSuccess(Boolean succ){

 this.IsSuccess=succ;

 }

 global void setErrorMessage(String err){

 this.ErrorMessage=err;

 }

 global void setSFDCOpportunityId(String sfdoptId){

 this.SFDCOpportunityId=sfdoptId;

 }

 global void setSynergyOpportunityId(String synoptId){

 this.SynergyOpportunityId=synoptId;

 }

}