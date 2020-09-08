# **INSTALLATION (For devs only)**
## **Android Setup**
1. Get the Flutter SDK (Run command below):
```bash
git clone https://github.com/flutter/flutter.git -b stable
```
**Note:** Add Flutter to the PATH environment variable if you wish to run Flutter commands in the regular Windows console

2. Download & Install Android Studio (https://developer.android.com/studio):
    - Set up your Android device
    - Set up the Android emulator

3. Install VS Code (https://code.visualstudio.com/)

4. Install the Flutter and Dart plugins
    - Start VS Code.
    - Invoke **View > Command Palette…**.
    - Type “install”, and select **Extensions: Install Extensions**.
    - Type “flutter” in the extensions search field, select **Flutter** in the list, and click **Install**. This also installs the required Dart plugin.

5. Validate your setup with the Flutter Doctor
    - Invoke **View > Command Palette…**.
    - Type “doctor”, and select the **Flutter: Run Flutter Doctor**.
    - Review the output in the **OUTPUT** pane for any issues.


6. Clone this app (Run command below):
```bash
git clone https://github.com/intek-training-jsc/digital-camera-photo-geolocation-khang_tran_khang_vu
```
Note: You need to have access permission from Intek Institute

7. Run the app (Press F5 on VS Code, make sure you already have Android emulator)

=> Please follow this link to get more details: https://flutter.dev/docs/get-started/install

## **Ios Setup**
Requirement: You MUST have a MacOS device with Xcode already installed

1. Clone this app (Run command below):
```bash
git clone https://github.com/intek-training-jsc/digital-camera-photo-geolocation-khang_tran_khang_vu
```

2. Install Flutter for Mac:
   - Follow closely to this official installation guide: https://flutter.dev/docs/get-started/install/macos

3. Run Flutter Doctor:
   - Double check if your environment is ready to run the flutter app by running this command in terminal:
```bash
flutter doctor
```

4. Open an iOS simulator:
   - Use this command in terminal: 
```bash
open -a Simulator
```

5. Install required Flutter packages:
   - Use this command in terminal and wait until the installation process finish: 
```bash
flutter pub get
```

6. Run app:
   - In terminal, run this command:
```bash
flutter run
```


