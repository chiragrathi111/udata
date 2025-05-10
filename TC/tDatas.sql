    Order Table:-
    CREATE TABLE adempiere.tc_order (
        tc_order_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25) NOT NULL,
        created TIMESTAMP without time zone DEFAULT now() NOT NULL,
        createdby NUMERIC(10,0) NOT NULL,
        updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
        updatedby NUMERIC(10,0) NOT NULL,
        description VARCHAR(255),
        documentNo VARCHAR(25) NOT NULL,
        isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
        dateOrdered DATE,
        docstatus character(2) NOT NULL,
        docaction character(2) NOT NULL,
        processing character(1),
   processed character(1) NOT NULL DEFAULT 'N'::bpchar,
   c_doctype_id numeric(10,0) NOT NULL,
   c_doctypetarget_id numeric(10,0) NOT NULL,
   isapproved character(1) NOT NULL DEFAULT 'Y'::bpchar,
        salesrep_id NUMERIC(10,0),
        m_warehouse_id NUMERIC(10,0),
        tc_order_uu VARCHAR(36) DEFAULT NULL::bpchar,
        FOREIGN KEY (m_warehouse_id) REFERENCES
        adempiere.m_warehouse(m_warehouse_id));
        
        
        
        CREATE TABLE adempiere.tc_in (
        tc_in_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        created TIMESTAMP without time zone DEFAULT now() NOT NULL,
        createdby NUMERIC(10,0) NOT NULL,
        updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
        updatedby NUMERIC(10,0) NOT NULL,
        description VARCHAR(255),
        isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
        quantity NUMERIC(10,0),
        tc_order_id NUMERIC(10,0),
        m_locator_id NUMERIC(10,0),
        m_product_id NUMERIC(10,0),
        c_uom_id NUMERIC(10,0),
        tc_in_uu VARCHAR(36) DEFAULT NULL::bpchar,
        FOREIGN KEY (c_uom_id) REFERENCES adempiere.c_uom(c_uom_id),
        FOREIGN KEY (tc_order_id) REFERENCES adempiere.tc_order(tc_order_id),
        FOREIGN KEY (m_locator_id) REFERENCES adempiere.m_locator(m_locator_id),
        FOREIGN KEY (m_product_id) REFERENCES adempiere.m_product(m_product_id));
        
        
        CREATE TABLE adempiere.tc_out (
        tc_out_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        created TIMESTAMP without time zone DEFAULT now() NOT NULL,
        createdby NUMERIC(10,0) NOT NULL,
        updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
        updatedby NUMERIC(10,0) NOT NULL,
        description VARCHAR(255),
        isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
        quantity NUMERIC(10,0),
        cycle NUMERIC(10,0),
        tc_order_id NUMERIC(10,0),
        m_locator_id NUMERIC(10,0),
        m_product_id NUMERIC(10,0),
        c_uom_id NUMERIC(10,0),
        tc_in_id NUMERIC(10,0),
        tc_out_uu VARCHAR(36) DEFAULT NULL::bpchar,
        FOREIGN KEY (tc_in_id) REFERENCES adempiere.tc_in(tc_in_id),
        FOREIGN KEY (c_uom_id) REFERENCES adempiere.c_uom(c_uom_id),
        FOREIGN KEY (tc_order_id) REFERENCES adempiere.tc_order(tc_order_id),
        FOREIGN KEY (m_locator_id) REFERENCES adempiere.m_locator(m_locator_id),
        FOREIGN KEY (m_product_id) REFERENCES adempiere.m_product(m_product_id));
        
        
  Alter table adempiere.tc_order
  Add column docstatus character(2) NOT NULL,
  Add column docaction character(2) NOT NULL,
  Add column processing character(1),
  Add column processed character(1) NOT NULL DEFAULT 'N'::bpchar,
  Add column c_doctype_id numeric(10,0) NOT NULL,
  Add column c_doctypetarget_id numeric(10,0) NOT NULL,
  Add column isapproved character(1) NOT NULL DEFAULT 'Y'::bpchar;


    farmer table:-
    CREATE TABLE adempiere.tc_farmer (
    tc_farmer_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_farmer_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),value varchar(25),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,  
    villageName VARCHAR(25),
    talukName VARCHAR(20),
    District VARCHAR(10),
    City VARCHAR(20),
    State VARCHAR(20),
    pinCode VARCHAR(6),
    Latitude VARCHAR(20),
    Longitude VARCHAR(20),
    mobileNo VARCHAR(10))
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar;

ALTER TABLE adempiere.tc_farmer ADD COLUMN talukName VARCHAR(25);
ALTER TABLE adempiere.tc_farmer ADD COLUMN District VARCHAR(25);
ALTER TABLE adempiere.tc_farmer ADD COLUMN City VARCHAR(25);
ALTER TABLE adempiere.tc_farmer ADD COLUMN State VARCHAR(25);
ALTER TABLE adempiere.tc_farmer ADD COLUMN pinCode VARCHAR(6);
ALTER TABLE adempiere.tc_farmer ADD COLUMN Latitude FLOAT;
ALTER TABLE adempiere.tc_farmer ADD COLUMN Longitude FLOAT;
ALTER TABLE adempiere.tc_farmer ALTER COLUMN mobileno TYPE VARCHAR(10);


