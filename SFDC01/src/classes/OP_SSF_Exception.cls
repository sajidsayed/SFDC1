public class OP_SSF_Exception extends Exception {
	public OP_SSF_Exception(Integer errorCode,Exception rootCause){
		this.errorCode=errorCode;
		this.errorMessage = rootCause.getMessage();
	}
	public Integer errorCode {get; set;}
	public String errorMessage {get; set;}
}