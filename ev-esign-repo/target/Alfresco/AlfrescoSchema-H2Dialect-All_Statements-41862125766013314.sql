CREATE TABLE alf_applied_patch
(
    id VARCHAR(64) NOT NULL,
    description VARCHAR(1024),
    fixes_from_schema INT4,
    fixes_to_schema INT4,
    applied_to_schema INT4,
    target_schema INT4,
    applied_on_date TIMESTAMP,
    applied_to_server VARCHAR(64),
    was_executed BOOL,
    succeeded BOOL,
    report VARCHAR(1024),
    PRIMARY KEY (id)
);

CREATE SEQUENCE alf_locale_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_locale
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    locale_str VARCHAR(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX locale_str ON alf_locale (locale_str);

CREATE SEQUENCE alf_namespace_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_namespace
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    uri VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uri ON alf_namespace (uri);

CREATE SEQUENCE alf_qname_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_qname
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    ns_id INT8 NOT NULL,
    local_name VARCHAR(200) NOT NULL,
    CONSTRAINT fk_alf_qname_ns FOREIGN KEY (ns_id) REFERENCES alf_namespace (id),
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX ns_id ON alf_qname (ns_id, local_name);

CREATE SEQUENCE alf_permission_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_permission
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    type_qname_id INT8 NOT NULL,
    name VARCHAR(100) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_perm_tqn FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id)
);

CREATE UNIQUE INDEX type_qname_id ON alf_permission (type_qname_id, name);

CREATE INDEX fk_alf_perm_tqn ON alf_permission (type_qname_id);

CREATE SEQUENCE alf_ace_context_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_ace_context
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    class_context VARCHAR(1024),
    property_context VARCHAR(1024),
    kvp_context VARCHAR(1024),
    PRIMARY KEY (id)
);

CREATE SEQUENCE alf_authority_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_authority
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    authority VARCHAR(100),
    crc INT8,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX authority ON alf_authority (authority, crc);

CREATE INDEX idx_alf_auth_aut ON alf_authority (authority);

CREATE SEQUENCE alf_access_control_entry_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_access_control_entry
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    permission_id INT8 NOT NULL,
    authority_id INT8 NOT NULL,
    allowed BOOL NOT NULL,
    applies INT4 NOT NULL,
    context_id INT8,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_ace_auth FOREIGN KEY (authority_id) REFERENCES alf_authority (id),
    CONSTRAINT fk_alf_ace_ctx FOREIGN KEY (context_id) REFERENCES alf_ace_context (id),
    CONSTRAINT fk_alf_ace_perm FOREIGN KEY (permission_id) REFERENCES alf_permission (id)
);

CREATE UNIQUE INDEX permission_id ON alf_access_control_entry (permission_id, authority_id, allowed, applies);

CREATE INDEX fk_alf_ace_ctx ON alf_access_control_entry (context_id);

CREATE INDEX fk_alf_ace_perm ON alf_access_control_entry (permission_id);

CREATE INDEX fk_alf_ace_auth ON alf_access_control_entry (authority_id);

CREATE SEQUENCE alf_acl_change_set_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_acl_change_set
(
    id INT8 NOT NULL,
    commit_time_ms INT8,
    PRIMARY KEY (id)
);

CREATE INDEX idx_alf_acs_ctms ON alf_acl_change_set (commit_time_ms);

CREATE SEQUENCE alf_access_control_list_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_access_control_list
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    acl_id VARCHAR(36)  NOT NULL,
    latest BOOL NOT NULL,
    acl_version INT8 NOT NULL,
    inherits BOOL NOT NULL,
    inherits_from INT8,
    type INT4 NOT NULL,
    inherited_acl INT8,
    is_versioned BOOL NOT NULL,
    requires_version BOOL NOT NULL,
    acl_change_set INT8,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_acl_acs FOREIGN KEY (acl_change_set) REFERENCES alf_acl_change_set (id)
);

CREATE UNIQUE INDEX acl_id ON alf_access_control_list (acl_id, latest, acl_version);

CREATE INDEX idx_alf_acl_inh ON alf_access_control_list (inherits, inherits_from);

CREATE INDEX fk_alf_acl_acs ON alf_access_control_list (acl_change_set);

CREATE SEQUENCE alf_acl_member_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_acl_member
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    acl_id INT8 NOT NULL,
    ace_id INT8 NOT NULL,
    pos INT4 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_aclm_ace FOREIGN KEY (ace_id) REFERENCES alf_access_control_entry (id),
    CONSTRAINT fk_alf_aclm_acl FOREIGN KEY (acl_id) REFERENCES alf_access_control_list (id)
);

CREATE UNIQUE INDEX aclm_acl_id ON alf_acl_member (acl_id, ace_id, pos);

CREATE INDEX fk_alf_aclm_acl ON alf_acl_member (acl_id);

CREATE INDEX fk_alf_aclm_ace ON alf_acl_member (ace_id);

CREATE SEQUENCE alf_authority_alias_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_authority_alias
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    auth_id INT8 NOT NULL,
    alias_id INT8 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_autha_aut FOREIGN KEY (auth_id) REFERENCES alf_authority (id),
    CONSTRAINT fk_alf_autha_ali FOREIGN KEY (alias_id) REFERENCES alf_authority (id)
);

CREATE UNIQUE INDEX auth_id ON alf_authority_alias (auth_id, alias_id);

CREATE INDEX fk_alf_autha_ali ON alf_authority_alias (alias_id);

CREATE INDEX fk_alf_autha_aut ON alf_authority_alias (auth_id);

CREATE SEQUENCE alf_server_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_server
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    ip_address VARCHAR(39) NOT NULL,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX ip_address ON alf_server (ip_address);

CREATE SEQUENCE alf_transaction_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_transaction
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    server_id INT8,
    change_txn_id VARCHAR(56) NOT NULL,
    commit_time_ms INT8,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_txn_svr FOREIGN KEY (server_id) REFERENCES alf_server (id)
);

CREATE INDEX idx_alf_txn_ctms ON alf_transaction (commit_time_ms, id);

CREATE INDEX fk_alf_txn_svr ON alf_transaction (server_id);

CREATE SEQUENCE alf_store_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_store
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    protocol VARCHAR(50) NOT NULL,
    identifier VARCHAR(100) NOT NULL,
    root_node_id INT8,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX protocol ON alf_store (protocol, identifier);

CREATE SEQUENCE alf_node_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_node
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    store_id INT8 NOT NULL,
    uuid VARCHAR(36) NOT NULL,
    transaction_id INT8 NOT NULL,
    type_qname_id INT8 NOT NULL,
    locale_id INT8 NOT NULL,
    acl_id INT8,
    audit_creator VARCHAR(255),
    audit_created VARCHAR(30),
    audit_modifier VARCHAR(255),
    audit_modified VARCHAR(30),
    audit_accessed VARCHAR(30),
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_node_acl FOREIGN KEY (acl_id) REFERENCES alf_access_control_list (id),
    CONSTRAINT fk_alf_node_store FOREIGN KEY (store_id) REFERENCES alf_store (id),
    CONSTRAINT fk_alf_node_tqn FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id),
    CONSTRAINT fk_alf_node_txn FOREIGN KEY (transaction_id) REFERENCES alf_transaction (id),
    CONSTRAINT fk_alf_node_loc FOREIGN KEY (locale_id) REFERENCES alf_locale (id)
);

CREATE UNIQUE INDEX store_id ON alf_node (store_id, uuid);

CREATE INDEX idx_alf_node_mdq ON alf_node (store_id, type_qname_id, id);

CREATE INDEX idx_alf_node_cor ON alf_node (audit_creator, store_id, type_qname_id, id);

CREATE INDEX idx_alf_node_crd ON alf_node (audit_created, store_id, type_qname_id, id);

CREATE INDEX idx_alf_node_mor ON alf_node (audit_modifier, store_id, type_qname_id, id);

CREATE INDEX idx_alf_node_mod ON alf_node (audit_modified, store_id, type_qname_id, id);

CREATE INDEX idx_alf_node_txn_type ON alf_node (transaction_id, type_qname_id);

CREATE INDEX fk_alf_node_acl ON alf_node (acl_id);

CREATE INDEX fk_alf_node_store ON alf_node (store_id);

