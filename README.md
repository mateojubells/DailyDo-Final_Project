# DailyDo

A cross-platform calendar and planning app built with **Flutter** and **Firebase**. DailyDo lets you organize
events and meetings in monthly and weekly views, share plans with groups, and connect your **Spotify** account to
browse your playlists. This was my final project.

## Features

- **Calendars**: monthly and weekly views powered by Syncfusion Calendar.
- **Events and meetings**: create, view, edit and delete events, with recurrence (none, daily, weekly, monthly).
- **Groups**: create, edit and list groups to organize shared plans.
- **Accounts**: email registration and login with Firebase Authentication, Google sign-in, password recovery, and
  profile management (change username, email and password).
- **Spotify integration**: log in with Spotify through OAuth and display your playlists in the app.
- **Notifications**: local reminders with `flutter_local_notifications`.
- **Localization**: available in English, Spanish and Catalan.

## Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter (Dart SDK >=3.2.3 <4.0.0) |
| Backend | Firebase (Authentication, Cloud Firestore, Realtime Database) |
| Calendar UI | `syncfusion_flutter_calendar` |
| Music | Spotify Web API (`spotify`, `oauth2_client`) |
| Auth | `firebase_auth`, `google_sign_in` |
| Other | `shared_preferences`, `url_launcher`, `image_picker`, `intl` |

## Project Structure

```
lib/
├── Calendarios/   Month and week calendars, event create / detail / edit screens
├── Clases/        Data classes (Meeting, Group, RecurrenceType)
├── Data/          Calendar data source and event commands
├── Group/         Group creation, editing and listing
├── Init/          Login, registration and side menu
├── Spotify/       Spotify login, tokens and playlist display
├── UserControll/  Profile, change email / username, forgot password
├── services/      Registration and password change
├── l10n/          Translations (en, es, ca)
└── main.dart
```

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) installed and on your `PATH`
  (run `flutter doctor` to verify your setup).
- An Android or iOS device or emulator.

### Run the app

```bash
git clone https://github.com/mateojubells/DailyDo-Final_Project.git
cd DailyDo-Final_Project
flutter pub get
flutter run
```

### Spotify access

The Spotify app is in development mode, so only allowlisted accounts can log in:

1. Ask the project admin to add your Spotify account email to the app's User Management list.
2. Once your email is registered, the Spotify features will work with the app's credentials.

## Contributing

Found a bug or have an idea? Feel free to open an issue or submit a pull request.
