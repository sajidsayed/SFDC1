global class EmpIntegrationResult{
    
    webservice String EmployeeBadgeId;
    webservice Boolean IsSuccess;
    webservice String ErrorMessage;
    
    public EmpIntegrationResult(String EmpId, Boolean issucs,String ErrMess){
        this.EmployeeBadgeId=EmpId;
        this.IsSuccess=issucs;
        this.ErrorMessage=ErrMess;
    }
    
    public EmpIntegrationResult(){}
    
    //getters
    global String getEmployeeBadgeId(){
        return this.EmployeeBadgeId;
    }
    global Boolean getIsSuccess(){
        return this.IsSuccess;
    }
    global String getErrorMessage(){
        return this.ErrorMessage;
    }
    
    //setters
    global void setEmployeeBadgeId(String empId){
        this.EmployeeBadgeId=empId;
    }
    global void setIsSuccess(Boolean succ){
        this.IsSuccess=succ;
    }
    global void setErrorMessage(String err){
        this.ErrorMessage=err;
    }

}