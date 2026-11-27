# CanteenGo

## Firebase setup

The app uses Firebase Authentication email/password sign-in, Cloud Firestore,
and Firebase Storage for profile photos.
Enable the Email/Password provider in Firebase Console under **Authentication →
Sign-in method**.
Enable Firebase Storage and create its default bucket in the Firebase Console.

Deploy the Firestore and Storage rules from the repository root:

```powershell
firebase.cmd deploy --only firestore:rules,storage --project canteengoappfiredb
```

Email/password authentication and Firestore rules do not require deploying a
Cloud Function.

## Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
