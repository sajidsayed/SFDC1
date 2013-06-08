global class EmployeeOperation{

    webservice Static List<EmpIntegrationResult> synchEmployees(List<Contact> EmpDetails){
        List<EmpIntegrationResult> resultlist=new List<EmpIntegrationResult>();
        resultlist= new EmployeeIntegrationOperation().upsertEmployees(EmpDetails);
        return resultlist;
    }  

}