CREATE INDEX idx_alf_node_tqn ON alf_node (type_qname_id, store_id, id);

CREATE INDEX fk_alf_node_loc ON alf_node (locale_id);

CREATE INDEX fk_alf_store_root ON alf_store (root_node_id);

ALTER TABLE alf_store ADD CONSTRAINT fk_alf_store_root FOREIGN KEY (root_node_id) REFERENCES alf_node (id);

CREATE SEQUENCE alf_child_assoc_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_child_assoc
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    parent_node_id INT8 NOT NULL,
    type_qname_id INT8 NOT NULL,
    child_node_name_crc INT8 NOT NULL,
    child_node_name VARCHAR(50) NOT NULL,
    child_node_id INT8 NOT NULL,
    qname_ns_id INT8 NOT NULL,
    qname_localname VARCHAR(255) NOT NULL,
    qname_crc INT8 NOT NULL,
    is_primary BOOL,
    assoc_index INT4,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_cass_cnode FOREIGN KEY (child_node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_cass_pnode FOREIGN KEY (parent_node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_cass_qnns FOREIGN KEY (qname_ns_id) REFERENCES alf_namespace (id),
    CONSTRAINT fk_alf_cass_tqn FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id)
);

CREATE UNIQUE INDEX parent_node_id ON alf_child_assoc (parent_node_id, type_qname_id, child_node_name_crc, child_node_name);

CREATE INDEX idx_alf_cass_pnode ON alf_child_assoc (parent_node_id, assoc_index, id);

CREATE INDEX fk_alf_cass_cnode ON alf_child_assoc (child_node_id);

CREATE INDEX fk_alf_cass_tqn ON alf_child_assoc (type_qname_id);

CREATE INDEX fk_alf_cass_qnns ON alf_child_assoc (qname_ns_id);

CREATE INDEX idx_alf_cass_qncrc ON alf_child_assoc (qname_crc, type_qname_id, parent_node_id);

CREATE INDEX idx_alf_cass_pri ON alf_child_assoc (parent_node_id, is_primary, child_node_id);

