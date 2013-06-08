/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  20.09.2010      Anand Sharma    #779        This will used to update Lead Records for accept lead.
 |  05.09.2010      Anirudh         Def-136     Updated Accept Method to set the Owner as 
 |                                              current logged in user.  
 |  11.10.2010      Ashwini Gowda   #1143       Blank out the EMC Lead Rejected checkbox 
 |                                              after a lead has been accepted by a different user.
 |  26.05.2011		Anand Sharma				Added check for Deal reg
 +=========================================================================================================================*/

global class PRM_AcceptLead{

     /* @Method <This method is used to update accept lead field of the lead record.>
    @param <It is taking LeadId as parameters>
    @return String of Success/Exception>
    @throws exception - <No Exception>
    */
    webservice static string Accept(Id leadId) { 
        //fetch lead record using Lead id
        Lead objLead = [select id, DealReg_Deal_Registration__c, Accept_Lead__c from lead where id  =: leadId limit 1];        
        string result; 
               
        try{   
            if(objLead.DealReg_Deal_Registration__c){
                result='Accept Lead is not available for Deal Registrations.';
                return result;
            }     
            //Set Accept Lead flag as true.
            objLead.Accept_Lead__c = true;
            // Defect Fix for Def#136 for October 2010 release
            //Set Owner of the Lead as the Logged in user.
            objLead.Ownerid = UserInfo.getUserId();  
            //Uncheck EMC_Lead_Rejected field as per req# 1143
            objLead.EMC_Lead_Rejected__c=false;
            // update lead record
            update objLead; 
                
            //set return value as success
            result = 'success';  
                  
        } catch (Exception e){  
            
            //return validation rule exception
            result = e.getMessage();
            if(result.contains('You Cannot Accept and Reject a Lead simultaneously')){
                result = 'You Cannot Accept and Reject a Lead simultaneously';
            }else{
                result = e.getMessage();
            }
        }       
        return result;
    }
}