import urllib.request
import urllib.parse
import json

BASE_URL = "http://127.0.0.1:8000/api/v1"

def test_health():
    url = f"{BASE_URL}/health"
    req = urllib.request.urlopen(url)
    data = json.loads(req.read().decode())
    print("[TEST] Health check status:", data)
    assert data["status"] == "healthy"

def test_get_posts():
    url = f"{BASE_URL}/posts"
    req = urllib.request.urlopen(url)
    data = json.loads(req.read().decode())
    print(f"[TEST] Total posts fetched: {data['total']}, items: {len(data['items'])}")
    assert data["total"] >= 4

def test_get_categories():
    url = f"{BASE_URL}/categories"
    req = urllib.request.urlopen(url)
    data = json.loads(req.read().decode())
    print(f"[TEST] Total categories: {len(data)}")
    assert len(data) >= 4

def test_get_tags():
    url = f"{BASE_URL}/tags"
    req = urllib.request.urlopen(url)
    data = json.loads(req.read().decode())
    print(f"[TEST] Total tags: {len(data)}")
    assert len(data) >= 6

def test_login():
    url = f"{BASE_URL}/auth/login/json"
    payload = json.dumps({"email": "admin@blogcms.com", "password": "admin123"}).encode('utf-8')
    headers = {'Content-Type': 'application/json'}
    req = urllib.request.Request(url, data=payload, headers=headers)
    res = urllib.request.urlopen(req)
    data = json.loads(res.read().decode())
    print("[TEST] Login token received:", data["access_token"][:20] + "...")
    assert "access_token" in data
    return data["access_token"]

if __name__ == "__main__":
    print("--- Running API Verification Tests ---")
    test_health()
    test_get_posts()
    test_get_categories()
    test_get_tags()
    token = test_login()
    print("--- All API Verification Tests Passed Cleanly! ---")