First Visit:-
     
     Field Selection Table:-
     
    CREATE TABLE adempiere.tc_fieldselection (
    tc_fieldselection_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_fieldselection_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);
    
    Soil Type Table:-
 
    CREATE TABLE adempiere.tc_soiltype (
    tc_soiltype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_soiltype_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    Watering Type Table:-   
     
    CREATE TABLE adempiere.tc_wateringtype (
    tc_wateringtype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_wateringtype_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    Field Management Table:-
    
    CREATE TABLE adempiere.tc_fieldmanagement (
    tc_fieldmanagement_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_fieldmanagement_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    Visit Type Table:-
    
    CREATE TABLE adempiere.tc_visittype (
    tc_visittype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_visittype_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    visit detils table:-
    
    CREATE TABLE adempiere.tc_visit (
    tc_visit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_visit_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(30),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    mobileNo VARCHAR(10),
    date DATE,
    reason VARCHAR(30),
    tc_farmer_id NUMERIC(10,0),
    tc_visittype_id NUMERIC(10,0),
    tc_status_id NUMERIC(10,0),
    FOREIGN KEY (tc_status_id) REFERENCES adempiere.tc_status(tc_status_id),
    FOREIGN KEY (tc_visittype_id) REFERENCES adempiere.tc_visittype(tc_visittype_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES adempiere.tc_farmer(tc_farmer_id)); 
    
    ALTER TABLE adempiere.tc_visit ALTER COLUMN mobileno TYPE VARCHAR(10);

    ALTER TABLE adempiere.tc_visit ADD COLUMN visitdone CHAR(1) NOT NULL DEFAULT 'N'::bpchar;
    
    ALTER TABLE adempiere.tc_firstvisit ALTER COLUMN plantNo DROP NOT NULL;

    ALTER TABLE adempiere.tc_visit ADD COLUMN cycleNo numeric(10,0);

    First Visit Table:-
    
    CREATE TABLE adempiere.tc_firstvisit (
    tc_firstvisit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_firstvisit_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(30),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    plantNo NUMERIC(10, 0),
    visitDate DATE,
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    pestHistory VARCHAR(255),
    nextVisitDate DATE,
    tc_visit_id NUMERIC(10,0),
    tc_farmer_id NUMERIC(10,0),
    tc_fieldselection_id NUMERIC(10,0),
    tc_soiltype_id NUMERIC(10,0),
    tc_wateringtype_id NUMERIC(10,0),
    tc_fieldmanagement_id NUMERIC(10,0),
    FOREIGN KEY (tc_visit_id) REFERENCES adempiere.tc_visit(tc_visit_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES adempiere.tc_farmer(tc_farmer_id),
    FOREIGN KEY (tc_fieldselection_id) REFERENCES
     adempiere.tc_fieldselection(tc_fieldselection_id),
    FOREIGN KEY (tc_soiltype_id) REFERENCES adempiere.tc_soiltype(tc_soiltype_id),
    FOREIGN KEY (tc_wateringtype_id) REFERENCES
     adempiere.tc_wateringtype(tc_wateringtype_id),
    FOREIGN KEY (tc_fieldmanagement_id) REFERENCES
     adempiere.tc_fieldmanagement(tc_fieldmanagement_id)); 

 Plant Details Table:-
     
    Plant Variety Table:-
    
    CREATE TABLE adempiere.tc_variety (
    tc_variety_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_variety_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(30),value varchar(25),
    codeNo VARCHAR(10) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault character(1) NOT NULL DEFAULT 'N'::bpchar);
    
         
    Plant Species Table:-
    
    CREATE TABLE adempiere.tc_plantspecies (
    tc_plantspecies_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_plantspecies_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(30),value varchar(25),
    codeNo VARCHAR(10) NOT NULL,
    varityCodeNo VARCHAR(10) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    tc_variety_id NUMERIC(10,0),
    FOREIGN KEY (tc_variety_id) REFERENCES
     adempiere.tc_variety(tc_variety_id));
     
    Plant Details Table:-

    Alter table adempiere.tc_plantdetails Add column parentCultureLine VARCHAR(255);
    
    CREATE TABLE adempiere.tc_plantdetails (
    tc_plantdetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_plantdetails_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    codeNo VARCHAR(10),
    date DATE,
    parentCultureLine VARCHAR(255),
    tagNo VARCHAR(10),
    diseaseName VARCHAR(25),
    medicineDetails VARCHAR(255),
    description VARCHAR(255),
    height VARCHAR(10),
    stature VARCHAR(10),
    leavesNo NUMERIC(10,0),
    bunceWeight VARCHAR(10),
    weight VARCHAR(10),
    bunchesNo VARCHAR(10),
    reason VARCHAR(30),
    enterDetailsOfInfestation varchar(25),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    plantTagUUId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault character(1) NOT NULL DEFAULT 'N'::bpchar,
    isrejected CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    tc_species_id NUMERIC(10,0),
    tc_variety_id NUMERIC(10,0),
    tc_farmer_id NUMERIC(10,0),
    FOREIGN KEY (tc_species_id) REFERENCES adempiere.tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_variety_id) REFERENCES adempiere.tc_variety(tc_variety_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES adempiere.tc_farmer(tc_farmer_id)); 

    ALTER TABLE adempiere.tc_plantdetails Add column plantTagUUId VARCHAR(36);
     
     
 Intermediate Visit:-
 
    Decision Table:-                   
     
    CREATE TABLE adempiere.tc_decision (
    tc_decision_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_decision_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),value varchar(25),
    reason VARCHAR(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    
    Intermediate Visit Table:-
    
    CREATE TABLE adempiere.tc_intermediatevisit (
    tc_intermediatevisit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_intermediatevisit_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    reviewDetails VARCHAR(255),
    reasonDetails VARCHAR(255),
    nextVisitDate DATE,
    tc_visit_id NUMERIC(10,0),
    tc_farmer_id NUMERIC(10,0),
    tc_decision_id NUMERIC(10,0),
    tc_firstvisit_id NUMERIC(10,0),
    FOREIGN KEY (tc_visit_id) REFERENCES adempiere.tc_visit(tc_visit_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES adempiere.tc_farmer(tc_farmer_id),
    FOREIGN KEY (tc_firstvisit_id) REFERENCES adempiere.tc_firstvisit(tc_firstvisit_id),
    FOREIGN KEY (tc_decision_id) REFERENCES adempiere.tc_decision(tc_decision_id));
     
     Collection Details Table:-
     
     CREATE TABLE adempiere.tc_collectiondetails (
    tc_collectiondetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_collectiondetails_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    yieldWeight VARCHAR(255),
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    tc_visit_id NUMERIC(10,0),
    tc_farmer_id NUMERIC(10,0),
    tc_intermediatevisit_id NUMERIC(10,0),
    tc_firstvisit_id NUMERIC(10,0),
    FOREIGN KEY (tc_visit_id) REFERENCES adempiere.tc_visit(tc_visit_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES adempiere.tc_farmer(tc_farmer_id),
    FOREIGN KEY (tc_firstvisit_id) REFERENCES
     adempiere.tc_firstvisit(tc_firstvisit_id),
    FOREIGN KEY (tc_intermediatevisit_id) REFERENCES
     adempiere.tc_intermediatevisit(tc_intermediatevisit_id));


     //LabDate:-


     nature of sample table
    
    CREATE TABLE adempiere.tc_naturesample (
    tc_naturesample_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_naturesample_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),value varchar(25),
    codeNo VARCHAR(10),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);
        
   Culture mini tables
        
    CREATE TABLE adempiere.tc_culturestage (
    tc_culturestage_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_culturestage_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),value varchar(25),
    codeNo VARCHAR(10),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);
        
        CREATE TABLE adempiere.tc_virustesting (
        tc_virustesting_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_virustesting_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25),value varchar(25),
        codeNo VARCHAR(10),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 



    Explant table:-
    
     CREATE TABLE adempiere.tc_machinetype (
        tc_machinetype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_machinetype_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25) NOT NULL,value varchar(25),
        machineCode VARCHAR(25),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        ismediatype CHAR(1) not null DEFAULT 'N'::bpchar, 
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar, 
        c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);

     ALTER TABLE adempiere.tc_machinetype ADD COLUMN ismediatype CHAR(1) NOT NULL DEFAULT 'N'::bpchar;
        
        
        Media Type:-

        CREATE TABLE adempiere.tc_mediatype (
        tc_mediatype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_mediatype_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,name varchar(25) NOT NULL,value varchar(25),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);
        
        
    Growth Room Table:-
        
        mini table
        
        CREATE TABLE adempiere.tc_roomnumber (
        tc_roomnumber_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25) NOT NULL,value varchar(25),
        roomNo NUMERIC(10, 0) NOT NULL,
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);

        ALTER TABLE adempiere.tc_roomnumber
      ALTER COLUMN roomNo TYPE VARCHAR(10);
        
        mini table
        
        CREATE TABLE adempiere.tc_cycle (
        tc_cycle_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25) NOT NULL,value varchar(25),
        cycleNo VARCHAR(10),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);

        ALTER TABLE adempiere.tc_cultureLabel
        ADD COLUMN tc_discardtype_id NUMERIC(10,0);

        ALTER TABLE adempiere.tc_cultureLabel
        ADD CONSTRAINT tc_cultureLabel_tc_discardtype_id_fkey
        FOREIGN KEY (tc_discardtype_id)
        REFERENCES adempiere.tc_discardtype(tc_discardtype_id);

        ALTER TABLE adempiere.tc_qualitycheck
ADD COLUMN tc_discardtype_id NUMERIC(10,0);

ALTER TABLE adempiere.tc_qualitycheck
ADD CONSTRAINT tc_qualitycheck_tc_discardtype_id_fkey
FOREIGN KEY (tc_discardtype_id)
REFERENCES adempiere.tc_discardtype(tc_discardtype_id);

ALTER TABLE adempiere.tc_mediaorder
ADD COLUMN m_product_id NUMERIC(10,0);

ALTER TABLE adempiere.tc_mediaorder
ADD CONSTRAINT tc_mediaorder_m_product_id_fkey
FOREIGN KEY (m_product_id)
REFERENCES adempiere.m_product(m_product_id);

ALTER TABLE adempiere.tc_mediaorder ADD COLUMN quantity NUMERIC(10,0);

ALTER TABLE adempiere.tc_mediaorder
ADD COLUMN ad_user_id NUMERIC(10,0);

ALTER TABLE adempiere.tc_mediaorder
ADD CONSTRAINT tc_mediaorder_ad_user_id_fkey
FOREIGN KEY (ad_user_id)
REFERENCES adempiere.ad_user(ad_user_id);

        //QAData:-

        create a table for quality check and added discard reason
     
        CREATE TABLE adempiere.tc_qualitycheck (
        tc_qualitycheck_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_qualitycheck_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25),value varchar(25),
        discardReason VARCHAR(255),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
        tcpf VARCHAR(25),
        date DATE,
        personalCode VARCHAR(25)
        tc_discardtype_id NUMERIC(10,0),
        FOREIGN KEY (tc_discardtype_id) REFERENCES adempiere.tc_discardtype(tc_discardtype_id));

        ALTER TABLE adempiere.tc_cultureLabel ADD COLUMN discardReason VARCHAR(255);

        ALTER TABLE adempiere.tc_mediaLabelQr
        ADD COLUMN discardDate DATE,
        ADD COLUMN tcpf2 VARCHAR(25),
        ADD COLUMN personalCode2 VARCHAR(25);

        ALTER TABLE adempiere.tc_cultureLabel
        ADD COLUMN discardDate DATE,
        ADD COLUMN tcpf2 VARCHAR(25),
        ADD COLUMN personalCode2 VARCHAR(25);


        Every Table added name and value filed .

        ALTER TABLE adempiere.tc_cycle ADD COLUMN value VARCHAR(40);

         ALTER TABLE adempiere.tc_planttag ADD COLUMN printqr character varying(2);
         ALTER TABLE adempiere.tc_planttag ADD COLUMN save_button character varying(2);

        CREATE TABLE adempiere.tc_planttag (
    tc_planttag_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_planttag_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(30),value varchar(25),
    documentNo VARCHAR(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    save_button VARCHAR(10),
    printqr VARCHAR(10),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    tc_planttag_uu VARCHAR(36) NOT NULL);

        CREATE TABLE adempiere.tc_hardeningtraytag (
    tc_hardeningtraytag_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_hardeningtraytag_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(30),value varchar(25),
    documentNo VARCHAR(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    tc_hardeningtraytag_uu VARCHAR(36) NOT NULL);


###
        CREATE TABLE adempiere.tc_cultureLabel (
    tc_cultureLabel_id SERIAL PRIMARY KEY,
    tc_cultureLabel_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdiscarded CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    tosubculturecheck CHAR(1) not null DEFAULT 'N'::bpchar,
    parentCultureLine VARCHAR(255),
    cultureDate DATE,
    cycleNo NUMERIC(10,0),
    discardDate DATE,
    tcpf2 VARCHAR(25),
    personalCode2 VARCHAR(25),
    tc_species_id NUMERIC(10,0),
    tc_species_ids NUMERIC(10,0),
    tc_naturesample_id NUMERIC(10,0),
    tc_culturestage_id NUMERIC(10,0),
    tc_virustesting_id NUMERIC(10,0),
    tc_mediatype_id NUMERIC(10,0),
    tcpf VARCHAR(25),
    cultureOperationDate DATE,
    personal_code VARCHAR(25),
    discardDate DATE,
    tcpf2 VARCHAR(25),
    personalCode2 VARCHAR(25),
    tc_machinetype_id NUMERIC(10,0),
    tc_discardtype_id NUMERIC(10,0),
    tc_in_id NUMERIC(10,0),
    tc_out_id NUMERIC(10,0),
    FOREIGN KEY (tc_in_id) REFERENCES adempiere.tc_in(tc_in_id)
    FOREIGN KEY (tc_out_id) REFERENCES adempiere.tc_out(tc_out_id),
    FOREIGN KEY (tc_discardtype_id) REFERENCES adempiere.tc_discardtype(tc_discardtype_id)
    FOREIGN KEY (tc_machinetype_id) REFERENCES adempiere.tc_machinetype(tc_machinetype_id),
    FOREIGN KEY (tc_mediatype_id) REFERENCES adempiere.tc_mediatype(tc_mediatype_id),
    FOREIGN KEY (tc_species_id) REFERENCES adempiere.tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_species_ids) REFERENCES adempiere.tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_naturesample_id) REFERENCES
     adempiere.tc_naturesample(tc_naturesample_id),
    FOREIGN KEY (tc_culturestage_id) REFERENCES
     adempiere.tc_culturestage(tc_culturestage_id),
    FOREIGN KEY (tc_virustesting_id) REFERENCES
     adempiere.tc_virustesting(tc_virustesting_id)
    );

        Alter table adempiere.tc_culturelabel add column tosubculturecheck CHAR(1) not null DEFAULT 'N'::bpchar;


        ## Explant LAbel:-

        CREATE TABLE adempiere.tc_explantLabel (
    tc_explantLabel_id SERIAL PRIMARY KEY,
    tc_explantLabel_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    parentCultureLine VARCHAR(255),
    sourcingDate DATE,
    tc_species_id NUMERIC(10,0),
    tc_species_ids NUMERIC(10,0),
    tc_naturesample_id NUMERIC(10,0),
    tcpf VARCHAR(25),
    operationDate DATE,
    personalCode VARCHAR(25),
    tc_in_id NUMERIC(10,0),
    tc_out_id NUMERIC(10,0),
    FOREIGN KEY (tc_in_id) REFERENCES adempiere.tc_in(tc_in_id)
    FOREIGN KEY (tc_out_id) REFERENCES adempiere.tc_out(tc_out_id),
    FOREIGN KEY (tc_species_id) REFERENCES adempiere.tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_species_ids) REFERENCES adempiere.tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_naturesample_id) REFERENCES
     adempiere.tc_naturesample(tc_naturesample_id)
    );

        ##Media Label

        CREATE TABLE adempiere.tc_mediaLabelQr (
    tc_mediaLabelQr_id SERIAL PRIMARY KEY,
    tc_mediaLabelQr_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    isdiscarded CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    tcpf VARCHAR(25),
    operationDate DATE,
    personalCode VARCHAR(25),
    discardDate DATE,
    tcpf2 VARCHAR(25),
    personalCode2 VARCHAR(25),
    discardReason VARCHAR(50),
    tc_machinetype_id NUMERIC(10,0),
    tc_mediatype_id NUMERIC(10,0),
    tc_medialine_id NUMERIC(10,0),
    FOREIGN KEY (tc_medialine_id) REFERENCES adempiere.tc_medialine(tc_medialine_id),
    FOREIGN KEY (tc_machinetype_id) REFERENCES adempiere.tc_machinetype(tc_machinetype_id),
    FOREIGN KEY (tc_mediatype_id) REFERENCES adempiere.tc_mediatype(tc_mediatype_id)
    );

        Alter Table adempiere.ad_user Add column personalCode VARCHAR(10);

        Alter Table adempiere.tc_medialabelQr Add column discardReason VARCHAR(50); 

ALTER TABLE adempiere.tc_cultureLabel ADD COLUMN tc_in_id NUMERIC(10,0) ;
ALTER TABLE adempiere.tc_cultureLabel
ADD CONSTRAINT tc_cultureLabel_tc_in_id_fkey
FOREIGN KEY (tc_in_id)
REFERENCES adempiere.tc_in(tc_in_id);

ALTER TABLE adempiere.tc_cultureLabel ADD COLUMN tc_out_id NUMERIC(10,0) ;
ALTER TABLE adempiere.tc_cultureLabel
ADD CONSTRAINT tc_cultureLabel_tc_out_id_fkey
FOREIGN KEY (tc_out_id)
REFERENCES adempiere.tc_out(tc_out_id);

ALTER TABLE adempiere.tc_explantLabel ADD COLUMN tc_in_id NUMERIC(10,0) ;
ALTER TABLE adempiere.tc_explantLabel
ADD CONSTRAINT tc_explantLabel_tc_in_id_fkey
FOREIGN KEY (tc_in_id)
REFERENCES adempiere.tc_in(tc_in_id);

ALTER TABLE adempiere.tc_explantLabel ADD COLUMN tc_out_id NUMERIC(10,0) ;
ALTER TABLE adempiere.tc_explantLabel
ADD CONSTRAINT tc_explantLabel_tc_out_id_fkey
FOREIGN KEY (tc_out_id)
REFERENCES adempiere.tc_out(tc_out_id);




ALTER TABLE adempiere.tc_primaryhardeningLabel add column lotNumber VARCHAR(1);

//PRIMARY Hardening :-
CREATE TABLE adempiere.tc_primaryhardeningLabel (
    tc_primaryhardeningLabel_id SERIAL PRIMARY KEY,
    tc_primaryhardeningLabel_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    cultureProcessedNumber VARCHAR(25),
    yearCode VARCHAR(25),
    parentCultureLine VARCHAR(255),
    sourcingDate DATE,
    plotNumberTray VARCHAR(25),
    tc_species_id NUMERIC(10,0),
    tc_species_ids NUMERIC(10,0),
    tc_culturestage_id NUMERIC(10,0),
    tcpf VARCHAR(25),
    lotNumber VARCHAR(1),
    operationDate DATE,
    personalCode VARCHAR(25),
    tc_in_id NUMERIC(10,0),
    tc_out_id NUMERIC(10,0),
    FOREIGN KEY (tc_in_id) REFERENCES adempiere.tc_in(tc_in_id),
    FOREIGN KEY (tc_out_id) REFERENCES adempiere.tc_out(tc_out_id),
    FOREIGN KEY (tc_species_id) REFERENCES adempiere.tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_species_ids) REFERENCES adempiere.tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_culturestage_id) REFERENCES
     adempiere.tc_culturestage(tc_culturestage_id)
    );

