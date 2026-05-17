import urllib.request
import urllib.error
import urllib.parse
import json
import os

# Configuration for Obsidian Local REST API Plugin
# By default, the plugin runs on port 27124.
OBSIDIAN_API_URL = "http://127.0.0.1:27124"

# We recommend setting this as an environment variable: OBSIDIAN_API_KEY
API_KEY = os.environ.get("OBSIDIAN_API_KEY", "your_api_key_here")

def query_obsidian(endpoint, method="GET", data=None, content_type="application/json"):
    """Generic function to interact with the Obsidian Local REST API."""
    url = f"{OBSIDIAN_API_URL.rstrip('/')}/{endpoint.lstrip('/')}"
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Accept": "application/json"
    }
    
    if data:
        if content_type == "application/json" and (isinstance(data, dict) or isinstance(data, list)):
            data = json.dumps(data).encode("utf-8")
        elif isinstance(data, str):
            data = data.encode("utf-8")
        headers["Content-Type"] = content_type
        
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    
    try:
        with urllib.request.urlopen(req) as response:
            resp_body = response.read().decode('utf-8')
            # Some endpoints (like /vault/filename.md) return raw markdown, not JSON
            if response.headers.get_content_type() == 'application/json':
                return json.loads(resp_body)
            return resp_body
    except urllib.error.HTTPError as e:
        print(f"[!] HTTP Error: {e.code} - {e.reason}")
        return None
    except urllib.error.URLError as e:
        print(f"[!] Connection Error: Could not connect to Obsidian API. Is Obsidian running? {e.reason}")
        return None

def search_vault(query):
    """Searches the vault for the given query."""
    print(f"Searching Obsidian vault for: '{query}'")
    result = query_obsidian(f"/search/simple/?query={urllib.parse.quote(query)}", method="POST")
    
    if result and isinstance(result, list):
        print(f"Found {len(result)} matching files:")
        for match in result:
            print(f" - {match.get('filename')}")

if __name__ == "__main__":
    # Example Usage: Retrieve a list of files in the root of the vault
    files = query_obsidian("/vault/")
    if files:
        print("Vault Root Files:", json.dumps(files, indent=2))
        
    print("\n" + "="*40 + "\n")
    
    # Example: Search for a specific term
    search_vault("Director")
