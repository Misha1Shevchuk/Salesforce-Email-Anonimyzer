# Email Anonymizer for Salesforce

## Overview

This Salesforce Apex package provides an efficient way to anonymize email addresses in your Salesforce Org. It ensures compliance with data protection policies by replacing real email addresses with randomized values. It is extremely useful for refreshed sandboxes with real customers data where there is automation that sends emails.

## Features

- Anonymizes email fields across Salesforce objects.
- Supports selective field anonymization.
- Allows filtering records using custom conditions.
- Ensures data integrity by updating only allowed fields.
- Provides batch processing for efficient execution on large datasets.

## Usage

### Anonymizing Email Fields

To anonymize email fields in your Salesforce Org, configure the `EmailAnonimyzerConfig` object and execute the batch process:

```apex
EmailAnonimyzerConfig config = new EmailAnonimyzerConfig(Contact.SObjectType)
        .addAllEmailFields()
        .withSettingValueWhenFieldIsBlank()
        .withBypassingFls()
        .withAtomicDml();

Id batchId = EmailAnonymizerBatch.run(config);
```

### Filtering Specific Records

You can filter records based on conditions before anonymization:

```apex
EmailAnonimyzerConfig config = new EmailAnonimyzerConfig(Contact.SObjectType)
        .addAllEmailFields()
        .addFilters('AND Owner.Profile.Name != :profileToBypass', new Map<String, Object>{'profileToBypass' => 'Integration User'});

Id batchId = EmailAnonymizerBatch.run(config);
```

### Custom Fields Selection

Instead of anonymizing all email fields, you can specify which fields to process:

```apex
EmailAnonimyzerConfig config = new EmailAnonimyzerConfig(Contact.SObjectType)
        .addFields(new Set<SObjectField>{Contact.Email, Contact.OtherEmail});

Id batchId = EmailAnonymizerBatch.run(config);
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Mykhailo Shevchuk - misha1shevchuk@gmail.com

## Contact

For issues or feature requests, please open an issue on [GitHub](https://github.com/Misha1Shevchuk/Salesforce-Email-Anonimyzer/issues).

