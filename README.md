# Deploying a Python app to Azure as a container

1. Create `./Dockerfile`:
    ```dockerfile
    FROM python:3.9
    LABEL authors="your_username"
    WORKDIR /app
    COPY requirements.txt requirements.txt
    RUN pip install --no-cache-dir -r requirements.txt
    COPY . .
    EXPOSE 5000 # change for your specific app
    CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
    ```
2. Create Azure Container Repo
    ```shell
   az login
   az acr create --resource-group containers-for-days --name testflask20241126containerrepo --sku Basic
   az group create -l eastus --name containers-for-days
   az acr login -n testflask20241126containerrepo  
   az acr update -n testflask20241126containerrepo --admin-enabled true
    ```
3. Build and push docker image: 
    ```shell
    docker build . -t test-flask:1
    docker tag test-flask:1 testflask20241126containerrepo.azurecr.io/test-flask:latest
    docker push testflask20241126containerrepo.azurecr.io/test-flask:1
    ```
4. Push Docker image to the repo
    ```shell
    docker push testflask20241126containerrepo.azurecr.io/test-flask:1
    ```
5. Set up Linux App Service
    ```shell
    az appservice plan create --name ASP-containers-for-days --location eastus --resource-group containers-for-days --sku B1 --is-linux 
    ```
6. Set up WebApp
    ```shell
    az webapp create -g containers-for-days -n testappservice --plan testappserviceplan --deployment-container-image-name testflask20241126containerrepo.azurecr.io/test-flask:1
    az webapp config appsettings set -g containers-for-days -n test-flask-20241126 --settings WEBSITES_PORT=5000
    az webapp restart -g containers-for-days -n test-flask-20241126
    ```
   
7. Done!