CREATE TABLE alf_node_aspects
(
    node_id INT8 NOT NULL,
    qname_id INT8 NOT NULL,
    PRIMARY KEY (node_id, qname_id),
 CONSTRAINT fk_alf_nasp_n FOREIGN KEY (node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_nasp_qn FOREIGN KEY (qname_id) REFERENCES alf_qname (id)
);

CREATE INDEX fk_alf_nasp_n ON alf_node_aspects (node_id);

CREATE INDEX fk_alf_nasp_qn ON alf_node_aspects (qname_id);

CREATE SEQUENCE alf_node_assoc_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_node_assoc
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    source_node_id INT8 NOT NULL,
    target_node_id INT8 NOT NULL,
    type_qname_id INT8 NOT NULL,
    assoc_index INT8 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_nass_snode FOREIGN KEY (source_node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_nass_tnode FOREIGN KEY (target_node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_nass_tqn FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id)
);

CREATE UNIQUE INDEX source_node_id ON alf_node_assoc (source_node_id, target_node_id, type_qname_id);

CREATE INDEX fk_alf_nass_snode ON alf_node_assoc (source_node_id, type_qname_id, assoc_index);

CREATE INDEX fk_alf_nass_tnode ON alf_node_assoc (target_node_id, type_qname_id);

CREATE INDEX fk_alf_nass_tqn ON alf_node_assoc (type_qname_id);

CREATE TABLE alf_node_properties
(
    node_id INT8 NOT NULL,
    actual_type_n INT4 NOT NULL,
    persisted_type_n INT4 NOT NULL,
    boolean_value BOOL,
    long_value INT8,
    float_value FLOAT4,
    double_value FLOAT8,
    string_value VARCHAR(1024),
    serializable_value BYTEA,
    qname_id INT8 NOT NULL,
    list_index INT4 NOT NULL,
    locale_id INT8 NOT NULL,
    PRIMARY KEY (node_id, qname_id, list_index, locale_id),
    CONSTRAINT fk_alf_nprop_loc FOREIGN KEY (locale_id) REFERENCES alf_locale (id),
    CONSTRAINT fk_alf_nprop_n FOREIGN KEY (node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_nprop_qn FOREIGN KEY (qname_id) REFERENCES alf_qname (id)
);

CREATE INDEX fk_alf_nprop_n ON alf_node_properties (node_id);

CREATE INDEX fk_alf_nprop_qn ON alf_node_properties (qname_id);

CREATE INDEX fk_alf_nprop_loc ON alf_node_properties (locale_id);

CREATE INDEX idx_alf_nprop_s ON alf_node_properties (qname_id, string_value, node_id);

CREATE INDEX idx_alf_nprop_l ON alf_node_properties (qname_id, long_value, node_id);

CREATE INDEX idx_alf_nprop_b ON alf_node_properties (qname_id, boolean_value, node_id);

CREATE INDEX idx_alf_nprop_f ON alf_node_properties (qname_id, float_value, node_id);

CREATE INDEX idx_alf_nprop_d ON alf_node_properties (qname_id, double_value, node_id);

CREATE SEQUENCE alf_lock_resource_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_lock_resource
(
   id INT8 NOT NULL,
   version INT8 NOT NULL,
   qname_ns_id INT8 NOT NULL,
   qname_localname VARCHAR(255) NOT NULL,
   CONSTRAINT fk_alf_lockr_ns FOREIGN KEY (qname_ns_id) REFERENCES alf_namespace (id),
   PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_lockr_key ON alf_lock_resource (qname_ns_id, qname_localname);

CREATE SEQUENCE alf_lock_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_lock
(
   id INT8 NOT NULL,
   version INT8 NOT NULL,
   shared_resource_id INT8 NOT NULL,
   excl_resource_id INT8 NOT NULL,
   lock_token VARCHAR(36) NOT NULL,
   start_time INT8 NOT NULL,
   expiry_time INT8 NOT NULL,
   CONSTRAINT fk_alf_lock_shared FOREIGN KEY (shared_resource_id) REFERENCES alf_lock_resource (id),
   CONSTRAINT fk_alf_lock_excl FOREIGN KEY (excl_resource_id) REFERENCES alf_lock_resource (id),
   PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_lock_key ON alf_lock (shared_resource_id, excl_resource_id);

CREATE INDEX fk_alf_lock_excl ON alf_lock (excl_resource_id);

CREATE SEQUENCE alf_mimetype_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_mimetype
(
   id INT8 NOT NULL,
   version INT8 NOT NULL,
   mimetype_str VARCHAR(100) NOT NULL,
   PRIMARY KEY (id),
   UNIQUE (mimetype_str)
);

CREATE SEQUENCE alf_encoding_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_encoding
(
   id INT8 NOT NULL,
   version INT8 NOT NULL,
   encoding_str VARCHAR(100) NOT NULL,
   PRIMARY KEY (id),
   UNIQUE (encoding_str)
);

CREATE SEQUENCE alf_content_url_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_content_url
(
   id INT8 NOT NULL,
   content_url VARCHAR(255) NOT NULL,
   content_url_short VARCHAR(12) NOT NULL,
   content_url_crc INT8 NOT NULL,
   content_size INT8 NOT NULL,
   orphan_time INT8 NULL,
   PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_conturl_cr ON alf_content_url (content_url_short, content_url_crc);

CREATE INDEX idx_alf_conturl_ot ON alf_content_url (orphan_time);

CREATE INDEX idx_alf_conturl_sz ON alf_content_url (content_size, id);

CREATE SEQUENCE alf_content_data_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_content_data
(
   id INT8 NOT NULL,
   version INT8 NOT NULL,
   content_url_id INT8 NULL,
   content_mimetype_id INT8 NULL,
   content_encoding_id INT8 NULL,
   content_locale_id INT8 NULL,
   CONSTRAINT fk_alf_cont_url FOREIGN KEY (content_url_id) REFERENCES alf_content_url (id),
   CONSTRAINT fk_alf_cont_mim FOREIGN KEY (content_mimetype_id) REFERENCES alf_mimetype (id),
   CONSTRAINT fk_alf_cont_enc FOREIGN KEY (content_encoding_id) REFERENCES alf_encoding (id),
   CONSTRAINT fk_alf_cont_loc FOREIGN KEY (content_locale_id) REFERENCES alf_locale (id),
   PRIMARY KEY (id)
);

CREATE INDEX fk_alf_cont_url ON alf_content_data (content_url_id);

CREATE INDEX fk_alf_cont_mim ON alf_content_data (content_mimetype_id);

CREATE INDEX fk_alf_cont_enc ON alf_content_data (content_encoding_id);

CREATE INDEX fk_alf_cont_loc ON alf_content_data (content_locale_id);

CREATE SEQUENCE alf_prop_class_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_prop_class
(
   id INT8 NOT NULL,
   java_class_name VARCHAR(255) NOT NULL,
   java_class_name_short VARCHAR(32) NOT NULL,
   java_class_name_crc INT8 NOT NULL,
   PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_propc_crc ON alf_prop_class(java_class_name_crc, java_class_name_short);

CREATE INDEX idx_alf_propc_clas ON alf_prop_class(java_class_name);

CREATE TABLE alf_prop_date_value
(
   date_value INT8 NOT NULL,
   full_year INT4 NOT NULL,
   half_of_year INT2 NOT NULL,
   quarter_of_year INT2 NOT NULL,
   month_of_year INT2 NOT NULL,
   week_of_year INT2 NOT NULL,
   week_of_month INT2 NOT NULL,
   day_of_year INT4 NOT NULL,
   day_of_month INT2 NOT NULL,
   day_of_week INT2 NOT NULL,
   PRIMARY KEY (date_value)
);

CREATE INDEX idx_alf_propdt_dt ON alf_prop_date_value(full_year, month_of_year, day_of_month);

CREATE SEQUENCE alf_prop_double_value_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_prop_double_value
(
   id INT8 NOT NULL,
   double_value FLOAT8 NOT NULL,
   PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_propd_val ON alf_prop_double_value(double_value);

CREATE SEQUENCE alf_prop_string_value_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_prop_string_value
(
   id INT8 NOT NULL,
   string_value VARCHAR(1024) NOT NULL,
   string_end_lower VARCHAR(16) NOT NULL,
   string_crc INT8 NOT NULL,
   PRIMARY KEY (id)
);

CREATE INDEX idx_alf_props_str ON alf_prop_string_value(string_value);

CREATE UNIQUE INDEX idx_alf_props_crc ON alf_prop_string_value(string_end_lower, string_crc);

CREATE SEQUENCE alf_prop_serializable_value_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_prop_serializable_value
(
   id INT8 NOT NULL,
   serializable_value BYTEA NOT NULL,
   PRIMARY KEY (id)
);

CREATE SEQUENCE alf_prop_value_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_prop_value
(
   id INT8 NOT NULL,
   actual_type_id INT8 NOT NULL,
   persisted_type INT2 NOT NULL,
   long_value INT8 NOT NULL,
   PRIMARY KEY (id)
);

CREATE INDEX idx_alf_propv_per ON alf_prop_value(persisted_type, long_value);

CREATE UNIQUE INDEX idx_alf_propv_act ON alf_prop_value(actual_type_id, long_value);

CREATE SEQUENCE alf_prop_root_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_prop_root
(
   id INT8 NOT NULL,
   version INT4 NOT NULL,
   PRIMARY KEY (id)
);

CREATE TABLE alf_prop_link
(
   root_prop_id INT8 NOT NULL,
   prop_index INT8 NOT NULL,
   contained_in INT8 NOT NULL,
   key_prop_id INT8 NOT NULL,
   value_prop_id INT8 NOT NULL,
   CONSTRAINT fk_alf_propln_root FOREIGN KEY (root_prop_id) REFERENCES alf_prop_root (id) ON DELETE CASCADE,
   CONSTRAINT fk_alf_propln_key FOREIGN KEY (key_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE,
   CONSTRAINT fk_alf_propln_val FOREIGN KEY (value_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE,
   PRIMARY KEY (root_prop_id, contained_in, prop_index)
);

CREATE INDEX idx_alf_propln_for ON alf_prop_link(root_prop_id, key_prop_id, value_prop_id);

CREATE INDEX fk_alf_propln_key ON alf_prop_link(key_prop_id);

CREATE INDEX fk_alf_propln_val ON alf_prop_link(value_prop_id);

CREATE SEQUENCE alf_prop_unique_ctx_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_prop_unique_ctx
(
   id INT8 NOT NULL,
   version INT4 NOT NULL,
   value1_prop_id INT8 NOT NULL,
   value2_prop_id INT8 NOT NULL,
   value3_prop_id INT8 NOT NULL,
   prop1_id INT8 NULL,
   CONSTRAINT fk_alf_propuctx_v1 FOREIGN KEY (value1_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE,
   CONSTRAINT fk_alf_propuctx_v2 FOREIGN KEY (value2_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE,
   CONSTRAINT fk_alf_propuctx_v3 FOREIGN KEY (value3_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE,
   CONSTRAINT fk_alf_propuctx_p1 FOREIGN KEY (prop1_id) REFERENCES alf_prop_root (id),
   PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_propuctx ON alf_prop_unique_ctx(value1_prop_id, value2_prop_id, value3_prop_id);

CREATE INDEX fk_alf_propuctx_v2 ON alf_prop_unique_ctx(value2_prop_id);

CREATE INDEX fk_alf_propuctx_v3 ON alf_prop_unique_ctx(value3_prop_id);

CREATE INDEX fk_alf_propuctx_p1 ON alf_prop_unique_ctx(prop1_id);

CREATE SEQUENCE alf_content_url_enc_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_content_url_encryption
(
   id INT8 NOT NULL,
   content_url_id INT8 NOT NULL,
   algorithm VARCHAR(10) NOT NULL,
   key_size INT4 NOT NULL,
   encrypted_key BYTEA NOT NULL,
   master_keystore_id VARCHAR(20) NOT NULL,
   master_key_alias VARCHAR(15) NOT NULL,
   unencrypted_file_size INT8 NULL,
   CONSTRAINT fk_alf_cont_enc_url FOREIGN KEY (content_url_id) REFERENCES alf_content_url (id) ON DELETE CASCADE,
   PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_cont_enc_url ON alf_content_url_encryption (content_url_id);

CREATE INDEX idx_alf_cont_enc_mka ON alf_content_url_encryption (master_key_alias);

DELETE FROM alf_applied_patch WHERE id = 'patch.db-V5.0-ContentUrlEncryptionTables';

INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V5.0-ContentUrlEncryptionTables', 'Manually executed script upgrade V5.0: Content Url Encryption Tables',
    0, 8001, -1, 8002, null, 'UNKNOWN', 1, 1, 'Script completed'
  );

CREATE SEQUENCE alf_audit_model_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_audit_model
(
   id INT8 NOT NULL,
   content_data_id INT8 NOT NULL,
   content_crc INT8 NOT NULL,
   CONSTRAINT fk_alf_aud_mod_cd FOREIGN KEY (content_data_id) REFERENCES alf_content_data (id),
   PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_aud_mod_cr ON alf_audit_model(content_crc);

CREATE INDEX fk_alf_aud_mod_cd ON alf_audit_model(content_data_id);

CREATE SEQUENCE alf_audit_app_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_audit_app
(
   id INT8 NOT NULL,
   version INT4 NOT NULL,
   app_name_id INT8 NOT NULL CONSTRAINT idx_alf_aud_app_an UNIQUE,
   audit_model_id INT8 NOT NULL,
   disabled_paths_id INT8 NOT NULL,
   CONSTRAINT fk_alf_aud_app_an FOREIGN KEY (app_name_id) REFERENCES alf_prop_value (id),
   CONSTRAINT fk_alf_aud_app_mod FOREIGN KEY (audit_model_id) REFERENCES alf_audit_model (id) ON DELETE CASCADE,
   CONSTRAINT fk_alf_aud_app_dis FOREIGN KEY (disabled_paths_id) REFERENCES alf_prop_root (id),
   PRIMARY KEY (id)
);

CREATE INDEX fk_alf_aud_app_mod ON alf_audit_app(audit_model_id);

CREATE INDEX fk_alf_aud_app_dis ON alf_audit_app(disabled_paths_id);

CREATE SEQUENCE alf_audit_entry_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_audit_entry
(
   id INT8 NOT NULL,
   audit_app_id INT8 NOT NULL,
   audit_time INT8 NOT NULL,
   audit_user_id INT8 NULL,
   audit_values_id INT8 NULL,
   CONSTRAINT fk_alf_aud_ent_app FOREIGN KEY (audit_app_id) REFERENCES alf_audit_app (id) ON DELETE CASCADE,
   CONSTRAINT fk_alf_aud_ent_use FOREIGN KEY (audit_user_id) REFERENCES alf_prop_value (id),
   CONSTRAINT fk_alf_aud_ent_pro FOREIGN KEY (audit_values_id) REFERENCES alf_prop_root (id),
   PRIMARY KEY (id)
);

CREATE INDEX idx_alf_aud_ent_tm ON alf_audit_entry(audit_time);

CREATE INDEX fk_alf_aud_ent_app ON alf_audit_entry(audit_app_id);

CREATE INDEX fk_alf_aud_ent_use ON alf_audit_entry(audit_user_id);

CREATE INDEX fk_alf_aud_ent_pro ON alf_audit_entry(audit_values_id);

CREATE SEQUENCE alf_activity_feed_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_activity_feed
(
    id INT8 NOT NULL,
    post_id INT8,
    post_date TIMESTAMP NOT NULL,
    activity_summary VARCHAR(1024),
    feed_user_id VARCHAR(255),
    activity_type VARCHAR(255) NOT NULL,
    site_network VARCHAR(255),
    app_tool VARCHAR(36),
    post_user_id VARCHAR(255) NOT NULL,
    feed_date TIMESTAMP NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX feed_postdate_idx ON alf_activity_feed (post_date);

CREATE INDEX feed_postuserid_idx ON alf_activity_feed (post_user_id);

CREATE INDEX feed_feeduserid_idx ON alf_activity_feed (feed_user_id);

CREATE INDEX feed_sitenetwork_idx ON alf_activity_feed (site_network);

CREATE SEQUENCE alf_activity_feed_control_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_activity_feed_control
(
    id INT8 NOT NULL,
    feed_user_id VARCHAR(255) NOT NULL,
    site_network VARCHAR(255),
    app_tool VARCHAR(36),
    last_modified TIMESTAMP NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX feedctrl_feeduserid_idx ON alf_activity_feed_control (feed_user_id);

CREATE SEQUENCE alf_activity_post_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_activity_post
(
    sequence_id INT8 NOT NULL,
    post_date TIMESTAMP NOT NULL,
    status VARCHAR(10) NOT NULL,
    activity_data VARCHAR(1024) NOT NULL,
    post_user_id VARCHAR(255) NOT NULL,
    job_task_node INT4 NOT NULL,
    site_network VARCHAR(255),
    app_tool VARCHAR(36),
    activity_type VARCHAR(255) NOT NULL,
    last_modified TIMESTAMP NOT NULL,
    PRIMARY KEY (sequence_id)
);

CREATE INDEX post_jobtasknode_idx ON alf_activity_post (job_task_node);

CREATE INDEX post_status_idx ON alf_activity_post (status);

CREATE SEQUENCE alf_usage_delta_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_usage_delta
(
    id INT8 NOT NULL,
    version INT8 NOT NULL,
    node_id INT8 NOT NULL,
    delta_size INT8 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_alf_usaged_n FOREIGN KEY (node_id) REFERENCES alf_node (id)
);

CREATE INDEX fk_alf_usaged_n ON alf_usage_delta (node_id);

DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.4-UsageTables';

INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.4-UsageTables', 'Manually executed script upgrade V3.4: Usage Tables',
    0, 113, -1, 114, null, 'UNKNOWN', 1, 1, 'Script completed'
  );

CREATE TABLE alf_subscriptions
(
  user_node_id INT8 NOT NULL,
  node_id INT8 NOT NULL,
  PRIMARY KEY (user_node_id, node_id),
  CONSTRAINT fk_alf_sub_user FOREIGN KEY (user_node_id) REFERENCES alf_node(id) ON DELETE CASCADE,
  CONSTRAINT fk_alf_sub_node FOREIGN KEY (node_id) REFERENCES alf_node(id) ON DELETE CASCADE
);

CREATE INDEX fk_alf_sub_node ON alf_subscriptions (node_id);

CREATE TABLE alf_tenant (
  tenant_domain VARCHAR(75) NOT NULL,
  version INT8 NOT NULL,
  enabled BOOL NOT NULL,
  tenant_name VARCHAR(75),
  content_root VARCHAR(255),
  db_url VARCHAR(255),
  PRIMARY KEY (tenant_domain)
);

DELETE FROM alf_applied_patch WHERE id = 'patch.db-V4.0-TenantTables';

INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V4.0-TenantTables', 'Manually executed script upgrade V4.0: Tenant Tables',
    0, 6004, -1, 6005, null, 'UNKNOWN', 1, 1, 'Script completed'
  );

CREATE SEQUENCE alf_auth_status_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE alf_auth_status
(
    id INT8 NOT NULL,
    username VARCHAR(100) NOT NULL,
    deleted BOOL NOT NULL,
    authorized BOOL NOT NULL,
    checksum BYTEA NOT NULL,
    authaction VARCHAR(10) NOT NULL,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_auth_usr_stat ON alf_auth_status (username, authorized);

CREATE INDEX idx_alf_auth_deleted ON alf_auth_status (deleted);

CREATE INDEX idx_alf_auth_action ON alf_auth_status (authaction);

DELETE FROM alf_applied_patch WHERE id = 'patch.db-V4.1-AuthorizationTables';

INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V4.1-AuthorizationTables', 'Manually executed script upgrade V4.1: Authorization status tables',
    0, 6075, -1, 6076, null, 'UNKNOWN', 1, 1, 'Script completed'
  );

create table JBPM_ACTION (ID_ bigint generated by default as identity, class char(255) not null, NAME_ varchar(255), ISPROPAGATIONALLOWED_ bit, ACTIONEXPRESSION_ varchar(255), ISASYNC_ bit, REFERENCEDACTION_ bigint, ACTIONDELEGATION_ bigint, EVENT_ bigint, PROCESSDEFINITION_ bigint, TIMERNAME_ varchar(255), DUEDATE_ varchar(255), REPEAT_ varchar(255), TRANSITIONNAME_ varchar(255), TIMERACTION_ bigint, EXPRESSION_ clob, EVENTINDEX_ integer, EXCEPTIONHANDLER_ bigint, EXCEPTIONHANDLERINDEX_ integer, primary key (ID_));

create table JBPM_BYTEARRAY (ID_ bigint generated by default as identity, NAME_ varchar(255), FILEDEFINITION_ bigint, primary key (ID_));

create table JBPM_BYTEBLOCK (PROCESSFILE_ bigint not null, BYTES_ binary(1024), INDEX_ integer not null, primary key (PROCESSFILE_, INDEX_));

create table JBPM_COMMENT (ID_ bigint generated by default as identity, VERSION_ integer not null, ACTORID_ varchar(255), TIME_ timestamp, MESSAGE_ clob, TOKEN_ bigint, TASKINSTANCE_ bigint, TOKENINDEX_ integer, TASKINSTANCEINDEX_ integer, primary key (ID_));

create table JBPM_DECISIONCONDITIONS (DECISION_ bigint not null, TRANSITIONNAME_ varchar(255), EXPRESSION_ varchar(255), INDEX_ integer not null, primary key (DECISION_, INDEX_));

create table JBPM_DELEGATION (ID_ bigint generated by default as identity, CLASSNAME_ clob, CONFIGURATION_ clob, CONFIGTYPE_ varchar(255), PROCESSDEFINITION_ bigint, primary key (ID_));

create table JBPM_EVENT (ID_ bigint generated by default as identity, EVENTTYPE_ varchar(255), TYPE_ char(255), GRAPHELEMENT_ bigint, PROCESSDEFINITION_ bigint, NODE_ bigint, TRANSITION_ bigint, TASK_ bigint, primary key (ID_));

create table JBPM_EXCEPTIONHANDLER (ID_ bigint generated by default as identity, EXCEPTIONCLASSNAME_ clob, TYPE_ char(255), GRAPHELEMENT_ bigint, PROCESSDEFINITION_ bigint, GRAPHELEMENTINDEX_ integer, NODE_ bigint, TRANSITION_ bigint, TASK_ bigint, primary key (ID_));

create table JBPM_JOB (ID_ bigint generated by default as identity, CLASS_ char(255) not null, VERSION_ integer not null, DUEDATE_ timestamp, PROCESSINSTANCE_ bigint, TOKEN_ bigint, TASKINSTANCE_ bigint, ISSUSPENDED_ bit, ISEXCLUSIVE_ bit, LOCKOWNER_ varchar(255), LOCKTIME_ timestamp, EXCEPTION_ clob, RETRIES_ integer, NAME_ varchar(255), REPEAT_ varchar(255), TRANSITIONNAME_ varchar(255), ACTION_ bigint, GRAPHELEMENTTYPE_ varchar(255), GRAPHELEMENT_ bigint, NODE_ bigint, primary key (ID_));

create table JBPM_LOG (ID_ bigint generated by default as identity, CLASS_ char(255) not null, INDEX_ integer, DATE_ timestamp, TOKEN_ bigint, PARENT_ bigint, MESSAGE_ clob, EXCEPTION_ clob, ACTION_ bigint, NODE_ bigint, ENTER_ timestamp, LEAVE_ timestamp, DURATION_ bigint, NEWLONGVALUE_ bigint, TRANSITION_ bigint, CHILD_ bigint, SOURCENODE_ bigint, DESTINATIONNODE_ bigint, VARIABLEINSTANCE_ bigint, OLDBYTEARRAY_ bigint, NEWBYTEARRAY_ bigint, OLDDATEVALUE_ timestamp, NEWDATEVALUE_ timestamp, OLDDOUBLEVALUE_ double, NEWDOUBLEVALUE_ double, OLDLONGIDCLASS_ varchar(255), OLDLONGIDVALUE_ bigint, NEWLONGIDCLASS_ varchar(255), NEWLONGIDVALUE_ bigint, OLDSTRINGIDCLASS_ varchar(255), OLDSTRINGIDVALUE_ varchar(255), NEWSTRINGIDCLASS_ varchar(255), NEWSTRINGIDVALUE_ varchar(255), OLDLONGVALUE_ bigint, OLDSTRINGVALUE_ clob, NEWSTRINGVALUE_ clob, TASKINSTANCE_ bigint, TASKACTORID_ varchar(255), TASKOLDACTORID_ varchar(255), SWIMLANEINSTANCE_ bigint, primary key (ID_));

create table JBPM_MODULEDEFINITION (ID_ bigint generated by default as identity, CLASS_ char(255) not null, NAME_ varchar(255), PROCESSDEFINITION_ bigint, STARTTASK_ bigint, primary key (ID_));

create table JBPM_MODULEINSTANCE (ID_ bigint generated by default as identity, CLASS_ char(255) not null, VERSION_ integer not null, PROCESSINSTANCE_ bigint, TASKMGMTDEFINITION_ bigint, NAME_ varchar(255), primary key (ID_));

create table JBPM_NODE (ID_ bigint generated by default as identity, CLASS_ char(255) not null, NAME_ varchar(255), DESCRIPTION_ clob, PROCESSDEFINITION_ bigint, ISASYNC_ bit, ISASYNCEXCL_ bit, ACTION_ bigint, SUPERSTATE_ bigint, SUBPROCNAME_ varchar(255), SUBPROCESSDEFINITION_ bigint, DECISIONEXPRESSION_ varchar(255), DECISIONDELEGATION bigint, SCRIPT_ bigint, SIGNAL_ integer, CREATETASKS_ bit, ENDTASKS_ bit, NODECOLLECTIONINDEX_ integer, primary key (ID_));

create table JBPM_POOLEDACTOR (ID_ bigint generated by default as identity, VERSION_ integer not null, ACTORID_ varchar(255), SWIMLANEINSTANCE_ bigint, primary key (ID_));

create table JBPM_PROCESSDEFINITION (ID_ bigint generated by default as identity, CLASS_ char(255) not null, NAME_ varchar(255), DESCRIPTION_ clob, VERSION_ integer, ISTERMINATIONIMPLICIT_ bit, STARTSTATE_ bigint, primary key (ID_));

create table JBPM_PROCESSINSTANCE (ID_ bigint generated by default as identity, VERSION_ integer not null, KEY_ varchar(255), START_ timestamp, END_ timestamp, ISSUSPENDED_ bit, PROCESSDEFINITION_ bigint, ROOTTOKEN_ bigint, SUPERPROCESSTOKEN_ bigint, primary key (ID_));

create table JBPM_RUNTIMEACTION (ID_ bigint generated by default as identity, VERSION_ integer not null, EVENTTYPE_ varchar(255), TYPE_ char(255), GRAPHELEMENT_ bigint, PROCESSINSTANCE_ bigint, ACTION_ bigint, PROCESSINSTANCEINDEX_ integer, primary key (ID_));

create table JBPM_SWIMLANE (ID_ bigint generated by default as identity, NAME_ varchar(255), ACTORIDEXPRESSION_ varchar(255), POOLEDACTORSEXPRESSION_ varchar(255), ASSIGNMENTDELEGATION_ bigint, TASKMGMTDEFINITION_ bigint, primary key (ID_));

create table JBPM_SWIMLANEINSTANCE (ID_ bigint generated by default as identity, VERSION_ integer not null, NAME_ varchar(255), ACTORID_ varchar(255), SWIMLANE_ bigint, TASKMGMTINSTANCE_ bigint, primary key (ID_));

create table JBPM_TASK (ID_ bigint generated by default as identity, NAME_ varchar(255), DESCRIPTION_ clob, PROCESSDEFINITION_ bigint, ISBLOCKING_ bit, ISSIGNALLING_ bit, CONDITION_ varchar(255), DUEDATE_ varchar(255), PRIORITY_ integer, ACTORIDEXPRESSION_ varchar(255), POOLEDACTORSEXPRESSION_ varchar(255), TASKMGMTDEFINITION_ bigint, TASKNODE_ bigint, STARTSTATE_ bigint, ASSIGNMENTDELEGATION_ bigint, SWIMLANE_ bigint, TASKCONTROLLER_ bigint, primary key (ID_));

create table JBPM_TASKACTORPOOL (TASKINSTANCE_ bigint not null, POOLEDACTOR_ bigint not null, primary key (TASKINSTANCE_, POOLEDACTOR_));

create table JBPM_TASKCONTROLLER (ID_ bigint generated by default as identity, TASKCONTROLLERDELEGATION_ bigint, primary key (ID_));

create table JBPM_TASKINSTANCE (ID_ bigint generated by default as identity, CLASS_ char(255) not null, VERSION_ integer not null, NAME_ varchar(255), DESCRIPTION_ clob, ACTORID_ varchar(255), CREATE_ timestamp, START_ timestamp, END_ timestamp, DUEDATE_ timestamp, PRIORITY_ integer, ISCANCELLED_ bit, ISSUSPENDED_ bit, ISOPEN_ bit, ISSIGNALLING_ bit, ISBLOCKING_ bit, TASK_ bigint, TOKEN_ bigint, PROCINST_ bigint, SWIMLANINSTANCE_ bigint, TASKMGMTINSTANCE_ bigint, JBPM_ENGINE_NAME varchar(50), primary key (ID_));

create table JBPM_TOKEN (ID_ bigint generated by default as identity, VERSION_ integer not null, NAME_ varchar(255), START_ timestamp, END_ timestamp, NODEENTER_ timestamp, NEXTLOGINDEX_ integer, ISABLETOREACTIVATEPARENT_ bit, ISTERMINATIONIMPLICIT_ bit, ISSUSPENDED_ bit, LOCK_ varchar(255), NODE_ bigint, PROCESSINSTANCE_ bigint, PARENT_ bigint, SUBPROCESSINSTANCE_ bigint, primary key (ID_));

create table JBPM_TOKENVARIABLEMAP (ID_ bigint generated by default as identity, VERSION_ integer not null, TOKEN_ bigint, CONTEXTINSTANCE_ bigint, primary key (ID_));

create table JBPM_TRANSITION (ID_ bigint generated by default as identity, NAME_ varchar(255), DESCRIPTION_ clob, PROCESSDEFINITION_ bigint, FROM_ bigint, TO_ bigint, CONDITION_ varchar(255), FROMINDEX_ integer, primary key (ID_));

create table JBPM_VARIABLEACCESS (ID_ bigint generated by default as identity, VARIABLENAME_ varchar(255), ACCESS_ varchar(255), MAPPEDNAME_ varchar(255), PROCESSSTATE_ bigint, TASKCONTROLLER_ bigint, INDEX_ integer, SCRIPT_ bigint, primary key (ID_));

create table JBPM_VARIABLEINSTANCE (ID_ bigint generated by default as identity, CLASS_ char(255) not null, VERSION_ integer not null, NAME_ varchar(255), CONVERTER_ char(255), TOKEN_ bigint, TOKENVARIABLEMAP_ bigint, PROCESSINSTANCE_ bigint, BYTEARRAYVALUE_ bigint, DATEVALUE_ timestamp, DOUBLEVALUE_ double, LONGIDCLASS_ varchar(255), LONGVALUE_ bigint, STRINGIDCLASS_ varchar(255), STRINGVALUE_ varchar(255), TASKINSTANCE_ bigint, primary key (ID_));

alter table JBPM_ACTION add constraint FK_ACTION_EVENT foreign key (EVENT_) references JBPM_EVENT;

alter table JBPM_ACTION add constraint FK_CRTETIMERACT_TA foreign key (TIMERACTION_) references JBPM_ACTION;

alter table JBPM_ACTION add constraint FK_ACTION_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION;

alter table JBPM_ACTION add constraint FK_ACTION_EXPTHDL foreign key (EXCEPTIONHANDLER_) references JBPM_EXCEPTIONHANDLER;

alter table JBPM_ACTION add constraint FK_ACTION_REFACT foreign key (REFERENCEDACTION_) references JBPM_ACTION;

alter table JBPM_ACTION add constraint FK_ACTION_ACTNDEL foreign key (ACTIONDELEGATION_) references JBPM_DELEGATION;

alter table JBPM_BYTEARRAY add constraint FK_BYTEARR_FILDEF foreign key (FILEDEFINITION_) references JBPM_MODULEDEFINITION;

alter table JBPM_BYTEBLOCK add constraint FK_BYTEBLOCK_FILE foreign key (PROCESSFILE_) references JBPM_BYTEARRAY;

alter table JBPM_COMMENT add constraint FK_COMMENT_TOKEN foreign key (TOKEN_) references JBPM_TOKEN;

alter table JBPM_COMMENT add constraint FK_COMMENT_TSK foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE;

alter table JBPM_DECISIONCONDITIONS add constraint FK_DECCOND_DEC foreign key (DECISION_) references JBPM_NODE;

alter table JBPM_DELEGATION add constraint FK_DELEGATION_PRCD foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION;

alter table JBPM_EVENT add constraint FK_EVENT_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION;

alter table JBPM_EVENT add constraint FK_EVENT_TRANS foreign key (TRANSITION_) references JBPM_TRANSITION;

alter table JBPM_EVENT add constraint FK_EVENT_TASK foreign key (TASK_) references JBPM_TASK;

alter table JBPM_EVENT add constraint FK_EVENT_NODE foreign key (NODE_) references JBPM_NODE;

alter table JBPM_JOB add constraint FK_JOB_PRINST foreign key (PROCESSINSTANCE_) references JBPM_PROCESSINSTANCE;

alter table JBPM_JOB add constraint FK_JOB_TOKEN foreign key (TOKEN_) references JBPM_TOKEN;

alter table JBPM_JOB add constraint FK_JOB_ACTION foreign key (ACTION_) references JBPM_ACTION;

alter table JBPM_JOB add constraint FK_JOB_TSKINST foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE;

alter table JBPM_JOB add constraint FK_JOB_NODE foreign key (NODE_) references JBPM_NODE;

alter table JBPM_LOG add constraint FK_LOG_PARENT foreign key (PARENT_) references JBPM_LOG;

alter table JBPM_LOG add constraint FK_LOG_DESTNODE foreign key (DESTINATIONNODE_) references JBPM_NODE;

alter table JBPM_LOG add constraint FK_LOG_TOKEN foreign key (TOKEN_) references JBPM_TOKEN;

alter table JBPM_LOG add constraint FK_LOG_SOURCENODE foreign key (SOURCENODE_) references JBPM_NODE;

alter table JBPM_LOG add constraint FK_LOG_ACTION foreign key (ACTION_) references JBPM_ACTION;

alter table JBPM_LOG add constraint FK_LOG_NEWBYTES foreign key (NEWBYTEARRAY_) references JBPM_BYTEARRAY;

alter table JBPM_LOG add constraint FK_LOG_SWIMINST foreign key (SWIMLANEINSTANCE_) references JBPM_SWIMLANEINSTANCE;

alter table JBPM_LOG add constraint FK_LOG_TRANSITION foreign key (TRANSITION_) references JBPM_TRANSITION;

alter table JBPM_LOG add constraint FK_LOG_VARINST foreign key (VARIABLEINSTANCE_) references JBPM_VARIABLEINSTANCE;

alter table JBPM_LOG add constraint FK_LOG_CHILDTOKEN foreign key (CHILD_) references JBPM_TOKEN;

alter table JBPM_LOG add constraint FK_LOG_OLDBYTES foreign key (OLDBYTEARRAY_) references JBPM_BYTEARRAY;

alter table JBPM_LOG add constraint FK_LOG_TASKINST foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE;

alter table JBPM_LOG add constraint FK_LOG_NODE foreign key (NODE_) references JBPM_NODE;

alter table JBPM_MODULEDEFINITION add constraint FK_TSKDEF_START foreign key (STARTTASK_) references JBPM_TASK;

alter table JBPM_MODULEDEFINITION add constraint FK_MODDEF_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION;

alter table JBPM_MODULEINSTANCE add constraint FK_MODINST_PRCINST foreign key (PROCESSINSTANCE_) references JBPM_PROCESSINSTANCE;

alter table JBPM_MODULEINSTANCE add constraint FK_TASKMGTINST_TMD foreign key (TASKMGMTDEFINITION_) references JBPM_MODULEDEFINITION;

alter table JBPM_NODE add constraint FK_NODE_SCRIPT foreign key (SCRIPT_) references JBPM_ACTION;

alter table JBPM_NODE add constraint FK_NODE_SUPERSTATE foreign key (SUPERSTATE_) references JBPM_NODE;

alter table JBPM_NODE add constraint FK_PROCST_SBPRCDEF foreign key (SUBPROCESSDEFINITION_) references JBPM_PROCESSDEFINITION;

alter table JBPM_NODE add constraint FK_DECISION_DELEG foreign key (DECISIONDELEGATION) references JBPM_DELEGATION;

alter table JBPM_NODE add constraint FK_NODE_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION;

alter table JBPM_NODE add constraint FK_NODE_ACTION foreign key (ACTION_) references JBPM_ACTION;

alter table JBPM_POOLEDACTOR add constraint FK_POOLEDACTOR_SLI foreign key (SWIMLANEINSTANCE_) references JBPM_SWIMLANEINSTANCE;

alter table JBPM_PROCESSDEFINITION add constraint FK_PROCDEF_STRTSTA foreign key (STARTSTATE_) references JBPM_NODE;

alter table JBPM_PROCESSINSTANCE add constraint FK_PROCIN_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION;

alter table JBPM_PROCESSINSTANCE add constraint FK_PROCIN_SPROCTKN foreign key (SUPERPROCESSTOKEN_) references JBPM_TOKEN;

alter table JBPM_PROCESSINSTANCE add constraint FK_PROCIN_ROOTTKN foreign key (ROOTTOKEN_) references JBPM_TOKEN;

alter table JBPM_RUNTIMEACTION add constraint FK_RTACTN_PROCINST foreign key (PROCESSINSTANCE_) references JBPM_PROCESSINSTANCE;

alter table JBPM_RUNTIMEACTION add constraint FK_RTACTN_ACTION foreign key (ACTION_) references JBPM_ACTION;

alter table JBPM_SWIMLANE add constraint FK_SWL_TSKMGMTDEF foreign key (TASKMGMTDEFINITION_) references JBPM_MODULEDEFINITION;

alter table JBPM_SWIMLANE add constraint FK_SWL_ASSDEL foreign key (ASSIGNMENTDELEGATION_) references JBPM_DELEGATION;

alter table JBPM_SWIMLANEINSTANCE add constraint FK_SWIMLANEINST_SL foreign key (SWIMLANE_) references JBPM_SWIMLANE;

alter table JBPM_SWIMLANEINSTANCE add constraint FK_SWIMLANEINST_TM foreign key (TASKMGMTINSTANCE_) references JBPM_MODULEINSTANCE;

alter table JBPM_TASK add constraint FK_TASK_TASKNODE foreign key (TASKNODE_) references JBPM_NODE;

alter table JBPM_TASK add constraint FK_TSK_TSKCTRL foreign key (TASKCONTROLLER_) references JBPM_TASKCONTROLLER;

alter table JBPM_TASK add constraint FK_TASK_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION;

alter table JBPM_TASK add constraint FK_TASK_STARTST foreign key (STARTSTATE_) references JBPM_NODE;

alter table JBPM_TASK add constraint FK_TASK_TASKMGTDEF foreign key (TASKMGMTDEFINITION_) references JBPM_MODULEDEFINITION;

alter table JBPM_TASK add constraint FK_TASK_SWIMLANE foreign key (SWIMLANE_) references JBPM_SWIMLANE;

alter table JBPM_TASK add constraint FK_TASK_ASSDEL foreign key (ASSIGNMENTDELEGATION_) references JBPM_DELEGATION;

alter table JBPM_TASKACTORPOOL add constraint FK_TSKACTPOL_PLACT foreign key (POOLEDACTOR_) references JBPM_POOLEDACTOR;

alter table JBPM_TASKACTORPOOL add constraint FK_TASKACTPL_TSKI foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE;

alter table JBPM_TASKCONTROLLER add constraint FK_TSKCTRL_DELEG foreign key (TASKCONTROLLERDELEGATION_) references JBPM_DELEGATION;

alter table JBPM_TASKINSTANCE add constraint FK_TASKINST_SLINST foreign key (SWIMLANINSTANCE_) references JBPM_SWIMLANEINSTANCE;

alter table JBPM_TASKINSTANCE add constraint FK_TASKINST_TOKEN foreign key (TOKEN_) references JBPM_TOKEN;

alter table JBPM_TASKINSTANCE add constraint FK_TSKINS_PRCINS foreign key (PROCINST_) references JBPM_PROCESSINSTANCE;

alter table JBPM_TASKINSTANCE add constraint FK_TASKINST_TASK foreign key (TASK_) references JBPM_TASK;

alter table JBPM_TASKINSTANCE add constraint FK_TASKINST_TMINST foreign key (TASKMGMTINSTANCE_) references JBPM_MODULEINSTANCE;

alter table JBPM_TOKEN add constraint FK_TOKEN_PROCINST foreign key (PROCESSINSTANCE_) references JBPM_PROCESSINSTANCE;

alter table JBPM_TOKEN add constraint FK_TOKEN_PARENT foreign key (PARENT_) references JBPM_TOKEN;

alter table JBPM_TOKEN add constraint FK_TOKEN_SUBPI foreign key (SUBPROCESSINSTANCE_) references JBPM_PROCESSINSTANCE;

alter table JBPM_TOKEN add constraint FK_TOKEN_NODE foreign key (NODE_) references JBPM_NODE;

alter table JBPM_TOKENVARIABLEMAP add constraint FK_TKVARMAP_TOKEN foreign key (TOKEN_) references JBPM_TOKEN;

alter table JBPM_TOKENVARIABLEMAP add constraint FK_TKVARMAP_CTXT foreign key (CONTEXTINSTANCE_) references JBPM_MODULEINSTANCE;

alter table JBPM_TRANSITION add constraint FK_TRANS_PROCDEF foreign key (PROCESSDEFINITION_) references JBPM_PROCESSDEFINITION;

alter table JBPM_TRANSITION add constraint FK_TRANSITION_TO foreign key (TO_) references JBPM_NODE;

alter table JBPM_TRANSITION add constraint FK_TRANSITION_FROM foreign key (FROM_) references JBPM_NODE;

alter table JBPM_VARIABLEACCESS add constraint FK_VARACC_SCRIPT foreign key (SCRIPT_) references JBPM_ACTION;

alter table JBPM_VARIABLEACCESS add constraint FK_VARACC_TSKCTRL foreign key (TASKCONTROLLER_) references JBPM_TASKCONTROLLER;

alter table JBPM_VARIABLEACCESS add constraint FK_VARACC_PROCST foreign key (PROCESSSTATE_) references JBPM_NODE;

alter table JBPM_VARIABLEINSTANCE add constraint FK_VARINST_PRCINST foreign key (PROCESSINSTANCE_) references JBPM_PROCESSINSTANCE;

alter table JBPM_VARIABLEINSTANCE add constraint FK_VARINST_TKVARMP foreign key (TOKENVARIABLEMAP_) references JBPM_TOKENVARIABLEMAP;

alter table JBPM_VARIABLEINSTANCE add constraint FK_VARINST_TK foreign key (TOKEN_) references JBPM_TOKEN;

alter table JBPM_VARIABLEINSTANCE add constraint FK_BYTEINST_ARRAY foreign key (BYTEARRAYVALUE_) references JBPM_BYTEARRAY;

alter table JBPM_VARIABLEINSTANCE add constraint FK_VAR_TSKINST foreign key (TASKINSTANCE_) references JBPM_TASKINSTANCE;

CREATE INDEX FK_ACTION_REFACT ON JBPM_ACTION (REFERENCEDACTION_);

CREATE INDEX FK_CRTETIMERACT_TA ON JBPM_ACTION (TIMERACTION_);

CREATE INDEX FK_ACTION_PROCDEF ON JBPM_ACTION (PROCESSDEFINITION_);

CREATE INDEX FK_ACTION_EVENT ON JBPM_ACTION (EVENT_);

CREATE INDEX FK_ACTION_ACTNDEL ON JBPM_ACTION (ACTIONDELEGATION_);

CREATE INDEX FK_ACTION_EXPTHDL ON  JBPM_ACTION(EXCEPTIONHANDLER_);

CREATE INDEX FK_BYTEARR_FILDEF ON JBPM_BYTEARRAY (FILEDEFINITION_);

CREATE INDEX FK_BYTEBLOCK_FILE ON JBPM_BYTEBLOCK (PROCESSFILE_);

CREATE INDEX FK_COMMENT_TOKEN ON JBPM_COMMENT (TOKEN_);

CREATE INDEX FK_COMMENT_TSK ON JBPM_COMMENT (TASKINSTANCE_);

CREATE INDEX FK_DECCOND_DEC ON JBPM_DECISIONCONDITIONS (DECISION_);

CREATE INDEX FK_DELEGATION_PRCD ON JBPM_DELEGATION (PROCESSDEFINITION_);

CREATE INDEX FK_EVENT_PROCDEF ON JBPM_EVENT (PROCESSDEFINITION_);

CREATE INDEX FK_EVENT_TRANS ON JBPM_EVENT (TRANSITION_);

CREATE INDEX FK_EVENT_NODE ON JBPM_EVENT (NODE_);

CREATE INDEX FK_EVENT_TASK ON JBPM_EVENT (TASK_);

CREATE INDEX FK_JOB_PRINST ON JBPM_JOB (PROCESSINSTANCE_);

CREATE INDEX FK_JOB_ACTION ON JBPM_JOB (ACTION_);

CREATE INDEX FK_JOB_TOKEN ON JBPM_JOB (TOKEN_);

CREATE INDEX FK_JOB_NODE ON JBPM_JOB (NODE_);

CREATE INDEX FK_JOB_TSKINST ON JBPM_JOB (TASKINSTANCE_);

CREATE INDEX FK_LOG_SOURCENODE ON JBPM_LOG (SOURCENODE_);

CREATE INDEX FK_LOG_DESTNODE ON JBPM_LOG (DESTINATIONNODE_);

CREATE INDEX FK_LOG_TOKEN ON JBPM_LOG (TOKEN_);

CREATE INDEX FK_LOG_TRANSITION ON JBPM_LOG (TRANSITION_);

CREATE INDEX FK_LOG_TASKINST ON JBPM_LOG (TASKINSTANCE_);

CREATE INDEX FK_LOG_CHILDTOKEN ON JBPM_LOG (CHILD_);

CREATE INDEX FK_LOG_OLDBYTES ON JBPM_LOG (OLDBYTEARRAY_);

CREATE INDEX FK_LOG_SWIMINST ON JBPM_LOG (SWIMLANEINSTANCE_);

CREATE INDEX FK_LOG_NEWBYTES ON JBPM_LOG (NEWBYTEARRAY_);

CREATE INDEX FK_LOG_ACTION ON JBPM_LOG (ACTION_);

CREATE INDEX FK_LOG_VARINST ON JBPM_LOG (VARIABLEINSTANCE_);

CREATE INDEX FK_LOG_NODE ON JBPM_LOG (NODE_);

CREATE INDEX FK_LOG_PARENT ON JBPM_LOG (PARENT_);

CREATE INDEX FK_MODDEF_PROCDEF ON JBPM_MODULEDEFINITION (PROCESSDEFINITION_);

CREATE INDEX FK_TSKDEF_START ON JBPM_MODULEDEFINITION (STARTTASK_);

CREATE INDEX FK_MODINST_PRCINST ON JBPM_MODULEINSTANCE (PROCESSINSTANCE_);

CREATE INDEX FK_TASKMGTINST_TMD ON JBPM_MODULEINSTANCE (TASKMGMTDEFINITION_);

CREATE INDEX FK_DECISION_DELEG ON JBPM_NODE (DECISIONDELEGATION);

CREATE INDEX FK_NODE_PROCDEF ON JBPM_NODE (PROCESSDEFINITION_);

CREATE INDEX FK_NODE_ACTION ON JBPM_NODE (ACTION_);

CREATE INDEX FK_PROCST_SBPRCDEF ON JBPM_NODE (SUBPROCESSDEFINITION_);

CREATE INDEX FK_NODE_SCRIPT ON JBPM_NODE (SCRIPT_);

CREATE INDEX FK_NODE_SUPERSTATE ON JBPM_NODE (SUPERSTATE_);

CREATE INDEX FK_POOLEDACTOR_SLI ON JBPM_POOLEDACTOR (SWIMLANEINSTANCE_);

CREATE INDEX FK_PROCDEF_STRTSTA ON JBPM_PROCESSDEFINITION (STARTSTATE_);

CREATE INDEX FK_PROCIN_PROCDEF ON JBPM_PROCESSINSTANCE (PROCESSDEFINITION_);

CREATE INDEX FK_PROCIN_ROOTTKN ON JBPM_PROCESSINSTANCE (ROOTTOKEN_);

CREATE INDEX FK_PROCIN_SPROCTKN ON JBPM_PROCESSINSTANCE (SUPERPROCESSTOKEN_);

CREATE INDEX FK_RTACTN_PROCINST ON JBPM_RUNTIMEACTION (PROCESSINSTANCE_);

CREATE INDEX FK_RTACTN_ACTION ON JBPM_RUNTIMEACTION (ACTION_);

CREATE INDEX FK_SWL_ASSDEL ON JBPM_SWIMLANE (ASSIGNMENTDELEGATION_);

CREATE INDEX FK_SWL_TSKMGMTDEF ON JBPM_SWIMLANE (TASKMGMTDEFINITION_);

CREATE INDEX FK_SWIMLANEINST_TM ON JBPM_SWIMLANEINSTANCE (TASKMGMTINSTANCE_);

CREATE INDEX FK_SWIMLANEINST_SL ON JBPM_SWIMLANEINSTANCE (SWIMLANE_);

CREATE INDEX FK_TASK_STARTST ON JBPM_TASK (STARTSTATE_);

CREATE INDEX FK_TASK_PROCDEF ON JBPM_TASK (PROCESSDEFINITION_);

CREATE INDEX FK_TASK_ASSDEL ON JBPM_TASK (ASSIGNMENTDELEGATION_);

CREATE INDEX FK_TASK_SWIMLANE ON JBPM_TASK (SWIMLANE_);

CREATE INDEX FK_TASK_TASKNODE ON JBPM_TASK (TASKNODE_);

CREATE INDEX FK_TASK_TASKMGTDEF ON JBPM_TASK (TASKMGMTDEFINITION_);

CREATE INDEX FK_TSK_TSKCTRL ON JBPM_TASK (TASKCONTROLLER_);

CREATE INDEX FK_TASKACTPL_TSKI ON JBPM_TASKACTORPOOL (TASKINSTANCE_);

CREATE INDEX FK_TSKACTPOL_PLACT ON JBPM_TASKACTORPOOL (POOLEDACTOR_);

CREATE INDEX FK_TSKCTRL_DELEG ON JBPM_TASKCONTROLLER (TASKCONTROLLERDELEGATION_);

CREATE INDEX FK_TSKINS_PRCINS ON JBPM_TASKINSTANCE (PROCINST_);

CREATE INDEX FK_TASKINST_TMINST ON JBPM_TASKINSTANCE (TASKMGMTINSTANCE_);

CREATE INDEX FK_TASKINST_TOKEN ON JBPM_TASKINSTANCE (TOKEN_);

CREATE INDEX FK_TASKINST_SLINST ON JBPM_TASKINSTANCE (SWIMLANINSTANCE_);

CREATE INDEX FK_TASKINST_TASK ON JBPM_TASKINSTANCE (TASK_);

CREATE INDEX FK_TOKEN_SUBPI ON JBPM_TOKEN (SUBPROCESSINSTANCE_);

CREATE INDEX FK_TOKEN_PROCINST ON JBPM_TOKEN (PROCESSINSTANCE_);

CREATE INDEX FK_TOKEN_NODE ON JBPM_TOKEN (NODE_);

CREATE INDEX FK_TOKEN_PARENT ON JBPM_TOKEN (PARENT_);

CREATE INDEX FK_TKVARMAP_TOKEN ON JBPM_TOKENVARIABLEMAP (TOKEN_);

CREATE INDEX FK_TKVARMAP_CTXT ON JBPM_TOKENVARIABLEMAP (CONTEXTINSTANCE_);

CREATE INDEX FK_TRANSITION_FROM ON JBPM_TRANSITION (FROM_);

CREATE INDEX FK_TRANS_PROCDEF ON JBPM_TRANSITION (PROCESSDEFINITION_);

CREATE INDEX FK_TRANSITION_TO ON JBPM_TRANSITION (TO_);

CREATE INDEX FK_VARACC_PROCST ON JBPM_VARIABLEACCESS (PROCESSSTATE_);

CREATE INDEX FK_VARACC_SCRIPT ON JBPM_VARIABLEACCESS (SCRIPT_);

CREATE INDEX FK_VARACC_TSKCTRL ON JBPM_VARIABLEACCESS (TASKCONTROLLER_);

CREATE INDEX FK_VARINST_PRCINST ON JBPM_VARIABLEINSTANCE (PROCESSINSTANCE_);

CREATE INDEX FK_VARINST_TKVARMP ON JBPM_VARIABLEINSTANCE (TOKENVARIABLEMAP_);

CREATE INDEX FK_VARINST_TK ON JBPM_VARIABLEINSTANCE (TOKEN_);

CREATE INDEX FK_BYTEINST_ARRAY ON JBPM_VARIABLEINSTANCE (BYTEARRAYVALUE_);

CREATE INDEX FK_VAR_TSKINST ON JBPM_VARIABLEINSTANCE (TASKINSTANCE_);

CREATE INDEX IDX_VARINST_STRVAL ON JBPM_VARIABLEINSTANCE (NAME_, CLASS_, STRINGVALUE_, TOKENVARIABLEMAP_);

DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.4-JBPM-varinst-indexes';

INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.4-JBPM-varinst-indexes', 'Manually executed script upgrade to add FK indexes for JBPM',
     0, 6016, -1, 6017, null, 'UNKOWN', 1, 1, 'Script completed'
   );

