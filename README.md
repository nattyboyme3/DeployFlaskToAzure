# Deploying a Flask app to Azure as a container
1. Create `./app.py`:
   ```python
   from flask import Flask,request
   app = Flask(__name__)
   
   
   @app.route('/')
   def hello_world():  # put application's code here
       micah = request.args.get('micah')
       if micah:
           return "Hello Micah!"
       return 'Hello World!'
   if __name__ == '__main__':
       app.run()
   ```
1. Create `./Dockerfile`:
    ```dockerfile
    FROM --platform=linux/amd64 python:3.9-slim-buster as test-flask
    LABEL authors="your_username"
    WORKDIR /app
    COPY requirements.txt requirements.txt
    RUN pip install --no-cache-dir -r requirements.txt
    COPY . .
    # change for your specific app
    EXPOSE 5000
    CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
    ```
2. Log in to azure CLI with: 
   ```shell
   az login
   ```
2. Create Azure Container Repo
    ```shell
   az group create -l eastus --name containers-for-days
   az acr create --resource-group containers-for-days --name testflask20241126containerrepo --sku Basic
   az acr login -n testflask20241126containerrepo  
   az acr update -n testflask20241126containerrepo --admin-enabled true
    ```
3. Build and push docker image: 
    ```shell
    docker build . -t test-flask:latest
    docker tag test-flask:latest testflask20241126containerrepo.azurecr.io/test-flask:latest
    docker push testflask20241126containerrepo.azurecr.io/test-flask:latest
    ```
4. Test locally with: 
   ```shell
   docker run -p 8501:8501 test-flask:latest
   ```
5. Set up Linux App Service
    ```shell
    az appservice plan create --name ASP-containers-for-days --location eastus --resource-group containers-for-days --sku B1 --is-linux 
    ```
6. Set up WebApp (use the port your application listens on instead of 5000)
    ```shell
    az webapp create -g containers-for-days -n test-flask-20241126 --plan ASP-containers-for-days --deployment-container-image-name testflask20241126containerrepo.azurecr.io/test-flask:latest
    az webapp config appsettings set -g containers-for-days -n test-flask-20241126 --settings WEBSITES_PORT=5000
    az webapp restart -g containers-for-days -n test-flask-20241126
    ```
7. Done!

# Deploying a Streamlit app to Azure as a container
1. Create `./mystreamlitapp.py`:
   ```python
   import streamlit as st
   st.write("""
   # My first app
   This is a test for Micah.
   """)
   ```
1. Create `./Dockerfile-Streamlit`:
    ```dockerfile
    FROM --platform=linux/amd64 python:3.9-slim-buster  as test-streamlit-build
   LABEL authors="nbiggs112"
   
   WORKDIR /app
   
   COPY streamlit-requirements.txt requirements.txt
   RUN pip install --no-cache-dir -r requirements.txt
   
   COPY mystreamlitapp.py app.py
   
   EXPOSE 8501
   
   CMD [ "python3", "-m" , "streamlit", "run", "app.py"]
    ```
2. Log in to azure CLI with: 
   ```shell
   az login
   ```
1. Create Azure Container Repo
    ```shell
   az login   
   az group create -l eastus --name containers-for-days
   az acr create --resource-group containers-for-days --name teststreamlit20241126containerrepo --sku Basic
   az acr login -n teststreamlit20241126containerrepo  
   az acr update -n teststreamlit20241126containerrepo --admin-enabled true
    ```
3. Build and push docker image: 
    ```shell
    docker build . -f Dockerfile-Streamlit -t test-streamlit:latest
    docker tag test-streamlit:latest teststreamlit20241126containerrepo.azurecr.io/test-streamlit:latest
    docker push teststreamlit20241126containerrepo.azurecr.io/test-streamlit:latest
    ```
4. Test locally with: 
   ```shell
   docker run -p 8501:8501 test-streamlit:latest
   ```
5. Set up Linux App Service
    ```shell
    az appservice plan create --name ASP-containers-for-days --location eastus --resource-group containers-for-days --sku B1 --is-linux 
    ```
6. Set up WebApp (use the port your application listens on instead of 8501)
    ```shell
    az webapp create -g containers-for-days -n test-streamlit-20241126 --plan ASP-containers-for-days --container-image-name teststreamlit20241126containerrepo.azurecr.io/test-streamlit:latest
    az webapp config appsettings set -g containers-for-days -n test-streamlit-20241126 --settings WEBSITES_PORT=8501
    az webapp restart -g containers-for-days -n test-streamlit-20241126
    ```
   
7. Done!

# Cleaning up
To remove all resources: 
   ```shell
    az group delete --resource-group containers-for-days -y
   ```