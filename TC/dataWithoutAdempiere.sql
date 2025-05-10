CREATE TABLE tc_farmer (
    tc_farmer_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
	
	CREATE TABLE tc_fieldselection (
    tc_fieldselection_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
	
	CREATE TABLE tc_soiltype (
    tc_soiltype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
	
	CREATE TABLE tc_wateringtype (
    tc_wateringtype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
	
	CREATE TABLE tc_fieldmanagement (
    tc_fieldmanagement_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
	
	CREATE TABLE tc_visittype (
    tc_visittype_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
	
	CREATE TABLE tc_visit (
    tc_visit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
    tc_farmer_id NUMERIC(10,0),
    tc_visittype_id NUMERIC(10,0),
    FOREIGN KEY (tc_visittype_id) REFERENCES tc_visittype(tc_visittype_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES tc_farmer(tc_farmer_id));
	
	CREATE TABLE tc_firstvisit (
    tc_firstvisit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
    tc_visit_id NUMERIC(10,0),
    tc_farmer_id NUMERIC(10,0),
    tc_fieldselection_id NUMERIC(10,0),
    tc_soiltype_id NUMERIC(10,0),
    tc_wateringtype_id NUMERIC(10,0),
    tc_fieldmanagement_id NUMERIC(10,0),
    FOREIGN KEY (tc_visit_id) REFERENCES tc_visit(tc_visit_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES tc_farmer(tc_farmer_id),
    FOREIGN KEY (tc_fieldselection_id) REFERENCES
     tc_fieldselection(tc_fieldselection_id),
    FOREIGN KEY (tc_soiltype_id) REFERENCES tc_soiltype(tc_soiltype_id),
    FOREIGN KEY (tc_wateringtype_id) REFERENCES
     tc_wateringtype(tc_wateringtype_id),
    FOREIGN KEY (tc_fieldmanagement_id) REFERENCES
     tc_fieldmanagement(tc_fieldmanagement_id)); 
	 
	 CREATE TABLE tc_variety (
    tc_variety_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
	
	CREATE TABLE tc_plantspecies (
    tc_plantspecies_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    code_no VARCHAR(10) NOT NULL,
    name VARCHAR(30) NOT NULL,
    varity_code_no VARCHAR(10) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
    tc_variety_id NUMERIC(10,0),
    FOREIGN KEY (tc_variety_id) REFERENCES
     tc_variety(tc_variety_id));
	 
	CREATE TABLE tc_plantdetails (
    tc_plantdetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
    tc_species_id NUMERIC(10,0),
    tc_species_ids NUMERIC(10,0),
    tc_farmer_id NUMERIC(10,0),
    FOREIGN KEY (tc_species_id) REFERENCES tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_species_ids) REFERENCES
    tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES
     tc_farmer(tc_farmer_id)); 
	 
	 CREATE TABLE tc_decesion (
    tc_decesion_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
    
	CREATE TABLE tc_intermediatevisit (
    tc_intermediatevisit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
    tc_visit_id NUMERIC(10,0),
    tc_farmer_id NUMERIC(10,0),
    tc_decesion_id NUMERIC(10,0),
    tc_firstvisit_id NUMERIC(10,0),
    FOREIGN KEY (tc_visit_id) REFERENCES tc_visit(tc_visit_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES tc_farmer(tc_farmer_id),
    FOREIGN KEY (tc_firstvisit_id) REFERENCES
     tc_firstvisit(tc_firstvisit_id),
    FOREIGN KEY (tc_decesion_id) REFERENCES
     tc_decesion(tc_decesion_id));
	 
	 CREATE TABLE tc_intermediatevisit (
    tc_intermediatevisit_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
    tc_visit_id NUMERIC(10,0),
    tc_farmer_id NUMERIC(10,0),
    tc_decesion_id NUMERIC(10,0),
    tc_firstvisit_id NUMERIC(10,0),
    FOREIGN KEY (tc_visit_id) REFERENCES tc_visit(tc_visit_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES tc_farmer(tc_farmer_id),
    FOREIGN KEY (tc_firstvisit_id) REFERENCES
     tc_firstvisit(tc_firstvisit_id),
    FOREIGN KEY (tc_decesion_id) REFERENCES
     tc_decesion(tc_decesion_id));
	 
	 CREATE TABLE tc_collectiondetails (
    tc_collectiondetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
    tc_visit_id NUMERIC(10,0),
    tc_farmer_id NUMERIC(10,0),
    tc_intermediatevisit_id NUMERIC(10,0),
    tc_firstvisit_id NUMERIC(10,0),
    FOREIGN KEY (tc_visit_id) REFERENCES tc_visit(tc_visit_id),
    FOREIGN KEY (tc_farmer_id) REFERENCES tc_farmer(tc_farmer_id),
    FOREIGN KEY (tc_firstvisit_id) REFERENCES
     tc_firstvisit(tc_firstvisit_id),
    FOREIGN KEY (tc_intermediatevisit_id) REFERENCES
     tc_intermediatevisit(tc_intermediatevisit_id));
	 
	 CREATE TABLE tc_naturesample (
    tc_naturesample_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
	
	CREATE TABLE tc_culturestage (
    tc_culturestage_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
	
	CREATE TABLE tc_virustesting (
        tc_virustesting_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
		
	CREATE TABLE tc_cropdetils (
    tc_cropdetils_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
    tc_species_id NUMERIC(10,0),
    tc_species_ids NUMERIC(10,0),
    tc_naturesample_id NUMERIC(10,0),
    tc_culturestage_id NUMERIC(10,0),
    tc_virustesting_id NUMERIC(10,0),
    FOREIGN KEY (tc_species_id) REFERENCES tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_species_ids) REFERENCES tc_plantspecies(tc_plantspecies_id),
    FOREIGN KEY (tc_naturesample_id) REFERENCES
     tc_naturesample(tc_naturesample_id),
    FOREIGN KEY (tc_culturestage_id) REFERENCES
     tc_culturestage(tc_culturestage_id),
    FOREIGN KEY (tc_virustesting_id) REFERENCES
     tc_virustesting(tc_virustesting_id));
	 
	 CREATE TABLE tc_operationaldetails (
        tc_operationaldetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
        personal_code VARCHAR(25),
        tc_cropdetils_id NUMERIC(10,0),
        FOREIGN KEY (tc_cropdetils_id) REFERENCES
        tc_cropdetils(tc_cropdetils_id));
		
		CREATE TABLE tc_mediadetails (
        tc_mediadetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        media_type VARCHAR(50),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
        tc_cropdetils_id NUMERIC(10,0),
        tc_operationaldetails_id NUMERIC(10,0),
        FOREIGN KEY (tc_cropdetils_id) REFERENCES
        tc_cropdetils(tc_cropdetils_id),
        FOREIGN KEY (tc_operationaldetails_id) REFERENCES
        tc_operationaldetails(tc_operationaldetails_id));
        
		
		CREATE TABLE tc_roomnumber (
        tc_roomnumber_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
		
		CREATE TABLE tc_storagedetails (
        tc_storagedetails_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
        isdefault CHAR(1) not null DEFAULT 'N'::bpchar,
        tc_roomnumber_id NUMERIC(10,0),
        FOREIGN KEY (tc_roomnumber_id) REFERENCES
        tc_roomnumber(tc_roomnumber_id));
		
		CREATE TABLE tc_cycle (
        tc_cycle_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
		
		CREATE TABLE tc_hardeningdetail (
        tc_hardeningdetail_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
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
        isdefault CHAR(1) not null DEFAULT 'N'::bpchar,
        tc_cycle_id NUMERIC(10,0),
        tc_cropdetils_id NUMERIC(10,0),
        tc_operationaldetails_id NUMERIC(10,0),
        FOREIGN KEY (tc_cycle_id) REFERENCES
        tc_cycle(tc_cycle_id),
        FOREIGN KEY (tc_cropdetils_id) REFERENCES
        tc_cropdetils(tc_cropdetils_id),
        FOREIGN KEY (tc_operationaldetails_id) REFERENCES
        tc_operationaldetails(tc_operationaldetails_id));
		
		CREATE TABLE tc_qualitycheck (
        tc_qualitycheck_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        discard_reason VARCHAR(255),
        created TIMESTAMP without time zone DEFAULT now() not null,
        createdby NUMERIC(10,0) not null,
        updated TIMESTAMP without time zone DEFAULT now() not null,
        updatedby NUMERIC(10,0) not null,
        description VARCHAR(255),
        isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
        tc_operationaldetails_id NUMERIC(10,0),
        FOREIGN KEY (tc_operationaldetails_id) REFERENCES
        tc_operationaldetails(tc_operationaldetails_id));

	
