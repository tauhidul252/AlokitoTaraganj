
# Android Release Workflow

## 1. Create a Keystore
To publish on Play Store, you need a signed App Bundle.
Run this command in terminal (Windows):
```powershell
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*It will ask for a password. Remember it!*

## 2. Configure Signing
Create a file `android/key.properties` with:
```
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=upload-keystore.jks
```
*(Do not commit this file to GitHub!)*

## 3. Update build.gradle
Modify `android/app/build.gradle` to use the keystore (already handled by the agent if requested, or check docs).

## 4. Build App Bundle
Run:
```powershell
flutter build appbundle
```
The output file will be at `build/app/outputs/bundle/release/app-release.aab`.

## 5. Upload to Play Console
- Go to Google Play Console.
- Create a new app "Alokito Taraganj".
- Upload the `app-release.aab`.
- Fill in store listing (Screenshots, Description, Privacy Policy).
- Submit for review!
