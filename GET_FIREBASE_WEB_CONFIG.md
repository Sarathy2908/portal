# Get Firebase Web Configuration

You need to get the Web API Key and App ID from Firebase Console.

## Steps:

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/project/portal-11326/settings/general

2. **Scroll down to "Your apps"**
   - If you see a web app already registered, click on it
   - If not, click the **Web icon** `</>` to add a web app

3. **Register or View Web App**
   - If registering new: Enter nickname "ML Hackathon Web"
   - Click "Register app"
   - You'll see the Firebase SDK configuration

4. **Copy the Configuration**
   
   You'll see something like:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
     authDomain: "portal-11326.firebaseapp.com",
     projectId: "portal-11326",
     storageBucket: "portal-11326.appspot.com",
     messagingSenderId: "104356827083159242224",
     appId: "1:104356827083159242224:web:XXXXXXXXXX"
   };
   ```

5. **Update the File**
   
   Open: `/Users/sarathyv/portal/frontend/lib/firebase_options.dart`
   
   Replace the web section with your actual values:
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'YOUR_ACTUAL_API_KEY',
     appId: 'YOUR_ACTUAL_APP_ID',
     messagingSenderId: '104356827083159242224',
     projectId: 'portal-11326',
     authDomain: 'portal-11326.firebaseapp.com',
     storageBucket: 'portal-11326.appspot.com',
   );
   ```

## Quick Link

Direct link to your project settings:
https://console.firebase.google.com/project/portal-11326/settings/general

---

**After updating, you can proceed with testing the platform!**
