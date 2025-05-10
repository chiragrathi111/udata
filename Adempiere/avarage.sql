WITH 
    RootingDate AS (
        SELECT clr.c_uuid AS rootuuid, clr.parentuuid AS rootingparentuuid, clr.updated AS rooting_date 
        FROM adempiere.tc_culturelabel clr
    ),
    ElongationDate AS (
        SELECT cle.c_uuid AS elongationuuid, cle.parentuuid AS elongationparentuuid, cle.updated AS elongation_date 
        FROM adempiere.tc_culturelabel cle
        JOIN adempiere.tc_culturelabel cl ON cle.c_uuid = cl.parentuuid
    ),
    multi2Date AS (
        SELECT clm2.c_uuid AS multi2uuid, clm2.parentuuid AS multi2parentuuid, clm2.updated AS multi2_date 
        FROM adempiere.tc_culturelabel clm2
        JOIN adempiere.tc_culturelabel cl ON clm2.c_uuid = cl.parentuuid
    ),
    multi1Date AS (
        SELECT clm1.c_uuid AS multi1uuid, clm1.parentuuid AS multi1parentuuid, clm1.updated AS multi1_date 
        FROM adempiere.tc_culturelabel clm1
        JOIN adempiere.tc_culturelabel cl ON clm1.c_uuid = cl.parentuuid
    ),
    initial2cultureDate AS (
        SELECT cl2.c_uuid AS initial2cultureuuid, cl2.parentuuid AS ini2cultureparentuuid, cl2.updated AS ini2culture_date 
        FROM adempiere.tc_culturelabel cl2
        JOIN adempiere.tc_culturelabel cl ON cl2.c_uuid = cl.parentuuid
    ),
    initialcultureDates AS (
        SELECT cl.c_uuid AS initialcultureuuid, cl.parentuuid AS inicultureparentuuid, cl.updated AS iniculture_date 
        FROM adempiere.tc_culturelabel cl
        JOIN adempiere.tc_culturelabel cll ON cl.c_uuid = cll.parentuuid
    ),
    explantDates AS (
        SELECT el.c_uuid AS explantuuid, el.parentuuid AS parentuuid, el.updated AS explant_date 
        FROM adempiere.tc_explantlabel el
        JOIN adempiere.tc_culturelabel cl ON el.c_uuid = cl.parentuuid
    ),
    SuckerCollectionDates AS (
        SELECT pt.planttaguuid AS planttaguuid, sc.tc_plantdetails_id, sc.suckerNo, sc.updated AS sucker_collection_date 
        FROM adempiere.tc_collectionjoinplant sc
        JOIN adempiere.tc_plantdetails pt ON pt.tc_plantdetails_id = sc.tc_plantdetails_id
        JOIN adempiere.tc_explantlabel el ON el.parentuuid = pt.planttaguuid
    ) 
SELECT DISTINCT r.rootuuid,sc.planttaguuid,
    r.rooting_date,
    ed.elongation_date,
    m2.multi2_date,
    m1.multi1_date,
    i2.ini2culture_date,
    i1.iniculture_date,
    el.explant_date,
    sc.sucker_collection_date,
    ROUND(EXTRACT(EPOCH FROM (r.rooting_date - sc.sucker_collection_date)) / 86400.0) AS duration_days
FROM RootingDate r
JOIN ElongationDate ed ON ed.elongationuuid = r.rootingparentuuid    
JOIN multi2Date m2 ON m2.multi2uuid = ed.elongationparentuuid
JOIN multi1Date m1 ON m1.multi1uuid = m2.multi2parentuuid
JOIN initial2cultureDate i2 ON i2.initial2cultureuuid = m1.multi1parentuuid
JOIN initialcultureDates i1 ON i1.initialcultureuuid = i2.ini2cultureparentuuid   
JOIN explantDates el ON el.explantuuid = i1.inicultureparentuuid   
JOIN SuckerCollectionDates sc ON sc.planttaguuid = el.parentuuid;





