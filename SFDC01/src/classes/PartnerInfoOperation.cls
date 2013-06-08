/*=====================================================================================================================================

History 
6th Aug 12  Kaustav Debnath    Initial creation of webservice method to fetch partner info                                 

======================================================================================================================================*/
global class PartnerInfoOperation {
     /* @Method <This method is used to by an external interface to get information from SFDC>
   @param <This is taking a string event message denoting what information the interface requires>
   @return <List<PartnerInfoHeader>> -- <This method return a wrapper list of the same class>.
   @throws exception - <No Exception>
    */
    webservice Static List<PartnerInfoHeader> getInfoFromSFDC (String strEventMessage){
        
        List<PartnerInfoHeader> lstPartnerInfoHeader=new List<PartnerInfoHeader>();
        if(strEventMessage=='PartnerInfoQuery')
        {
            lstPartnerInfoHeader=PartnerInfoIntegrationOperation.getPartnerInformation();
        }
        return lstPartnerInfoHeader;
    }

}