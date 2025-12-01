# Agri-Culture App Blueprint

## Overview

This document outlines the architecture and implementation details of the Agri-Culture mobile application, a Flutter-based tool for farmers. The app provides features for user authentication, farm management, and location-verified photo uploads.

## Features & Design

### User Onboarding & Authentication

The app uses a secure, OTP-based authentication flow for user registration and login.

*   **Signup:** Users register using their full name, email, and phone number. An OTP is sent to their phone for verification.
*   **OTP Verification:** The user enters the received OTP to verify their phone number.
*   **Password Setup:** After successful verification, the user sets a password for their account.
*   **Login:** Registered users can log in using their phone number and password.

### Farm Management

Once authenticated, users can register their farms.

*   **Add Farm:** Users can add a new farm by providing a name, address, and drawing the farm's boundary on a map.
*   **Map Interaction:** The app uses the device's GPS to center the map on the user's current location. Users can tap on the map to mark the vertices of their farm.
*   **Data Submission:** The farm's name, address, and boundary (in GeoJSON format) are sent to the backend and saved.

### Photo Verification

(Future Implementation) The app will allow users to upload photos that are geo-tagged and verified against their registered farm location.

## Current Implementation Plan

### Task: Implement End-to-End User Onboarding and Farm Setup

**Objective:** To create a seamless flow for users to register, authenticate, and add their first farm.

**Steps:**

1.  **API Client:**
    *   Implemented `requestOtp`, `verifyOtp`, `setPassword`, and `login` methods for handling authentication.
    *   Added an `addFarm` method to send farm data to the backend.
    *   Replaced the hardcoded authentication token with a dynamic one.

2.  **Signup Screen (`signup_screen.dart`):**
    *   Modified the UI to include a phone number field instead of a password field.
    *   Implemented the `requestOtp` method to initiate the OTP flow.
    *   Added navigation to the `VerifyOTPScreen` upon successful OTP request.

3.  **OTP Verification Screen (`verify_otp_screen.dart`):**
    *   Created a new screen for users to enter the OTP.
    *   Implemented the `verifyOtp` method to validate the OTP.
    *   Added navigation to the `SetPasswordScreen` upon successful verification.

4.  **Set Password Screen (`set_password_screen.dart`):**
    *   Created a new screen for users to set their password.
    *   Implemented the `setPassword` method to save the user's password.
    *   Added navigation to the `AddFarmScreen` upon successful password setup.

5.  **Login Screen (`login_screen.dart`):**
    *   Updated the login screen to use the new `login` method in the `ApiClient`.
    *   Implemented navigation to the `AddFarmScreen` upon successful login.

6.  **Add Farm Screen (`add_farm_screen.dart`):**
    *   Updated the screen to use the `addFarm` method in the `ApiClient`.
    *   Removed the redundant `FarmService`.

7.  **Routing (`router.dart`):**
    *   Added new routes for `/verify-otp`, `/set-password`, and `/add-farm`.
    *   Configured the routes to handle parameters passed between screens.
    *   Set the initial route to `/signup` to start the onboarding process.
