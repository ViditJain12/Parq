# Parq

Parq is a simple iOS parking reminder app that helps users save where they parked, set a timer, and get alerts before their parking expires.

The goal is to keep parking simple: tap once, set a timer, and know when to head back.

## Features

- Save your parked car location
- Set a parking timer
- Use preset timers or a custom circular dial
- Get local notifications before parking expires
- View your parked location on a map
- Navigate back using Google Maps or Apple Maps
- Add an optional parking photo for garages or parking lots
- Smart leave-now alerts based on walking time
- Clean black and blue modern UI

## Why I Built This

Most parking reminder apps feel cluttered and overbuilt. Parq focuses on the core task: helping users remember where they parked and avoid parking tickets.

The app is designed to be fast, simple, and useful in real situations like street parking, campus parking, garages, and busy lots.

## Tech Stack

- Swift
- SwiftUI
- Core Location
- MapKit
- UserNotifications
- Local storage with UserDefaults

## Core Flow

1. Open the app
2. Tap **Parked**
3. Choose a timer
4. Add an optional photo
5. Get alerts before parking expires
6. Navigate back to the car

## Smart Leave-Now Alert

Parq estimates how long it will take to walk back to the parked car. It then uses a safety buffer to decide when the user should leave.

Example:

If parking expires in 20 minutes and the user is 10 minutes away, Parq adds a X minute buffer and alerts the user Y minutes before expiry.

## Project Structure

```text
Parq/
├── Models/
├── Managers/
├── ViewModels/
├── Views/
├── Utils/
└── Assets/