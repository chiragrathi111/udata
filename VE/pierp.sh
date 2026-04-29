Step 1 — Set up environment:

bash
cd /home/chirag/PiERP/pi-erp/core/build-run-push/linux
source setup_env.sh

Step 2 — Build the server 

bash
cd build_first_run_reset
chmod +x PiERP_Build.sh
./PiERP_Build.sh

Step 3 — First-time DB import + config 

bash
# Create DB user first (your system PostgreSQL needs this):
sudo -u postgres psql -c "CREATE USER adempiere WITH PASSWORD 'adempiere' CREATEDB;"
sudo -u postgres psql -c "CREATE DATABASE idempiere OWNER adempiere;"
# Then run setup:
chmod +x PiERP_First_Run.sh
./PiERP_First_Run.sh
# → Type Y when it asks to import the database

Step 4 — Daily start (every day after first-time setup):

bash
cd /home/chirag/PiERP/pi-erp/core/build-run-push/linux
./PiERP_Local_Run.sh

Step 5 — Stop:

bash
./PiERP_Local_Stop.sh