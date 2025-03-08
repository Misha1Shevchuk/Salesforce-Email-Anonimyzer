@IsTest
private class EmailAnonymizerBatchTest {

    @TestSetup
    private static void createData() {
        insert new List<Contact>{
                new Contact(LastName = 'Doe'),
                new Contact(LastName = 'Stark'),
                new Contact(LastName = 'ToBypass')
        };
    }

    @IsTest
    private static void checkExecution() {
        EmailAnonimyzerConfig config = new EmailAnonimyzerConfig(Contact.SObjectType)
                .addAllEmailFields()
                .addFields(new Set<SObjectField>{Contact.FirstName})
                .withSettingValueWhenFieldIsBlank()
                .withBypassingFls()
                .withAtomicDml()
                .addFilters('AND LastName != :valueToBypass', new Map<String, Object>{'valueToBypass' => 'ToBypass'});

        Test.startTest();
        EmailAnonymizerBatch.run(config);
        Test.stopTest();

        List<Contact> contacts = [SELECT FirstName, LastName, Email FROM Contact];

        Map<String, Contact> contactByLastName = new Map<String, Contact>();
        for (Contact contact : contacts) {
            contactByLastName.put(contact.LastName, contact);
        }

        Assert.isTrue(contactByLastName.get('Doe').FirstName.contains('@'), contactByLastName.get('Doe').FirstName);
        Assert.isTrue(contactByLastName.get('Doe').Email.contains('@'), contactByLastName.get('Doe').Email);
        Assert.isTrue(contactByLastName.get('Stark').FirstName.contains('@'), contactByLastName.get('Stark').FirstName);
        Assert.isTrue(contactByLastName.get('Stark').Email.contains('@'), contactByLastName.get('Stark').Email);
        Assert.isNull(contactByLastName.get('ToBypass').FirstName);
        Assert.isNull(contactByLastName.get('ToBypass').Email);
    }
}