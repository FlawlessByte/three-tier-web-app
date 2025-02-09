# Use the official Node.js image as the build stage
FROM node:22.13.1-alpine AS build

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json files to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Build the application (optional, for example, if using a transpiler like TypeScript)
# RUN npm run build

# Use a lightweight image for the runtime stage
FROM node:22.13.1-alpine AS runtime

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy only the necessary files from the build stage
COPY --from=build /usr/src/app /usr/src/app

# Install only production dependencies
RUN npm prune --production

# Expose the application port
EXPOSE 3000

# Define the command to run the application
CMD ["npm", "start"]