ALTER TABLE adempiere.tc_secondaryhardeningLabel add column serialNumber VARCHAR(5);

CREATE TABLE adempiere.pi_userToken (
    pi_userToken_ID SERIAL PRIMARY KEY,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    ad_user_ID NUMERIC(10,0),   
    deviceType varchar(50),
    deviceToken varchar(500),
    FOREIGN KEY (ad_client_iD) REFERENCES adempiere.ad_client(ad_client_id),
    FOREIGN KEY (ad_org_iD) REFERENCES adempiere.ad_org(ad_org_id),
    FOREIGN KEY (createdby) REFERENCES adempiere.ad_user(ad_user_id),
    FOREIGN KEY (updatedby) REFERENCES adempiere.ad_user(ad_user_id),
    FOREIGN KEY (ad_user_ID) REFERENCES adempiere.ad_user(ad_user_ID));

//Secondery Hardening:-
CREATE TABLE adempiere.tc_secondaryhardeningLabel (
    tc_secondaryhardeningLabel_id SERIAL PRIMARY KEY,
    tc_secondaryhardeningLabel_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    cultureProcessedNumber VARCHAR(25),
    parentCultureLine VARCHAR(255),
    yearCode VARCHAR(25),
    sourcingDate DATE,
    batchNumber VARCHAR(25),
    tc_species_id NUMERIC(10,0),
    tc_species_ids NUMERIC(10,0),
    tc_culturestage_id NUMERIC(10,0),
    tcpf VARCHAR(25),
    operationDate DATE,
    personalCode VARCHAR(25),
    tc_in_id NUMERIC(10,0),
    tc_out_id NUMERIC(10,0),
    FOREIGN KEY (tc_in_id) REFERENCES adempiere.tc_in(tc_in_id),
    FOREIGN KEY (tc_out_id) REFERENCES adempiere.tc_out(tc_out_id),
    FOREIGN KEY (tc_species_id) REFERENCES adempiere.tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_species_ids) REFERENCES adempiere.tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_culturestage_id) REFERENCES
     adempiere.tc_culturestage(tc_culturestage_id)
    );


