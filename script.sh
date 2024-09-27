###############################################
# Solicitando o nome do aplicativo e o link do repositório Git ao usuário
read -p "Digite o nome do aplicativo: " PROJECT_NAME
read -p "Digite o link do repositório Git: " LINK_GIT
PASSWORD=$(openssl rand -base64 12)
###############################################

# Step 1 — Installing the Packages from the Ubuntu Repositories
sudo apt update
sudo apt install python3-venv python3-dev libpq-dev postgresql postgresql-contrib nginx curl git

# Step 2 — Creating the PostgreSQL Database and User
sudo -u postgres psql -c "CREATE DATABASE ${PROJECT_NAME}_db;"
sudo -u postgres psql -c "CREATE USER ${PROJECT_NAME}_user WITH PASSWORD '${PASSWORD}';"
sudo -u postgres psql -c "ALTER ROLE ${PROJECT_NAME}_user SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE ${PROJECT_NAME}_user SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE ${PROJECT_NAME}_user SET timezone TO 'UTC';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${PROJECT_NAME}_db TO ${PROJECT_NAME}_user;"

# Step 3 — Creating a Python Virtual Environment for your Project
mkdir -p ~/${PROJECT_NAME}
cd ~/${PROJECT_NAME}

python3 -m venv env_${PROJECT_NAME}
source env_${PROJECT_NAME}/bin/activate  # Ativando o ambiente virtual

pip install django gunicorn psycopg2-binary  # Instalando pacotes no ambiente virtual

# Step 4 — Cloning the Git Repository into the Project Directory
git clone ${LINK_GIT} temp_repo
mv temp_repo/* temp_repo/.* . 2>/dev/null || :
rm -rf temp_repo

# Step 5 — Displaying the Database, User, and Password
echo "=========================================="
echo "Nome do Aplicativo: ${PROJECT_NAME}"
echo "Database Name: ${PROJECT_NAME}_db"
echo "Database User: ${PROJECT_NAME}_user"
echo "Database Password: ${PASSWORD}"
echo "Repositório Git clonado de: ${LINK_GIT}"
echo "=========================================="

# Step 6 — Ensure the terminal is left inside the project directory
cd ~/${PROJECT_NAME}
exec $SHELL
