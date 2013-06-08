public class EBC_WrapperShowRoomAssignment
{
	public string StartDate;
    public string EndDate;
    public String BriefingEvent;
    public Id RoomId;
    public String RoomName;
    public String getStartDate()
    {
        return this.StartDate;
    }
    public void setStartDate(string s)
    {
        this.StartDate = s;
    }
    public string getEndDate()
    {
        return this.EndDate;
    }
    public void setEndDate(string s)
    {
        this.EndDate = s;
    }
    
    public String getBriefingEvent()
    {
        return this.BriefingEvent;
    }
    public void setBriefingEvent(String s)
    {
        this.BriefingEvent = s;
    }    
    
    public String getRoomId()
    {
        return this.RoomId;
    }
    public void setRoomId(Id s)
    {
        this.RoomId = s;
    }
    
    public String getRoomName()
    {
        return this.RoomName;
    }
    public void setRoomName(String s)
    {
        this.RoomName = s;
    }    
}