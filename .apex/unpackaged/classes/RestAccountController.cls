@RestResource(urlMapping='/Accounts/*')
global with sharing class RestAccountController
{
    @HttpPost
    global static void insertAccount()
    {
        RestRequest request = RestContext.request;

        AccountWrapper wrapper = AccountWrapper.parse(request.requestBody.toString());

        List<Account> accounts = new List<Account>();
        Map <Account, AccountWrapper.AccountJSON> accountJSONMap = new Map<Account, AccountWrapper.AccountJSON>();
        for (AccountWrapper.AccountJSON acc : wrapper.newAccounts)
        {
            Account currAccount = new Account(name = acc.name);
            accounts.add(currAccount);
            accountJSONMap.put(currAccount, acc);
        }

        System.debug('******' + accountJSONMap);

      
        insert accounts;
      
        /*Loop through inserted Accounts to get its Ids. Then get appropriate AccountJSON to get related Contacts.
          Loop through currJSONAccount.relatedContacts creating new Contacts.  */

        List<Contact> relContacts = new List<Contact>();
        for( Account acc : accounts)
        {   
            AccountWrapper.AccountJSON currJSONAccount =  accountJSONMap.get(acc);

            System.debug('***acc' + acc);
            System.debug('***accountJSONMap' + accountJSONMap);


            System.debug('currJSONAccount******' + currJSONAccount);


            for (AccountWrapper.ContactJSON conJSON : currJSONAccount.relatedContacts)
            {
                relContacts.add(new Contact(
                        FirstName = conJSON.fistName,
                        LastName = conJSON.lastName,
                        AccountId = acc.Id));
            }
        }
        insert  relContacts;
    }
}