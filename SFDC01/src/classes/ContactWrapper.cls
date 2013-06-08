public class ContactWrapper{
    
    public boolean checked=false;
    Contact contact= null;
    public boolean getChecked(){
        return checked;
    }
    public void setChecked(boolean c){
        checked=c;
    }
    public ContactWrapper(Contact contact){
        this.contact=contact;
    }
    public Contact getContact(){
        return contact;
    }
    public void setContact(Contact c){
        contact=c;
    }
    
}