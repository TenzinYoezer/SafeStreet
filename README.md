# SafeStreet Frontend Prototype

SafeStreet is a Flutter frontend prototype for a community hazard reporting app.

## Included Screens

1. Login
2. Register
3. Home Dashboard
4. Submit Hazard Report
5. My Reports
6. Report Details
7. Profile
8. Settings

## Included Frontend Features

- Clean Material UI
- Bottom navigation
- Form validation
- Mock login/register flow
- Mock hazard report submission
- Mock GPS capture button
- Mock camera/photo button
- Report list with filters
- Report detail page with status timeline
- Profile and settings pages

## Important Note

This is the frontend-only version. Firebase, real GPS, and real camera packages can be connected in the backend/sensor stage.

## How to Run in VS Code

1. Extract the ZIP file.
2. Open the `safestreet_frontend` folder in VS Code.
3. Open terminal in VS Code.
4. Run:

```bash
flutter pub get
flutter run
```

## How to Run on Android Emulator

1. Open Android Studio.
2. Start your Android Emulator.
3. In VS Code terminal, run:

```bash
flutter devices
flutter run -d emulator-5554
```

If your emulator ID is different, use the device ID shown by `flutter devices`.


## Running on Edge/Web
This updated package includes a `web/` folder. If your local Flutter still says web is not configured, run `flutter create .` inside the project once, then run `flutter run -d edge`.
