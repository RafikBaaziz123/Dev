from utils import *

def getLogs(payload):
    root_dir = "/var"
    archive_name = "All_logs.tar.gz"
    archive_path = os.path.join("/tmp", archive_name)  # Use /tmp to avoid permission issues
    try:
        with tarfile.open(archive_path, "w:gz") as tar:
            for dirpath, dirnames, _ in os.walk(root_dir):
                for dirname in dirnames:
                    if dirname.startswith("vol"):  # Check if the directory name starts with "vol"
                        logs_dir = os.path.join(dirpath, dirname, 'logs')
                        if os.path.isdir(logs_dir):
                            for log_file in os.listdir(logs_dir):
                                log_file_path = os.path.join(logs_dir, log_file)
                                if os.path.isfile(log_file_path) and log_file.endswith(".log"):
                                    tar.add(log_file_path, arcname=os.path.join(dirname, log_file))
                                    print(f"Added to archive: {log_file_path} as {dirname}/{log_file}")
    
        print(f"All log files have been archived in {archive_path}")
        # URL and parameters
        url = "https://camreporter.teamusages.qa.protectline.fr/v1/logs"
        params = {
            "mac": "3C62F00C69BA",
            "type": "restclient"
        }

        # Basic Auth credentials (already base64-encoded in your curl, but better practice is to decode and pass raw)
        username = "camreporter"
        password = "1DFA3k4viB1u7m2ao2iJ"

        # File to send
        file_path = "/tmp/All_logs.tar.gz"

        # Read and send the file
        with open(file_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(url, params=params, files=files, auth=HTTPBasicAuth(username, password))

        # Print HTTP status code
        print("HTTP Status Code:", response.status_code)
        if(response.status_code == 200):
            return {"logFileName": archive_name}
        else:
            return {"success": "false", "cause": response.status_code}    

    except Exception as e:
        # Handle any exceptions (e.g., file I/O errors, tar errors)
        return {"success": "false", "cause": str(e)}
        