==================================================================================================================================================
Working Avarage Query:-
WITH 
RootingDate AS (
    SELECT clr.c_uuid AS rootuuid, clr.parentuuid AS rootingparentuuid, clr.updated AS rooting_date 
    FROM adempiere.tc_culturelabel clr 
    WHERE clr.ad_client_id = 1000000
),
ElongationDate AS (
    SELECT cle.c_uuid AS elongationuuid, cle.parentuuid AS elongationparentuuid, cle.updated AS elongation_date 
    FROM adempiere.tc_culturelabel cle
    JOIN adempiere.tc_culturelabel cl ON cle.c_uuid = cl.parentuuid 
    WHERE cle.ad_client_id = 1000000
),
multi2Date AS (
    SELECT clm2.c_uuid AS multi2uuid, clm2.parentuuid AS multi2parentuuid, clm2.updated AS multi2_date 
    FROM adempiere.tc_culturelabel clm2
    JOIN adempiere.tc_culturelabel cl ON clm2.c_uuid = cl.parentuuid 
    WHERE clm2.ad_client_id = 1000000
),
multi1Date AS (
    SELECT clm1.c_uuid AS multi1uuid, clm1.parentuuid AS multi1parentuuid, clm1.updated AS multi1_date 
    FROM adempiere.tc_culturelabel clm1
    JOIN adempiere.tc_culturelabel cl ON clm1.c_uuid = cl.parentuuid 
    WHERE clm1.ad_client_id = 1000000
),
initial2cultureDate AS (
    SELECT cl2.c_uuid AS initial2cultureuuid, cl2.parentuuid AS ini2cultureparentuuid, cl2.updated AS ini2culture_date 
    FROM adempiere.tc_culturelabel cl2
    JOIN adempiere.tc_culturelabel cl ON cl2.c_uuid = cl.parentuuid 
    WHERE cl2.ad_client_id = 1000000
),
initialcultureDates AS (
    SELECT cl.c_uuid AS initialcultureuuid, cl.parentuuid AS inicultureparentuuid, cl.updated AS iniculture_date 
    FROM adempiere.tc_culturelabel cl
    JOIN adempiere.tc_culturelabel cll ON cl.c_uuid = cll.parentuuid 
    WHERE cl.ad_client_id = 1000000
),
explantDates AS (
    SELECT el.c_uuid AS explantuuid, el.parentuuid AS parentuuid, el.updated AS explant_date 
    FROM adempiere.tc_explantlabel el
    JOIN adempiere.tc_culturelabel cl ON el.c_uuid = cl.parentuuid 
    WHERE el.ad_client_id = 1000000
),
SuckerCollectionDates AS (
    SELECT pt.planttaguuid AS planttaguuid, sc.tc_plantdetails_id, sc.suckerNo, sc.updated AS sucker_collection_date 
    FROM adempiere.tc_collectionjoinplant sc 
    JOIN adempiere.tc_plantdetails pt ON pt.tc_plantdetails_id = sc.tc_plantdetails_id
    JOIN adempiere.tc_explantlabel el ON el.parentuuid = pt.planttaguuid 
    WHERE sc.ad_client_id = 1000000
)
SELECT DISTINCT r.rootuuid, sc.planttaguuid, r.rooting_date, ed.elongation_date, m2.multi2_date, 
    m1.multi1_date, i2.ini2culture_date, i1.iniculture_date, el.explant_date, sc.sucker_collection_date,
    ROUND(EXTRACT(EPOCH FROM (r.rooting_date - sc.sucker_collection_date)) / 86400.0) AS duration_days,
    ROUND(AVG(ROUND(EXTRACT(EPOCH FROM (r.rooting_date - sc.sucker_collection_date)) / 86400.0)) OVER ()) AS avg_duration_days
FROM RootingDate r
LEFT JOIN ElongationDate ed ON ed.elongationuuid = r.rootingparentuuid    
LEFT JOIN multi2Date m2 ON m2.multi2uuid = COALESCE(ed.elongationparentuuid, r.rootingparentuuid)
LEFT JOIN multi1Date m1 ON m1.multi1uuid = COALESCE(m2.multi2parentuuid, ed.elongationparentuuid, r.rootingparentuuid)
LEFT JOIN initial2cultureDate i2 ON i2.initial2cultureuuid = COALESCE(m1.multi1parentuuid, m2.multi2parentuuid, ed.elongationparentuuid, r.rootingparentuuid)
JOIN initialcultureDates i1 ON i1.initialcultureuuid = COALESCE(i2.ini2cultureparentuuid, m1.multi1parentuuid, m2.multi2parentuuid, r.rootingparentuuid)
JOIN explantDates el ON el.explantuuid = i1.inicultureparentuuid
JOIN SuckerCollectionDates sc ON sc.planttaguuid = el.parentuuid
LIMIT 1;




while joining the tables above 1 parentUUid is childid in 2 if no data availble in 2 for 1 parent id it should check 1parentid in 3 same for all