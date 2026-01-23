# Stride

Stride is a Flutter application designed to help users track and manage training sessions, heart rate data, and client information. The app follows the MVVM architecture for maintainable and scalable code.

## Features

- Client management and session tracking
- Heart rate recording and Heart Rate Recovery (HRR) calculation
- Data visualization with charts
- Local notifications
- Permissions handling
- Modern, sectioned UI for easy navigation

## Project Structure

- `lib/model/` – Data models (Client, Session, HeartRate, etc.)
- `lib/service/` – Data management and business logic (e.g., saving/loading clients and sessions)
- `lib/view/` – UI screens and widgets for user interaction
- `lib/view_model/` – State management and logic for views
- `lib/widgets/` – Reusable UI components
- `assets/` – Icons and other static assets
- `test/` – Widget and unit tests

## Getting Started

1. Install Flutter: [Flutter installation guide](https://docs.flutter.dev/get-started/install)
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Launch the app with `flutter run`

## Dependencies

- table_calendar
- stop_watch_timer
- movesense_plus
- permission_handler
- uuid
- fl_chart
- flutter_local_notifications

See `pubspec.yaml` for full details.

## AI Assistance Declaration

Some code and UI sections were generated or refactored with the help of Generative AI (GitHub Copilot), including repetitive tasks, error fixes, and section titling for clarity.
