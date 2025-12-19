# SnapMemo

A temporary photo memo app for quick picture capture with automatic deletion.

## App Logic

### Core Functionality
**SnapMemo** is designed for temporary picture capture:
- **Private Storage**: Images are stored on the device in the app's private directory
- **App-Only Access**: Only SnapMemo can view the captured images (until explicitly saved)
- **Auto-Delete**: Images automatically delete after a configurable time period (default: 14 days)
- **Offline Mode**: All data is stored locally, no backend required

### Features

#### Home Screen
- View all captured memos in a grid layout
- Search memos by note content
- See time remaining before auto-delete on each memo
- Quick access to camera and settings
- Long-press to delete individual memos

#### Camera Screen
- Capture photos using device camera
- Optional: Add quick notes to remember context
- Configure default time-to-live in settings
- Note input visibility controlled by settings

#### Memo Detail Screen
Actions available on each memo:
- **Share**: Send image to other apps (Facebook, Messages, etc.) without saving
- **Save**: Export image to device gallery where all apps can access it permanently
- **Extend**: Add more time before auto-delete (1 day, 1 week, or 1 month)
- **Delete**: Immediately remove the memo

#### Settings Screen
- **Default TTL**: Set default expiry time (24 hours, 3 days, 1 week, 1 month)
- **Show Note Input**: Toggle quick note field visibility on camera screen
- **Storage Info**: View total space used by all memos
- **Danger Zone**: Delete all memos at once

### Technical Details
- **Architecture**: MVVM pattern with Provider state management
- **Dependency Injection**: GetIt for service locator
- **Storage**: Local file system with JSON metadata
- **Theme**: Dark mode with teal accents
- **Auto-Purge**: Hourly background cleanup of expired memos

## Getting Started

```bash
flutter pub get
flutter run
```

## Architecture (MVVM)

This app uses a lightweight MVVM pattern with `provider` and `get_it`.

- Views: [lib/views](lib/views) — UI widgets bound to ViewModels
- ViewModels: [lib/viewmodels](lib/viewmodels) — `ChangeNotifier` classes exposing state and actions
- DI: [lib/core/di.dart](lib/core/di.dart) — service locator registrations
- App scaffold: [lib/core/app.dart](lib/core/app.dart) — `MaterialApp` and routes

### Adding a new screen

1. Create a `YourFeatureViewModel` in [lib/viewmodels](lib/viewmodels) and register it in [lib/core/di.dart](lib/core/di.dart).
2. Create a `YourFeatureView` in [lib/views](lib/views) and provide the ViewModel via `ChangeNotifierProvider(create: (_) => locator<YourFeatureViewModel>())`.
3. Add a route in [lib/core/app.dart](lib/core/app.dart).

### Running

```bash
flutter run
```
