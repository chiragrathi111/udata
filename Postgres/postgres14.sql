# Step 1: Install required packages
sudo apt install -y curl ca-certificates

# Step 2: Add PostgreSQL official repository
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
    --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc

# Step 3: Add the repository to sources
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] \
    https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list'

# Step 4: Update package list
sudo apt update

# Step 5: Install PostgreSQL 14 specifically
sudo apt install -y postgresql-14

# Step 6: Verify installation
psql --version
# Should show: psql (PostgreSQL) 14.x