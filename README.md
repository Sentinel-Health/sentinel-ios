# Sentinel iOS App

This repository contains the source code for the Sentinel iOS app. The app connects to your Apple HealthKit data and provides you with a personalized AI health assistant.

The app is built using Swift and SwiftUI and requires a backend API to function properly. You can find the backend API repository [here](https://github.com/Sentinel-Health/sentinel-server).

## Background

Sentinel was started to address the problem that the traditional healthcare system is not designed for the patient. There are many factors contributing to this, in particular misaligned incentives and asymmetric information, the latter of which is what we built Sentinel to solve. Unfortunately, due to a number of different challenges we decided to shut it down.

However, we also decided to open source all of the code used to build Sentinel. We hope that by doing so, others may be able to continue to use it on their own, improve upon it, or just learn something from it. This is one of the repositories. The other can be found [here](https://github.com/Sentinel-Health/sentinel-server).

## Prerequisites

Before running the app locally, ensure that you have the following:

- Xcode (latest version recommended)
- iOS Simulator or a physical iOS device for testing

## Getting Started

To get started with the Sentinel iOS app, follow these steps:

1. Clone this repository to your local machine using the following command:

   ```
   git clone https://github.com/Sentinel-Health/sentinel-ios.git
   ```

2. Navigate to the project directory:

   ```
   cd ios-app
   ```

3. Open the project in Xcode:

   ```
   open Sentinel.xcodeproj
   ```

4. Build and run the app in Xcode using the iOS Simulator or a connected iOS device.

## Backend API

To fully utilize the features of the Sentinel iOS app, you'll need to have the Rails backend API running. The backend repository can be found [here](https://github.com/Sentinel-Health/sentinel-server.git).

Please refer to the backend repository's README for instructions on setting up and running the API.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
