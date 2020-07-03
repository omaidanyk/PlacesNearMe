# PlacesNearMe

This is an iOS application which is written using Swift. This app shows nearby food places as pins on the Google Maps. List of all found places is also available for display. Tapping on map pin shows place details (info view). Tapping on clicking list item opens place on map and shows place details. 

######  Implemented features
* ArcGIS Runtime SDK for iOS ( https://developers.arcgis.com/ios/ ) is using as a service that provides places.
* Number of places per fetch is limited to 20. 
* Last 20 fetched places stored locally using CoreData.
* On app start, app plays animation center initial map camera position to device location with zoom level 14. 
* App shows stored places on app start, that are visible on initial screen (if any such place exist app won't make a service fetch call)
* Fetching places should happen only when all map interactions stopped (zoom, pan or camera movement). All fetched places have to be visible on map after search

## Installation
This app uses pods so before you run it in `XCode` you should navigate to project's folder via terminal and run `pod install`. 
You should launch only `PlacesNearMe.xcworkspace` file.

> *Note*: ArcGIS Runtime SDK uses **Metal**. In order to run this app in a simulator you must meet some minimum requirements: You must be developing on **macOS Catalina**, using **Xcode 11**, and simulating **iOS 13**.

> *Note*: iOS simulator doesn't have own location like real device. You should simulate device location via `XCode` for proper app work

## Further steps and potential improvements
This app may be improved with some additional features:
* Implement mechanism for better error-handling
* Implement possibility to change places' category or even set of categories.
* Add Settings which allows user to change such things as numer of places per fetch, color of map markers, location tracking accuracy and so on
* Implement place detail page which shows such things as Phone, URL, description, photos, rating, feedbacks and so on. *(Needs more deep investigation of ArcGIS Runtime SDK)*
