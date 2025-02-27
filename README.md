# Study Tracker

A standalone Flutter application to track study topics and revision schedules without requiring a server. The app stores data locally and dynamically adjusts revision schedules based on completion.

## Features
- **Add Study Topics**: Enter a topic and study date to store in the local database.
- **Automated Revision Scheduling**:
  - First Revision: 3 days after study date
  - Second Revision: 7 days after study date
  - Third Revision: 15 days after study date
  - If a revision is delayed, the next revision dates adjust accordingly.
- **View and Track Revisions**:
  - A table displays topics scheduled for revision on a selected date.
  - Mark topics as revised to update their next revision date automatically.

## Installation

### Android
Download the latest APK from the link below and install it on your device:
[Download for Android](https://github.com/Nagamanikanta-manam/study_tracker/releases/download/v1.0.0/app-release.apk)  

### Windows
Download the latest Windows executable file from the link below:
[Download for Windows](https://github.com/Nagamanikanta-manam/study_tracker/releases/download/v1.0.0/Release.zip)

## Screenshots
<p align="center">

<p align="center">
  <img src="https://raw.githubusercontent.com/Nagamanikanta-manam/study_tracker/master/screenshots/IMG_20250216_135341.jpg" 
       alt="Mobile Screenshot" 
       width="250" 
       style="max-width:100%; height:auto; border-radius: 10px; margin:5px;">
  
  <img src="https://raw.githubusercontent.com/Nagamanikanta-manam/study_tracker/master/screenshots/IMG_20250216_135355.jpg" 
       alt="Mobile Screenshot" 
       width="250" 
       style="max-width:100%; height:auto; border-radius: 10px; margin:5px;">
  
  <img src="https://raw.githubusercontent.com/Nagamanikanta-manam/study_tracker/master/screenshots/IMG_20250216_135404.jpg" 
       alt="Mobile Screenshot" 
       width="250" 
       style="max-width:100%; height:auto; border-radius: 10px; margin:5px;">
</p>

</p>



## Technology Stack
- **Flutter** - Cross-platform framework
- **SQFlite** - Local database for storing study topics and revisions
- **Dart** - Programming language for Flutter

## Getting Started (Developers)

### Prerequisites
- Install Flutter: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- Ensure you have Android Studio or Visual Studio Code set up

### Clone the Repository
```sh
git clone 
https://github.com/Nagamanikanta-manam/study_tracker.git
cd study-tracker
```

### Run the App
```sh
flutter pub get
flutter run
```

## License
This project is licensed under the MIT License.

## Contributing
Contributions are welcome! Feel free to submit a pull request or open an issue.

## Contact
For any queries, contact: 
Email:nagamanikanta2015@gmail.com <br>
Linkedin:https://www.linkedin.com/in/manam-naga-manikanta-91659b18a
