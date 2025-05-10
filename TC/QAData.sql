     QA Data
     
     create a table for quality check and added discard reason
     
     CREATE TABLE adempiere.c_qualitycheck (
    	c_qualitycheck_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	discard_reason VARCHAR(255),
   	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar
    	c_operationaldetails_id NUMERIC(10,0),
    	FOREIGN KEY (c_operationaldetails_id) REFERENCES
     	adempiere.c_operationaldetails(c_operationaldetails_id));
     	
     	
     	
     	
     Medium Technician
     
     media table run in LT 
     this table is already use in LT and LA role 
     	
