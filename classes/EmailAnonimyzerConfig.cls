public inherited sharing class EmailAnonimyzerConfig {

    public final SObjectType sobjectType { public get; private set; }
    public final Set<SObjectField> fields { public get; private set; }
    public Boolean setValueIfFieldIsBlank { public get; private set; }
    public Boolean isAllOrNone { public get; private set; }
    public Map<String, Object> queryBinds { public get; private set; }

    private String additionalQueryFilter = '';
    private Boolean bypassFls = false;

    public EmailAnonimyzerConfig(SObjectType sobjectType) {
        this.sobjectType = sobjectType;
        this.fields = new Set<SObjectField>();
        this.setValueIfFieldIsBlank = false;
        this.isAllOrNone = true;
        this.queryBinds = new Map<String, Object>();
    }

    public EmailAnonimyzerConfig addAllEmailFields() {
        for (SObjectField field : this.sobjectType.getDescribe().fields.getMap().values()) {
            if (field.getDescribe().getType() == DisplayType.EMAIL) {
                this.addField(field);
            }
        }

        return this;
    }

    public EmailAnonimyzerConfig addFields(Set<SObjectField> fields) {
        for (SObjectField field : fields) {
            this.addField(field);
        }

        return this;
    }

    public EmailAnonimyzerConfig addField(SObjectField field) {
        if (this.bypassFls || field.getDescribe().isUpdateable()) {
            this.fields.add(field);
        }

        return this;
    }

    public EmailAnonimyzerConfig addFilters(String additionalQueryFilter) {
        this.additionalQueryFilter = additionalQueryFilter;

        return this;
    }

    public EmailAnonimyzerConfig addFilters(String additionalQueryFilter, Map<String, Object> queryBinds) {
        this.addFilters(additionalQueryFilter);
        this.queryBinds = queryBinds;

        return this;
    }

    public EmailAnonimyzerConfig withAtomicDml() {
        this.isAllOrNone = false;

        return this;
    }

    public EmailAnonimyzerConfig withSettingValueWhenFieldIsBlank() {
        this.setValueIfFieldIsBlank = true;

        return this;
    }

    public EmailAnonimyzerConfig withBypassingFls() {
        this.bypassFls = true;

        return this;
    }

    public Set<String> getFieldNames() {
        Set<String> fieldNames = new Set<String>();

        for (SObjectField field : this.fields) {
            fieldNames.add(field.getDescribe().getName());
        }

        return fieldNames;
    }

    public String buildQuery() {
        Set<String> filters = new Set<String>();
        if (this.setValueIfFieldIsBlank) {
            filters.add('Id != NULL');
        } else {
            for (String fieldName : this.getFieldNames()) {
                filters.add(fieldName + ' != NULL');
            }
        }

        return String.format(
                'SELECT Id, {0} FROM {1} WHERE ({2}) {3}',
                new List<Object>{
                        String.join(this.getFieldNames(), ', '),
                        this.sobjectType,
                        String.join(filters, ' OR '),
                        this.additionalQueryFilter
                }
        );
    }
}