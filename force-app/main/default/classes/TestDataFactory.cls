/**
 * Centralised factory for creating test SObject records.
 */
@IsTest
public class TestDataFactory {

    /**
     * Creates and optionally inserts Account records.
     *
     * @param count  Number of Account records to create
     * @param doInsert  Whether to insert the records into the database
     * @return List of Account records
     */
    public static List<Account> createAccounts(Integer count, Boolean doInsert) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        if (doInsert) {
            insert accounts;
        }
        return accounts;
    }
}
