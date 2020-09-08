# **Digital Camera Photo Geolocation**

## **1. Application Description**

A mobile application (Android or iOS) that allows the photograph to start and stop recording his route. The application doesn't require the mobile phone to be connected to the Internet while it records the route of the photograph. The application encrypts the routes that have been recorded with a passphrase provided by the photograph.

## **2. Main Feature**

- **Record route**: When the photograph runs the dedicated mobile application to *start recording* his route, the mobile application *generates and displays* a QR code that the photograph needs to shoot with his digital camera. The QR code contains an *identifier of the route of the photograph*.

- **Display route information**: Once the photographer is back home, he downloads the image files of his photographs in a folder of his personal computer, *including the photo of the QR code*. The photographer runs an application that detects the image file of the QR code, and calls an online service to retrieve the photographer's route.

- **Read and store route data to image**: The application retrieves the Exif information of every photograph image file and reads the capture *time given by the digital camera*. After that, the application fetches the route of the photographer and it writes *the GPS tag of the Exif information* stored in the image file of each photograph.

## **3. Technology**
- Flutter

## **4. Installation**
Read INSTALL.md file

## **5. Contact team (Author & Maintainer)**
**1. Khang VU**
- Email:
- Facebook:
- Phone:

**2. Huy TRAN**
- Email:
- Facebook:
- Phone:

**3. Khang TRAN**
- Email: haphongpk12@gmail.com
- Facebook: https://www.facebook.com/haphongpk12
- Phone: (+84) 909 77 8046