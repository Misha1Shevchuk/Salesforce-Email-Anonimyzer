public with sharing class EmailAnonymizerBatch implements Database.Batchable<SObject> {

    private final EmailAnonimyzerConfig config;

    public static Id run(EmailAnonimyzerConfig config) {
        return run(config, 200);
    }

    public static Id run(EmailAnonimyzerConfig config, Integer chunkSize) {
        return Database.executeBatch(new EmailAnonymizerBatch(config), chunkSize);
    }

    private EmailAnonymizerBatch(EmailAnonimyzerConfig config) {
        if (config.fields.isEmpty()) {
            throw new HandledException('No fields to process');
        }

        this.config = config;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocatorWithBinds(
                this.config.buildQuery(),
                this.config.queryBinds,
                AccessLevel.SYSTEM_MODE
        );
    }

    public void execute(Database.BatchableContext context, List<SObject> records) {
        for (SObject record : records) {
            for (SObjectField field : this.config.fields) {
                if (record.get(field) != null || this.config.setValueIfFieldIsBlank) {
                    record.put(field, this.generateEmail());
                }
            }
        }

        Database.update(records, this.config.isAllOrNone);
    }

    public void finish(Database.BatchableContext context) {}

    private String generateEmail() {
        return UUID.randomUUID().toString().replaceAll('-', '').right(10) + '@random.com';
    }
}