CREATE TABLE adempiere.tc_status (
        tc_status_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_status_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25),value varchar(25),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);

CREATE TABLE adempiere.tc_lightstatus (
        tc_lightstatus_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_lightstatus_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar);

CREATE TABLE adempiere.tc_temperatureposition (
        tc_temperatureposition_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_temperatureposition_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);

CREATE TABLE adempiere.tc_sensortype (
    tc_sensortype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_sensortype_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(30),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar);

CREATE TABLE adempiere.tc_tcpf (
    tc_tcpf_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_tcpf_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(30),value varchar(25),
    codeNo VARCHAR(10) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar);

CREATE TABLE adempiere.tc_devicedata (
    tc_devicedata_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_devicedata_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),frequency VARCHAR(30),
    deviceid varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    m_locatortype_id NUMERIC(10,0),
    tc_temperatureposition_id NUMERIC(10,0),
    tc_sensortype_id NUMERIC(10,0),
    FOREIGN KEY (tc_sensortype_id) REFERENCES adempiere.tc_sensortype(tc_sensortype_id),
    FOREIGN KEY (m_locatortype_id) REFERENCES adempiere.m_locatortype(m_locatortype_id),
    FOREIGN KEY (tc_temperatureposition_id) REFERENCES adempiere.tc_temperatureposition(tc_temperatureposition_id)
);

Alter table adempiere.m_locatortype Add column frequency VARCHAR(30);

ALTER TABLE adempiere.tc_visit ADD COLUMN tc_status_id NUMERIC(10,0) ;
ALTER TABLE adempiere.tc_visit
ADD CONSTRAINT tc_visit_tc_status_id_fkey
FOREIGN KEY (tc_status_id)
REFERENCES adempiere.tc_status(tc_status_id);

Alter Table adempiere.tc_plantdetails Add column isrejected CHAR(1) NOT NULL DEFAULT 'N'::bpchar
Alter Table adempiere.tc_culturelabel Add column isdiscarded CHAR(1) NOT NULL DEFAULT 'N'::bpchar
Alter Table adempiere.tc_medialabelQr Add column isdiscarded CHAR(1) NOT NULL DEFAULT 'N'::bpchar

CREATE TABLE adempiere.tc_temperature (
    tc_temperature_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_temperature_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),value varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    minTemp varchar(25),
    maxTemp varchar(25),
    minHumidity varchar(25),
    maxHumidity varchar(25),
    m_locatortype_id NUMERIC(10,0),
    FOREIGN KEY (m_locatortype_id) REFERENCES adempiere.m_locatortype(m_locatortype_id)
);

Alter Table adempiere.tc_temperatureStatus Add column deviceid varchar(25);

CREATE TABLE adempiere.tc_temperatureStatus (
    tc_temperatureStatus_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_temperatureStatus_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    Temperature varchar(25),
    Humidity varchar(25),
    m_locatortype_id NUMERIC(10,0),
    tc_tempstatus_id NUMERIC(10,0),
    FOREIGN KEY (m_locatortype_id) REFERENCES adempiere.m_locatortype(m_locatortype_id),
    FOREIGN KEY (tc_tempstatus_id) REFERENCES adempiere.tc_tempstatus(tc_tempstatus_id)
); 

CREATE TABLE adempiere.tc_tempstatus (
    tc_tempstatus_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_tempstatus_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar
);

CREATE TABLE adempiere.tc_light (
    tc_light_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_light_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    islightOnAndOff CHAR(1) not null DEFAULT 'Y'::bpchar
); 

Alter table adempiere.tc_light
add column lightoff VARCHAR(36);

Alter table adempiere.tc_light
add column lighton VARCHAR(36);

Alter table adempiere.tc_culturelabel
add column parentUUid VARCHAR(36) DEFAULT NULL::bpchar;

Alter table adempiere.tc_explantlabel
add column parentUUid VARCHAR(36) DEFAULT NULL::bpchar;

ALTER TABLE adempiere.tc_firstvisit
ADD COLUMN enterDetailsOfInfestation VARCHAR(30);

Alter table adempiere.tc_visit add column reason VARCHAR(36);

Alter table adempiere.tc_plantdetails add column reason VARCHAR(36);

CREATE TABLE adempiere.tc_firstjoinplant (
    tc_firstjoinplant_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_firstjoinplant_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    tc_plantdetails_id NUMERIC(10,0),
    tc_firstvisit_id NUMERIC(10,0),
    tc_plantstatus_id NUMERIC(10,0),
    FOREIGN KEY (tc_plantstatus_id) REFERENCES adempiere.tc_plantstatus(tc_plantstatus_id),
    FOREIGN KEY (tc_plantdetails_id) REFERENCES adempiere.tc_plantdetails(tc_plantdetails_id),
    FOREIGN KEY (tc_firstvisit_id) REFERENCES adempiere.tc_firstvisit(tc_firstvisit_id)
    );


CREATE TABLE adempiere.tc_intermediatejoinplant (
    tc_intermediatejoinplant_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_intermediatejoinplant_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    tc_plantdetails_id NUMERIC(10,0),
    tc_intermediatevisit_id NUMERIC(10,0),
    tc_plantstatus_id NUMERIC(10,0),
    FOREIGN KEY (tc_plantstatus_id) REFERENCES adempiere.tc_plantstatus(tc_plantstatus_id),
    FOREIGN KEY (tc_plantdetails_id) REFERENCES adempiere.tc_plantdetails(tc_plantdetails_id),
    FOREIGN KEY (tc_intermediatevisit_id) REFERENCES adempiere.tc_intermediatevisit(tc_intermediatevisit_id)
    );

CREATE TABLE adempiere.tc_plantstatus (
        tc_plantstatus_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_plantstatus_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        c_uuId VARCHAR(36) DEFAULT NULL::bpchar);

CREATE TABLE adempiere.tc_labelName (
        tc_labelName_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_labelName_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar);

ALTER TABLE adempiere.tc_intermediatejoinplant ADD COLUMN tc_plantstatus_id NUMERIC(10,0) ;
ALTER TABLE adempiere.tc_intermediatejoinplant
ADD CONSTRAINT tc_intermediatejoinplant_tc_plantstatus_id_fkey
FOREIGN KEY (tc_plantstatus_id)
REFERENCES adempiere.tc_plantstatus(tc_plantstatus_id);

CREATE TABLE adempiere.tc_collectionjoinplant (
    tc_collectionjoinplant_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_collectionjoinplant_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    suckerNo NUMERIC(10,0),
    tc_plantdetails_id NUMERIC(10,0),
    tc_collectiondetails_id NUMERIC(10,0),
    tc_plantstatus_id NUMERIC(10,0),
    FOREIGN KEY (tc_plantstatus_id) REFERENCES adempiere.tc_plantstatus(tc_plantstatus_id),
    FOREIGN KEY (tc_plantdetails_id) REFERENCES adempiere.tc_plantdetails(tc_plantdetails_id),
    FOREIGN KEY (tc_collectiondetails_id) REFERENCES adempiere.tc_collectiondetails(tc_collectiondetails_id)
    );

ALTER TABLE adempiere.tc_collectionjoinplant ADD COLUMN tc_plantstatus_id NUMERIC(10,0) ;
ALTER TABLE adempiere.tc_collectionjoinplant
ADD CONSTRAINT tc_collectionjoinplant_tc_plantstatus_id_fkey
FOREIGN KEY (tc_plantstatus_id)
REFERENCES adempiere.tc_plantstatus(tc_plantstatus_id);

CREATE TABLE adempiere.tc_columnfield (
        tc_columnfield_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        tc_columnfield_uu VARCHAR(36) DEFAULT NULL::bpchar,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25),value varchar(25),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        isfarmerfield CHAR(1) not null DEFAULT 'N'::bpchar,
        isvisitfield CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);

CREATE TABLE adempiere.tc_discardtype (
    tc_discardtype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_discardtype_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar
);

