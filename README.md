# CupCompanion
Senior Project

Welcome to the CupCompanion project! This project is structured as a Flutter application leveraging Firebase and Firestore for backend services. Our main language of development is Dart within the Flutter framework. This README will guide you through the basics of the project structure, Flutter conventions, Firebase integration, and where to find and place various pieces of the application.

## Branch Naming Convention

To maintain a clean and consistent codebase, we ask that all contributors follow the guidelines outlined below when creating their branch to work on project features.

1. **Clone the Repository**:
   - Clone the repository to your local machine using `git clone`, followed by the URL of your fork or the main repository.

2. **Create a New Branch**:
   - Navigate into the cloned repository directory.
   - Use the `git checkout -b [branch-name]` command to create a new branch following our naming convention.

3. **Make Your Changes**:
   - Implement your feature, bug fix, documentation update, or other changes.
   - Commit your changes to your branch, using `git commit -m "Your commit message"`.

4. **Push Your Changes**:
   - Push your changes to your fork (if applicable) or directly to the main repository using `git push origin [branch-name]`.

5. **Open a Pull Request**:
   - Navigate to the repository on GitHub.
   - Click the "New pull request" button.
   - Select your branch as the source and the main or master branch as the destination.
   - Fill in the pull request details, explaining the changes you've made and any other relevant information.
   - Click "Create pull request".

```
[type]/[username]-[short-description]
```

Where:
- `[type]` is the type of work being done (e.g., `feature`, `bugfix`, `hotfix`, `docs`, `refactor`)
- `[username]` is your GitHub username or an abbreviation of your name
- `[short-description]` is a brief description of the work, separated by hyphens

## Project Overview

CupCompanion is a dynamic mobile application designed to visualize and interact with geographical data. Utilizing Flutter for cross-platform mobile development and Firebase with Firestore for backend data management, this project aims to provide an intuitive interface for mapping and data analysis.

## Flutter Basics

Flutter is an open-source UI software development kit created by Google for building natively compiled applications for mobile, web, and desktop from a single codebase.

- **Dart**: The programming language used to write Flutter apps. Dart syntax is easy to understand for JavaScript or Java developers.
- **Widgets**: In Flutter, everything is a widget. Widgets describe what their view should look like given their current configuration and state.
- **Stateful and Stateless Widgets**: Stateless widgets are immutable, meaning that their properties can’t change—all values are final. Stateful widgets maintain state that might change during the lifecycle of the widget.

## Firebase and Firestore

Firebase provides a suite of cloud services for mobile and web applications, including Firestore, a scalable database for mobile, web, and server development. Firestore's real-time data syncing makes it an excellent choice for dynamic, collaborative applications.

## Folder Structure

Here is an overview of the main folders and files:

- `lib/`: The starting point of the Flutter application.
  - `main.dart`: The entry point of the application.
  - `views/`: Contains the UI screens of your application.
  - `services/`: Services for interacting with Firebase and other APIs.

## Getting Started

To get started with development:

1. Install Flutter by following the instructions on the [Flutter official documentation](https://flutter.dev/docs/get-started/install).
2. Set up Firebase for your Flutter project by following the [Firebase Flutter setup guide](https://firebase.flutter.dev/docs/overview).
3. Run `flutter pub get` to install the project dependencies.
4. Launch the application using `flutter run`.

## Ubuntu Installation Guide
- These placeholders need to get changed with what version you are downloading and the path to where you have cloned the project and your branch is.
- flutter_linux_*.tar.xz
- path/to/your/file
- your-branch-name

### Installing Flutter

1. **Update package list and install dependencies**:

2. **Download Flutter SDK**:
- Go to the [Flutter SDK releases page](https://flutter.dev/docs/development/tools/sdk/releases) and download the latest stable release for Linux.
- Extract the tar file to a desired location, for example:
  ```
  cd ~
  tar xf ~/Downloads/flutter_linux_*.tar.xz
  ```

3. **Add Flutter to your PATH**:
- Open your `.bashrc` or `.zshrc` file in a text editor.
- Add the following line at the end of the file:
  ```
  export PATH="$PATH:`pwd`/flutter/bin"
  ```
- Save the file and run `source ~/.bashrc` or `source ~/.zshrc` to refresh your path.

4. **Run Flutter Doctor**:
- Run the following command to see if there are any dependencies you need to install to complete the setup:
  ```
  flutter doctor
  ```

### Installing Android Studio:

If you need to develop for Android, install Android Studio as follows:

1. **Download Android Studio**:
- Visit the [Android Studio download page](https://developer.android.com/studio) and download the Android Studio package for Linux.

2. **Unpack the ZIP file**:
- Unpack the ZIP file you downloaded to an appropriate location for your applications, such as `/usr/local/android-studio`.

3. **Run Android Studio**:
- Navigate to the `android-studio/bin/` directory and execute `studio.sh`.

4. **Complete the Setup Wizard**:
- The setup wizard will download and install the Android SDK, which is necessary for Flutter development.

### Setting up Firebase

To use Firebase services, you need to create a Firebase project and configure it:

1. **Create a Firebase project** in the [Firebase console](https://console.firebase.google.com/).

2. **Register your app** with Firebase and follow the instructions to download the `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) file.

3. **Place your configuration file** in the appropriate directory (`android/app/` for Android and `ios/Runner/` for iOS).

4. **Use the FlutterFire CLI to configure your Firebase services**:
- dart pub global activate flutterfire_cli
- flutterfire configure

5. **Add Firebase packages** to your `pubspec.yaml` file as needed and run `flutter pub get`.

For a detailed guide, refer to the [Firebase for Flutter setup guide](https://firebase.flutter.dev/docs/overview).

## Running the App on Ubuntu

After setting up your environment, you can run the application using the Flutter command:
- flutter run

## Contributing

When contributing to CupCompanion, please ensure you follow the established Flutter and Firebase conventions:

- For new features or bug fixes, thoroughly test your code on both iOS and Android platforms.
- Use Dart effectively, following the [Dart language style guide](https://dart.dev/guides/language/effective-dart/style).
- Document any Firebase schema changes or new Firestore collections clearly in your pull requests.

## Learning Resources

For those new to Flutter, Dart, or Firebase, the following resources are highly recommended:

- [Flutter Official Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Firebase for Flutter](https://firebase.flutter.dev/docs/overview)
