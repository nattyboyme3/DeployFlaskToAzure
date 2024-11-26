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
