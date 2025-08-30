FROM node:16

WORKDIR /usr/src/app

COPY package*.json ./

# Use legacy-peer-deps if you're still on MUI v4
RUN npm install --legacy-peer-deps

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
