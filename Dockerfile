FROM --platform=linux/amd64 python:3.9-slim-buster  as test-flask-build
LABEL authors="nbiggs112"

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
