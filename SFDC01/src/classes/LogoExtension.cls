public class LogoExtension extends PartnerFinderBaseController {
	
	public static String INVALID_PAGE_FLOW {get{return 'INVALID_PAGE_FLOW';}}
	public String error{get;private set;}
	public Boolean errorOccurred{get{return StringUtils.isNotBlank(error);}}

	private SObject record;
	public Account account {get;private set;}
	public Logo__c logoRecord {get;private set;}
	public Attachment logoAttachment {get;private set;}
		
 	public String 	attachmentContentType {get;set;}
 	public String 	attachmentFileName {get;set;}
 	public transient Blob 	attachmentFile {get;set;}
 	public String	accountId {get;private set;}
 	public String	retURL {get;private set;}
 	public String	cancelURL {get;private set;}
 	public String	showHeader {get;private set;}
 	

	public LogoExtension(ApexPages.StandardController controller){
		this.record = controller.getRecord();
		this.accountId = PageUtils.get('accountId');
		this.retURL = PageUtils.param('retURL');
		this.cancelURL = PageUtils.param('cancelURL');
		this.showHeader = PageUtils.param('showHeader');
	}

	public PageReference doOnLoad(){
		if(record == null || !(record instanceof Logo__c)){
			error = INVALID_PAGE_FLOW;
			return null;
		}
		try{
			if(this.record.id == null){
				account = [select id,name,logo__c from Account where id = :accountId];
				if(StringUtils.isNotBlank(account.logo__c)){
					return PageUtils.redirect(Page.Logo.getUrl() + '?id=' + account.logo__c 
						+ (StringUtils.isBlank(this.retURL) ? '' : '&retURL='+EncodingUtil.urlEncode(this.retURL, 'UTF-8'))
						+ (StringUtils.isBlank(this.cancelURL) ? '' : '&cancelURL='+EncodingUtil.urlEncode(this.cancelURL, 'UTF-8'))
						+ (StringUtils.isBlank(this.showHeader) ? '' : '&showHeader='+EncodingUtil.urlEncode(this.showHeader, 'UTF-8'))
					);
				}
			}else{
				account = [select id,name,logo__c from Account where logo__c = :this.record.id];
			}
		}catch(QueryException e){
			error = INVALID_PAGE_FLOW;
			return null;
		}
		this.retURL = StringUtils.isBlank(this.retURL) ? '/'+account.id : this.retURL;
		this.cancelURL = StringUtils.isBlank(this.cancelURL) ? '/'+account.id : this.cancelURL;
		try{
			logoRecord = (Logo__c) record;
			logoAttachment = [select id from Attachment where parentid = :logoRecord.id];
		}catch(QueryException e){}
		return null;
	}
	
	public static Double MAX_BLOB_SIZE_IN_KB {get{return 10;}}
	 
	public PageReference doReplaceLogo(){
		if(attachmentFile == null){
			PageUtils.addError('Please select a file to upload.');
			return null;
		}
		
		final Double size = Decimal.valueOf(((Double)attachmentFile.size()/1024)).setScale(2);
		if(size > MAX_BLOB_SIZE_IN_KB){
			PageUtils.addError('Logo size (' + size + ' KB) exceeds maximum file size (' + MAX_BLOB_SIZE_IN_KB + ' KB).');
			return null;
		}
        Savepoint sp = null;
		try { 
			sp = Database.setSavepoint();
			logoRecord.Name=attachmentFileName;
			if(logoRecord.id == null){
				insert logoRecord;
				account.logo__c = logoRecord.id;
				update account;
			} else {
				update logoRecord;
			}
			if(logoAttachment == null){
				logoAttachment = new Attachment(
					Body=attachmentFile,
					ContentType=attachmentContentType,
					IsPrivate=false,
					Name=attachmentFileName,
					ParentID=logoRecord.id
				);				
				insert logoAttachment;
			} else {
				logoAttachment.Body=attachmentFile;
				logoAttachment.IsPrivate=false;
				logoAttachment.Name=attachmentFileName;
				update logoAttachment;
			}
		}catch(Exception e) {
			Database.rollback(sp);
			ApexPages.addMessages(e);
			return null;
		}
		return null;	
	}
	
	public PageReference doReturn(){
		if(StringUtils.isBlank(this.retURL)){
			return null;			
		}
		return new PageReference(this.retURL);
	}

	public PageReference doCancel(){
		if(StringUtils.isBlank(this.cancelURL)){
			return null;			
		}
		return new PageReference(this.cancelURL);
	}

}