

Role - Lab Technicians And Lab Assistants



	Explant Label:-
	
	Crop Detils:-
	
		create three Explent table,two culture table :-
     		crop type table,
     		Varity (Check),
     		Nature of sample,
     		sub culture stage (culture table)
     		virus testing result(culture table)
     		
     		create a crop details table:-
     		crop type list,variety list,Parent culture line,Date,nature of sample,
     		culture stage,cycle number,virus testing result(culture field)
     		
     		create a operational details table:-
     		TCPF,Date,machine code(culture field),Personal code
     		
     		create a Media detils table(culture table)
     		
     		field media type
     		
     		
     	Growth Room:-
     		
     		storage details table:-
     		
     		small table Room Number
     		
     		Storage details table
     		list of room number,rack number,column number
     		
     	Hardening Label:-
     	
     		small table hardening cycle table
     		
     		hardening detail table
     		
     		list of hardening cycle,number of cultures processed	
     		
     		

 Crop Details tabel:-
	
	plant type and variety table already created
	
   nature of sample table
	
	CREATE TABLE adempiere.c_naturesample (
    	c_naturesample_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	name VARCHAR(25),
    	code_no VARCHAR(10),
   	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);
    	
   Culture mini tables
    	
    	CREATE TABLE adempiere.c_culturestage (
    	c_culturestage_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	name VARCHAR(25),
    	code_no VARCHAR(10),
   	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);
    	
    	CREATE TABLE adempiere.c_virustesting (
    	c_virustesting_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	name VARCHAR(25),
    	code_no VARCHAR(10),
   	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    	
   Cropdetils Tables:-
    	
    	CREATE TABLE adempiere.c_cropdetils (
    	c_cropdetils_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
	ad_client_id NUMERIC(10, 0) NOT NULL,
	ad_org_id NUMERIC(10, 0) NOT NULL,
   	created TIMESTAMP without time zone DEFAULT now() not null,
   	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
	parent_culture_line VARCHAR(255),
	date DATE,
	cycle_number NUMERIC(10,0),
	c_species_id NUMERIC(10,0),
	c_species_ids NUMERIC(10,0),
	c_naturesample_id NUMERIC(10,0),
	c_culturestage_id NUMERIC(10,0),
	c_virustesting_id NUMERIC(10,0),
	FOREIGN KEY (c_species_id) REFERENCES adempiere.c_species(c_species_id),
	FOREIGN KEY (c_species_ids) REFERENCES adempiere.c_species(c_species_id),
	FOREIGN KEY (c_naturesample_id) REFERENCES
	 adempiere.c_naturesample(c_naturesample_id),
	FOREIGN KEY (c_culturestage_id) REFERENCES
	 adempiere.c_culturestage(c_culturestage_id),
	FOREIGN KEY (c_virustesting_id) REFERENCES
	 adempiere.c_virustesting(c_virustesting_id)); 
	 
   Operational Tabel:-
	
	CREATE TABLE adempiere.c_operationaldetails (
    	c_operationaldetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	tcpf VARCHAR(25),
    	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar, 
    	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar, 
    	date DATE,
    	machine_code VARCHAR(25),
    	personal_code VARCHAR(25)
    	c_cropdetils_id NUMERIC(10,0),
    	FOREIGN KEY (c_cropdetils_id) REFERENCES
     	adempiere.c_cropdetils(c_cropdetils_id));
    	
    	
   Media Details tabel:-
    	
    	CREATE TABLE adempiere.c_mediadetails (
    	c_mediadetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	media_type VARCHAR(50),
    	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar)
    	c_cropdetils_id NUMERIC(10,0),
    	c_operationaldetails_id NUMERIC(10,0),
    	FOREIGN KEY (c_cropdetils_id) REFERENCES
     	adempiere.c_cropdetils(c_cropdetils_id),
    	FOREIGN KEY (c_operationaldetails_id) REFERENCES
     	adempiere.c_operationaldetails(c_operationaldetails_id));
     	
     	
    Growth Room Table:-
     	
     	mini table
     	
     	CREATE TABLE adempiere.c_roomnumber (
    	c_roomnumber_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	room_no NUMERIC(10, 0) NOT NULL,
   	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);
    	
    storage details:-
    	
    	CREATE TABLE adempiere.c_storagedetails (
    	c_storagedetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	rack_number VARCHAR(25) NOT NULL,
    	column_number VARCHAR(25) NOT NULL,
    	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	c_roomnumber_id NUMERIC(10,0),
    	FOREIGN KEY (c_roomnumber_id) REFERENCES
     	adempiere.c_roomnumber(c_roomnumber_id));
     	
     	
    Hardening Table:-
     	
     	mini table
     	
     	CREATE TABLE adempiere.c_cycle (
    	c_cycle_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	cycle_no VARCHAR(10),
   	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);
    	
    Hardeneing details:-
    	
    	CREATE TABLE adempiere.c_hardeningdetail (
    	c_hardeningdetail_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    	ad_client_id NUMERIC(10, 0) NOT NULL,
    	ad_org_id NUMERIC(10, 0) NOT NULL,
    	rack_number VARCHAR(25),
    	culture_processed_number VARCHAR(25),
    	created TIMESTAMP without time zone DEFAULT now() not null,
    	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    	c_cycle_id NUMERIC(10,0),
    	c_cropdetils_id NUMERIC(10,0),
    	c_operationaldetails_id NUMERIC(10,0),
    	FOREIGN KEY (c_cycle_id) REFERENCES
     	adempiere.c_cycle(c_cycle_id),
    	FOREIGN KEY (c_cropdetils_id) REFERENCES
     	adempiere.c_cropdetils(c_cropdetils_id),
    	FOREIGN KEY (c_operationaldetails_id) REFERENCES
     	adempiere.c_operationaldetails(c_operationaldetails_id)); 	
    
     			