CREATE TABLE adempiere.tc_mediadiscardtype (
    tc_mediadiscardtype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_mediadiscardtype_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name varchar(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar
);

CREATE TABLE adempiere.tc_primaryHardeningcultureS (
    tc_primaryHardeningcultureS_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_primaryHardeningcultureS_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() NOT NULL,
    createdby NUMERIC(10,0) NOT NULL,
    updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
    updatedby NUMERIC(10,0) NOT NULL,
    description VARCHAR(255),
    isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    cultureUUId VARCHAR(36),
    tc_culturelabel_id INTEGER,
    tc_primaryhardeningLabel_id INTEGER,
    FOREIGN KEY (tc_culturelabel_id) REFERENCES adempiere.tc_culturelabel(tc_culturelabel_id),
    FOREIGN KEY (tc_primaryhardeningLabel_id) REFERENCES adempiere.tc_primaryhardeningLabel(tc_primaryhardeningLabel_id)
);

ALTER TABLE adempiere.tc_explantLabel ADD COLUMN tc_variety_id INTEGER ;
ALTER TABLE adempiere.tc_explantLabel
ADD CONSTRAINT tc_explantLabel_tc_variety_id_fkey
FOREIGN KEY (tc_variety_id)
REFERENCES adempiere.tc_variety(tc_variety_id);

ALTER TABLE adempiere.tc_cultureLabel ADD COLUMN tc_variety_id INTEGER ;
ALTER TABLE adempiere.tc_cultureLabel
ADD CONSTRAINT tc_cultureLabel_tc_variety_id_fkey
FOREIGN KEY (tc_variety_id)
REFERENCES adempiere.tc_variety(tc_variety_id);

ALTER TABLE adempiere.tc_primaryhardeningLabel ADD COLUMN tc_variety_id INTEGER ;
ALTER TABLE adempiere.tc_primaryhardeningLabel
ADD CONSTRAINT tc_primaryhardeningLabel_tc_variety_id_fkey
FOREIGN KEY (tc_variety_id)
REFERENCES adempiere.tc_variety(tc_variety_id);

ALTER TABLE adempiere.tc_secondaryhardeningLabel ADD COLUMN tc_variety_id INTEGER ;
ALTER TABLE adempiere.tc_secondaryhardeningLabel
ADD CONSTRAINT tc_secondaryhardeningLabel_tc_variety_id_fkey
FOREIGN KEY (tc_variety_id)
REFERENCES adempiere.tc_variety(tc_variety_id);

ALTER TABLE adempiere.tc_planttag
ADD COLUMN printqr character varying(2);

ALTER TABLE adempiere.tc_planttag
ADD COLUMN save_button character varying(2);

ALTER TABLE adempiere.tc_plantdetails
ADD COLUMN IF NOT EXISTS raw CHAR(25),
ADD COLUMN IF NOT EXISTS columns CHAR(25);

ALTER TABLE adempiere.tc_order 
ADD cultureCode VARCHAR(255);

ALTER TABLE adempiere.tc_order
ADD COLUMN tc_variety_id NUMERIC(10,0);

ALTER TABLE adempiere.tc_order
ADD CONSTRAINT tc_order_tc_variety_id_fkey
FOREIGN KEY (tc_variety_id)
REFERENCES adempiere.tc_variety(tc_variety_id);

ALTER TABLE adempiere.tc_light ADD COLUMN TC_devicedata_id INTEGER ;
ALTER TABLE adempiere.tc_light
ADD CONSTRAINT tc_light_TC_devicedata_id_fkey
FOREIGN KEY (TC_devicedata_id)
REFERENCES adempiere.TC_devicedata(TC_devicedata_id);

ALTER TABLE adempiere.tc_plantdetails
ADD COLUMN IF NOT EXISTS isattachedintermediate CHAR(1) NOT NULL DEFAULT 'N'::bpchar;

-- ALTER TABLE adempiere.tc_plantdetails
-- ADD COLUMN IF NOT EXISTS isattachedcollection DEFAULT 'N'::bpchar;

ALTER TABLE adempiere.tc_collectiondetails
ADD COLUMN IF NOT EXISTS issuckercollectcollection CHAR(1) NOT NULL DEFAULT 'N'::bpchar;

ALTER TABLE adempiere.tc_intermediatevisit
ADD COLUMN IF NOT EXISTS isattachedintermediatetocollection CHAR(1) NOT NULL DEFAULT 'N'::bpchar;

if(description.getValue() != null){
   if (!description.getValue().includes("@"))
        result = "Invalid email: The value must contain '@'";
}
result = "";

if (description.getValue() != null) {
    def email = description.getValue().toString();
    if (!email.contains("@")) {
        result = "Invalid email: The value must contain '@'";
    } else {
        result = "";
    }
} else {
    result = ""; 
}



=========================================================================
Tc media order script:-
-- Table: adempiere.tc_mediaorder

-- DROP TABLE IF EXISTS adempiere.tc_mediaorder;

CREATE TABLE IF NOT EXISTS adempiere.tc_mediaorder
(
    tc_mediaorder_id numeric(10,0) NOT NULL,
    ad_client_id numeric(10,0) NOT NULL,
    ad_org_id numeric(10,0) NOT NULL,
    name character varying(25) COLLATE pg_catalog."default" NOT NULL,
    value character varying(25) COLLATE pg_catalog."default",
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    description character varying(255) COLLATE pg_catalog."default",
    documentno character varying(25) COLLATE pg_catalog."default" NOT NULL,
    isactive character(1) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Y'::bpchar,
    isdefault character(1) COLLATE pg_catalog."default" NOT NULL DEFAULT 'N'::bpchar,
    docaction character(2) COLLATE pg_catalog."default" NOT NULL DEFAULT 'CO'::bpchar,
    docstatus character(2) COLLATE pg_catalog."default" NOT NULL DEFAULT 'DR'::bpchar,
    c_doctype_id numeric(10,0) NOT NULL,
    c_doctypetarget_id numeric(10,0) NOT NULL,
    processed character(1) COLLATE pg_catalog."default" DEFAULT 'N'::bpchar,
    processing character(1) COLLATE pg_catalog."default" DEFAULT 'N'::bpchar,
    posted character(1) COLLATE pg_catalog."default" DEFAULT 'N'::bpchar,
    isapproved character(1) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Y'::bpchar,
    dateordered date,
    salesrep_id numeric(10,0),
    m_warehouse_id numeric(10,0),
    c_uuid character varying(36) COLLATE pg_catalog."default" DEFAULT NULL::bpchar,
    m_product_id numeric(10,0),
    quantity numeric(10,0),
    ad_user_id numeric(10,0),
    CONSTRAINT tc_mediaorder_pkey PRIMARY KEY (tc_mediaorder_id),
    CONSTRAINT tc_mediaorder_ad_user_id_fkey FOREIGN KEY (ad_user_id)
        REFERENCES adempiere.ad_user (ad_user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT tc_mediaorder_m_product_id_fkey FOREIGN KEY (m_product_id)
        REFERENCES adempiere.m_product (m_product_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT tc_mediaorder_m_warehouse_id_fkey FOREIGN KEY (m_warehouse_id)
        REFERENCES adempiere.m_warehouse (m_warehouse_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

-- Table: adempiere.tc_medialine

-- DROP TABLE IF EXISTS adempiere.tc_medialine;

CREATE TABLE IF NOT EXISTS adempiere.tc_medialine
(
    tc_medialine_id numeric(10,0) NOT NULL,
    ad_client_id numeric(10,0) NOT NULL,
    ad_org_id numeric(10,0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    line numeric(10,0),
    description character varying(255) COLLATE pg_catalog."default",
    isactive character(1) COLLATE pg_catalog."default" NOT NULL DEFAULT 'Y'::bpchar,
    quantity numeric(10,0),
    tc_mediaorder_id numeric(10,0),
    m_locator_id numeric(10,0),
    m_product_id numeric(10,0),
    c_uom_id numeric(10,0),
    discardqty numeric(10,0),
    c_uuid character varying(36) COLLATE pg_catalog."default" DEFAULT NULL::bpchar,
    CONSTRAINT tc_medialine_pkey PRIMARY KEY (tc_medialine_id),
    CONSTRAINT tc_medialine_c_uom_id_fkey FOREIGN KEY (c_uom_id)
        REFERENCES adempiere.c_uom (c_uom_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT tc_medialine_m_locator_id_fkey FOREIGN KEY (m_locator_id)
        REFERENCES adempiere.m_locator (m_locator_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT tc_medialine_m_product_id_fkey FOREIGN KEY (m_product_id)
        REFERENCES adempiere.m_product (m_product_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT tc_medialine_tc_mediaorder_id_fkey FOREIGN KEY (tc_mediaorder_id)
        REFERENCES adempiere.tc_mediaorder (tc_mediaorder_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

=======================================================================================================================================

SELECT v.tc_visit_id AS id,v.tc_farmer_id As farmerId,f.name As farmerName,v.mobileNo AS mobileNo,v.date As visitDate,
vt.name As visitType,s.name As status,v.visitdone As visitdone,d.name FROM adempiere.tc_visit v
JOIN adempiere.tc_farmer f ON f.tc_farmer_id = v.tc_farmer_id Left JOIN adempiere.tc_intermediatevisit iv ON iv.tc_visit_id = v.tc_visit_id
LEFT JOIN adempiere.tc_decision d ON d.tc_decision_id = iv.tc_decision_id
JOIN adempiere.tc_visitType vt ON vt.tc_visittype_id = v.tc_visittype_id JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id 
WHERE v.ad_client_id = 1000000 AND v.tc_farmer_id = 1000323 AND s.name <> 'Cancelled' 
AND d.name <> 'Rejected' AND d.name is null
ORDER BY v.created

SELECT v.tc_visit_id AS id,v.tc_farmer_id AS farmerId,f.name AS farmerName,v.mobileNo AS mobileNo,v.date AS visitDate,vt.name AS visitType,
s.name AS status,v.visitdone AS visitdone,COALESCE(d.name, 'Not Applicable') AS decisionStatus,
CASE WHEN d.name = 'Rejected' THEN 1 ELSE 0 END AS isRejected
FROM adempiere.tc_visit v
JOIN adempiere.tc_farmer f ON f.tc_farmer_id = v.tc_farmer_id 
LEFT JOIN adempiere.tc_intermediatevisit iv ON iv.tc_visit_id = v.tc_visit_id
LEFT JOIN adempiere.tc_decision d ON d.tc_decision_id = iv.tc_decision_id
JOIN adempiere.tc_visitType vt ON vt.tc_visittype_id = v.tc_visittype_id 
JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id 
WHERE v.ad_client_id = 1000000 
AND v.tc_farmer_id = 1000323 
AND s.name <> 'Cancelled'
group by v.tc_visit_id,v.tc_farmer_id,f.name,v.mobileNo,v.date,vt.name,s.name,v.visitdone,d.name
HAVING MAX(CASE WHEN d.name = 'Rejected' THEN 1 ELSE 0 END) = 0  -- Ensure no rejected visits
ORDER BY v.created;

=======================================================================================================================================
Visit with cycleNo:-

public boolean canCreateVisit(int farmerId, int cycleNo, int visitTypeId) {
    String visitType = getVisitType(visitTypeId); // Fetch visit type from DB

    if ("Intermediate".equalsIgnoreCase(visitType)) {
        return true; // Intermediate visits are allowed multiple times
    }

    -- String sql = "SELECT COUNT(*) FROM adempiere.tc_visit WHERE tc_farmer_id = ? AND cycleNo = ? AND tc_visittype_id = ?";
    
    -- int existingCount = DB.getSQLValue(null, sql, farmerId, cycleNo, visitTypeId);

     int existingCount = new Query(Env.getCtx(), "tc_visit", 
                          "tc_farmer_id = ? AND cycleNo = ? AND tc_visittype_id = ?", null)
                    .setParameters(farmerId, cycleNo, visitTypeId)
                    .count();
    
    return existingCount == 0; // Allow only if no existing First/Collection visit found
}


if (!canCreateVisit(farmerId, cycleNo, visitTypeId)) {
    throw new RuntimeException("Error: Farmer can only have one First and one Collection visit per cycle.");
}

=======================================================================================================================================
RWPL:-

CREATE TABLE adempiere.m_inward_window_process (
    m_inward_window_process_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    m_inward_window_process_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
   movementDate DATE,
    m_warehouse_id INTEGER,
    m_locator_id INTEGER,
   m_product_category_id INTEGER,
    FOREIGN KEY (m_warehouse_id) REFERENCES adempiere.m_warehouse(m_warehouse_id),
    FOREIGN KEY (m_locator_id) REFERENCES adempiere.m_locator(m_locator_id),
    FOREIGN KEY (m_product_category_id) REFERENCES adempiere.m_product_category(m_product_category_id)
    );

CREATE TABLE adempiere.m_inward_window_processline (
    m_inward_window_processline_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    m_inward_window_processline_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    quantity NUMERIC(10, 0),
    m_product_id INTEGER,
    FOREIGN KEY (m_product_id) REFERENCES adempiere.m_product(m_product_id)
    );   

=======================================================================================================================================




=======================================================================================================================================




=======================================================================================================================================


// Vinay Table:-
ALTER TABLE adempiere.m_product
DROP COLUMN IF EXISTS vendorLabel,
DROP COLUMN IF EXISTS assembly,
DROP COLUMN IF EXISTS manufacturingreceipt,
DROP COLUMN IF EXISTS assemblycreator;

ALTER TABLE ad_role
ADD COLUMN IF NOT EXISTS productionSupervisor CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
ADD COLUMN IF NOT EXISTS productionAgent CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
ADD COLUMN IF NOT EXISTS productionReceipt CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
ADD COLUMN IF NOT EXISTS assemblySupervisor CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
ADD COLUMN IF NOT EXISTS assemblyAgent CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
ADD COLUMN IF NOT EXISTS assemblyPacking CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
ADD COLUMN IF NOT EXISTS assemblyreceipt CHAR(1) NOT NULL DEFAULT 'N'::bpchar;

ALTER TABLE adempiere.m_product DROP COLUMN IF EXISTS vendorLabel;

ALTER TABLE adempiere.m_product
Add COLUMN IF not EXISTS scanLabel CHAR(1) NOT NULL DEFAULT 'N'::bpchar;

Delete Any records:-
DELETE FROM adempiere.tc_farmer
WHERE tc_farmer_id = 1000168;
DELETE FROM adempiere.tc_farmer
WHERE tc_farmer_id = 1000188;
DELETE FROM adempiere.tc_farmer
WHERE tc_farmer_id = 1000166;
DELETE FROM adempiere.tc_farmer
WHERE tc_farmer_id = 1000167;

DELETE FROM adempiere.c_orderline
WHERE c_order_id = 1000007;

Update any Records:-
UPDATE adempiere.tc_mediaorder
SET quantity = 10
WHERE tc_mediaorder_id = 1000175;



In system_configurator
  1. for name change in login page and browser tittle
      name: ZK_BROWSER_TITLE
      Configured Value: WarePro
  
  2. for browser icon
      name: ZK_BROWSER_ICON
      Configured Value: ~./theme/default/images/icon.png

  3. for icon which is same as 5th one, but will used in diff locations
      name: ZK_LOGIN_ICON
      Configured Value: /images/warepro-logo.svg

  4. for app description:
      name: ZK_APP_DESCRIPTION
      Configured Value: WarePro is a large commericial building used for<br></br> the storage of goods materials

Insert into adempiere.AD_SysConfig

select name from  adempiere.AD_SysConfig where name = 'ZK_BROWSER_TITLE';  

INSERT INTO adempiere.AD_SysConfig (AD_SysConfig_ID, AD_Client_ID, AD_Org_ID, Name, Value, Description, IsActive, Created, CreatedBy, Updated, UpdatedBy)
VALUES (nextval('adempiere.AD_SysConfig_seq'), 0, 0, 'ZK_BROWSER_TITLE', 'WarePro', 'Custom Browser Title', 'Y', NOW(), 100, NOW(), 100);

INSERT INTO adempiere.AD_SysConfig (AD_SysConfig_ID, AD_Client_ID, AD_Org_ID, Name, Value, Description, IsActive, Created, CreatedBy, Updated, UpdatedBy)
VALUES (1000216, 0, 0, 'ZK_BROWSER_TITLE', 'WarePro', 'Custom Browser Title', 'Y', NOW(), 100, NOW(), 100);

INSERT INTO adempiere.AD_SysConfig (AD_SysConfig_ID, AD_Client_ID, AD_Org_ID, Name, Value, Description, IsActive, Created, CreatedBy, Updated, UpdatedBy)
VALUES (1000217, 0, 0, 'ZK_APP_DESCRIPTION', 'WarePro is a large commericial building used for<br></br> the storage of goods materials', 'Custom Browser DESCRIPTION', 'Y', NOW(), 100, NOW(), 100);  
    
INSERT INTO adempiere.AD_SysConfig (AD_SysConfig_ID, AD_Client_ID, AD_Org_ID, Name, Value, Description, IsActive, Created, CreatedBy, Updated, UpdatedBy)
VALUES (1000218, 0, 0, 'ZK_BROWSER_ICON', '~./theme/default/images/icon.png', 'Icon', 'Y', NOW(), 100, NOW(), 100);  

INSERT INTO adempiere.AD_SysConfig (AD_SysConfig_ID, AD_Client_ID, AD_Org_ID, Name, Value, Description, IsActive, Created, CreatedBy, Updated, UpdatedBy)
VALUES (1000219, 0, 0, 'ZK_LOGIN_ICON', '/images/warepro-logo.svg', 'Login Icon', 'Y', NOW(), 100, NOW(), 100); 


Image Part:-

URL url;
         try 
         {
            url = new URL(getImageURL());
            Toolkit tk = Toolkit.getDefaultToolkit();
            m_image = tk.getImage(url);
         }

         
Tracebility:-
WITH RECURSIVE cte AS (
SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,cl.cycleno,ps.name AS cropType,cs.name AS stage,
var.name AS variety, cl.personal_code,ts.temperature AS temp, ts.humidity AS humidity, 1 AS level
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
WHERE cl.c_uuid = '6654184e-f8c6-4f9d-b04e-b6814fc532d5' AND cl.ad_client_id = 1000002
AND DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus WHERE ad_client_id = 1000002 )
UNION ALL
SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,cl2.cycleno,ps.name AS cropType,cs.name AS stage,
var.name AS variety,cl2.personal_code,ts.temperature AS temp,ts.humidity AS humidity,cte.level + 1 AS level FROM cte
JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
-- WHERE DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus WHERE created = ts.created)
   ),
culture_result AS (
SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,cte.cropType,cte.stage,cte.variety,cte.personal_code, 
MIN(cte.temp) AS min_temperature,MAX(cte.temp) AS max_temperature,MIN(cte.humidity) AS min_humidity, MAX(cte.humidity) AS max_humidity,cte.level FROM cte
GROUP BY cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid, cte.location,cte.created, cte.cycleno, cte.cropType, cte.stage, cte.variety,cte.personal_code, cte.level
UNION ALL
SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,cte.cropType,pr.name AS stage,
cte.variety,tcc.personalcode AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level 
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
UNION ALL
SELECT DISTINCT NULL AS parentuuid,0 AS tc_in_id,0 AS tc_out_id,tpt.c_uuid,NULL AS location,tpt.created,0 AS cycleno,cte.cropType,'Plant Tag' AS stage, 
cte.variety,NULL AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level 
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
WHERE tpt.c_uuid IS NOT NULL ORDER BY created ASC
),
explant_result AS (
SELECT DISTINCT tcc.parentuuid, tcc.tc_in_id, tcc.tc_out_id, tcc.c_uuid, loc.value AS location,tcc.created, 0 AS cycleno, ps.name AS cropType,
pr.name AS stage, var.name AS variety,tcc.personalcode AS personal_code, NULL AS min_temperature, NULL AS max_temperature, 
NULL AS min_humidity, NULL AS max_humidity, 1 AS level FROM adempiere.tc_explantlabel tcc
JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = tcc.tc_species_id JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id WHERE tcc.c_uuid = '6654184e-f8c6-4f9d-b04e-b6814fc532d5' AND tcc.ad_client_id = 1000002
UNION ALL
SELECT DISTINCT NULL AS parentuuid, 0 AS tc_in_id, 0 AS tc_out_id, tpt.c_uuid, NULL AS location,tpt.created, 0 AS cycleno, ps.name AS cropType,
'Plant Tag' AS stage, var.name AS variety,NULL AS personal_code, NULL AS min_temperature, NULL AS max_temperature,NULL AS min_humidity, NULL AS max_humidity, 2 AS level
FROM adempiere.tc_planttag tpt JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid
JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id WHERE tcc.c_uuid = '6654184e-f8c6-4f9d-b04e-b6814fc532d5' AND tpt.c_uuid IS NOT NULL
),
plant_tag_result AS (
SELECT DISTINCT NULL AS parentuuid, 0 AS tc_in_id, 0 AS tc_out_id, tpt.c_uuid, NULL AS location,tpt.created, 0 AS cycleno, ps.name AS cropType,
'Plant Tag' AS stage, var.name AS variety,NULL AS personal_code, NULL AS min_temperature, NULL AS max_temperature,NULL AS min_humidity, NULL AS max_humidity, 1 AS level
FROM adempiere.tc_planttag tpt JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id   
WHERE tpt.c_uuid = '6654184e-f8c6-4f9d-b04e-b6814fc532d5' AND tpt.ad_client_id = 1000002 
   -- AND NOT EXISTS (SELECT 1 FROM explant_result)
)  
SELECT * FROM culture_result
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL
SELECT * FROM plant_tag_result WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC;



================================================================================================================================
View:-

create or replace view tc_technicianwiseproductvity as
 SELECT
 o.createdby AS technician,
    o.m_product_id AS stage,
    o.m_locator_id AS rrc,
    o.quantity,
    o.ad_client_id,
    o.ad_org_id,
    o.created,
    pr.name AS stagen
   FROM adempiere.tc_out o
     JOIN adempiere.tc_order ord ON ord.tc_order_id = o.tc_order_id
     JOIN adempiere.m_product pr ON pr.m_product_id = o.m_product_id;


Dynamic Validation:-
Region depend on country     
validation
C_Region.C_Country_ID=@C_Country_ID@

double validation
((@C_Region_ID@>0 AND C_City.C_Region_ID=@C_Region_ID@) OR (@C_Region_ID@=0 AND C_City.C_Country_ID=@C_Country_ID@ AND C_City.C_Region_ID IS NULL))


==================================================================================================================================
@Override
         public Response getFORoleReportSuckerCountDownload(
               GetFORoleReportSuckerCountDownloadRequestDocument req) {
//          GetFORoleReportVisitCountDownloadResponseDocument resp = GetFORoleReportVisitCountDownloadResponseDocument.Factory
//                   .newInstance();
//          GetFORoleReportVisitCountDownloadResponse response = resp
//                   .addNewGetFORoleReportVisitCountDownloadResponse();
            GetFORoleReportSuckerCountDownloadRequest loginRequest = req.getGetFORoleReportSuckerCountDownloadRequest();
               ADLoginRequest login = loginRequest.getADLoginRequest();
               String user = login.getUser();
               int clientId = login.getClientID();
               String userInput = loginRequest.getUserInput();
//             String serviceType = loginRequest.getServiceType();
               ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
               PreparedStatement pstm = null;
               ResultSet rs = null;
               Trx trx = null;
               try {
                  getCompiereService().connect();
                  String trxName = Trx.createTrxName(getClass().getName() + "_");
                  trx = Trx.get(trxName, true);
                  trx.start();
//                String err = login(login, webServiceName, "getReport", "getReport");
//                if (err != null && err.length() > 0) {
//                   response.setError(err);
//                   response.setIsError(true);
//                   return resp;
//                }
//                if (!serviceType.equalsIgnoreCase("getReport")) {
//                   response.setError("Service type " + serviceType + " not configured");
//                   response.setIsError(true);
////                    return resp;
//                }
                  SXSSFWorkbook workbook = new SXSSFWorkbook(-1);

                  CellStyle myStyle = workbook.createCellStyle();
                  org.apache.poi.ss.usermodel.Font myFont = workbook.createFont();
                  myFont.setBold(true);
                  myStyle.setFont(myFont);

                  CellStyle wrapStyle = workbook.createCellStyle();
                  wrapStyle.setWrapText(true);
                  // Create sheet and rows
                  SXSSFSheet sheet = workbook.createSheet("Field Officer Sucker Count Report");
                  SXSSFRow headerRow = sheet.createRow(0);

                  // Create header cells
                  SXSSFCell cellH0 = headerRow.createCell(0);
                  cellH0.setCellValue("Label Name");
                  cellH0.setCellStyle(myStyle);

                  SXSSFCell cellH1 = headerRow.createCell(1);
                  cellH1.setCellValue("Count");
                  cellH1.setCellStyle(myStyle);
                  String sql = null;

                  if (userInput.equals("day")) {
                     sql = "SELECT day_info.day_name AS day_name,current_date AS date,COALESCE(SUM(cv.suckerno), 0) AS sucker_count\n"
                           + "FROM (SELECT to_char(current_date, 'Day') AS day_name) AS day_info\n"
                           + "LEFT JOIN adempiere.tc_collectionjoinplant cv ON cv.created::date = current_date AND cv.ad_client_id = "
                           + clientId + "\n"
                           + "AND cv.createdby IN (SELECT ad_user_id FROM adempiere.ad_user WHERE name = '" + user
                           + "') GROUP BY day_info.day_name;";
                  } else if (userInput.equals("week")) {
                     sql = "WITH days AS (SELECT generate_series(0, 6) AS day_of_week),\n" + "sucker_counts AS (\n"
                           + "SELECT date_trunc('day', v.created) AS visit_day,to_char(v.created, 'FMDay') AS day_name,\n"
                           + "EXTRACT(dow FROM v.created) AS day_of_week,SUM(v.suckerno) AS visit_count\n"
                           + "FROM adempiere.tc_collectionjoinplant v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                           + "WHERE v.ad_client_id = " + clientId + " AND u.name = '" + user
                           + "' AND v.created::date >= current_date - interval '6 days' AND v.created::date <= current_date\n"
                           + "GROUP BY date_trunc('day', v.created),to_char(v.created, 'FMDay'),EXTRACT(dow FROM v.created))\n"
                           + "SELECT (current_date - interval '6 days' + d.day_of_week * interval '1 day')::date AS dates,\n"
                           + "COALESCE(vc.day_name, to_char(current_date - interval '6 days' + d.day_of_week * interval '1 day', 'FMDay')) AS day_name,\n"
                           + "COALESCE(vc.visit_count, 0) AS sucker_count FROM days d\n"
                           + "LEFT JOIN sucker_counts vc ON current_date - interval '6 days' + d.day_of_week * interval '1 day' = vc.visit_day ORDER BY dates;";
                  } else if (userInput.equals("month")) {
                     sql = "WITH weeks AS (SELECT generate_series(0, 4) AS week_number),\n"
                           + "sucker_counts AS (SELECT date_trunc('week', v.created) AS week_start,to_char(date_trunc('week', v.created), 'YYYY-MM-DD') AS week_start_str,\n"
                           + "SUM(v.suckerno) AS sucker_count FROM adempiere.tc_collectionjoinplant v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                           + "WHERE v.ad_client_id = " + clientId + " AND u.name = '" + user
                           + "' AND v.created::date >= (current_date - interval '29 days') AND v.created::date <= current_date GROUP BY date_trunc('week', v.created)),\n"
                           + "date_range AS (SELECT (current_date - interval '29 days')::date + generate_series(0, 29) AS day)\n"
                           + "SELECT to_char(date_trunc('week', day), 'YYYY-MM-DD') AS week_start,COALESCE(vc.sucker_count, 0) AS sucker_count\n"
                           + "FROM date_range LEFT JOIN sucker_counts vc ON date_trunc('week', day) = vc.week_start\n"
                           + "GROUP BY date_trunc('week', day), vc.sucker_count ORDER BY week_start;\n" + "";
                  } else if (userInput.equals("year")) {
                     sql = "WITH months AS (SELECT generate_series(0, 11) AS month),\n" + "sucker_counts AS (\n"
                           + "SELECT date_trunc('month', v.created) AS month_year,to_char(v.created, 'FMMonth') AS month_name,SUM(v.suckerno) AS sucker_count\n"
                           + "FROM adempiere.tc_collectionjoinplant v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                           + "WHERE v.ad_client_id = " + clientId + " AND u.name = '" + user
                           + "' AND v.created::date >= (current_date - interval '364 days') \n"
                           + "AND v.created::date <= current_date GROUP BY date_trunc('month', v.created), to_char(v.created, 'FMMonth'))\n"
                           + "SELECT to_char(date_trunc('month', current_date) - (m.month || ' months')::interval, 'YYYY-MM-01') AS month_date,COALESCE(vc.sucker_count, 0) AS sucker_count \n"
                           + "FROM months m LEFT JOIN sucker_counts vc \n"
                           + "ON date_trunc('month', current_date) - (m.month || ' months')::interval = vc.month_year\n"
                           + "ORDER BY date_trunc('month', current_date) - (m.month || ' months')::interval;";
                  } else if (userInput.equals("all")) {
                     sql = "WITH year_counts AS (\n"
                           + "SELECT date_trunc('year', v.created) AS year_start, sum(v.suckerno) AS counts FROM adempiere.tc_collectionjoinplant v\n"
                           + "JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby WHERE v.ad_client_id = " + clientId
                           + " AND u.name = '" + user + "'\n" + "GROUP BY date_trunc('year', v.created)),\n"
                           + "year_range AS (SELECT date_trunc('year', CURRENT_DATE) AS year_start\n" + "UNION ALL\n"
                           + "SELECT generate_series((SELECT MIN(year_start) FROM year_counts),date_trunc('year', CURRENT_DATE),interval '1 year') AS year_start\n"
                           + "),\n" + "all_years AS (SELECT DISTINCT year_start FROM year_range)\n"
                           + "SELECT to_char(a.year_start, 'YYYY-01-01') AS year_date, COALESCE(y.counts, 0) AS counts FROM all_years a\n"
                           + "LEFT JOIN year_counts y ON a.year_start = y.year_start ORDER BY a.year_start;";
                  }
//                if (sql == null) {
//                   response.setError("No SQL");
//                   response.setIsError(true);
////                    return resp;
//                }
                  pstm = DB.prepareStatement(sql.toString(), null);
                  rs = pstm.executeQuery();
                  int i = 1;
                  while (rs.next()) {
                     if (userInput.equals("day")) {
                        String date = rs.getString("date");
                        int count = rs.getInt("sucker_count");
                        
                        Row row = sheet.createRow(i++);
                            row.createCell(0).setCellValue(date);
                            row.createCell(1).setCellValue(count);

//                      SXSSFRow tableDescriptionRow = sheet.createRow(i);
//                      SXSSFCell cell1 = tableDescriptionRow.createCell(0);
//                      cell1.setCellValue(date);
//                      cell1.setCellStyle(wrapStyle);
//
//                      SXSSFCell cell2 = tableDescriptionRow.createCell(1);
//                      cell2.setCellValue(count);
//                      cell2.setCellStyle(wrapStyle);
                     } else if (userInput.equals("week")) {
                        String dates = rs.getString("dates");
                        int count = rs.getInt("sucker_count");
                        
                        Row row = sheet.createRow(i++);
                            row.createCell(0).setCellValue(dates);
                            row.createCell(1).setCellValue(count);

//                      SXSSFRow tableDescriptionRow = sheet.createRow(i);
//                      SXSSFCell cell1 = tableDescriptionRow.createCell(0);
//                      cell1.setCellValue(dates);
//                      cell1.setCellStyle(wrapStyle);
//
//                      SXSSFCell cell2 = tableDescriptionRow.createCell(1);
//                      cell2.setCellValue(count);
//                      cell2.setCellStyle(wrapStyle);
                     } else if (userInput.equals("month")) {
                        String week_start = rs.getString("week_start");
                        int count = rs.getInt("sucker_count");
                        
                        Row row = sheet.createRow(i++);
                            row.createCell(0).setCellValue(week_start);
                            row.createCell(1).setCellValue(count);

//                      SXSSFRow tableDescriptionRow = sheet.createRow(i);
//                      SXSSFCell cell1 = tableDescriptionRow.createCell(0);
//                      cell1.setCellValue(week_start);
//                      cell1.setCellStyle(wrapStyle);
//
//                      SXSSFCell cell2 = tableDescriptionRow.createCell(1);
//                      cell2.setCellValue(count);
//                      cell2.setCellStyle(wrapStyle);
                     } else if (userInput.equals("year")) {
                        String month_date = rs.getString("month_date");
                        int count = rs.getInt("sucker_count");
                        
                        Row row = sheet.createRow(i++);
                            row.createCell(0).setCellValue(month_date);
                            row.createCell(1).setCellValue(count);

//                      SXSSFRow tableDescriptionRow = sheet.createRow(i);
//                      SXSSFCell cell1 = tableDescriptionRow.createCell(0);
//                      cell1.setCellValue(month_date);
//                      cell1.setCellStyle(wrapStyle);
//
//                      SXSSFCell cell2 = tableDescriptionRow.createCell(1);
//                      cell2.setCellValue(count);
//                      cell2.setCellStyle(wrapStyle);
                     } else if (userInput.equals("all")) {
                        String year_date = rs.getString("year_date");
                        int count = rs.getInt("counts");
                        
                        Row row = sheet.createRow(i++);
                            row.createCell(0).setCellValue(year_date);
                            row.createCell(1).setCellValue(count);

//                      SXSSFRow tableDescriptionRow = sheet.createRow(i);
//                      SXSSFCell cell1 = tableDescriptionRow.createCell(0);
//                      cell1.setCellValue(year_date);
//                      cell1.setCellStyle(wrapStyle);
//
//                      SXSSFCell cell2 = tableDescriptionRow.createCell(1);
//                      cell2.setCellValue(count);
//                      cell2.setCellStyle(wrapStyle);
                     }
                     i++;
                  }
                  
                  
                  // Generate XML from workbook data
//                java.nio.file.Path tempFilePath = Files.createTempFile("SuckerCountReport", ".xml");
//                   ByteArrayOutputStream xmlOutputStream = new ByteArrayOutputStream();
//
//                   xmlOutputStream.write("<SuckerCountReport>".getBytes());
//                   for (int j = 1; j <= sheet.getLastRowNum(); j++) {
//                       SXSSFRow row = sheet.getRow(j);
//                       if (row != null) {
//                           String label = row.getCell(0).getStringCellValue();
//                           Cell countCell = row.getCell(1);
//                           String countStr = "";
//                           if (countCell.getCellType() == CellType.NUMERIC) {
//                               countStr = String.valueOf(countCell.getNumericCellValue());
//                           } else if (countCell.getCellType() == CellType.STRING) {
//                               countStr = countCell.getStringCellValue();
//                           }
//
////                            xmlOutputStream.write(
////                                ("<Record><Label>" + label + "</Label><Count>" + countStr + "</Count></Record>").getBytes()
////                            );
//                       }
//                   }
//                   xmlOutputStream.write("</SuckerCountReport>".getBytes());
//
//                   // Write XML to file
////                    Files.write(tempFile, xmlOutputStream.toByteArray());
//                // Write XML content to the temporary file
//                   try (FileOutputStream fileOutputStream = new FileOutputStream(((java.nio.file.Path) tempFilePath).toFile())) {
//                       fileOutputStream.write(xmlOutputStream.toByteArray());
//                   }
//
//                   // Dispose of workbook resources
//                   workbook.dispose();
//
//                   // Build response for file download
//                   ResponseBuilder response = Response.ok(((java.nio.file.Path) tempFilePath).toFile());
//                   response.header("Content-Disposition", "attachment; filename=SuckerCountReport.xml");
//                   response.header("Content-Type", "application/xml");
//                   return response.build();
                  workbook.write(byteArrayOutputStream);
                  System.out.println(byteArrayOutputStream.toByteArray());
                  workbook.close();
                  
//                if (excelBlobBytes == null || excelBlobBytes.length == 0) {
//                   return Response.status(Response.Status.NOT_FOUND).entity("File data not found").build();
//                }
//                return Response.ok(excelBlobBytes).type("file/xml").header("Content-Disposition", "inline; filename=\"report.xml\"")
//                      .build();
////                 response.setExcelBlob(excelBlobBytes);
////                 response.setIsError(false);
               } catch (Exception e) {
                  log.error("Error fetching data", e);
//                response.setError(e.getMessage());
//                response.setIsError(true);
               } finally {
                  trx.close();
                  getCompiereService().disconnect();
                  closeDbCon(pstm, rs);
               }
//             return resp;
               byte[] excelFileContent = byteArrayOutputStream.toByteArray();
//             return Response.ok(excelFileContent)
//                      .header("Content-Disposition", "attachment; filename=field_officer_report.xlsx")
//                      .header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
//                      .build();
               return Response.ok(excelFileContent).type("field_officer_report/xlsx")
                        .header("Content-Disposition", "inline; filename=\"field_officer_report.xlsx\"")
//                      .header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                        .build();
               
         }.
