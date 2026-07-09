Create Index for the product label

CREATE INDEX CONCURRENTLY idx_ppl_locator
ON pi_productlabel(m_locator_id);

CREATE INDEX CONCURRENTLY idx_ppl_labeluuid
ON pi_productlabel(labeluuid);

CREATE INDEX CONCURRENTLY idx_ppl_active
ON pi_productlabel(isactive);

CREATE INDEX CONCURRENTLY idx_ppl_sotrx
ON pi_productlabel(issotrx);

CREATE INDEX CONCURRENTLY idx_ppl_orderline
ON pi_productlabel(c_orderline_id);


=======================================================================================
If we delete any record in postgresql or update any record on postgres so data not deleted, data store dead tunnal, so if any case our application very slow 
then run below commands for the specific table:-

SELECT
    relname,
    n_live_tup,
    n_dead_tup
FROM pg_stat_user_tables
WHERE relname='pi_productlabel';

like this time shoiwng pi_productlabel table dead record

result:-

"pi_productlabel"	83196	3715

so if we want to clean up this 3715 dead records in postgresql so run the below commands

VACUUM ANALYZE pi_productlabel;

data is clean up. 
