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
[Download for Android](#)  

### Windows
Download the latest Windows executable file from the link below:
[Download for Windows](#)

## Screenshots
(Include screenshots of the application here)

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
git clone https://github.com/yourusername/study-tracker.git
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
For any queries, contact: [Your Email or Social Links]
