---

## . The Fix — Ready to Run in pgAdmin

Run these **one at a time** (see note below on why) against the `rwpl_prod` database:

```sql
-- 1. Barcode/label scan lookup — the actual per-scan hot path (putAway, shipment, label resolution)
CREATE INDEX CONCURRENTLY idx_pi_productlabel_labeluuid
  ON adempiere.pi_productlabel (labeluuid);

-- 2. Order-line lookup — this is the one flooding the logs (MLookup "Too many records")
CREATE INDEX CONCURRENTLY idx_pi_productlabel_orderline
  ON adempiere.pi_productlabel (c_orderline_id);

-- 3. Product + active-flag lookup — confirmed hit with this exact filter combo
CREATE INDEX CONCURRENTLY idx_pi_productlabel_product_active
  ON adempiere.pi_productlabel (m_product_id)
  WHERE isactive = 'Y';
```

**Optional, same missing-FK-index pattern but not directly log-confirmed yet** — worth adding at the same time since they cost almost nothing on a 28 MB table:

```sql
CREATE INDEX CONCURRENTLY idx_pi_productlabel_locator
  ON adempiere.pi_productlabel (m_locator_id);

CREATE INDEX CONCURRENTLY idx_pi_productlabel_inoutline
  ON adempiere.pi_productlabel (m_inoutline_id);
```