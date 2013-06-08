/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
                                                       
| 10/17/2012    Krishna Pydavula        197607        This class is used to send an email Notification to Distribution list and 
                                                      submitter for ESBI VPP Scheduler Jobs.
   15/11/2012     vivek kodi            197607          To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.                                                                                                        
+=====================================================================================================*/

public class SendEmailNotificationToAllBatchjobs {

public SendEmailNotificationToAllBatchjobs()
{
	          
}
public static String Body;
public static String batchprocessname;  
public static String status;
public static String ListAsString(List <String> collection, String seperator){
    String returnVal = '';
    
    if (collection != null) {
        if (collection.size() > 0) {
            for (String value : collection) {
                returnVal += value + seperator + ' '; 
            }
            returnVal = returnVal.substring(0, (returnVal.length() - 2));       
        }
    }
    return returnVal; 
}

public static void EmailProcessor(string batchid,List <EMCException> errs)
{
    try
    {
 
    if(batchid!=null)
    {
        
      AsyncApexJob a = [SELECT Id, Status,ApexClassId,ApexClass.Name, ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, CreatedBy.Name,CreatedDate,CompletedDate FROM AsyncApexJob WHERE Id=:batchid];
     
            batchprocessname=a.ApexClass.Name;
            
            System.debug('errorserrors'+errs+'errors.size'+errs.size()); 
             
            String jobbodystart =' A batch job:<b>'+batchprocessname+'</b> has started.';
             jobbodystart += '<br></br><br></br> Below is the information related to this batch job:';
             jobbodystart += '<br></br><br></br> Name of the Job &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+batchprocessname;
             jobbodystart += '<br></br> Status&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;Started';
             jobbodystart += '<br></br> Job ID &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.Id;
             jobbodystart += '<br></br> Submitted By&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.CreatedBy.Name;
             jobbodystart += '<br></br> Submission Information :&nbsp;'+a.CreatedDate;
             jobbodystart += '<br></br><br></br> You will further receive an email notification once the batch job is completed.';
             jobbodystart += '<br></br><br></br> Thanks!';
                          
            String jobbodycomp = 'Dear&nbsp;&nbsp;' + a.CreatedBy.Name+',' ;
             jobbodycomp += '<br></br><br></br><b>'+batchprocessname +'</b> is completed successfully.';
             jobbodycomp += '<br></br><br></br> Below is the information related to this batch job:';
             jobbodycomp += '<br></br><br></br> Name of the Job &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+batchprocessname;
             jobbodycomp += '<br></br> Status&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.Status;
             jobbodycomp += '<br></br> Job ID &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.Id;
             jobbodycomp += '<br></br> Submitter &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.CreatedBy.Name;
             jobbodycomp += '<br></br> Submission Information          :&nbsp;'+a.CreatedDate;
             jobbodycomp += '<br></br> Completion Information :&nbsp;'+a.CompletedDate;
             jobbodycomp += '<br></br><br></br> Thanks!'; 
             
             String jobbodyfail = 'Dear&nbsp;&nbsp;' + a.CreatedBy.Name+',' ;
             jobbodyfail += '<br></br><br></br><b>'+batchprocessname+'</b>has failed';
             jobbodyfail += '<br></br><br></br> Below is the information related to this batch job:';
             jobbodyfail += '<br></br> Name of the Job &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+batchprocessname;
             jobbodyfail += '<br></br> Status&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.Status;
             jobbodyfail += '<br></br>Job ID &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.Id;
             jobbodyfail += '<br></br> Submitter &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.CreatedBy.Name;
             jobbodyfail += '<br></br>Submission Information   :&nbsp;'+a.CreatedDate;
             jobbodyfail += '<br></br><br></br> Completion Information  :&nbsp;'+a.CompletedDate;
             jobbodyfail += '<br></br> Thanks!'; 
             
             String jobbodycomperror = 'Dear&nbsp;&nbsp;' + a.CreatedBy.Name+',' ;
             jobbodycomperror +='<br></br><br></br><b>'+batchprocessname +'</b> is completed successfully.';             
             jobbodycomperror += '<br></br><br></br> Below is the information related to this batch job:';
             jobbodycomperror += '<br></br> Name of the Job &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+batchprocessname;
             jobbodycomperror += '<br></br> Status&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.Status+' with error(s)';
             jobbodycomperror += '<br></br>Job ID &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.Id;
             jobbodycomperror += '<br></br> Submitter &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;:&nbsp;'+a.CreatedBy.Name;
             jobbodycomperror += '<br></br>Submission Information  :&nbsp;'+a.CreatedDate;
             jobbodycomperror += '<br></br>Completion Information  :&nbsp;'+a.CompletedDate;                                  
             jobbodycomperror += '<br></br><br></br><html><body><table border="1"><tr> <td> Process ID</td> <td>Message(s)</td></tr>';
             if(errs.size()>0){
	             for(EMCException errors:errs){
	               jobbodycomperror += '<tr><td>'+errors.ProcessId +'</td>  <td>'+errors.getMessage()+'</td></tr>';
	             }          
             }
             jobbodycomperror += '</table><br></br> Thanks!</body></html>';
             
             String jobbodynooferrors = 'Dear&nbsp;&nbsp;' + a.CreatedBy.Name+',' ;
             jobbodynooferrors +='<br></br><br></br><b>'+batchprocessname +'</b> is completed successfully.';             
             jobbodynooferrors += '<br></br><br></br> Below is the information related to this batch job:';
             jobbodynooferrors += '<br></br> Name of the Job &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+batchprocessname;
             jobbodynooferrors += '<br></br> Status&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.Status+' with error(s)';
             jobbodynooferrors += '<br></br>Job ID &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;'+a.Id;
             jobbodynooferrors += '<br></br> Submitter &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;:&nbsp;'+a.CreatedBy.Name;
             jobbodynooferrors += '<br></br>Submission Information  :&nbsp;'+a.CreatedDate;
             jobbodynooferrors += '<br></br>Completion Information  :&nbsp;'+a.CompletedDate;                                  
             jobbodynooferrors += '<br></br><br></br><html><body><table border="1"><tr> <td> Process ID</td> <td>Message(s)</td> <td>No.of Batches Failed</td></tr>';
             jobbodynooferrors += '<tr><td>'+a.Id+'</td> <td>'+a.ExtendedStatus+'</td> <td>'+ a.NumberOfErrors +'</td></tr>';
	         jobbodynooferrors += '</table><br></br> Thanks!</body></html>';
          
          if(a.status=='Preparing')
          {
                Body=jobbodystart;
          }
          else if(a.status=='Completed' && (a.NumberOfErrors >0 || (a.ExtendedStatus !='' && a.ExtendedStatus != null))){
              Body=jobbodynooferrors;
          }
          else if(a.status=='Completed' && errs.size()>0)
	      {
	           Body=jobbodycomperror;
	      }
          else if(a.status=='Completed') {
               Body=jobbodycomp;
          }else if(a.Status == 'Failed'){
               Body=jobbodyfail;
          }
        
        
         
         System.debug('BodyBody'+Body);
             
           String[] toaddress = new String[]{};
          Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();   
          if(DataValueMap.containsKey('SFDC Batch Admin'))
         {
            toaddress = DataValueMap.get('SFDC Batch Admin').DataValue__c.split(';') ;
            toaddress.add(a.CreatedBy.Email);
            
         }
            
       String orgwide=DataValueMap.get('OrgwideEmailIdforBatch').DataValue__c;  
       OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:orgwide];          
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       if(toaddress !=null &&toaddress.size()>0)
       {
         mail.setToAddresses(toaddress);
        }
        
        if (a.Status == 'Preparing'){
            Status = 'Started'; 
        }
        else if(a.Status == 'Completed')
        {
            Status = 'Completed';
        }
        else if(a.Status == 'Failed'){
            Status = 'Failed';
        }
        system.debug('a.NumberOfErrors'+a.NumberOfErrors +'errs.size'+errs.size());
      if(a.Status == 'Completed' && (errs.size()>0 || (a.NumberOfErrors >0 || (a.ExtendedStatus !='' && a.ExtendedStatus != null)))){
          mail.setSubject(batchprocessname+ ' Job is: ' + status +' with errors');
       }else{
          mail.setSubject(batchprocessname+ ' Job is: ' + status);
       }   
       mail.sethtmlBody(Body);
       if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }

       if(batchprocessname=='PRM_Contact_Functional_Area_UpdateBatch'||batchprocessname=='AccountPartnerSEFieldsUpdateBatch'||batchprocessname=='PartnerSEContactSummaryFieldsUpdateBatch'||batchprocessname=='PRM_PAN_VPP_VelocityRuleEvaluatorJob'||batchprocessname=='PRM_VPP_RollupRuleEvaluatorJob'||batchprocessname=='PRM_VPP_VelocityRuleEvaluatorJob'
	            ||batchprocessname=='PRM_PAN_VPP_VelocityRuleResultJob1'||batchprocessname=='PRM_VPP_VelocityRuleResultJob1'||batchprocessname=='PRM_VPP_DeleteRecordsJob'||batchprocessname=='PRM_BatchDeleteEducation'||batchprocessname=='PRM_BatchCreateEducationFromStaging'||batchprocessname=='PRM_PopulateEducationMasterBatch'
	            ||batchprocessname=='PRM_ESBI_VPP_StagingDataOperator') 
	            {
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
    }
            
    }    
    }
    catch (Exception ex){
    system.debug('------------SendEmailNotificationToAllBatchjobs--------'+ex);             
}

 
}
}