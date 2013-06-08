public with sharing class SFA_MOJO_AssetMassUpdateComponent {

    private final PageReference fromPage;
    private final List<SObject> objs;
    private transient ApexPages.Message currentMsg;
    private final String newLine ='<br></br>';
    private Map<String, Schema.SObjectField> fieldMap;
    private Schema.SObjectField field;
    private String sType;
    public Boolean Flag1=true; 
    private Object convertedFieldData;
    private List<SelectOption> picklistValues;
    private String currentStep;
    public Boolean Flag=true;  
    private String titleName;
    private Boolean okFlag=false;
    private Boolean previousFlag=true;
    private Boolean cancelFlag=true;
    public List<SObject> getSelectedRecords{ get; set;}
    public List<Asset__c> lstAssetRecords {get; set;}
    public PageReference returnURL {get; set;}
    public SFA_MOJO_AssetMassUpdateComponent(){
        system.debug('in to set AssetList--->');    
       currentStep = '1';
       title();
       
       
    }   
    
       public String getStep() {
        title();
        return currentStep;
    }
    
    public String getsType() {
        return sType;
    }    
       
    public integer getRecordSize() {
     if (lstAssetRecords !=null) {
        return lstAssetRecords.size();
     } else {
        return 0;
     }
    }
    
    public String filterId {
        get;
        set;    
    }
     
   public Boolean getFlag(){
        return flag;
   }     
    public void setFlag(Boolean flag){
        this.flag=flag;
    }        
    
    public String getNow(Boolean bShowTime) {
        DateTime now = DateTime.now();
        if (bShowTime)
            return  now.year() + '-' + now.month()+ '-' + now.day()+' '+now.hour()+ ':' +now.minute() + ':' + now.second();
        else
            return  now.year() + '-' + now.month()+ '-' + now.day();
    }
  

    public List<SObject> objsToUpdate {
        get {
            return (List<SObject>) objs;
        }
        set;
    }
  
    public String valueToUpdate {
        get;
        set;    
    }
    
    public Sobject valueToUpdate_object {
        get;
        set;    
    }

    public String fieldName {
        get;
        set {
            field = fieldMap.get(value);
            fieldType = field.getDescribe().getType().name();
            value = field.getDescribe().getLabel();
            fieldName=value;
            System.debug('Field:'+ field);            
        }   
    }
    
    public String fieldType{
        get;
        set;    
    }
   
   private Object convertUserInputToFieldData(){
        if (field==null) return null;
        DisplayType t = field.getDescribe().getType();
        Object s = null;
        
        try {       
                if (t==DisplayType.Double||t==DisplayType.Currency || t==DisplayType.Integer || t==DisplayType.Percent){
                    s = decimal.valueOf((String)valueToupdate);         
                } else if (t==DisplayType.Boolean){                 
                    if (valueToUpdate=='true'){
                        s = true;               
                    } else if (valueToUpdate=='false'){
                        s = false;              
                    } else {
                        s = Boolean.valueOf(valueToUpdate);
                    }
                } else if (t==DisplayType.Date) {
                    s = Date.valueOf(valueToUpdate);
                } else if (t==DisplayType.DateTime) {
                    s = DateTime.valueOf(valueToUpdate);
                } else if ((t==DisplayType.PickList || t==DisplayType.PickList) && valueToUpdate==null) {
                    s = '';
                }else {
                    s = valueToupdate;
                }
        } catch (System.TypeException e){
            System.debug('Type exception: ' + e.getMessage());
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            System.debug('Message : ' + currentMsg );
            }  
        
        return s;
    }
    
    
    public String getFieldInfoToDisplay() {
        if (field==null)  return '';
           String msg = Label.Field_Type_Mass_Update + fieldType + '<br/>';
        Schema.DescribeFieldResult d = field.getDescribe();
        
        if (d.getType()==DisplayType.TextArea || d.getType()==(DisplayType.String)||d.getType()==(DisplayType.URL)) {
            msg += Label.Max_Length + d.getLength();
            valueToUpdate='';
        } else if (d.getType()==DisplayType.DateTime ){
            msg += Label.Date_Time_Format;
            valueToUpdate=getNow(true);
        } else if (d.getType()==DisplayType.Date){
            msg += Label.Date_Format;
            valueToUpdate=getNow(false);
        } else if (d.getType()==DisplayType.Picklist){
            
            picklistValues = new List<SelectOption>();      
            if (d.isNillable()) {
                picklistValues.add(new SelectOption('', '--None--'));
            }
            for (Schema.PicklistEntry p : d.getPickListValues()) {
                picklistValues.add(new SelectOption(p.getValue(), p.getLabel()));
            }
             msg += ' ' + Label.Select_Picklist_Value;
        } else if (d.getType()==DisplayType.MultiPicklist){
            
             msg += Label.Valid_Picklist;
            String combined ='';
            
            for (Schema.PicklistEntry p : d.getPickListValues()) {
                msg += newLine + '    <b>' +p.getValue()+'</b>';
                combined += p.getValue()+';';
            }
             msg += newline + Label.Separate_Picklist_Values;
             msg += newline + Label.Select_Picklist_Value1  + combined + Label.Select_Picklist_Value2;
        } else if (d.getType()==DisplayType.Integer){
             msg += Label.Max_Digits + d.getDigits();
        } else if (d.getType()==DisplayType.String){
             msg += Label.Max_Length + d.getLength();
        } else if (d.getType()==DisplayType.Double || d.getType()==DisplayType.Currency || d.getType()==DisplayType.Percent){
            msg += Label.Format + (d.getPrecision()-d.getScale()) + ','+d.getScale() +')';
        } else if (d.getType()==DisplayType.Reference){
            msg += Label.Selected_Records + newLine;
            msg += Label.Please_enter + d.getName() + Label.Selected_Records_Reference;
        }
        
        return msg;
    }
    
       
    public PageReference cancel() {
        //return fromPage;
        return returnURL;
    }
         
    public PageReference step1() { 
       currentStep='Step 1 of 5 : Confirm records to be updated';  
       system.debug('currentStep-->'+currentStep);       
       //return ApexPages.currentPage();
       return null;
    }
    
    public PageReference step2() {
        if(getRecordSize()<1) return returnURL; 
        System.debug('Step 2 Error Message :' + fromPage);     
        currentStep='2';    
        System.debug('Step 2- Current Page : ' +ApexPages.currentPage());
        valueToUpdate='';    
        title();
               system.debug('currentStep-->'+currentStep);
        //return ApexPages.currentPage();
        return null;
    }
    
    public PageReference step3() {
         System.debug('Field:'+ fieldName);       
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
        ApexPages.addMessage(currentMsg);
        currentStep='3';         
        title();
               system.debug('currentStep-->'+currentStep);
        //return ApexPages.currentPage();
        return null;
    } 
  
    public PageReference step4() {
        convertedFieldData = convertUserInputToFieldData();
        
        // data type validation
        if (currentMsg!=null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
            ApexPages.addMessage(msg);
            ApexPages.addMessage(currentMsg);
            //return ApexPages.currentPage();
        }
        
        String msg = Label.Review_Selections;
          msg = msg + Label.Records_Selected + getRecordSize();
          msg = msg + Label.Field_To_Be_Updated + fieldName;
          msg = msg + Label.New_Value            + convertedFieldData;
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        ApexPages.addMessage(currentMsg);
        currentStep='4';         
        title();
               system.debug('currentStep-->'+currentStep);
        //return ApexPages.currentPage();
        return null;
    } 
      
    public PageReference step5() {
       // List<Object> lstAssetRecords = (List<Object>)lstAssetRecords;
       try {
        String Expected_Success_Messsage= Label.Updated + ' ' + lstAssetRecords.size() + ' ' + Label.Records_Mass_Update;
        currentMsg = (new MassUpdater(lstAssetRecords, field, convertedFieldData)).massUpdate();
              
        System.debug('I am lstAssetRecords-------------->'+ lstAssetRecords);
        //update lstAssetRecords;
        String strResult=''+currentMsg;
        
        if((strResult.indexOf(Expected_Success_Messsage)==-1)){
            Flag = False;
            System.debug('I am wrong-------------->');
            System.debug('STRRESULT-------------->' + strResult );
        }
        else{  
            Flag = True;
            ApexPages.addMessage(currentMsg);
            System.Debug('MSG'+currentMsg);
            System.debug('I am correct-------------->');
        } 
        currentStep='5';      
        title();
               system.debug('currentStep-->'+currentStep);
        //return ApexPages.currentPage();
        
       }
       catch(NullPointerException ex) {
       System.debug('Exception');
       }
 return null;

    }
   
    
    public DescribeSObjectResult discoverSObjectType(SObject s) {
        Map<String, Schema.SObjectType> des = Schema.getGlobalDescribe();
        
        for(Schema.SObjectType o:des.values()) {
           
           try{
           if( s.getSObjectType()==o) {
                return o.getDescribe();
            }
           }
           catch(NullpointerException ex){
           system.debug('exception');
           }
          }         
        return null;
    }
    
    public List<SelectOption> getFieldTypeOptions() {
    try{
        if (lstAssetRecords.size()<1) return null;
        }
        catch(Nullpointerexception ex){
        system.debug('exception');
        }
        List<SelectOption> options = new List<SelectOption>(); 
    
        Schema.DescribeSObjectResult sObj = discoverSObjectType(lstAssetRecords.get(0));
                
        fieldMap = sObj.fields.getMap();
        system.debug('fieldMap'+fieldMap);
        List<String> keys = sortByFieldLabel(fieldMap);
        
        for(String key:keys) {
            Schema.DescribeFieldResult d = fieldMap.get(key).getDescribe();

            if(d.isAccessible() && d.isUpdateable()) {
                if (isSupportedFieldType(d)) {
                    String label = d.getLabel();
                       String not_req_fields = ',Name,CreatedBy,CurrencyIsoCode,LastModifiedBy,RecordTypeId,Custom_Asset_Name__c,Customer_Name__c,Product_Name_Vendor__c,Product_Family__c,'; 
                        if(not_req_fields.indexOf(','+key+',')==-1){
                        System.debug('API:'+ key); 
                        options.add(new SelectOption(key, label));                                  
                     }
                }
            }
        }
        System.debug('test----->'+options);
        return options;
        }
           
    private List<String> sortByFieldLabel(Map<String, Schema.SObjectField> gd) {
        List<String> keys = new List<String>();
        
        Map<String, List<String>> labelMap = new Map<String, List<String>>();
        
        for(Schema.SObjectField s:gd.values()) {
            String label = s.getDescribe().getLabel();
            if(labelMap.get(label) == null) {
                labelMap.put(label, new List<String>());
            }
            
            labelMap.get(label).add(s.getDescribe().getName());        
        }
        
        List<String> labels = new List<String>(labelMap.keySet());
        labels.sort();
        
        for(String label:labels){
            keys.addAll(labelMap.get(label));
        }
        
        return keys;
    }
    
    public List<SelectOption> getPicklistValues() {
        return picklistValues;
    }
    
    private boolean isSupportedFieldType(DescribeFieldResult d) {
        // always return true for now, but in future some fields might not be supported
        return true;
    }
    
    
    public String title(){
    System.debug('currentStep--->'+currentStep);
    if(currentStep=='1')
        titleName = Label.MassUpdate_Title1;
    else if(currentStep=='2'){
        titleName =Label.MassUpdate_Title2;
    }
    else if(currentStep=='3'){
        titleName = Label.MassUpdate_Title3+fieldName;
    }
    else if(currentStep=='4'){
        titleName = Label.MassUpdate_Title4;
    }
    else{
        titleName = Label.MassUpdate_Title5;
    }
    System.debug('titleName--->'+titleName);
    return titleName;
    }
    
    public String gettitle(){
        return titleName;
    }
    public void settitle(String titleName){
        this.titleName = titleName;
    }
    public pageReference showOk(){
        return returnURL;
    }
    
    public Boolean getpreviousFlag(){
        return previousFlag;
    }
    
    public Boolean getFlag1(){
        return flag1;
    }     
    public void setFlag1(Boolean flag1){
        this.flag1=flag1;
    }
    
    public Boolean getcancelFlag(){
        return cancelFlag;
    }
    public Boolean getokFlag(){
        return okFlag;
    }

    public class aAsset { 
        public Asset__c ass {get;set;}
        public Boolean selected {get;set;}
        
        public aAsset(Asset__c a)
        {
            ass = a;
            selected = false;
        }
    }
    
    
    
}