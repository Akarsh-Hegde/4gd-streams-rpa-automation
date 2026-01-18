from flask import Flask, request, jsonify
import winrm

app = Flask(__name__)

@app.route('/execute', methods=['POST'])
def execute():
    data = request.json
    session = winrm.Session(
        f"https://3.139.52.231:5986/wsman",
        auth=('Administrator', 'z0w(MR!dEVQdMj979T!@hY;8qIxx%yHZ'),
        server_cert_validation='ignore'
    )
    result = session.run_ps(data['script'])
    return jsonify({
        'stdout': result.std_out.decode('utf-8'),
        'stderr': result.std_err.decode('utf-8'),
        'status': result.status_code
    })

if __name__ == '__main__':
    app.run(port=5000)