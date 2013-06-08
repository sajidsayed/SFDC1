public class OP_SSF_SaveResult{
	public OP_SSF_SaveResult(List<Detail_Line__c> details){
		this.detailLines = details;
	}
	public List<Detail_Line__c> detailLines {get; set;}
	public Database.SaveResult[] dmlSaveResult {get; set;}
}