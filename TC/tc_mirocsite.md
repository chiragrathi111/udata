Microsite (Angular Universal SSR) — Deployment Notes

Deployment sequence for an Angular Universal SSR app (microsite): check config → build client + server bundles → start the Node SSR server with PM2.

1. Check the project & environment config
bash
cd salecode           # Go into the project folder
ls                     # List files to see what's inside (package.json, src/, etc.)

cd src/environments/   # Angular apps keep environment-specific config here
ls                      # Should show environment.ts and environment.prod.ts

less environment.prod.ts   # View the PRODUCTION config (used when you build with --configuration production)
less environment.ts        # View the DEFAULT/DEV config (used in local `ng serve`)

Both files currently contain:

ts
export const environment = {
  production: true,  // or false in the dev file
  apiurl: 'https://tc.warepro.in/tcapi/',   // Backend API this frontend talks to
  validateLabel: 'gettracedataforqr'         // API endpoint/label used in the app
};

⚠️ Note: Both dev and prod point to the same live API (tc.warepro.in). No separate staging/dev backend is configured.

2. Set Node version
bash
nvm use 14
# Switch Node.js version to v14 using nvm (Node Version Manager).
# Angular Universal / older Angular CLI versions often need a specific Node version —
# newer Node can break older SSR builds.
3. Build the SSR bundles
bash
ng run microsite:server:production
# Runs the "server" builder target named "production" for project "microsite"
# (defined in angular.json). Compiles the SSR (server-side) bundle —
# produces main.js, the Node.js Express server that renders the Angular app.

ng build --configuration production && ng run microsite:server:production
# ng build --configuration production  → builds the CLIENT (browser) bundle in production mode
# &&                                    → only runs next command if the build succeeds
# ng run microsite:server:production   → builds/rebuilds the SERVER bundle too
# Together: builds BOTH client + server bundles for a full SSR production build.
4. Start the server with PM2
bash
cd dist/microsite/server   # Go into the compiled output folder — this is where main.js (the SSR server) lives
nvm use 14                  # (repeated) ensure Node 14 is active in this shell too

pm2 start dist/microsite/server/main.js
# PM2 = a process manager for Node.js apps (keeps apps running in background,
# auto-restarts on crash, handles logs, can run on server reboot).
# Starts the Angular Universal SSR server as a managed background process
# instead of running `node main.js` directly (which dies when the terminal closes).
Overall Purpose

This is the deployment sequence for an Angular Universal SSR app: check config → build client + server bundles for production → start the Node SSR server persistently with PM2 so it survives terminal closes/crashes and can serve server-rendered pages (better SEO, faster first paint) instead of a plain client-side Angular app.

Suggestions
Avoid repeating nvm use 14 every shell session — set it as default:
bash
   nvm alias default 14
Name the PM2 process for easier management:
bash
   pm2 start dist/microsite/server/main.js --name microsite
   pm2 save              # persist process list
   pm2 startup           # generate command to auto-start pm2 on server reboot
Check package.json for a combined build script (e.g. "build:ssr") instead of running ng build + ng run ... server manually each time:
bash
   npm run build:ssr
Environment file concern: dev and prod both hit the live API (tc.warepro.in). If a separate dev/staging backend is ever needed, uncomment/edit the commented lines (selfcare.realmeds.io, login creds, etc.) in environment.ts.
Node 14 is EOL (end of life) — if this project is actively maintained, consider checking Angular CLI compatibility with Node 18/20 for security patches, unless there's a hard dependency forcing Node 14.