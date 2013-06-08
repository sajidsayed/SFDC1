/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |                                              Initial draft             
 |  21.10.2010      Anand Sharma                Added variable Tst data"isChannelVisibilityExecuted" to handle recurrsive call
 |  17.01.2011      Shipra Misra                Added variable Tst data"isLeadInsertUpdateExecuted" to handle recurrsive call
 |  29-Sep-2011     Shipra M        173667      Place Account Theater on the Opportunity into a Text Field                               
 |  25-Nov-2011     Shipra M        180005      Added Boolean to handle Account trigger's not to fire again after TA Assignment Job execution.                               
 |  05-Dec-2011     Shipra M        173965      Added 2 maps to store old & new onwer Id against updated opportunity.
 |  30 jULY 2012    Arif            PAN Theater Added a flag isPopulateVelocitySpecialty 
 |  08-Aug-2012     Kaustav         198481      Added an eBusiness flag to check inserted leads
 |  17-Oct-2012     Smitha          205017      Added a Boolean "blnUpdateAssetId" to update Opty after insert of Asset-Opty Junction Obj record.
 +=========================================================================================================================*/
 
Public class Util{
    Public static Boolean isTestUser=false;
    Public static boolean fromuserattributemapping=false;
    Public static Boolean isPopulaAMDM=true;
    Public static boolean isPopulateVelocitySpecialty = true;
    Public static Boolean setActivityOwnerBefore=true;
    Public static Boolean setActivityOwnerAfter=true;
    Public static Boolean isUpdatelastleadowner=true;
    Public static Boolean isFeatureCalledonAcitivity=true;
    Public static Boolean CheckOpportunityAccess=true;
    Public static Boolean IsTheaterUpdatedFromAccount=false;
    Public static Map <id,User> users= null;
    Public static Boolean isTestCoverage=false;
    /*eBusiness code*/
    Public static Boolean iseBusinessLeadInsert=false;
    /*end of eBusiness code*/
    //added to handle Channel visibility recurrsive call
    public static Boolean isChannelVisibilityExecuted =false;
    //added to store Old Owner Id against update dOpportunity.Defect #877 December 2011.
    public static Map<Id,Id> mapOldOpportunityOwner =new Map<Id,Id>();
    //added to store New Owner Id against update dOpportunity.Defect #877 December 2011.
    public static Map<Id,Id> mapNewOpportunityOwner =new Map<Id,Id>();
    //added to handle Account trigger's not to fire again after TA Assignment Job execution.
    public static Boolean UPDATED_FROM_TO_TA_ASSIGNMENT_JOB_FLAG =false;
    //added to handle Update Install Base Account issue for Production release. this will avoid recurrsive calls.
    public static Boolean isLeadInsertUpdateExecuted =false;
    //added for MOJO project - To Update Opty.AssetId field after insert of record in Junction Object.
    public static Boolean blnUpdateAssetId =false;
    //added to handle Under pen emea alert only once.
    public static Boolean Underpen_EMAIL_Alert_fired =false;
    //added to handle Under pen emea alert only once.
    public static Boolean TA_Sync_Job_Scheduler_Inserted =false;
    
    Public static Map <id,User> getUsers(List <Configuration__c> configs,Set<String> owners){
        if(users==null){
           
            Set <String> profiles= new Set <String>();
            for(Configuration__c c :configs){
                String profile =' ';
                profile = c.Value__c+','+c.Value2__c;
    
                String[] split_profile = new String[1];
                split_profile= profile.split(',',-1);
                
                for(String p: split_profile){
                   profiles.add(p);
                   
                }        
            }  
           System.debug('profiles '+profiles);
           users= new Map <id,User>([Select Id, Profile_Name__c from User where Profile_Name__c in :profiles and id in :owners]);
        }
        return users;
    }
}