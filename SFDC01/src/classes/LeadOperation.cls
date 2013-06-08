global class LeadOperation{
    webservice Static List<LeadIntegrationResult> LeadIntegration(List<LeadHeader> lead_headers) 
    {
        List< LeadIntegrationResult> resultlist=new List<LeadIntegrationResult>();
        resultlist= new LeadIntegrationOperation().LeadIntegration(lead_headers);
        return resultlist;
    }  
}