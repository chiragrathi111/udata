ALTER TABLE adempiere.pi_productlabel ADD COLUMN ismanufacturing CHAR(1) NOT NULL DEFAULT 'N'::bpchar;

ALTER TABLE adempiere.pi_productlabel ADD COLUMN pp_order_id INTEGER;

ALTER TABLE adempiere.pi_productlabel
ADD CONSTRAINT pi_productlabel_pp_order_id_fkey
FOREIGN KEY (pp_order_id)
REFERENCES adempiere.pp_order(pp_order_id);