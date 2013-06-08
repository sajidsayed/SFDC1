/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     DESCRIPTION                               
 |  ====       =========     =========== 
 |  28-OCT-09  Prasad K       Initial creation
 |  19-Jan-10  Prasad K       Uncommneted quote version and commented Next steps as per J Mail.   
 |  09-Mar-10  Sajid S        Commented updateSFDCOpp for WR 127727
 |  26-Jul-10  Shipra         Commented the Not Required fields for Defect 738 & uncommented the required one's.
 |  16-Aug-10  Pratibh        New code added at line nos: 648-651, 714-718  to default 'Update Forecast Amount' Checkbox on 
 |                            Opportunity when creating from or linking to Quote.
 |  06-Sep-10  Pratibh        WR 141883, Code Updated at lines: 42-46, 712-718, 726-738
 |  22-Oct-10  Pratibh        WR 150060, Break Fix to comment OwnerId field to stop getting it updated from Integration.
 |  23-Dec-10  Srinivas       WR 151217, commented the code for changing the 'Update Forecast Amount' Checkbox. moving the logic to trigger on opportunity
 |  27-Dec-10  Srinivas       WR 153588 , Checking the 'createSFDCProduct' methods return value is null or not. not adding to productslist if it is null to avoid DML exceptions at the time of inserting products.
                              Added try - catch - finally block to Add EMC Exception When Inactive product is added to Opportunity 
    12-Jan-11  Srinivas       WR-155951 , Changed "userIdsFromInterface" from set of Strings to set of IDs, align with UserHelper changes for WR155951                           
    19 Dec 11  Dann Quin      WR-134590,SFA - System Integration issues with SFDC when DXP Quote archives (FD required)
               Shipra Misra   WR-177092,SFA - Enhance Oracle->SFDC Opportunity Updates to Filter on Status (FD required)
 |  07 Feb 12  Shipra misra   WR-185642,SFA - Delete Quote Amount from Product Lines when Quote is unlinked from Oppty  
 |  24 May 12  Shipra Misra   Project- 191098.Integration of Salesforce with RQF.
 |  08 Jan 13  Hemavathi      WR-222446 - Oppty linking / Unlinking based on Quote Number field                        
 +===========================================================================*/


