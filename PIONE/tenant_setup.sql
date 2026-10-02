PGHOST="127.0.0.1" PGPORT=5434 PGUSER=adempiere PGPASSWORD=adempiere \
python3 tools/create_tenant.py \
  --host "pierp.pipra.solutions" \
  --port "443" \
  --client "Deccan Heavy Engineering" \
  --org "HQ" \
  --warehouse "FG" \
  --admin "DHEAdmin" \
  --user "DHEUser" \
  --country "IN" \
  --currency "INR" \
  --address "Hyderabad"


==================================

PGHOST="127.0.0.1" PGPORT=5434 PGUSER=adempiere PGPASSWORD=adempiere \
python3 tools/create_tenant.py \
  --host "pione.pipra.solutions" \
  --port "443" \
  --client "Deccan Heavy Engineering" \
  --org "HQ" \
  --warehouse "FG" \
  --admin "DHEAdmin" \
  --user "DHEUser" \
  --country "IN" \
  --currency "INR" \
  --address "Hyderabad"

  pi-erp-plugins/com.pipra.warepro.corewebservices/migration/postgresql/sql-migrations/1.0.7/18_dhe_tenant_roles_locators.sql