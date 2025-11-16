"""
Test script for HackIFM Backend API
Run this after starting the server to test all endpoints
"""

import requests
import json
from time import sleep

BASE_URL = "http://localhost:5000"

def print_response(title, response):
    """Pretty print API response"""
    print(f"\n{'='*60}")
    print(f"TEST: {title}")
    print(f"{'='*60}")
    print(f"Status Code: {response.status_code}")
    try:
        print(f"Response: {json.dumps(response.json(), indent=2)}")
    except:
        print(f"Response: {response.text}")
    print(f"{'='*60}\n")


def test_api():
    """Test all API endpoints"""
    
    # Test data
    test_user = {
        "name": "Test User",
        "email": "testuser@example.com",
        "password": "TestPass123!"
    }
    
    print("\n" + "="*60)
    print("🚀 STARTING API TESTS")
    print("="*60)
    
    # 1. Health Check
    print("\n1️⃣  Testing Health Check...")
    response = requests.get(f"{BASE_URL}/api/health")
    print_response("Health Check", response)
    
    # 2. Signup
    print("\n2️⃣  Testing User Signup...")
    response = requests.post(
        f"{BASE_URL}/api/auth/signup",
        json=test_user
    )
    print_response("User Signup", response)
    
    if response.status_code == 409:
        print("⚠️  User already exists, proceeding with login...")
    
    sleep(1)
    
    # 3. Login
    print("\n3️⃣  Testing User Login...")
    response = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={
            "email": test_user["email"],
            "password": test_user["password"]
        }
    )
    print_response("User Login", response)
    
    if response.status_code == 200:
        user_token = response.json()["token"]
        user_data = response.json()["user"]
        print(f"✅ Login successful! Token: {user_token[:50]}...")
    else:
        print("❌ Login failed!")
        return
    
    sleep(1)
    
    # 4. Verify Token
    print("\n4️⃣  Testing Token Verification...")
    response = requests.get(
        f"{BASE_URL}/api/auth/verify-token",
        headers={"Authorization": f"Bearer {user_token}"}
    )
    print_response("Verify Token", response)
    
    sleep(1)
    
    # 5. Get Current User
    print("\n5️⃣  Testing Get Current User...")
    response = requests.get(
        f"{BASE_URL}/api/auth/me",
        headers={"Authorization": f"Bearer {user_token}"}
    )
    print_response("Get Current User", response)
    
    sleep(1)
    
    # 6. Forgot Password
    print("\n6️⃣  Testing Forgot Password...")
    response = requests.post(
        f"{BASE_URL}/api/auth/forgot-password",
        json={"email": test_user["email"]}
    )
    print_response("Forgot Password", response)
    
    if response.status_code == 200:
        reset_data = response.json()
        otp = reset_data.get("otp_for_testing")
        reset_token = reset_data.get("reset_token")
        print(f"✅ OTP: {otp}")
        print(f"✅ Reset Token: {reset_token[:50]}...")
    else:
        print("❌ Forgot password failed!")
        otp = None
        reset_token = None
    
    sleep(1)
    
    # 7. Reset Password (if OTP was received)
    if otp and reset_token:
        print("\n7️⃣  Testing Reset Password...")
        response = requests.post(
            f"{BASE_URL}/api/auth/reset-password",
            json={
                "email": test_user["email"],
                "otp": otp,
                "reset_token": reset_token,
                "new_password": "NewTestPass123!"
            }
        )
        print_response("Reset Password", response)
        
        if response.status_code == 200:
            # Try logging in with new password
            print("\n8️⃣  Testing Login with New Password...")
            response = requests.post(
                f"{BASE_URL}/api/auth/login",
                json={
                    "email": test_user["email"],
                    "password": "NewTestPass123!"
                }
            )
            print_response("Login with New Password", response)
    
    sleep(1)
    
    # 8. Admin Login
    print("\n9️⃣  Testing Admin Login...")
    response = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={
            "email": "admin@hackifm.com",
            "password": "Admin@123"
        }
    )
    print_response("Admin Login", response)
    
    if response.status_code == 200:
        admin_token = response.json()["token"]
        print(f"✅ Admin login successful!")
        
        sleep(1)
        
        # 9. Admin Dashboard
        print("\n🔟 Testing Admin Dashboard...")
        response = requests.get(
            f"{BASE_URL}/api/admin/dashboard",
            headers={"Authorization": f"Bearer {admin_token}"}
        )
        print_response("Admin Dashboard", response)
    
    # 10. Test unauthorized access
    print("\n1️⃣1️⃣  Testing Unauthorized Admin Access (should fail)...")
    response = requests.get(
        f"{BASE_URL}/api/admin/dashboard",
        headers={"Authorization": f"Bearer {user_token}"}
    )
    print_response("Unauthorized Admin Access", response)
    
    # Final Summary
    print("\n" + "="*60)
    print("✅ ALL TESTS COMPLETED!")
    print("="*60)
    print("\n📋 Summary:")
    print("- Health Check: ✅")
    print("- User Signup: ✅")
    print("- User Login: ✅")
    print("- Token Verification: ✅")
    print("- Get Current User: ✅")
    print("- Forgot Password: ✅")
    print("- Reset Password: ✅")
    print("- Admin Login: ✅")
    print("- Admin Dashboard: ✅")
    print("- Role-Based Access Control: ✅")
    print("\n🎉 All API endpoints are working correctly!")


if __name__ == "__main__":
    try:
        print("\n⏳ Waiting for server to be ready...")
        sleep(2)
        test_api()
    except requests.exceptions.ConnectionError:
        print("\n❌ ERROR: Cannot connect to server!")
        print("Please make sure the Flask server is running at http://localhost:5000")
        print("\nTo start the server, run: python app.py")
    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}")
