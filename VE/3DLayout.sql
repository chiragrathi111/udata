WarePro :-

npm install -g pm2

cd repos/3DLayoutDemoInstance/

nohup npx serve . &

pm2 start "npx serve ." --name 3dlayout-rwpl

RWPL :-

cd WarePro/RWPL3DLayout/whgen/

nohup npx serve . &

Vinay Electricals :-

cd /home/ubuntu/Vinay 3DLayoutCR/Vinay 3DLayout/Vinay 3DLayout/whgen/

nohup npx serve . &

pm2 start "npx serve ." --name 3dlayout-vk