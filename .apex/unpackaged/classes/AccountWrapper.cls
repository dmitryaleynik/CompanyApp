/*  {"newAccounts":[
           {
           "name" : "SpaceX",
           "relatedContacts" : [
                        {
                        "fistName":"Elon",
                        "LastName" : "Musk"
                        }
                               ]
            }
                        ]} */
public class AccountWrapper
{
    public AccountJSON[] newAccounts;
    public  class AccountJSON
    {
        public String name;
        public ContactJSON [] relatedContacts;

    }
    public class ContactJSON
    {
        public  String fistName;
        public  String lastName;
    }
    public static AccountWrapper parse(String json)
    {
        return (AccountWrapper) System.JSON.deserialize(json, AccountWrapper.class);
    } 
}