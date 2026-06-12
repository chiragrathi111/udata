Step 1: Compile and Stage the Plugins
Run the build script to compile the Java code and generate the deployment assets:

bash
pwsh /home/chirag/PiERP/pi-erp/pi-erp-plugins/build_plugins.ps1
Prompt 1: Select S for Specific plugin, then choose the number corresponding to com.pipra.dashboard.pipeline.
Prompt 2: Select P (Packin).
Step 2: Deploy to the Container
Run the deploy script to copy the compiled JAR into the container, update the OSGi configuration, and restart the application server:

bash
pwsh /home/chirag/PiERP/pi-erp/docker-image/image-builder/deploy_plugins.ps1
Prompt: Select A to deploy all staged plugins.
Once the script finishes restarting the server, log back into the app (https://localhost:8443/webui), and your widget should be visible on the home dashboard.