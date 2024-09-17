# ref: https://claude.ai/chat/e73cd979-7e30-4822-88a8-db79924b871c

# 1. Make sure you have Node.js 16.10 or later installed
node --version

# 2. Enable Corepack
corepack enable

# 3. Install or update to the latest Yarn version
corepack prepare yarn@stable --activate

# 4. Verify the installation
yarn --version

# 5. Set Yarn 4 as the default for your project
yarn init -2

# 6. Configure Yarn to use Node.js packages by default
yarn config set nodeLinker node-modules

# 7. Install dependencies (if you have a package.json file)
yarn install

# 8. (Optional) Set Yarn 4 as the default globally
yarn config set --home defaultYarnVersion stable
