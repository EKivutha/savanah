# savanah
savanah devops

## Nextjs WEB application
Use typscript 

npm install 
npm run dev 
npm run build

## Docker 
multistage build
Use the latested node lts to build the web application
Copy the build html and css files to a nginx container to maintain a small image size and fast web loading

## Docker-compose

Configured to allow deployment on AWS ECS

## CI/CD
Using codecommit jenkins intergration.
Jenkins pipline will deploy the aws resources by running terraform scripts,
Build a docker image and push to ECR,
and update the image in AWS ECS