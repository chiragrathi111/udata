Alter table adempiere.ad_role
  Add column users_app character(1) NOT NULL DEFAULT 'N'::bpchar,
  Add column unauthorised_events character(1) NOT NULL DEFAULT 'N'::bpchar,
  Add column receiving_processed_app character(1) NOT NULL DEFAULT 'N'::bpchar;

  Alter table adempiere.ad_role
  Add column item_inout character(1) NOT NULL DEFAULT 'N'::bpchar;

  =========================================================================================
  CREATE TABLE adempiere.pi_item_inout (
    pi_item_inout_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    pi_item_inout_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    id NUMERIC(10,0) NOT NULL,
    in_qty NUMERIC(10,0),
    out_qty NUMERIC(10,0),
    created TIMESTAMP without time zone DEFAULT now() NOT NULL,
    createdby NUMERIC(10,0) NOT NULL,
    updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
    updatedby NUMERIC(10,0) NOT NULL,
    description VARCHAR(255),
    isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
    CONSTRAINT pi_item_inout_id_uk UNIQUE (id) -- enforce uniqueness
);

Alter table adempiere.pi_items_inout
Add column processed character(1) NOT NULL DEFAULT 'N'::bpchar;
========================================================================================================
<<<<<<< HEAD
>>>>>>> 56bcaeb8b096ec9f140e9651aa02e35cdde49697
