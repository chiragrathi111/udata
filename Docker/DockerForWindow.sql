Steps to Install Docker and Docker Compose on Windows using CMD/PowerShell

1. Install Docker Desktop
	1. Open CMD or PowerShell as an administrator.

	2. Download the Docker Desktop installer via the command	
		Invoke-WebRequest -Uri https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe -OutFile DockerDesktopInstaller.exe
	
	3. Run the installer
	
		Start-Process -Wait -FilePath .\DockerDesktopInstaller.exe

		after run this command new pop-up window open press ok then docker installing inside

		after restart check 
		docker --version

	4. Follow the installation wizard. Ensure
		WSL 2 is selected as the backend.

		The system restarts if prompted.	

2. Enable WSL 2 (if not already enabled)
	Run the following commands to enable and set WSL 2 as the default version:

	1. Enable WSL:
		dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

	2. Enable Virtual Machine Platform:
		dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

	3. Set WSL 2 as the default version:
		wsl --set-default-version 2

	4. Install a Linux Distro for WSL (e.g., Ubuntu):
		wsl --install -d Ubuntu

3. Verify Docker Installation		
	
	1. Open a new CMD/PowerShell window.

	2. Run the following command to check Docker version:
		docker --version
		docker-compose --version


Optional: Install Standalone Docker Compose:-
	If you need the standalone Docker Compose binary:

	1. Download Docker Compose:
		Invoke-WebRequest "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -OutFile "docker-compose.exe"

	2. Move it to a directory in your system's PATH, such as
		Move-Item -Path ".\docker-compose.exe" -Destination "C:\Program Files\Docker\Docker\resources\bin\docker-compose.exe"

	3. Verify the installation
		docker-compose --version


4. Run Docker Commands

	Once Docker is installed:

	Open Docker Desktop and ensure it is running.
	Run Docker commands in CMD or PowerShell, for example		


5. Prepare Your Docker Setup			
	a. Create a Project Directory
	Navigate to your working directory or create a new one:
		mkdir C:\docker_idempiere
		cd C:\docker_idempiere

	b. Create a .env File
	Create an .env file with the required variables:
	  1. Open a text editor like Notepad or VS Code.
	  2. Add the following content:

IDEMPIERE_DB_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
IDEMPIERE_DB_NAME=idempiere
POSTGRES_HOST_AUTH_METHOD=trust
PG_VERSION=14
IDEMPIERE_WEB_PORT=8443
IDEMPIERE_USER=adempiere
IDEMPIERE_DB_PASSWORD=adempiere
IDEMPIERE_VERSION=10

	  3. Save the file as .env in the C:\docker_idempiere directory.

	c. Add docker-compose.yml File 
	  1. Create a docker-compose.yml file in the same directory (C:\docker_idempiere).

	  2. Add the following content

services:
  idempiere:
    image: idempiereofficial/idempiere:${IDEMPIERE_VERSION}
    container_name: idempiere
    ports:
      - "${IDEMPIERE_WEB_PORT}:8443"
    networks:
      - app-network
    depends_on:
      - db
    environment:
      IDEMPIERE_DB_HOST: db
      IDEMPIERE_DB_PORT: ${IDEMPIERE_DB_PORT}
      IDEMPIERE_DB_NAME: ${IDEMPIERE_DB_NAME}
      IDEMPIERE_DB_USER: ${IDEMPIERE_USER}
      IDEMPIERE_DB_PASSWORD: ${IDEMPIERE_DB_PASSWORD}
    volumes:
      - idempiere_config:/opt/idempiere/configuration
      - idempiere_plugins:/opt/idempiere/plugins

  db:
    image: postgres:${PG_VERSION}
    container_name: postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${IDEMPIERE_DB_NAME}
      POSTGRES_HOST_AUTH_METHOD: ${POSTGRES_HOST_AUTH_METHOD}
    ports:
      - "${IDEMPIERE_DB_PORT}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  postgres_data:
  idempiere_plugins:
  idempiere_config:

networks:
  app-network:
    driver: bridge


4. Start Docker Containers

  1. Open CMD or PowerShell and navigate to the project directory:
  		cd C:\docker_idempiere

  		Rename-Item ".env.txt" -NewName ".env"


  2. Start the Docker containers using the following command:
  		docker-compose up -d

  3. Check the status of the containers:
		docker ps
		

			
    	  



	
		
	

