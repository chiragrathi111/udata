Locator type an dProduct category table:-

CREATE TABLE adempiere.pi_Locator_Product (
    pi_Locator_Product_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    pi_Locator_Product_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() NOT NULL,
    createdby NUMERIC(10,0) NOT NULL,
    updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
    updatedby NUMERIC(10,0) NOT NULL,
    description VARCHAR(255),
    isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
    M_LocatorType_ID INTEGER,
    M_Product_Category_ID INTEGER,
    FOREIGN KEY (M_LocatorType_ID) REFERENCES adempiere.M_LocatorType(M_LocatorType_ID),
    FOREIGN KEY (M_Product_Category_ID) REFERENCES adempiere.M_Product_Category(M_Product_Category_ID)
);