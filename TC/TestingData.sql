
                                 Tissue Culture
                                   
           
     User -                            
     Role - Field Officer 
     
     
     New Registration :- (BPartner)
     
     Create a new Table for Farmer Registration  
     like field name,address,survey no.,village,mobile no.
      
     Table Schema:-
    CREATE TABLE adempiere.c_farmer (
    c_farmer_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,  
    address VARCHAR(255),
    landmark VARCHAR(100),
    survey_number VARCHAR(10),
    village_name VARCHAR(50),
    mobile_no NUMERIC(10));

     
     
     Manage Visiter :-   
     
     	list of all visit
     
     First Visit:- (Purchase Order)
     
    	
     
     	create a new visit Field table above table 
     
     		 create a new small table 
    	 	 field selection,
    		 soil type,
    		 watering type,
    		 field managment 
     		
     	create a new plant details table (added status)                     
     		create a small table
     		plant species table, mini
     			Varity (Check)
     
     
     Intermediate Vist:- (Material Receipt)
     
     	created small table using value (Accepted,Rejected,Need of Monitor)
     
    	 First visiter details also come like Field details,Plant details
     
     Collection Visit:- (Invoice)
     
    	 create a new table 
     
     First Visit >> Intermediate Vist >> Collection Visit 
     
 First Visit:-
     
     Field Selection Table:-
     
    CREATE TABLE adempiere.c_fieldselection (
    c_fieldselection_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    ceatedby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar);
    
    Soil Type Table:-
 
    CREATE TABLE adempiere.c_soiltype (
    c_soiltype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    Watering Type Table:-   
     
    CREATE TABLE adempiere.c_wateringtype (
    c_wateringtype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    Field Management Table:-
    
    CREATE TABLE adempiere.c_fieldmanagement (
    c_fieldmanagement_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    Visit Type Table:-
    
    CREATE TABLE adempiere.c_visittype (
    c_visittype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    visit detils table:-
    
    CREATE TABLE adempiere.c_visit (
    c_visit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    name VARCHAR(25) NOT NULL,
    mobile_no NUMERIC(10,0),
    date DATE,
    c_farmer_id NUMERIC(10,0),
    c_visittype_id NUMERIC(10,0),
    FOREIGN KEY (c_visittype_id) REFERENCES adempiere.c_visittype(c_visittype_id),
    FOREIGN KEY (c_farmer_id) REFERENCES adempiere.c_farmer(c_farmer_id)
    ); 
    
    
    First Visit Table:-
    
	CREATE TABLE adempiere.c_firstvisit (
    	c_firstvisit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
	ad_client_id NUMERIC(10, 0) NOT NULL,
	ad_org_id NUMERIC(10, 0) NOT NULL,
   	created TIMESTAMP without time zone DEFAULT now() not null,
   	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
   	plant_no NUMERIC(10, 0) NOT NULL,
    	visit_date DATE,
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
	pest_history VARCHAR(255),
	next_visit_date DATE,
	c_visit_id NUMERIC(10,0),
	c_farmer_id NUMERIC(10,0),
	c_fieldselection_id NUMERIC(10,0),
	c_soiltype_id NUMERIC(10,0),
	c_wateringtype_id NUMERIC(10,0),
	c_fieldmanagement_id NUMERIC(10,0),
	FOREIGN KEY (c_visit_id) REFERENCES adempiere.c_visit(c_visit_id),
	FOREIGN KEY (c_farmer_id) REFERENCES adempiere.c_farmer(c_farmer_id),
	FOREIGN KEY (c_fieldselection_id) REFERENCES
	 adempiere.c_fieldselection(c_fieldselection_id),
	FOREIGN KEY (c_soiltype_id) REFERENCES adempiere.c_soiltype(c_soiltype_id),
	FOREIGN KEY (c_wateringtype_id) REFERENCES
	 adempiere.c_wateringtype(c_wateringtype_id),
	FOREIGN KEY (c_fieldmanagement_id) REFERENCES
	 adempiere.c_fieldmanagement(c_fieldmanagement_id)); 

 Plant Details Table:-
     
    Plant Variety Table:-
    
    CREATE TABLE adempiere.c_variety (
    c_variety_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,
    code_no VARCHAR(10) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault character(1) NOT NULL DEFAULT 'N'::bpchar);
    
     	 
    Plant Species Table:-
    
    CREATE TABLE adempiere.c_plantspecies (
    c_plantspecies_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    code_no VARCHAR(10) NOT NULL,
    name VARCHAR(30) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    c_variety_id NUMERIC(10,0),
    FOREIGN KEY (c_variety_id) REFERENCES
     adempiere.c_variety(c_variety_id));
     
    Plant Details Table:-
    
    CREATE TABLE adempiere.c_plantdetails (
    c_plantdetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    code_no VARCHAR(10) not null,
    date DATE,
    tag_number VARCHAR(10),
    disease_name VARCHAR(25),
    medicine_details VARCHAR(255),
    description VARCHAR(255),
    height VARCHAR(10),
    stature VARCHAR(10),
    leaves_no NUMERIC(10,0),
    bunce_weight VARCHAR(10),
    weight VARCHAR(10),
    bunches_no VARCHAR(10),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault character(1) NOT NULL DEFAULT 'N'::bpchar,
    c_species_id NUMERIC(10,0),
    c_species_ids NUMERIC(10,0),
    c_farmer_id NUMERIC(10,0),
    FOREIGN KEY (c_species_id) REFERENCES adempiere.c_species(c_species_id),
    FOREIGN KEY (c_species_ids) REFERENCES
    adempiere.c_species(c_species_id),
    FOREIGN KEY (c_fieldmanagement_id) REFERENCES
	 adempiere.c_fieldmanagement(c_fieldmanagement_id)); 
	 
	 
 Intermediate Visit:-
 
    Decision Table:-	 	           
     
    CREATE TABLE adempiere.c_decision (
    c_decesion_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    reason VARCHAR(25),
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar); 
    
    
    Intermediate Visit Table:-
    
	CREATE TABLE adempiere.c_intermediatevisit (
    	c_intermediatevisit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
	ad_client_id NUMERIC(10, 0) NOT NULL,
	ad_org_id NUMERIC(10, 0) NOT NULL,
   	created TIMESTAMP without time zone DEFAULT now() not null,
   	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
	review_details VARCHAR(255),
	reason_details VARCHAR(255),
	next_visit_date DATE,
	c_visit_id NUMERIC(10,0),
	c_farmer_id NUMERIC(10,0),
	c_decesion_id NUMERIC(10,0),
	c_firstvisit_id NUMERIC(10,0),
	FOREIGN KEY (c_visit_id) REFERENCES adempiere.c_visit(c_visit_id),
	FOREIGN KEY (c_farmer_id) REFERENCES adempiere.c_farmer(c_farmer_id),
	FOREIGN KEY (c_firstvisit_id) REFERENCES
	 adempiere.c_firstvisit(c_firstvisit_id),
	FOREIGN KEY (c_decesion_id) REFERENCES
	 adempiere.c_decesion(c_decesion_id));
	 
     Collection Details Table:-
     
     CREATE TABLE adempiere.c_intermediatevisit (
    	c_intermediatevisit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
	ad_client_id NUMERIC(10, 0) NOT NULL,
	ad_org_id NUMERIC(10, 0) NOT NULL,
   	created TIMESTAMP without time zone DEFAULT now() not null,
   	createdby NUMERIC(10,0) not null,
    	updated TIMESTAMP without time zone DEFAULT now() not null,
    	updatedby NUMERIC(10,0) not null,
    	yield_weight VARCHAR(255),
    	no_of_suckers NUMERIC(10,0),
    	description VARCHAR(255),
    	isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
	isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
	c_visit_id NUMERIC(10,0),
	c_farmer_id NUMERIC(10,0),
	c_intermediatevisit_id NUMERIC(10,0),
	c_firstvisit_id NUMERIC(10,0),
	FOREIGN KEY (c_visit_id) REFERENCES adempiere.c_visit(c_visit_id),
	FOREIGN KEY (c_farmer_id) REFERENCES adempiere.c_farmer(c_farmer_id),
	FOREIGN KEY (c_firstvisit_id) REFERENCES
	 adempiere.c_firstvisit(c_firstvisit_id),
	FOREIGN KEY (c_intermediatevisit_id) REFERENCES
	 adempiere.c_intermediatevisit(c_intermediatevisit_id));
     
     	 

     
