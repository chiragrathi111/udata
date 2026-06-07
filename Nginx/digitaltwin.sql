rename dist folder as layout folder
zip layout folder as layout.zip

upload to server

	scp -i democ.pem /home/anudeep/layout.zip ubuntu@3.7.97.129:/home/ubuntu

unzip and move to deployment folder

	unzip layout.zip

	rm layout.zip

	sudo rm -rf /var/www/html/layout/

	sudo cp -r /home/ubuntu/layout/ /var/www/html/layout

	rm -rf layout/


--------------------------------------------------------------
vite.config.ts

Exact place to add — just add base: '/layout/', here:
typescriptimport path from 'path';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, '.', '');
    return {
      base: '/layout/',        // ← ADD THIS LINE HERE
      server: {
        port: 3000,
        host: '0.0.0.0',
      },
      plugins: [react()],
      define: {
        'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY)
      },
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '.'),
        }
      }
    };
});


Fix — Open your index.html and change this one line:
Find:
html<link rel="stylesheet" href="/index.css">
Change to:
html<link rel="stylesheet" href="/layout/index.css">


# 1. Clean old build
rm -rf dist layout layout.zip

# 2. Rebuild
npm run build

# 3. Verify — both paths should now have /layout/
cat dist/index.html | grep -E "src=|href="

# 4. Rename + zip
mv dist layout
zip -r layout.zip layout

# 5. Upload
scp -i democ.pem layout.zip ubuntu@3.7.97.129:/home/ubuntu

# 6. Deploy on server
ssh -i democ.pem ubuntu@3.7.97.129
unzip layout.zip
rm layout.zip
sudo rm -rf /var/www/html/layout/
sudo cp -r /home/ubuntu/layout/ /var/www/html/layout/
rm -rf layout/
-----------------------------------------------------------------------------------------