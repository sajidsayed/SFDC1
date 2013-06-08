/*================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR        DESCRIPTION                               

|  ====          =========                ==        =========== 

| 12/10/2010     Karthik Shivprakash      1173      This class is used to provide 
                                                    the ability to have filters
|                                                   on the Objectives under Channel 
                                                    Account Plans. 
| 16/12/2010     Karthik Shivprakash     Def#178    Updated the query to fetch only
                                                    objectives of the current channel
                                                    account plan.
| 28/12/2010     Karthik Shivprakash     Def#185    Updated the selectLists to flip the
                                                    values based on the record type. 
| 29/12/2010     Karthik Shivprakash     Def#218    Updated the value of selectList of Objective
                                                    Type field.
  11/1/2011      Ashwini Gowda           Def#251    Added check to restrict users by deleting
                                                    Objectives if they do not have delete permissions
  18/02/2011     Anil Sure                1646      Added a new action method goonpdfpage() for PDFView Button
                                                    which will displays PRMFilterObjectives in the form of PDF.
                                                    
                  Prasad                            updated for the CAP changes      
 17/08/2012      Ganesh                  200760     Added logic to show values in Geography Picklist for EMEA and APJ                                                                                                                                                      
+================================================================================================*/

 
public with sharing class PRM_FilterObjective {

//Used to get and set the values from the visual force page for the field
//Parent Objective Type
public String ParentObjectiveType {get;set;}

//Used to get and set the values from the visual force page for the field
//Objective Type
public String ObjectiveType {get;set;}

//Used to get and set the values from the visual force page for the field
//Solution Focus
public String SolutionFocus {get;set;}

//Used to get and set the values from the visual force page for the field
//Solution
public String Solutions {get;set;}

//Used to get and set the values from the visual force page for the field
//Industry Focus
public String IndustryFocus {get;set;}

//Used to get and set the values from the visual force page for the field
//Segment
public String Segment {get;set;}

//Used to get and set the values from the visual force page for the field
//Vertical
public String Vertical {get;set;}

//=========================================================

//Used to get and set the values from the visual force page for the field
//Geography
public String Geography {get;set;}

//Used to store the list of Objective records after fetching.
public List<SFDC_Objective__c> ObjectiveList = new List<SFDC_Objective__c>();


public SFDC_Objective__c Objective {get;set;}
public String ParentObjectiveRegion {get;set;}

//===================================================
//Used to store the picklist values.
List<SelectOption> ParentObjectiveTypeList;
List<SelectOption> ObjectiveTypeList;
List<SelectOption> SolutionFocusList;
List<SelectOption> SolutionList;
List<SelectOption> IndustryFocusList;
List<SelectOption> VerticalList;
List<SelectOption> SegmentList;
List<SelectOption> GeographyList;

public Boolean EMEAFilters {get;set;}
public Boolean APJFilters {get;set;}
public Boolean AmerciaFilters {get;set;}

public SFDC_Channel_Account_Plan__c channelAccountPlan{get; set;}

//Fetching the record type values from the custom setting
Map<String,CustomSettingDataValueMap__c> RecordTypeMap = CustomSettingDataValueMap__c.getAll();

SFDC_Channel_Account_Plan__c  ChannelRecord;


/*@Method <This method PRM_FilterObjective is constructor for the extension of
            the standard controller.>
@param <This method take ApexPages.StandardController as parameters>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    public PRM_FilterObjective(ApexPages.StandardController stdcontroller) {
         ChannelRecord = (SFDC_Channel_Account_Plan__c)stdController.getRecord();        
         fetchFilterValues();    
         try{
          Objective =[select id,Parent_Objective_Type__c,Objective_Type__c,Segment__c,Solution__c,Vertical__c from SFDC_Objective__c limit 1  ];
         }catch(Exception e){
             Objective= new SFDC_Objective__c();
         }
         Objective.Parent_Objective_Type__c='';
         Objective.Parent_Objective_Type__c='';
         Objective.Objective_Type__c ='';
         Objective.Segment__c='';
         Objective.Solution__c ='';
         Objective.Vertical__c ='';
    }
 
/*@Method <This method recrodTypeForFocusArea is used to find out the recordtype of
         the user and filter the values based on the record type>
@param <This method take the list of FocusAreaList as parameter>
@return <List<SelectOption>> - <Returing the list of FocusArea picklist values>
@throws exception - <No Exception>
*/

    public void fetchFilterValues(){
        
        SFDC_Channel_Account_Plan__c ChannelObject = [Select s.Id, s.RecordTypeId, 
                                                        s.RecordType.Name, s.Name
                                                        from SFDC_Channel_Account_Plan__c s
                                                        where s.Id=:ChannelRecord.Id];

        for(CustomSettingDataValueMap__c recordType: RecordTypeMap.values()){
            if(ChannelObject.RecordTypeId == RecordTypeMap.get('APJDistributorCAPLocked').DataValue__c || ChannelObject.RecordTypeId == RecordTypeMap.get('APJResellerCAPLocked').DataValue__c ||
                ChannelObject.RecordTypeId == RecordTypeMap.get('APJDistributorCAP').DataValue__c || ChannelObject.RecordTypeId == RecordTypeMap.get('APJResellerCAP').DataValue__c){
                
                APJFilters = True;
            }
            else if(ChannelObject.RecordTypeId ==RecordTypeMap.get('EMEADistributorCAPLocked').DataValue__c || ChannelObject.RecordTypeId ==RecordTypeMap.get('EMEAResellerCAPLocked').DataValue__c ||
                    ChannelObject.RecordTypeId ==RecordTypeMap.get('EMEAResellerCAP').DataValue__c || ChannelObject.RecordTypeId ==RecordTypeMap.get('EMEADistributorCAP').DataValue__c){
                
                EMEAFilters = True;
            }
            else if(ChannelObject.RecordTypeId ==RecordTypeMap.get('AmericasDistributorCAPLocked').DataValue__c || ChannelObject.RecordTypeId ==RecordTypeMap.get('AmericasResellerCAPLocked').DataValue__c ||
                    ChannelObject.RecordTypeId ==RecordTypeMap.get('AmericasDistributorCAP').DataValue__c || ChannelObject.RecordTypeId ==RecordTypeMap.get('AmericasResellerCAP').DataValue__c){
               
               AmerciaFilters = True;
            }            
        }
       channelAccountPlan=[Select s.Name from SFDC_Channel_Account_Plan__c s where s.Id=:ChannelRecord.Id];
     }


/*@Method <This method getParentObjectiveTypeList used to get the picklist values
            from the Objective via metadata for the field FocusArea>
@param <This method does not take any parameters>
@return <SelectOption> - <selected picklist values from configuration>
@throws exception - <No Exception>
*/
    //updated the selectList for the def#185
    public List<SelectOption> getParentObjectiveTypeList(){
        List<SelectOption> ParentObjectiveTypeList = new List<SelectOption>();
        if(EMEAFilters==true){
            ParentObjectiveTypeList.add(new SelectOption('--None--','--None--'));
            ParentObjectiveTypeList.add(new SelectOption('Revenue','Revenue'));
            ParentObjectiveTypeList.add(new SelectOption('Unit Count','Unit Count'));
            ParentObjectiveTypeList.add(new SelectOption('Partner Own Development','Partner Own Development'));
            ParentObjectiveTypeList.add(new SelectOption('Tier2 Reseller Recruitment','Tier2 Reseller Recruitment'));
            ParentObjectiveTypeList.add(new SelectOption('Marketing','Marketing'));
            ParentObjectiveTypeList.add(new SelectOption('Partner Enablement','Partner Enablement'));
            ParentObjectiveTypeList.add(new SelectOption('Deal Registration','Deal Registration'));
        }
        return ParentObjectiveTypeList;
    }


/*@Method <This method getObjectiveTypeList used to get the picklist values
            from the Objective via metadata for the field Geography>
@param <This method does not take any parameters>
@return <SelectOption> - <selected picklist values from configuration>
@throws exception - <No Exception>
*/
    //updated the selectList for the def#185
    public List<SelectOption> getObjectiveTypeList(){
        List<SelectOption> ObjectiveTypeList = new List<SelectOption>();
        if(AmerciaFilters==true){
            ObjectiveTypeList.add(new SelectOption('--None--','--None--'));
            ObjectiveTypeList.add(new SelectOption('Corporate Based','Corporate Based'));
            ObjectiveTypeList.add(new SelectOption('Demand Generation/Pipeline Creation','Demand Generation/Pipeline Creation'));
            //Defect#218 Space was missing between chars.
            ObjectiveTypeList.add(new SelectOption('Field based (Execution)','Field based (Execution)'));
            ObjectiveTypeList.add(new SelectOption('Market Expansion (Geographic, Vertical, Product)','Market Expansion (Geographic, Vertical, Product)'));
            ObjectiveTypeList.add(new SelectOption('Partner Enablement','Partner Enablement'));
            ObjectiveTypeList.add(new SelectOption('Resource Investment (Headcount, Coverage, Lab, etc)','Resource Investment (Headcount, Coverage, Lab, etc)'));
            ObjectiveTypeList.add(new SelectOption('Solution and/or Practice Build out','Solution and/or Practice Build out'));
        }
        if(EMEAFilters==true){
            ObjectiveTypeList.add(new SelectOption('--None--','--None--'));
            ObjectiveTypeList.add(new SelectOption('3Cs','3Cs'));
            ObjectiveTypeList.add(new SelectOption('BRS','BRS'));
            ObjectiveTypeList.add(new SelectOption('SYMM','SYMM'));
            ObjectiveTypeList.add(new SelectOption('Other','Other'));
            ObjectiveTypeList.add(new SelectOption('Total','Total'));
            ObjectiveTypeList.add(new SelectOption('C Segment','C Segment'));
            ObjectiveTypeList.add(new SelectOption('Key Reseller','Key Reseller'));
            ObjectiveTypeList.add(new SelectOption('3Cs - Total','3Cs - Total'));
            ObjectiveTypeList.add(new SelectOption('# of Active Tier2 Resellers','# of Active Tier2 Resellers'));
            ObjectiveTypeList.add(new SelectOption('Recruitment','Recruitment'));
            ObjectiveTypeList.add(new SelectOption('Training','Training'));
            ObjectiveTypeList.add(new SelectOption('Velocity Specialty','Velocity Specialty'));
            ObjectiveTypeList.add(new SelectOption('# of Opportunities','# of Opportunities'));
            ObjectiveTypeList.add(new SelectOption('# of Marketing Qualified Leads','# of Marketing Qualified Leads'));
            ObjectiveTypeList.add(new SelectOption('Awareness & Consideration','Awareness & Consideration'));
            ObjectiveTypeList.add(new SelectOption('Demand Generation','Demand Generation'));
            ObjectiveTypeList.add(new SelectOption('Marketing Investment','Marketing Investment'));
        }
        return ObjectiveTypeList;
    }
    
    
    
    
/*@Method <This method getSolutionFocusList used to get the picklist values
            from the Objective via metadata for the field FocusArea>
@param <This method does not take any parameters>
@return <SelectOption> - <selected picklist values from configuration>
@throws exception - <No Exception>
*/
    public List<SelectOption> getSolutionFocusList(){
        if(SolutionFocusList == null && APJFilters==true){
            SolutionFocusList = new List<SelectOption>();
            SolutionFocusList.add(new SelectOption('--None--','--None--'));
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.SFDC_Objective__c.fields.Solution_Focus__c;
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    SolutionFocusList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return SolutionFocusList;
    }


/*@Method <This method getIndustryFocusList used to get the picklist values
            from the Objective via metadata for the field FocusArea>
@param <This method does not take any parameters>
@return <SelectOption> - <selected picklist values from configuration>
@throws exception - <No Exception>
*/
    public List<SelectOption> getIndustryFocusList(){
        if(IndustryFocusList == null && APJFilters==true){
            IndustryFocusList = new List<SelectOption>();
            IndustryFocusList.add(new SelectOption('--None--','--None--'));
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.SFDC_Objective__c.fields.Industry_Focus__c;
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    IndustryFocusList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return IndustryFocusList;
    }

/*@Method <This method getSolutionList used to get the picklist values
            from the Objective via metadata for the field FocusArea>
@param <This method does not take any parameters>
@return <SelectOption> - <selected picklist values from configuration>
@throws exception - <No Exception>
*/
    public List<SelectOption> getSolutionList(){
        if(SolutionList == null && AmerciaFilters==true){
            SolutionList = new List<SelectOption>();
            SolutionList.add(new SelectOption('--None--','--None--'));
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.SFDC_Objective__c.fields.Solution__c;
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    SolutionList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return SolutionList;
    }


/*@Method <This method getVerticalList used to get the picklist values
            from the Objective via metadata for the field FocusArea>
@param <This method does not take any parameters>
@return <SelectOption> - <selected picklist values from configuration>
@throws exception - <No Exception>
*/
    public List<SelectOption> getVerticalList(){
        if(VerticalList == null && AmerciaFilters==true){
            VerticalList = new List<SelectOption>();
            VerticalList.add(new SelectOption('--None--','--None--'));
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.SFDC_Objective__c.fields.Vertical__c;
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    VerticalList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return VerticalList;
    }


/*@Method <This method getSegmentList used to get the picklist values
            from the Objective via metadata for the field FocusArea>
@param <This method does not take any parameters>
@return <SelectOption> - <selected picklist values from configuration>
@throws exception - <No Exception>
*/
    public List<SelectOption> getSegmentList(){
        if(SegmentList == null && AmerciaFilters==true){
            SegmentList = new List<SelectOption>();
            SegmentList.add(new SelectOption('--None--','--None--'));
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.SFDC_Objective__c.fields.Segment__c;
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    SegmentList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return SegmentList;
    }
 /*@Method <This method getGeographyList used to get the picklist values
            from the Objective via metadata for the field FocusArea>
@param <This method does not take any parameters>
@return <SelectOption> - <selected picklist values from configuration>
@throws exception - <No Exception>
*/
    public List<SelectOption> getGeographyList(){
        if(GeographyList == null && (AmerciaFilters==true|| EmeaFilters== true || ApjFilters== true)){
            GeographyList = new List<SelectOption>();
            GeographyList.add(new SelectOption('--None--','--None--'));
            Schema.DescribeFieldResult pickListValues = Schema.sObjectType.Strategy__c.fields.Geography__c;
            for (Schema.PickListEntry nextPickVal : pickListValues.getPicklistValues()){
                    GeographyList.add(new SelectOption(nextPickVal.getValue(),nextPickVal.getLabel()));
            }
        }
        return GeographyList;
    }



/* @Method <This method goOnDetailPage is used to query on Objective and display 
            result in a new page>
   @param <This method not taking any arguements>
   @return <Page Reference> - <returning new page reference>
   @throws exception - <No Exception>
*/ 

    public PageReference goOnDetailPage() {
        //StringBuffer SubQuery = new StringBuffer();
        List<String> CriteriaItem = new List<String>();
            
            if(ParentObjectiveRegion!=''){
                CriteriaItem.add(' Parent_Objective_Region__c=\''+ParentObjectiveRegion +'\'');            
            }
            if(Geography!='' && Geography != '--None--' && Geography !=null ){
                CriteriaItem.add(' Parent_Objective_Geography__c=\''+Geography +'\'');            
            }
            
            if(Objective.Segment__c!='--None--' && Objective.Segment__c!=null  ){            
                CriteriaItem.add(' Segment__c= \''+Objective.Segment__c+ '\'');              
            }
            if(Objective.Solution__c!='--None--'  && Objective.Solution__c!=null){            
                CriteriaItem.add(' Solution__c= \''+Objective.Solution__c + '\''); 
            }
            if(Objective.Parent_Objective_Type__c!= '--None--'  && Objective.Parent_Objective_Type__c!=null){           
                CriteriaItem.add(' Parent_Objective_Type__c=\''+Objective.Parent_Objective_Type__c + '\'');             
            }
             if(Objective.Objective_Type__c!='--None--'  && Objective.Objective_Type__c!=null){           
                CriteriaItem.add(' Objective_Type__c=\''+Objective.Objective_Type__c + '\'');             
            }
             if(Objective.Vertical__c!='--None--'  && Objective.Vertical__c!=null){           
                CriteriaItem.add(' Vertical__c=\''+Objective.Vertical__c+ '\'');             
            }
           
           String WhereClause='';
           for(String condition :CriteriaItem){
                if( WhereClause==''){
                    WhereClause=condition;
                }else{
                    WhereClause=WhereClause+' and '+condition;
                }
           }
           System.debug('Subquery in goondetailpage' + WhereClause);
           ObjectiveList=fetchResult(WhereClause);
           System.debug(ObjectiveList);        
           return page.PRM_FilterObjectiveDetail;
    }


/* @Method <This method goOnpdfpage is used to query on Objective and 
            display result in a PDF Formatted page>
   @param <This method not taking any arguements>
   @return <Page Reference> - <returning page reference>
   @throws exception - <No Exception>
*/ 
    public PageReference goonpdfpage()
    {
        //ChannelRecord.id;
        PageReference returnPage=null;
        returnPage = new PageReference('/apex/PRM_FilterObjectiveDetailPDFView?id='+ChannelRecord.id);
        System.debug('Return Page is:' + returnPage);
        return returnPage;
          //return page.PRM_FilterObjectiveDetailPDFView;
    }
/* @Method <This method OpenObjective is used to display the record on click of 
             the link of the respective objective.> 
   @param <This method not taking any arguements>
   @return <Page Reference> - <returning new page reference>
   @throws exception - <No Exception>
*/
    
    public PageReference OpenObjective() {
        String ObjectiveRecord = ApexPages.currentPage().getParameters().get('ObjectName');
        System.debug('ObjectiveRecord-->'+ObjectiveRecord);
        return new PageReference('/'+ObjectiveRecord);
    }
    
/* @Method <This method EditRecord is used to edit the record on click of 
             the link of the respective objective.> 
   @param <This method not taking any arguements>
   @return <Page Reference> - <returning new page reference>
   @throws exception - <No Exception>
*/
    
    public PageReference EditRecord(){
        String ObjectiveEditId = ApexPages.currentPage().getParameters().get('ObjectiveEditId');
        System.debug('ObjectiveEditId-->'+ObjectiveEditId);
        return new PageReference('/'+ObjectiveEditId+'/e?retURL=%2F'+ObjectiveEditId);
    }
    
/* @Method <This method DeleteRecord is used to delete the record on click of 
             the link of the respective objective.> 
   @param <This method not taking any arguements>
   @return <Page Reference> - <returning new page reference>
   @throws exception - <No Exception>
*/
    
    public PageReference DeleteRecord(){
        String ObjectiveDeleteId = ApexPages.currentPage().getParameters().get('ObjectiveDeleteId');
        System.debug('ObjectiveDeleteId-->'+ObjectiveDeleteId);
        SFDC_Objective__c deleteRecords = [select id,name 
                                            from SFDC_Objective__c
                                            where Id=:ObjectiveDeleteId];
        //Check if User has delete access on record.
        boolean hasDeleteAccess = Schema.sObjectType.SFDC_Objective__c.isDeletable();
        System.debug('hasDeleteAccess'+hasDeleteAccess);        
        PageReference returnPage=null;
        try{
            if(hasDeleteAccess){            
                delete deleteRecords;
                returnPage = new PageReference('/apex/PRM_FilterObjective?id='+ChannelRecord.id);
                System.debug('returnPage'+returnPage);
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.Cannot_Delete_Objective);
                ApexPages.addMessage(myMsg);
                System.debug('myMsg'+myMsg);
            }
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }            
        return returnPage;
    }
    
/* @Method <This method setObjectiveList is setter method used to set the list
             of the objectives.>
   @param <This method is taking List<SFDC_Objective__c> which contains list of 
            Objective>
   @return <void> - <not returning anything>
   @throws exception - <No Exception>
*/
    
    public void setObjectiveList(List<SFDC_Objective__c> ObjectivesList){
        System.debug('ObjectivesList===>'+ObjectivesList);
        this.ObjectiveList = ObjectivesList;
    }

/* @Method <This method fetchResult is used to fetch the list of records from 
             objective based on focusarea and geography>
   @param <This method is taking String as parameter which contains query 
            string to fetch the record from objective>
   @return <List<SFDC_Objective__c>> - <Contains the list of objective records>
   @throws exception - <No Exception>
*/
    
    public List<SFDC_Objective__c> fetchResult(String SubQuery2){
        
        List<SFDC_Objective__c> ObjectivesList = new List<SFDC_Objective__c>();
        
        String FinalQueryString;
        Id ChannelAccountId = ChannelRecord.Id;
        
        
        //Defect#178 Updated the query to fetch only the current channle account plan objectives
        String SubQuery1 = 'Select s.Days_Left_Over__c, s.Focus_Area__c, s.Id,' 
                            +'s.End_Date__c, s.Name, s.Region__c, s.Stage__c,' 
                            +'s.Success_Measure__c,s.Objective_Type__c,SFDC_Objective__c.Strategy__r.name,'
                            +'s.Vertical__c,s.Segment__c,s.Solution__c,Parent_Objective_Region__c,' 
                            +'s.Industry_Focus__c,s.Solution_Focus__c,Parent_Objective_Geography__c,'                            
                            +'s.Parent_Objective_Type__c,Start_Date__c,Strategy__c'
                            +' from SFDC_Objective__c s'
                            +' where s.Channel_Account_Plan__r.Id=:ChannelAccountId ';
        
        if(SubQuery2!=''){
            FinalQueryString = SubQuery1+' and  '+SubQuery2;
        }else{
            FinalQueryString = SubQuery1;
        }
        System.debug('Query in if'+FinalQueryString);
        ObjectivesList = Database.Query(FinalQueryString);
        
        return ObjectivesList;                            
    }

/* @Method <This method getObjectiveList is a getter method to get the list of 
            recrods from the Objective>
   @param <This method is not taking any arguments>
   @return <List<SFDC_Objective__c>> - <Contains list of objective records>
   @throws exception - <No Exception>
*/

    public List<SFDC_Objective__c> getObjectiveList(){
        System.debug('ObjectiveList===>'+ObjectiveList);
        return ObjectiveList;
    }
    
    
  
}