global class OpportunityIntegrationOperation{

    final String Integration_Opportunity_Creation_Error_in_SFDC='INTEGRATION_OPPORTUNITY_CREATION_ERROR_IN_SFDC';
    final String Integration_Exception_During_Create_Opportunity_in_SFDC='INTEGRATION_EXCEPTION_DURING_CREATE_OPPORTUNITY_IN_SFDC';
    final String Integration_Product_Creation_Error_in_SFDC='INTEGRATION_PRODUCT_CREATION_ERROR_IN_SFDC';
    final String Integration_Credit_Creation_Error_in_SFDC='Integration_CREDIT_CREATION_ERROR_IN_SFDC';
    
    integer MaxOpportunityNameLength = Opportunity.Name.getDescribe().getLength();
    
    List<EMCException> errors=new List<EMCException>();
    Map<String,IntegrationResult> results=new Map<String,IntegrationResult>();
    Map<String,String> SfdcIdMap=new Map<String,String>();
    Map<String,String> SynergyIdMap=new Map<String,String>();
    //** WR 185642
    Set<Id> unlinkedOpptySet = new Set<Id>();
    //*** WR 185462
    List<OpportunityLineItem> DeleteProducts =  new List<OpportunityLineItem>();
    List<OpportunityLineItem> InsertProducts =  new List<OpportunityLineItem>();
    List<OpportunityLineItem> UpdateProducts =  new List<OpportunityLineItem>();
    Set<String> userIdsFromInterface = new Set<String>();//Added-Pratibh: 6-Sep-2010 //  12-Jan-11 : Srinivas : Changed for WR-155951, from set of Strings to set of IDs
    
public List<IntegrationResult> createOpportunities(List<OpportunityDetails> OppDetails){
    
    List<Opportunity> OpportunitiesToCreate=new List<Opportunity>();    
    List<OpportunityLineItem> ProductList=new List<OpportunityLineItem>();
    List<OpportunitySplit> CreditList=new List<OpportunitySplit>();
    Database.SaveResult[] sr;
    System.Savepoint OpportunityCreate = Database.setSavepoint();
    try{
        //Code Added-Pratibh: 06-Sep-2010, Segregating all the OwnerSfdcId from interface in a set 
        //and then retreiving User Info corresponding to these Ids in SFDC.
        for (OpportunityDetails OppDetail:OppDetails){
            userIdsFromInterface.add(OppDetail.POpptyHeaderBo.OwnerSfdcId);
        }
        UserHelper.retrieveUserData(userIdsFromInterface);
        
        for(OpportunityDetails OppDetail:OppDetails){
                Opportunity New_SFDC_OppCreated=createNewOpportunity(OppDetail);
                OpportunitiesToCreate.add(New_SFDC_OppCreated);
        }
        
        sr= executeDMLOperation(OpportunitiesToCreate,'Insert','Opportunity');    
        if(!sr[0].isSuccess()){
            Database.rollback(OpportunityCreate);
                
        }
           
        //Product and Credits insertion Start
        
        for(OpportunityDetails OppDetail:OppDetails){
            String sfdcOpportunityId=SfdcIdMap.get(OppDetail.POpptyHeaderBo.OracleOppId);
            System.debug('OppDetail.POpptyProductBoTblItem'+OppDetail.POpptyProductBoTblItem);
            System.debug('sfdcOpportunityId'+sfdcOpportunityId);
           // System.debug('OppDetail.POpptyHeaderBo.OracleOppId'+OppDetail.POpptyHeaderBo.OracleOppId);
            //System.debug('OppDetail.POpptyProductBoTblItem.forecastamount'+OppDetail.POpptyProductBoTblItem.forecastamount);
            if(OppDetail.POpptyProductBoTblItem==null || OppDetail.POpptyProductBoTblItem.size()==0){
                continue;
            }
            for(OpptyProductTbl prodlist:OppDetail.POpptyProductBoTblItem){ 
                OpportunityLineItem NewProduct=createSFDCProduct(prodlist,sfdcOpportunityId,OppDetail.POpptyHeaderBo.CurrencyCode);
                // Added by Srinivas for WR - 153588
                if(NewProduct != null)
                    ProductList.add(NewProduct);
            }
            
            //Splits
            /* for(OpptyCreditsTbl Credlist:OppDetail.POpptyCreaditsBoTblItem){
                OpportunitySplit NewCredit=createNewCreditSpilt(Credlist,sfdcOpportunityId);
                CreditList.add(NewCredit);                                    
            }*/
            
        }    
       //Insert Products
        sr= executeDMLOperation(ProductList,'Insert','OpportunityLineItem');
        System.debug('sr '+sr);
        if(sr!=null && !sr[0].isSuccess()){
            Database.rollback(OpportunityCreate);
        }           
       // Insert Splits 
       // sr= executeDMLOperation(CreditList,'Insert','DetailLine');   
       //  if(!sr[0].isSuccess()){
       //     Database.rollback(OpportunityCreate);
       // }              
    }catch(Exception ex){
        System.debug('Main Exception'+ex);
        Database.rollback(OpportunityCreate);   
       
         // Add in integration Result
           IntegrationResult result= results.get(OppDetails[0].POpptyHeaderBo.OracleOppId);
           if(result==null){
                result = new IntegrationResult();
           }
              
       result.ErrorMessage=result.ErrorMessage+' '+ex.getMessage();
       result.IsSuccess=false;
       result.SynergyOpportunityId= OppDetails[0].POpptyHeaderBo.OracleOppId;
       result.SFDCOpportunityId='';
       result.Warning='';
                       System.debug(' results.put line 86 ');
       results.put(result.SynergyOpportunityId,result); 
        
        EMCException ExceptionError=new EMCException(ex.getmessage(),Integration_Exception_During_Create_Opportunity_in_SFDC,new String[]{'Excetion'});
        errors.add(ExceptionError);
    }finally{
        EMC_UTILITY.logErrors(errors);      
    }
    return results.values();
}

public IntegrationResult udpateCreateOpportunityStatus(OpportunityDetails OppDetails){
   List <Opportunity> opps=new OpportunityIntegrationOperation().getSFDCOpportunities(new List<String>{OppDetails.POpptyHeaderBo.SfdcOpptyId},new List<String>());
   IntegrationResult result = new IntegrationResult();
   if(opps==null || opps.size()==0 ){
       result.IsSuccess=false;
       result.SynergyOpportunityId=OppDetails.POpptyHeaderBo.OracleOppId;
       result.SFDCOpportunityId=OppDetails.POpptyHeaderBo.SfdcOpptyId; 
       result.ErrorMessage='Invalid Opportunity Number or SFDC Id';     
       return result;
   } 
   Opps[0].Integration_Error_Message__c = OppDetails.POpptyHeaderBo.ErrorMessage;
   Opps[0].Opportunity_Number__c = OppDetails.POpptyHeaderBo.OracleOppId;  
    
   Database.SaveResult sr =Database.update(opps[0],false); 
   
   System.debug('opps[0].Opportunity_Number__c '+opps[0].Opportunity_Number__c);  
   System.debug('opps[0].Integration_Error_Message__c '+opps[0].Integration_Error_Message__c);  

   
   if(!sr.isSuccess()){
       result.ErrorMessage='';
       for (Database.Error err : sr.getErrors()) {
            result.ErrorMessage+= ','+err.getMessage();
       }              
       result.IsSuccess=false;
       result.SynergyOpportunityId=OppDetails.POpptyHeaderBo.OracleOppId;
       result.SFDCOpportunityId=OppDetails.POpptyHeaderBo.SfdcOpptyId;  
   }else{
       result.ErrorMessage='';
       result.IsSuccess=true;
       result.SynergyOpportunityId=OppDetails.POpptyHeaderBo.OracleOppId;
       result.SFDCOpportunityId=OppDetails.POpptyHeaderBo.SfdcOpptyId;  
   }
   return result;
}

public IntegrationResult udpateCreateQuoteStatus(OpportunityDetails OppDetails){
   IntegrationResult result = new IntegrationResult(); 
   List <Opportunity> opps=new OpportunityIntegrationOperation().getSFDCOpportunities(new List<String>{OppDetails.POpptyHeaderBo.SfdcOpptyId},new List<String>());
  if(opps==null || opps.size()==0 ){
       result.IsSuccess=false;
       result.SynergyOpportunityId=OppDetails.POpptyHeaderBo.OracleOppId;
       result.SFDCOpportunityId=OppDetails.POpptyHeaderBo.SfdcOpptyId; 
       result.ErrorMessage='Invalid Opportunity Number or SFDC Id';     
       return result;
   } 
   String orgQuoteCartVal = Opps[0].Quote_Cart_Number__c;
   Opps[0].Integration_Error_Message__c = OppDetails.POpptyHeaderBo.ErrorMessage;
   Opps[0].Quote_Cart_Number__c = OppDetails.POpptyHeaderBo.QuoteNumber;
   //RQF. Shipra 22 May 12. 
   //Opps[0].Quote_Type__c='DXP';commented as part of RQF.
   //Opps[0].Quote_Version__c='1';
   Opps[0].Quote_Version__c=OppDetails.POpptyHeaderBo.QuoteVersion;
   Opps[0].Quote_Type__c=OppDetails.POpptyHeaderBo.QuoteType;
   //** End RQF.
   
   
    /*23-Dec-10  Srinivas       WR 151217, commented the code for changing the 'Update Forecast Amount' Checkbox. moving the logic to trigger on opportunity
    //Code Changes-Pratibh: 27-Sep-10, Set Update Update_Forecast_Amount_from_Quote__c = true when Opportunity is linked to DXP quote by integration.
    //Boolean userPrefForcastAmount = Opps[0].Update_Forecast_Amount_from_Quote__c;//Storing the original value of Checkbox field as preferred by user.
    if (Opps[0].Quote_Cart_Number__c!= null && orgQuoteCartVal!=null){
        Opps[0].Update_Forecast_Amount_from_Quote__c= true;
    }
    //Opps[0].Update_Forecast_Amount_from_Quote__c = userPrefForcastAmount;
     end of WR 151217 */
   Database.SaveResult sr =Database.update(Opps[0]); 
   
   if(!sr.isSuccess()){
       result.ErrorMessage='';
       for (Database.Error err : sr.getErrors()) {
             result.ErrorMessage+= ','+err.getMessage();
       }              
       result.IsSuccess=false;
       result.SynergyOpportunityId=Opps[0].Opportunity_Number__c;
       result.SFDCOpportunityId=OppDetails.POpptyHeaderBo.SfdcOpptyId;  
   }else{
       result.ErrorMessage='';
       result.IsSuccess=true;
       result.SynergyOpportunityId=Opps[0].Opportunity_Number__c;
       result.SFDCOpportunityId=OppDetails.POpptyHeaderBo.SfdcOpptyId;  
   }
   return result;
}


private Database.SaveResult[] executeDMLOperation(List<SObject>Data,String Operation,String TypeofData){
        integer index=0;
        String OppdataErrs='';
        
        Database.SaveResult[] ResultToProcess=null;
        Database.DeleteResult[] DeleteResultToProcess=null;
        
        if(Data==null || Data.size()==0){
            return ResultToProcess;
        }
        
        try{
        
        if(Operation=='Insert'){
            if(TypeofData=='OpportunityLineItem'){
                System.debug('OP_SSF_CommonUtils.getInstance() '+OP_SSF_CommonUtils.getInstance());
                OP_SSF_SaveResult save_result=OP_SSF_CommonUtils.getInstance().addProducts((OpportunityLineItem[])data,true);
                System.debug('save_result '+save_result);
                ResultToProcess=save_result.dmlSaveResult;                                    
            }else{
                 System.debug('Data****'+Data);
                 ResultToProcess= Database.Insert(Data,false);
            }
        }else if(Operation=='Update'){
            System.debug('Data****'+Data);
            /*if(TypeofData=='OpportunityLineItem'){
                System.debug('data '+data);
                OP_SSF_SaveResult save_result=OP_SSF_CommonUtils.getInstance().addProducts((OpportunityLineItem[])data,false);
                System.debug('save_result '+save_result);
                ResultToProcess=save_result.dmlSaveResult;    
            }else{*/
                System.debug('TypeofData'+TypeofData);
                ResultToProcess = Database.Update(Data,false);
                System.debug('ResultToProcess'+ResultToProcess);
            //}
        }else if(Operation=='Delete'){
            if(TypeofData=='OpportunityLineItem'){
                    
                OP_SSF_CommonUtils.getInstance().removeProducts((OpportunityLineItem[])data,true);
                
            }else{
                DeleteResultToProcess = Database.Delete(Data,false);   
            }
        }
        
        }catch(OP_SSF_Exception ex){
             EMCException ExceptionError=new EMCException(ex.getMessage(),'Integration Error during linking the line item to opportunity',null);
             errors.add(ExceptionError);
            
        }
        // geting the SfdcIdMap and SynergyIdMap Map
        
         if(TypeofData=='Opportunity' && Operation=='Insert'){
            index=0;
            
            for(Database.SaveResult sr: ResultToProcess){
                SfdcIdMap.put(((Opportunity)Data[index]).Opportunity_Number__c,sr.getid());
                SynergyIdMap.put(sr.getid(),((Opportunity)Data[index]).Opportunity_Number__c);
                index++;
            }
         }
        
        // Log the error and create Integration result
        index=0;
        if (ResultToProcess==null){
            return null;
        }
        for(Database.SaveResult sr:ResultToProcess){
            if(TypeofData=='OpportunityLineItem'){
                 processResult(Data[index], sr.isSuccess(),sr.getErrors(),TypeofData,((OpportunityLineItem)Data[index]).opportunityId);                              
            }else{
                 processResult(Data[index], sr.isSuccess(),sr.getErrors(),TypeofData,sr.getId());                              
            }
            index++;
        }//for Save Result
        index=0;
        if(DeleteResultToProcess!=null){
            for(Database.DeleteResult sr:DeleteResultToProcess){
            if(TypeofData=='OpportunityLineItem'){
                 processResult(Data[index], sr.isSuccess(),sr.getErrors(),TypeofData,((OpportunityLineItem)Data[index]).opportunityId);                              
            }else{
                 processResult(Data[index], sr.isSuccess(),sr.getErrors(),TypeofData,sr.getId());                              
            }

                index++;
            }//for Delete Result
        }
        System.debug('ResultToProcess'+ResultToProcess);
        return ResultToProcess;
}

private void processResult(Sobject Data, boolean isSuccess,List <Database.Error> DatabaseErrors, String TypeofData,String SfdcOppId){
     
     String OppdataErrs='';
     String affectedId=''; 
     List <String> affetedIds= new List <String>();
     System.debug('processResult '+SfdcOppId + '   TypeofData   '+ TypeofData);

       if(TypeofData=='Opportunity'){
            affectedId=((Opportunity)Data).Opportunity_Number__c;
            affetedIds.add(affectedId);
             
       }else if(TypeofData=='OpportunityLineItem'){
            affectedId=SynergyIdMap.get(((OpportunityLineItem)Data).opportunityId);
            affetedIds.add(affectedId);
       }
       IntegrationResult result=results.get(affectedId);
       if(result==null){
            result= new IntegrationResult();
       }    

       if (!isSuccess) {
               // if the particular record did not get inserted, we log the data error 
                   for (Database.Error err : DatabaseErrors) {
                        OppdataErrs += ','+err.getMessage();
                   }
                   OppdataErrs=OppdataErrs.substring(1);
                   System.debug('OppdataErrs---'+OppdataErrs); 
                   
                   
                // Integration Result
                  
                   if(TypeofData=='Opportunity'){
                    result.ErrorMessage=OppdataErrs;
                   }else{
                    result.Warning=OppdataErrs;
                   }
                   result.IsSuccess=false;
                   result.SynergyOpportunityId=affectedId;
                   result.SFDCOpportunityId='null';
                                     
                //Log in custom object             
                EMCException exception1 =new EMCException(OppdataErrs, Integration_Opportunity_Creation_Error_in_SFDC,null);                           
                errors.add(exception1);
                
            }else{
                   System.debug('Else  '+SfdcOppId);
                  
                   result.ErrorMessage='';
                   result.IsSuccess=true;
                   result.SynergyOpportunityId=affectedId;
                   result.SFDCOpportunityId=SfdcOppId;
                  
            }
             System.debug(' results.put line 239 '+TypeofData + '  '+ result.SynergyOpportunityId);
             results.put(result.SynergyOpportunityId,result);
             System.debug('IntegrationResult  '+results.get(affectedId)); 
} 

//Webservice for UpdateOpportunity in SFDC
 public List<IntegrationResult> updateOpportunities(List<OpportunityDetails> OppDetails){
      Final String IntegrationError_During_Opportunity_Update_In_SFDC='Integration_Error_During_Update_In_SFDC';
      Final String IntegrationError_During_Split_Delete_In_SFDC='IntegrationError_During_Split_Delete_In_SFDC';
      Final String IntegrationError_During_New_Split_Insert_In_SFDC='IntegrationError_During_New_Split_Insert_In_SFDC';
      Final String IntegrationError_During_Update_Split_In_SFDC='IntegrationError_During_Update_Split_In_SFDC';
      List<String> IdsToUpdate=new List<String>();
      List<Opportunity> OppToUpdate=new List<Opportunity>();
      List<EMCException> errors=new List<EMCException>();
      Map<String,OpportunityHeader> SynergyOpportunityMap=new Map<String,OpportunityHeader>();
      Map<id,Opportunity> SFDCMap=new Map<id,Opportunity>();
      Map<String,List<OpptyCreditsTbl>> SynergyCreditMap=new Map<String,List<OpptyCreditsTbl>>();
      Map<id,List<OpportunitySplit>> SFDCCredit_Map=new Map<id,List<OpportunitySplit>> ();
      List<OpptyCreditsTbl> Synergy_Credit_List =new List<OpptyCreditsTbl>();
      List<OpportunitySplit> SFDC_Credit_List =new List<OpportunitySplit>();
      List<OpportunitySplit> SFDC_Credit_To_Delete=new List<OpportunitySplit>();
      List<OpportunitySplit> New_SFDC_Credit_List=new List<OpportunitySplit>();
      List<OpportunitySplit> Updated_Credit_Detail_from_Synergy= new List<OpportunitySplit>();
      
      Map<String,List<OpportunityLineItem>>SFDCProductMap = new Map<String,List<OpportunityLineItem>>();
      Map<String,List<OpptyProductTbl>>SynergyProductMap = new Map<String,List<OpptyProductTbl>>();
      List <String> SynergyIdsToUpdate  = new List <String>();
      
      //Iteration Incoming Detail and fetch all the SFDCids in list.
      //Map containing SFDCid Coming from Synergy with all Opportunity record Detail.
      System.debug('UPdate');
      System.debug('OppDetails.POpptyProductBoTblItem'+OppDetails);
    try
    {
          for(OpportunityDetails OppDetail:OppDetails)
          {
              if( (OppDetail.POpptyHeaderBo.SFDCOPPTYID=='' || OppDetail.POpptyHeaderBo.SFDCOPPTYID==null) &&
                    (OppDetail.POpptyHeaderBo.OracleOppId =='' || OppDetail.POpptyHeaderBo.OracleOppId ==null) )
              {
                         
                  //add error
                  EMCException ExceptionError=new EMCException('No SFDC or Synergy Opportunity Id','No SFDC or Synergy Opportunity Id to update Opportunity',new String[] {OppDetail.POpptyHeaderBo.OracleOppId});
                  errors.add(ExceptionError);
                    
                  // Add in integration Result
                  IntegrationResult result= results.get(OppDetail.POpptyHeaderBo.OracleOppId);
                  if(result==null){
                       result = new IntegrationResult();
                  }
                  
                  result.ErrorMessage=result.ErrorMessage+ ' No SFDC or Synergy Opportunity Id';
                  result.IsSuccess=false;
                  result.SynergyOpportunityId= OppDetail.POpptyHeaderBo.OracleOppId;
                  result.SFDCOpportunityId='';
                  result.Warning='';
                  System.debug(' results.put line 288 ');
                  results.put(result.SynergyOpportunityId,result); 
                  continue;
              }
              
    
              if(OppDetail.POpptyHeaderBo.SFDCOPPTYID!='' && OppDetail.POpptyHeaderBo.SFDCOPPTYID!=null   )
              {    
                  IdsToUpdate.add(OppDetail.POpptyHeaderBo.SFDCOPPTYID);
                  SynergyOpportunityMap.put(OppDetail.POpptyHeaderBo.SfdcOpptyId,OppDetail.POpptyHeaderBo);  
                  SynergyProductMap.put(OppDetail.POpptyHeaderBo.SfdcOpptyId,OppDetail.POpptyProductBoTblItem);  
                //  System.debug('SynergyProductMap'+OppDetail.POpptyProductBoTblItem);
              }
              else if(OppDetail.POpptyHeaderBo.OracleOppId !='' && OppDetail.POpptyHeaderBo.OracleOppId !=null   )
              {    
                  SynergyIdsToUpdate.add(OppDetail.POpptyHeaderBo.OracleOppId);
                  SynergyOpportunityMap.put(OppDetail.POpptyHeaderBo.OracleOppId,OppDetail.POpptyHeaderBo);
                  SynergyProductMap.put(OppDetail.POpptyHeaderBo.OracleOppId,OppDetail.POpptyProductBoTblItem);  
              }
          
          
             // System.debug('Line 283  SynergyOpportunityMap '+SynergyOpportunityMap.get(OppDetail.POpptyHeaderBo.SfdcOpptyId));
          
              if((OppDetail.POpptyHeaderBo.SFDCOPPTYID!='' || OppDetail.POpptyHeaderBo.SFDCOPPTYID!=null) &&
                     (OppDetail.POpptyHeaderBo.OracleOppId !='' || OppDetail.POpptyHeaderBo.OracleOppId !=null)  )
               {      
                         SfdcIdMap.put(OppDetail.POpptyHeaderBo.OracleOppId ,OppDetail.POpptyHeaderBo.SfdcOpptyId);
                         SynergyIdMap.put(OppDetail.POpptyHeaderBo.SfdcOpptyId,OppDetail.POpptyHeaderBo.OracleOppId );     
               }
          }
          //fetchRecordsToUpdate will return the list of Opportunity exist in SFDC for above ID list
          OppToUpdate=getSFDCOpportunities(IdsToUpdate,SynergyIdsToUpdate);
          
          // create entires against SyndergyIds
          if(SynergyIdsToUpdate.size()>0)
          {
            System.debug('SynergyIdsToUpdate--->'+SynergyIdsToUpdate);
              for(String SynergyNumber: SynergyIdsToUpdate)
              {
                    boolean found=false;
                    for(Opportunity sfdcOpp:OppToUpdate)
                    {
                        if(sfdcOpp.Opportunity_Number__c==SynergyNumber)
                        {
                             IdsToUpdate.add(sfdcOpp.id);
                             
                             SfdcIdMap.put(sfdcOpp.Opportunity_Number__c ,sfdcOpp.Id);
                             SynergyIdMap.put(sfdcOpp.Id,sfdcOpp.Opportunity_Number__c);    

                             SynergyOpportunityMap.put(sfdcOpp.Id,SynergyOpportunityMap.get(SynergyNumber));
                             SynergyProductMap.put(sfdcOpp.Id,SynergyProductMap.get(SynergyNumber));  

                            SynergyOpportunityMap.remove(SynergyNumber);
                            SynergyProductMap.remove(SynergyNumber);
                            
                            found=true;
                            break;                                
                        }             
                     }
                     if(!found)
                     {
                         //add error
                       EMCException ExceptionError=new EMCException('Opportunity does not exist with Synergy Opportunity Id','Opportunity does not exist with Synergy Opportunity Id',new String[]{SynergyNumber});
                       errors.add(ExceptionError);
                        
                       // Add in integration Result
                       IntegrationResult result= results.get(SynergyNumber);
                       if(result==null)
                       {
                            result = new IntegrationResult();
                       }
                       
                       result.ErrorMessage=result.ErrorMessage+ 'Opportunity does not exist with Synergy Opportunity Id';
                       result.IsSuccess=false;
                       result.SynergyOpportunityId= SynergyNumber;
                       result.SFDCOpportunityId='';
                       result.Warning='';
                                       System.debug(' results.put line 352 ');
                       results.put(result.SynergyOpportunityId,result); 
                    }
              }
          }
    
          // Get SFDC Products
          System.debug('IdsToUpdate '+IdsToUpdate);  
     
          SFDCProductMap=getSFDCProducts(IdsToUpdate);
          //System.debug('SFDCProductMap '+SFDCProductMap.get(IdsToUpdate[0]));       
           
          //Iterate the Opp records of SFDC  
           for(Opportunity sfdcOpp:OppToUpdate)
           {
             OpportunityHeader SynergyOppDetail;  
             /* if((''+sfdcOpp.id).length()==18){ 
                  SynergyOppDetail=SynergyOpportunityMap.get((''+sfdcOpp.id).substring(0,15));
              }*/  
    
              SynergyOppDetail=SynergyOpportunityMap.get(sfdcOpp.id);
             // System.debug('sfdcOpp.id '+sfdcOpp.id);        
             // System.debug(' Line 309 SynergyOpportunityMap.get(sfdcOpp.id);  '+SynergyOpportunityMap.get(sfdcOpp.id));
              System.debug('Before updateSFDCOpp ');
              updateSFDCOpp(sfdcOpp,SynergyOppDetail);
              System.debug('After updateSFDCOpp ');        
             
             // System.debug('SFDCProductMap '+SFDCProductMap.get(sfdcOpp.id));
              //System.debug('SynergyProductMap '+SynergyProductMap.get(sfdcOpp.id));
              updateSFDCProducts(SFDCProductMap.get(sfdcOpp.id),SynergyProductMap.get(sfdcOpp.id),sfdcOpp.id,sfdcOpp.CurrencyISOCode); 
              System.debug('After updateSFDCProducts');
          }
        
          //System.debug('After updateSFDCProducts InsertProducts.size() ' +InsertProducts.size());
         // System.debug('InsertProduct'+InsertProducts);
         // System.debug('UpdateProducts.size'+UpdateProducts);
         /// System.debug('After updateSFDCProducts UpdateProducts.size() ' +UpdateProducts.size());
         // System.debug('After updateSFDCProducts DeleteProducts.size() ' +DeleteProducts.size());
    
            //uPDATED BY sHIPRA.
          if(UpdateProducts!=null && DeleteProducts.size()!=0){  
              executeDMLOperation(DeleteProducts,'Delete','OpportunityLineItem');
          }
          if(OppToUpdate!=null && OppToUpdate.size()!=0){  
              executeDMLOperation(OppToUpdate,'Update','Opportunity');
          }
          
          if(InsertProducts!=null && InsertProducts.size()!=0){  
              executeDMLOperation(InsertProducts,'Insert','OpportunityLineItem');
          }
          if(UpdateProducts!=null && UpdateProducts.size()!=0){  
              executeDMLOperation(UpdateProducts,'Update','OpportunityLineItem');
          }
          
      
    }catch(Exception e)
    {
        // just throwing the error as I added this try-catch block to have finall block to log the errors
        throw e;
    }
    finally
    {
        EMC_UTILITY.logErrors(errors);  
    } 
        
     return results.values();
     
            
           
 }//Update webservice ends.
 
 private void updateSFDCProducts(List<OpportunityLineItem> SfdcProducts ,List<OpptyProductTbl> SyndergyPorducts,String SfdcOppId,String CurrencyCode )
 {
    System.debug('SfdcProducts '+SfdcProducts);
    System.debug('SyndergyPorducts'+SyndergyPorducts);
    if(SfdcProducts==null && SyndergyPorducts==null )
    {
       return;
    }
    
    integer noOfSfdcProducts=0;
    if(SfdcProducts!=null && SfdcProducts[0].CurrencyIsoCode==CurrencyCode){
       //&& SfdcProducts[0].CurrencyIsoCode==CurrencyCode
       noOfSfdcProducts= SfdcProducts.size();
    }
    else if(SyndergyPorducts!=null)
    {
         for( OpptyProductTbl SynergyProduct :SyndergyPorducts)
         {
                System.debug('SynergyProduct***'+SynergyProduct);
                // Added by Srinivas for WR - 153588
                OpportunityLineItem NewProduct=createSFDCProduct(SynergyProduct,SfdcOppId,CurrencyCode);
                if(NewProduct != null)
                {
                    noOfSfdcProducts++;
                    InsertProducts.add(NewProduct);
                }
        }
        System.debug('InsertProducts===>'+InsertProducts);
       // return;
    }
    
    
    integer noOfSyndergyPorducts=0;
    if(SyndergyPorducts!=null){
       noOfSyndergyPorducts= SyndergyPorducts.size();
       //System.debug('noOfSyndergyPorducts'+noOfSyndergyPorducts);
    }
    //System.debug('SfdcProducts===>'+SfdcProducts+'SfdcProducts[0].CurrencyIsoCode===>'+SfdcProducts[0].CurrencyIsoCode+'CurrencyCode===>'+CurrencyCode);
    if(SfdcProducts!=null && SfdcProducts[0].CurrencyIsoCode!=CurrencyCode){
         for( OpportunityLineItem SfdcProduct :SfdcProducts){
                   //|| SfdcProducts[0].CurrencyIsoCode==CurrencyCode
                    noOfSfdcProducts--;
                    DeleteProducts.add(SfdcProduct);
                    //System.debug('DeleteProducts===>'+DeleteProducts);
        }
        return;
    }   


    Map<String,OpptyProductTbl> SynergyProductMap=new Map<String,OpptyProductTbl>(); 
    
    if(SyndergyPorducts!=null){
        for( OpptyProductTbl SynergyProduct :SyndergyPorducts){
            SynergyProductMap.put(SynergyProduct.ProductName,SynergyProduct);
        }
    }
    if(SfdcProducts!=null)
    {
        for( OpportunityLineItem SfdcProduct :SfdcProducts){
            OpptyProductTbl SynergyProduct=SynergyProductMap.get(SfdcProduct.PricebookEntry.Product2.Name);
            //System.debug('SfdcProduct.PricebookEntry.Product2.Name==>'+SfdcProduct.PricebookEntry.Product2.Name);
            //System.debug('SynergyProductMap===>'+SynergyProductMap);
            //System.debug('SynergyProduct==>'+SynergyProduct);
            if(SynergyProduct==null){
                noOfSfdcProducts--;
                DeleteProducts.add(SfdcProduct);
            }else{
                updateSfdcProduct(SfdcProduct,SynergyProduct);
                UpdateProducts.add(SfdcProduct);
                
            }
        }
    }
     System.debug('297 ');
    if(noOfSfdcProducts!=noOfSyndergyPorducts){
        Map<String,OpportunityLineItem> SfdcProductMap=new Map<String,OpportunityLineItem>(); 
        for( OpportunityLineItem SfdcProduct :SfdcProducts ){
            SfdcProductMap.put(SfdcProduct.PricebookEntry.Product2.Name,SfdcProduct);
        }
        
     System.debug('303 ');
        for( OpptyProductTbl SynergyProduct :SyndergyPorducts){
            OpportunityLineItem SfdcProduct=SfdcProductMap.get(SynergyProduct.ProductName);
            if(SfdcProduct==null){
                // Added by Srinivas for WR - 153588
                OpportunityLineItem NewProduct=createSFDCProduct(SynergyProduct,SfdcOppId,CurrencyCode);
                if(NewProduct != null)
                {
                    noOfSfdcProducts++;
                    InsertProducts.add(NewProduct);
                }
            }
        }   
    }
    
 }
    
    
    Private   Map<String,List<OpportunityLineItem>> getSFDCProducts(List<String> Oppids){
        //roducts=null;
        Map<String,List<OpportunityLineItem>> productsMap = new Map<String,List<OpportunityLineItem>>(); 
        for( List<OpportunityLineItem> products :[SELECT UnitPrice,id,Quote_Amount__c,currencyIsocode,OpportunityId,PricebookEntry.Product2.Name 
                          FROM OpportunityLineItem WHERE OpportunityId in :Oppids]){
        
             for( OpportunityLineItem product :products){   
                List <OpportunityLineItem> ProductList= productsMap.get(''+product.OpportunityId);
                if(ProductList==null){
                    ProductList = new List <OpportunityLineItem>();
                }
                ProductList.add(product);
                productsMap.put(product.OpportunityId,ProductList);
             }
       }
        return productsMap ;
    }
    
    public List<Opportunity> getSFDCOpportunities(List<String> SFDCIds,List<String> SynergyIds ){
    List<Opportunity> OppDetail=null;
    System.debug('get OppDetail SynergyIds '+SynergyIds);
        System.debug('get OppDetail SFDCIds '+SFDCIds);
                    OppDetail=[Select Id,o.Approval_Date__c, o.Close_Comments__c, 
                                 o.Closed_Reason__c, o.CloseDate, o.Expiration_Date__c, 
                                 o.Name, o.NextStep, o.CurrencyIsoCode,Integration_Error_Message__c,House_Account_Name__c,
                                 o.Opportunity_Number__c, o.Originator__c, o.OwnerId, 
                                 o.Pricebook2Id, o.Quote_Cart_Number__c, o.Quote_Type__c, 
                                 o.Sales_Channel__c, o.Sales_Force__c, o.Sell_Relationship__c, o.SW_Discount_percent__c,
                                 o.HW_TLA_Start_Date__c, o.Quote_Created_by__c,o.Quote_Start_Date__c, o.Quote_End_Date__c, o.HW_Discount_percent__c, o.Discount_percent__c,
                                 o.Contract_Number__c, o.Contract_Modifier__c, o.Bill_To__c,
                                 o.SO_Number__c, o.LeadSource,o.Tier_2_Partner__c, o.Vmware_Related__c,Update_Forecast_Amount_from_Quote__c, o.StageName,
                                 o.Total_Quote_Amount__c,  o.Software_Discount__c,  o.Services_Discount__c,  
                         o.SW_Revenue__c,  o.Price_Floor__c,  o.Prepaid_SW_MA_Revenue__c,  o.Prepaid_SW_MA_Discount__c,  o.Prepaid_HW_MA_Revenue__c,  
                         o.Prepaid_HW_MA_Discount__c,  o.Hardware_Discount__c,  o.HW_Warranty_Upgrade_Revenue__c,  o.HW_Warranty_Upgrade_Discount__c, o.Services_Revenue__c, o.HW_Revenue__c
                          from Opportunity o where id in:SFDCIds or Opportunity_Number__c 

in:SynergyIds];

    System.debug('get OppDetail '+OppDetail);
    return OppDetail;
    }
    
   private   void updateSFDCOpp(Opportunity sfdcopp,OpportunityHeader Synergyheader){
                System.debug('Synergyheader '+Synergyheader);
                System.debug('sfdcopp  '+sfdcopp);
               /* Commented for Defect #738 as per comments from J' 
                sfdcopp.CurrencyIsoCode=Synergyheader.CurrencyCode;
                sfdcopp.Name=Synergyheader.OpportunityName;
                sfdcopp.Sales_Channel__c=Synergyheader.SalesChannel;
                sfdcopp.Sales_Force__c=Synergyheader.SalesForceOrg;
                sfdcopp.Partner__c=Synergyheader.PartnerSfdcCustId;
                sfdcopp.Vmware_Related__c=Synergyheader.VmwareCode;
                   */
                //New fields introduced as part of RQF.
                sfdcopp.CurrencyIsoCode=Synergyheader.CurrencyCode;
                sfdcopp.SW_Discount_percent__c=Synergyheader.SWDiscount;
                sfdcopp.HW_Discount_percent__c=Synergyheader.HWDiscount;
                sfdcopp.Discount_percent__c=Synergyheader.Discount;
                sfdcopp.Quote_Start_Date__c=Synergyheader.QuoteStartDate;
                sfdcopp.Quote_End_Date__c=Synergyheader.QuoteEndDate;
                sfdcopp.HW_TLA_Start_Date__c=Synergyheader.HWTLAStartDate;
                sfdcopp.Quote_Created_by__c=Synergyheader.QuoteCreatedBy;
                sfdcopp.Contract_Number__c=Synergyheader.ContractNumber;
                sfdcopp.Contract_Modifier__c=Synergyheader.ContractNumberModifier;
                sfdcopp.Bill_To__c=Synergyheader.BillToParty;
                // Below values not required for update WR 127727
                String orgQuoteCartVal = sfdcopp.Quote_Cart_Number__c;
                sfdcopp.Opportunity_Number__c=Synergyheader.OracleOppId;
                sfdcopp.Close_Comments__c=Synergyheader.CloseComments;
                //sfdcopp.CloseDate=Synergyheader.DecisionDate;
                sfdcopp.Closed_Reason__c=Synergyheader.ClosedReason;
                //177092 & 134590
                Map<String,Opportunity_Intg_Status_Rules__c> mapStatusAllowedforUpdate = Opportunity_Intg_Status_Rules__c.getAll();
                Opportunity_Intg_Status_Rules__c statusRule = new Opportunity_Intg_Status_Rules__c();
                
                sfdcopp.AccountId=Synergyheader.SfdcCustomerId;
                sfdcopp.Approval_Date__c=Synergyheader.DealRegApprovalDate;
                sfdcopp.Expiration_Date__c=Synergyheader.DealRegExpirationDate;
                sfdcopp.Disposition_Code__c=Synergyheader.DispositionCode;
                //Pricing fields**Shipraa
                //Percentage fields
                //WR -222446
                if((Synergyheader.QuoteNumber != null && Synergyheader.QuoteNumber != '' )){
                sfdcopp.Hardware_Discount__c=Synergyheader.HardwareDiscount;
                sfdcopp.Software_Discount__c=Synergyheader.SoftwareDiscount;
                sfdcopp.Services_Discount__c=Synergyheader.ServicesDiscount;
                sfdcopp.Prepaid_HW_MA_Discount__c=Synergyheader.PrepaidHWMADiscount;
                sfdcopp.HW_Warranty_Upgrade_Discount__c=Synergyheader.HWWarrantyUpgradeDiscount;
                sfdcopp.Prepaid_SW_MA_Discount__c=Synergyheader.PrepaidSWMADiscount;
                //currency fields
                sfdcopp.Total_Quote_Amount__c=Synergyheader.TotalQuoteAmount;
                sfdcopp.HW_Revenue__c=Synergyheader.HWRevenue;
                sfdcopp.SW_Revenue__c=Synergyheader.SWRevenue;
                sfdcopp.Services_Revenue__c=Synergyheader.ServicesRevenue;
                sfdcopp.Prepaid_HW_MA_Revenue__c=Synergyheader.PrepaidHWMARevenue;
                sfdcopp.Prepaid_SW_MA_Revenue__c=Synergyheader.PrepaidSWMARevenue;
                sfdcopp.HW_Warranty_Upgrade_Revenue__c=Synergyheader.HWWarrantyUpgradeRevenue;
                }
                else{
                sfdcopp.Hardware_Discount__c=null;
                sfdcopp.Software_Discount__c=null;
                sfdcopp.Services_Discount__c=null;
                sfdcopp.Prepaid_HW_MA_Discount__c=null;
                sfdcopp.HW_Warranty_Upgrade_Discount__c=null;
                sfdcopp.Prepaid_SW_MA_Discount__c=null;
                //currency fields
                sfdcopp.Total_Quote_Amount__c=null;
                sfdcopp.HW_Revenue__c=null;
                sfdcopp.SW_Revenue__c=null;
                sfdcopp.Services_Revenue__c=null;
                sfdcopp.Prepaid_HW_MA_Revenue__c=null;
                sfdcopp.Prepaid_SW_MA_Revenue__c=null;
                sfdcopp.HW_Warranty_Upgrade_Revenue__c=null;
                }
                //WR 222446
                //string field**  
                sfdcopp.Price_Floor__c=Synergyheader.PriceFloor;
    
                // Get status rule custom setting
                if(mapStatusAllowedforUpdate.containsKey(Synergyheader.Status))
                {
                    statusRule = mapStatusAllowedforUpdate.get(Synergyheader.Status);
                }
                // Check if synergy Oppty status can overwrite SFDC Status
                if (statusRule!=null && statusRule.SFDC_overwrite_allowed__c)
                {
                    if (statusRule.Overwriteable_Statuses__c != null) {
                        // If Synergy status can only overwrite certain SFDC statuses
                        List<String> ow_stats = new List<String>();
                        ow_stats = statusRule.Overwriteable_Statuses__c.split(';') ;
                        for (String  owstat : ow_stats) {
                            if (owstat == sfdcopp.StageName) {
                              sfdcopp.StageName=Synergyheader.Status;
                                  sfdcopp.CloseDate=Synergyheader.DecisionDate;
                            }
                        }
                    } else {
                        // else Synergy Status can overwrite any status
                      sfdcopp.StageName=Synergyheader.Status;
                          sfdcopp.CloseDate=Synergyheader.DecisionDate;
                    }
                }
                //sfdcopp.StageName=Synergyheader.Status;
                //sfdcopp.Next_Steps__c=Synergyheader.NextSteps;
                
                sfdcopp.Originator__c=Synergyheader.OpptyOriginator;

                // get status rule for latest sfdc status (may or may not be overwritten from oracle)
                statusRule = null;
                if(mapStatusAllowedforUpdate.containsKey(sfdcopp.StageName))
                {
                    statusRule = mapStatusAllowedforUpdate.get(sfdcopp.StageName);
                }
                // SFDC quote fields will be preserved if Oracle Oppty quote is null for a "Preserve_Archived_Quote_Number" status
                if (    (Synergyheader.QuoteNumber != null && Synergyheader.QuoteNumber != '' )
                     ||  statusRule == null
                     || (statusRule!=null && !statusRule.Preserve_Archived_Quote_Number__c )
                    ) {
                    sfdcopp.Quote_Operating_Unit__c=Synergyheader.QuoteOu;
                    sfdcopp.Quote_Type__c=Synergyheader.QuoteType;
                    sfdcopp.Quote_Version__c=Synergyheader.QuoteVersion;
                    sfdcopp.Quote_Cart_Number__c=Synergyheader.QuoteNumber;
                } 
                //**END OF 177092 & 134590***//
                sfdcopp.Sell_Relationship__c=Synergyheader.SellingRelationship;
                //sfdcopp.Opportunity_Number__c=Synergyheader.SfdcOpptyId;
                sfdcopp.SO_Number__c=Synergyheader.SalesOrderNumber;
                sfdcopp.LeadSource=Synergyheader.SourceCode;
                //sfdcopp.Integration_Error_Message__c=Synergyheader.ErrorMessage;
                //** WR 185642
                if((Synergyheader.QuoteNumber == null || Synergyheader.QuoteNumber == '') && Synergyheader.Status!='Closed' )
                {
                    unlinkedOpptySet.add(sfdcopp.id);
                }
                //*** WR 185642
                System.debug('Test1 ');
                String ownerid=sfdcopp.OwnerId;
                System.debug('ownerid ' +ownerid);
                
                /*23-Dec-10  Srinivas       WR 151217, commented the code for changing the 'Update Forecast Amount' Checkbox. moving the logic to trigger on opportunity
                //Code Changes-Pratibh: 27-Sep-10, Set Update Update_Forecast_Amount_from_Quote__c = true when Opportunity is linked to a Quote and Status is Booked or Submitted
                if (sfdcopp.Quote_Cart_Number__c!= null && orgQuoteCartVal==null){
                    sfdcopp.Update_Forecast_Amount_from_Quote__c= true;
                }
                End of WR 151217 */
                if(Synergyheader.OwnerSfdcId!=null && Synergyheader.OwnerSfdcId.trim()!='' ){
                    ownerid=Synergyheader.OwnerSfdcId;
                }
              
            System.debug('Update the Forecast Status on opportunity'+ sfdcopp.StageName);
              //Adding the condition as part of the Phase 2 Contract Renewals Requirement 
               if(sfdcopp.Quote_Type__c =='RQF' && Synergyheader.Status == 'Submitted'){
                  sfdcopp.StageName = 'Booked';
                  System.debug('Update the Forecast Status on opportunity'+ sfdcopp.StageName);
                  }
                    
                 System.debug('ownerid ' +ownerid);
                 System.debug('sfdcopp.OwnerId ' +sfdcopp.OwnerId);
                 System.debug('Test1 ' +Synergyheader.OwnerSfdcId);
                //Code commmented as per WR 127727
                /*if(Synergyheader.OwnerSfdcId!=null && ownerid.indexOf('005')<0 ){           
                    sfdcopp.House_Account_Name__c = Synergyheader.OwnerSfdcId;
                    sfdcopp.OwnerId=System.Label.Hose_Account_User;        
                }
                if(Synergyheader.OwnerSfdcId!=null && Synergyheader.OwnerSfdcId!='' && ownerid.indexOf('005')>=0){
                    sfdcopp.OwnerId=Synergyheader.OwnerSfdcId;
                }*/
                 System.debug('Test2 ');     
    }
 
 
    private   Opportunity createNewOpportunity(OpportunityDetails OppDetail){
        System.debug('OppDetail.POpptyHeaderBo.Status'+OppDetail.POpptyHeaderBo.Status);
        //System.debug('OppDetail.POpptyHeaderBo.OracleOppId'+OppDetail.POpptyHeaderBo.OracleOppId);
       // System.debug('OppDetail.POpptyHeaderBo.DecisionDate'+OppDetail.POpptyHeaderBo.DecisionDate);
        //OppDetail.POpptyHeaderBo.OracleOppId='1234567890';
       
       //WR : 222446
       Decimal  Hardware_Discount = null;
       Decimal  Software_Discount = null;
       Decimal  Services_Discount = null;
       Decimal  Prepaid_HW_MA_Discount = null ;
       Decimal  HW_Warranty_Upgrade_Discount = null;
       Decimal  Prepaid_SW_MA_Discount = null;
       //currency fields 
       Decimal  Total_Quote_Amount = null;
       Decimal  HW_Revenue =null;
       Decimal  SW_Revenue =null;
       Decimal  Services_Revenue =null;
       Decimal  Prepaid_HW_MA_Revenue=null;
       Decimal  Prepaid_SW_MA_Revenue=null;
       Decimal  HW_Warranty_Upgrade_Revenue=null;
       String  Price_Floor='';
       
       if((OppDetail.POpptyHeaderBo.QuoteNumber != null || OppDetail.POpptyHeaderBo.QuoteNumber != '')){ 
            Hardware_Discount = OppDetail.POpptyHeaderBo.HardwareDiscount;
            Software_Discount = OppDetail.POpptyHeaderBo.SoftwareDiscount;
            Services_Discount = OppDetail.POpptyHeaderBo.ServicesDiscount;
            Prepaid_HW_MA_Discount = OppDetail.POpptyHeaderBo.PrepaidHWMADiscount;
            HW_Warranty_Upgrade_Discount = OppDetail.POpptyHeaderBo.HWWarrantyUpgradeDiscount;
            Prepaid_SW_MA_Discount =OppDetail.POpptyHeaderBo.PrepaidSWMADiscount;
            
            Total_Quote_Amount =OppDetail.POpptyHeaderBo.TotalQuoteAmount;
            HW_Revenue =OppDetail.POpptyHeaderBo.HWRevenue;
            SW_Revenue =OppDetail.POpptyHeaderBo.SWRevenue;
            Services_Revenue=OppDetail.POpptyHeaderBo.ServicesRevenue;
            Prepaid_HW_MA_Revenue=OppDetail.POpptyHeaderBo.PrepaidHWMARevenue;
            Prepaid_SW_MA_Revenue=OppDetail.POpptyHeaderBo.PrepaidSWMARevenue;
            HW_Warranty_Upgrade_Revenue=OppDetail.POpptyHeaderBo.HWWarrantyUpgradeRevenue;
            Price_Floor = OppDetail.POpptyHeaderBo.PriceFloor;
       }
       
       //End WR : 222446
       
        Opportunity newOpp=new Opportunity(Opportunity_Number__c=OppDetail.POpptyHeaderBo.OracleOppId,
                Close_Comments__c=OppDetail.POpptyHeaderBo.CloseComments,
                CloseDate=OppDetail.POpptyHeaderBo.DecisionDate,
                Closed_Reason__c=OppDetail.POpptyHeaderBo.ClosedReason,
                CurrencyIsoCode=OppDetail.POpptyHeaderBo.CurrencyCode,
                AccountId=OppDetail.POpptyHeaderBo.SfdcCustomerId,
                Approval_Date__c=OppDetail.POpptyHeaderBo.DealRegApprovalDate,
                Expiration_Date__c=OppDetail.POpptyHeaderBo.DealRegExpirationDate,
                Disposition_Code__c=OppDetail.POpptyHeaderBo.DispositionCode,
                StageName=OppDetail.POpptyHeaderBo.Status,
                Next_Steps__c=OppDetail.POpptyHeaderBo.NextSteps,
                Name=trimStr(OppDetail.POpptyHeaderBo.OpportunityName,MaxOpportunityNameLength ),
                Originator__c=OppDetail.POpptyHeaderBo.OpptyOriginator,

                Quote_Operating_Unit__c=OppDetail.POpptyHeaderBo.QuoteOu,
                Quote_Type__c=OppDetail.POpptyHeaderBo.QuoteType,
                Quote_Version__c=OppDetail.POpptyHeaderBo.QuoteVersion,
                Quote_Cart_Number__c=OppDetail.POpptyHeaderBo.QuoteNumber,
                Sales_Channel__c=OppDetail.POpptyHeaderBo.SalesChannel,
                Sales_Force__c=OppDetail.POpptyHeaderBo.SalesForceOrg,
                Sell_Relationship__c=OppDetail.POpptyHeaderBo.SellingRelationship,
                //Opportunity_Number__c=OppDetail.POpptyHeaderBo.SfdcOpptyId,
                SO_Number__c=OppDetail.POpptyHeaderBo.SalesOrderNumber,
                LeadSource=OppDetail.POpptyHeaderBo.SourceCode,
                Partner__c=OppDetail.POpptyHeaderBo.PartnerSfdcCustId,
                Vmware_Related__c=OppDetail.POpptyHeaderBo.VmwareCode,
                //New fields introduced as part of RQF.
                SW_Discount_percent__c=OppDetail.POpptyHeaderBo.SWDiscount,
                HW_Discount_percent__c=OppDetail.POpptyHeaderBo.HWDiscount,
                Discount_percent__c=OppDetail.POpptyHeaderBo.Discount,
                Quote_Start_Date__c=OppDetail.POpptyHeaderBo.QuoteStartDate,
                Quote_End_Date__c=OppDetail.POpptyHeaderBo.QuoteEndDate,
                HW_TLA_Start_Date__c=OppDetail.POpptyHeaderBo.HWTLAStartDate,
                Quote_Created_by__c=OppDetail.POpptyHeaderBo.QuoteCreatedBy,
                Contract_Number__c=OppDetail.POpptyHeaderBo.ContractNumber,
                Contract_Modifier__c=OppDetail.POpptyHeaderBo.ContractNumberModifier,
                Bill_To__c=OppDetail.POpptyHeaderBo.BillToParty,
                //Pricing fields**Shipraa
                //Percentage fields
                //WR : 222446
                Hardware_Discount__c =  Hardware_Discount,
                Software_Discount__c =  Software_Discount,
                Services_Discount__c =  Services_Discount,
                Prepaid_HW_MA_Discount__c = Prepaid_HW_MA_Discount,
                HW_Warranty_Upgrade_Discount__c = HW_Warranty_Upgrade_Discount,
                Prepaid_SW_MA_Discount__c = Prepaid_SW_MA_Discount,
                //currency fields
                Total_Quote_Amount__c = Total_Quote_Amount,
                HW_Revenue__c = HW_Revenue,
                SW_Revenue__c = SW_Revenue,
                Services_Revenue__c = Services_Revenue,
                Prepaid_HW_MA_Revenue__c = Prepaid_HW_MA_Revenue,
                Prepaid_SW_MA_Revenue__c = Prepaid_SW_MA_Revenue,
                HW_Warranty_Upgrade_Revenue__c = HW_Warranty_Upgrade_Revenue,
                
                //string field**  
                Price_Floor__c=Price_Floor
                //END WR : 222446
                
  
                );
                //Integration_Error_Message__c=OppDetail.POpptyHeaderBo.ErrorMessage                    
               // OwnerId=OppDetail.POpptyHeaderBo.OwnerSfdcId
                //Code comment-Pratibh:06-Sep-10, As per work request- 141883
                /*if(OppDetail.POpptyHeaderBo.OwnerSfdcId.indexOf('005')<0){
                    newOpp.House_Account_Name__c = OppDetail.POpptyHeaderBo.OwnerSfdcId;
                    newOpp.OwnerId=System.Label.Hose_Account_User;        
                }else{
                    newOpp.OwnerId=OppDetail.POpptyHeaderBo.OwnerSfdcId;
                }*/
                
                /* 23-Dec-10  Srinivas       WR 151217, commented the code for changing the 'Update Forecast Amount' Checkbox. moving the logic to trigger on opportunity
                //Code Changes-Pratibh: 16-Aug-10, Set Update Update_Forecast_Amount_from_Quote__c = true when Opportunity is linked to a Quote
                if (newOpp.Quote_Cart_Number__c!= null){
                    newOpp.Update_Forecast_Amount_from_Quote__c= true;
                }
                End of WR 151217 */ 
                
                //Code Added-Pratibh: 06-Sep-10, Set default owner when User Id returned from interface is inactive or invalid.
                Boolean validActiveUser = false;
                if(OppDetail.POpptyHeaderBo.OwnerSfdcId != null)
                {
                    if(OppDetail.POpptyHeaderBo.OwnerSfdcId.startsWith('005'))
                    {
                        id opptyId;
                        try{
                        opptyId = OppDetail.POpptyHeaderBo.OwnerSfdcId;
                        }catch(Exception e){
                                System.debug('Exception'+e.getmessage());
                        }
                        if(UserHelper.isValidUserId(opptyId) && UserHelper.isActiveUserId(opptyId))
                        {
                            validActiveUser = true;
                            newOpp.OwnerId=opptyId;
                        }
                    }
                    else
                    {   if(UserHelper.isValidUserName(OppDetail.POpptyHeaderBo.OwnerSfdcId) && UserHelper.isActiveUserName(OppDetail.POpptyHeaderBo.OwnerSfdcId))
                        {
                            validActiveUser = true;
                            newOpp.OwnerId= UserHelper.retrieveUserId(OppDetail.POpptyHeaderBo.OwnerSfdcId);
                        }
                    }
                }
                if(!validActiveUser)
                {
                    newOpp.House_Account_Name__c = OppDetail.POpptyHeaderBo.OwnerSfdcId;
                    if(newOpp.LeadSource=='Contract Renewal'){
                        newOpp.OwnerId = UserHelper.retrieveUserId('Renewals Rep Maintenance');
                    }
                    else{
                        newOpp.OwnerId = UserHelper.retrieveUserId('House Account');
                    }
                }
                system.debug('OUTPUT'+newOpp.OwnerId+' Name'+ newOpp.House_Account_Name__c);
            return newOpp;
    }            

   
        Private OpportunityLineItem createSFDCProduct(OpptyProductTbl product,String oppid,String CurrencyCode){       
            System.debug('oppid*****'+oppid);
            OpportunityLineItem OppProduct=null;
            String PricebookEntryid;
            if(oppid==null ||oppid=='' ){
                return null;
            }
            try{
                
                PricebookEntryid=[Select p.Product2Id,p.CurrencyIsoCode, p.Pricebook2Id, p.Name, p.Id From PricebookEntry p where Pricebook2.Name='Standard Price Book' and CurrencyIsoCode 

=:CurrencyCode and isActive=true and Product2.Name = :product.ProductName].id;
                System.debug('PricebookEntryid'+PricebookEntryid);
                OppProduct=new OpportunityLineItem ();
                OppProduct.Quote_Amount__c=product.QuoteAmount;
                OppProduct.UnitPrice=product.ForecastAmount;
                System.debug('product.ForecastAmount'+product.ForecastAmount);
                  try{
                OppProduct.PricebookEntryId =PricebookEntryid;
                }catch(Exception ex){
                    System.debug('Exception in Relation'+ex);}
                    //System.debug('OppProduct.PricebookEntry.product2Id'+OppProduct.PricebookEntry.product2Id);                
                    OppProduct.OpportunityId=oppid;
            }catch(Exception ex){
                System.debug('Exception during product'+ex);
                EMCException ExceptionError=new EMCException(ex.getMessage(),'Integration Error during linking the line item to opportunity, Posssible reasons are Inactive Product or Product Name missmatch ',new String[]{SynergyIdMap.get

(oppid)});
                errors.add(ExceptionError);
                
                // Add in integration Result
                   IntegrationResult result= results.get(SynergyIdMap.get(oppid));
                   if(result==null){
                        result = new IntegrationResult();
                   }
                   
                   result.ErrorMessage=ex.getMessage()+' on creating Opportunity Line Item '+product.ProductName;
                   result.IsSuccess=false;
                   result.SynergyOpportunityId= SynergyIdMap.get(oppid);
                   result.SFDCOpportunityId='';
                   result.Warning='';
                   System.debug(' results.put line 627 ');
                   results.put(result.SynergyOpportunityId,result); 
            }                            
                                            
        return OppProduct; 
        }
        
       Private void  updateSfdcProduct(OpportunityLineItem SfdcProduct,OpptyProductTbl SynergyProduct){
        
                System.debug('SfdcProduct****'+SfdcProduct);
                System.debug('SynergyProduct'+SynergyProduct);
                //**WR 185642
                if(unlinkedOpptySet.contains(SfdcProduct.OpportunityId))
                {
                    SfdcProduct.Quote_Amount__c=null;
                }
                else
                {
                    SfdcProduct.Quote_Amount__c=SynergyProduct.QuoteAmount;
                    // SfdcProduct.UnitPrice=SynergyProduct.ForecastAmount;
                }
        }
    
    private String trimStr(String initialString, Integer maxLength) 
    {
        if (initialString == null || initialString == '') 
        {
            return null;
        } else if (initialString.length() <= maxLength) 
          {
            return initialString;
          } else 
            {
                return initialString.substring(0, maxlength);
            }
    }
          
}