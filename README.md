# Classly

## 1. Introduction

Classly is a Flutter application designed to streamline students' class management experience. Whether it's managing schedules, accessing class information, or reserving seats for lectures, Classly offers a user-friendly interface for both students and educational institutions. This document provides an overview of the application structure, key features, and instructions for testing.

## 2. Folder Structure

### 2.1. Model

The `model` folder contains Dart files defining essential data structures within Classly. These models, including `CalendarEvent`, `Course`, `CustomUser`, `AppNotification`, `Professor`, and `Room`, play a crucial role in organizing and managing application data.

### 2.2. Screens

The `screens` folder comprises Dart files defining interactive user interfaces. Notable screens include:

- **CalendarPage:** Displays daily events using Syncfusion Flutter Calendar, integrated with Firebase Firestore.
- **EventScreen:** Offers detailed views of specific calendar events, allowing editing and deletion.
- **NotificationsScreen:** Organizes and displays notifications grouped by date, enhancing user comprehension.
- **ProfileScreen:** Displays user information and offers functionality for logging out and enrolling in new courses.
- **RoomScreen:** Provides detailed information about a room, including building, floor, and seat arrangement.

### 2.3. Services

The `services` folder encapsulates key functionalities using Firebase services and local notifications:

- **AuthService:** Handles user authentication using Firebase Authentication.
- **CalendarEventService:** Manages calendar events using Firebase Cloud Firestore.
- **NotificationsService:** Handles scheduling and retrieval of notifications using Firestore and Flutter Local Notifications.

## 3. Features Implementation

### 3.1. Web Service

Classly utilizes Firebase services, including Firebase Authentication and Cloud Firestore. Additionally, a dynamic 'WeatherWidget' connects with the OpenWeatherMap API for real-time weather information based on the user's location.

### 3.2. Custom UI Elements

Classly integrates custom UI elements for enhanced visual appeal and user experience. Notable examples include the 'CalendarPage' with the Syncfusion Flutter Calendar widget and the 'RoomInfoScreen' with a custom layout for displaying room details.

### 3.3. Design Patterns

Classly implements design patterns such as Singleton, Factory, Component-Based Architecture, and Navigation Design Pattern to enhance efficiency, modularity, and scalability.

### 3.4. State Management

Classly utilizes Flutter's inherent state management features and local state handling for responsive UI updates.

### 3.5. Camera and Location Services

Camera and location services are incorporated for functionalities such as profile picture upload and real-time weather information.

## 4. Instructions

For testing purposes, use the following credentials to log in:

- **Email:** test@test.com
- **Password:** test123

Feel free to explore the application's features and provide feedback for further improvements.


