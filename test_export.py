import os
import re

def source_env_file(env_file_path):
    """Load environment variables from a file, supporting multi-line values."""
    try:
        with open(env_file_path, 'r') as file:
            content = file.read()
            
            # Remove comments (lines starting with #)
            content = re.sub(r'^\s*#.*$', '', content, flags=re.MULTILINE)
            
            # Split into key=value pairs (handling multi-line values)
            for match in re.finditer(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)(?=^\s*[A-Za-z_]|\Z)', 
                                  content, flags=re.MULTILINE | re.DOTALL):
                key, value = match.groups()
                key = key.strip()
                value = value.strip()
                
                # Remove surrounding quotes if present
                if (value.startswith('"') and value.endswith('"')) or \
                   (value.startswith("'") and value.endswith("'")):
                    value = value[1:-1]
                
                # Set in environment (even if empty)
                os.environ[key] = value
                print(f"Loaded: {key}={os.environ[key]}")  # Optional logging
                
    except FileNotFoundError:
        print(f"Error: File '{env_file_path}' not found.")
        return False
    except Exception as e:
        print(f"Error loading environment: {e}")
        return False
    return True

# Example usage

if source_env_file("variables.env"):
    print("Thread cred:", os.environ.get("thread_cred"))
    print("Rotate config:", os.environ.get("broker_ip"))