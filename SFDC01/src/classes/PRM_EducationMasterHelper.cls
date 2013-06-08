/*=====================================================================================================+
|  HISTORY  | 
|  DATE          DEVELOPER                WR            DESCRIPTION
|  ====          =========                ==            =========== 
| 28/12/2010    Karthik Shivprakash       1314          This is a helper class used to populate
                                                        modified information from education master.
                                                        
| 28/12/2010    Anand Sharma                            Created method  removeDuplicateStagingForEducationMaster
                                                        which will remove staging record, that cause duplicate record.
                                                         
| 07/01/2011    Anand Sharma                            Change request:Match Education master on 
                                                        education with ESBI NAME in place of ESBI ID 
                                                        Update method removeDuplicateStagingForEducationMaster
                                                        
| 30/03/2011     Suman B								Modified  removeDuplicateStagingForEducationMaster method to
                                                        filter the Staging Data from duplicate ESBI Names (Text2__c)                                                                                                        
+=======================================================================================================================*/
public with sharing class PRM_EducationMasterHelper {
    
    /*  @Method <The populateModifiedInfo() is used to populate the modified information of
                the education master data.>
        @param <List<Education_Master__c> EducationMasterList - List of education master from
            the trigger.new>
        @return <void> - <Not returning anything>
        @throws exception - <No Exception>
    */  
    public static void populateModifiedInfo(List<Education_Master__c> EducationMasterList){     
        List<Education_Master__c> EducationMaster = new List<Education_Master__c>();        
        //Used to store the data mapping for the education master using the custom setting.
        Map<String,CustomSettingEducationDataValueMapping__c> DataValueMap = CustomSettingEducationDataValueMapping__c.getAll(); 
        
        //Used to store level data mapping for the education master using the custom setting.
        Map<String,CustomSettingEducationMasterLevelMapping__c> LevelValueMap = CustomSettingEducationMasterLevelMapping__c.getAll();
               
        for(Education_Master__c educationObj: EducationMasterList){     
            if(educationObj.ESBI_Category__c!=null && DataValueMap.containsKey(educationObj.ESBI_Category__c)){
                if(DataValueMap.get(educationObj.ESBI_Category__c).Category__c!='null'){
                    educationObj.Modified_Category__c=DataValueMap.get(educationObj.ESBI_Category__c).Category__c;
                }
                else{
                    educationObj.Modified_Category__c=null;
                }
            }
            if(educationObj.ESBI_Level__c!=null && LevelValueMap.containsKey(educationObj.ESBI_Level__c)){
                if(LevelValueMap.get(educationObj.ESBI_Level__c).Level__c!='null'){
                    educationObj.Modified_Level__c=LevelValueMap.get(educationObj.ESBI_Level__c).Level__c;
                }
                else{
                    educationObj.Modified_Level__c=null;
                }
            }   
            if(educationObj.ESBI_Type__c!=null && DataValueMap.containsKey(educationObj.ESBI_Type__c)){
                if(DataValueMap.get(educationObj.ESBI_Type__c).Type__c!='null'){
                    educationObj.Modified_Type__c=DataValueMap.get(educationObj.ESBI_Type__c).Type__c;
                }
                else{
                    educationObj.Modified_Type__c=null;
                }
            }
            if(educationObj.ESBI_Version__c!=null && DataValueMap.containsKey(educationObj.ESBI_Version__c)){
                if(DataValueMap.get(educationObj.ESBI_Version__c).Version__c!='null'){
                    educationObj.Modified_Version__c = DataValueMap.get(educationObj.ESBI_Version__c).Version__c;
                }
                else{
                    educationObj.Modified_Version__c = educationObj.ESBI_Version__c;
                }
            }
            EducationMaster.add(educationObj);
        }
        if(EducationMaster.size()>0){
            System.debug('EducationMaster'+EducationMaster);
            update EducationMaster;
        }
    }
    
    /* @Method <This method is used to handle duplicate education master record creation>.
       @param <This is taking list of Staging records >
       @return <List of Staging records> 
       @throws exception - <No Exception>
    */
    public static List<Staging_Data__c> removeDuplicateStagingForEducationMaster(List<Staging_Data__c> DataStagingList)
    {
        //hold education Name for Staging data
        Set<String> setEducationNames = new Set<String>();
        Map<String, Education_Master__c> mapEducationidAndEducationMaster = new Map<String, Education_Master__c>();
        List<Staging_Data__c> lstStagingDataNotInEduMaster = new List<Staging_Data__c>();
        Map<String, Staging_Data__c> mapESBIName_StagingData = new Map<String,Staging_Data__c>();
        
        if(DataStagingList.size() >0){
            for(Staging_Data__c objStagingData : DataStagingList){
                if(objStagingData.Text2__c != null){
                    setEducationNames.add(objStagingData.Text2__c);
                    mapESBIName_StagingData.put(objStagingData.Text2__c,objStagingData);
                }           
            }
            //fetch all education master record with education name
            List<Education_Master__c> lstEducationMaster = [Select Id,ESBI_Name__c, ESBI_ID__c from Education_Master__c 
                                                            Where ESBI_Name__c in: setEducationNames limit 10000];
            
            //create map with education name as key and education master record as value.
            if(lstEducationMaster.size() >0){
                for(Education_Master__c objEbuMaster : lstEducationMaster){
                    mapEducationidAndEducationMaster.put(objEbuMaster.ESBI_Name__c,objEbuMaster);
                }   
            }
            
            for(Staging_Data__c objStagingData : mapESBIName_StagingData.values()){
                if(objStagingData.Text2__c != null){
                    if(!mapEducationidAndEducationMaster.containsKey(objStagingData.Text2__c)){
                        lstStagingDataNotInEduMaster.add(objStagingData);
                    }
                }                   
            }               
        }
        
        return lstStagingDataNotInEduMaster;                                                                    
    }   
}