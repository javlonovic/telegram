# Firebase Service Account

Place your Firebase service account JSON file here and name it:
  `service_account.json`

Download it from:
  Firebase Console → Project Settings → Service Accounts → Generate new private key

Then set in your .env:
  FIREBASE_CREDENTIALS_PATH=telegram_backend/firebase/service_account.json

IMPORTANT: Never commit service_account.json to version control.
Add it to .gitignore.
