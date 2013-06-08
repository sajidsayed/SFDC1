public class EmailMaskingTool {
   
    public String batchSize { get; set; }
    public String AppendText { get; set; }
    public String  citeria { get; set; }

    public String[] selectedFields { get; set; }
     public List<SelectOption> getEmail() {
        List<SelectOption> options = new List<SelectOption>();
        if(inputHiddenValue!=null){
        for(String email:inputHiddenValue.split(':'))
        options.add(new SelectOption(email,email));
        }
        return options;
    }
    public String inputHiddenValue { get; set; }
    public String objectName { get; set; }
    public PageReference startMasking() {
        System.debug('objectName***'+objectName);
        System.debug('selectedFields***'+selectedFields);
        System.debug('AppendText***'+AppendText);
        Integer bsize=Integer.valueOf(batchSize);
               
        id batchinstanceid = database.executeBatch(new AutomateMaskingBatch(objectName,selectedFields,AppendText,citeria ),bsize);
        
        return null;
    }
    
    public static testMethod void EmailMaskingTool () {
        EmailMaskingTool emailToolNew=new EmailMaskingTool();
        emailToolNew.batchSize ='200';
        emailToolNew.AppendText='Test';
        emailToolNew.selectedFields= new List<String>();
        emailToolNew.selectedFields.add('Email');
        emailToolNew.getEmail();    
        emailToolNew.startMasking();         
    }
}