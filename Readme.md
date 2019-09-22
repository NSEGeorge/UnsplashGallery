# UnsplashGallery

## Description
iOS client for Unsplash(https://unsplash.com/). 

Two screens: feed and full screen viewer. Feed contains two sections: random photos (horizontal scroll) and popular photos (vertical scroll). Application supports pagination and refreshing.
Pagination work only for popular photos. But refreshing content refresh both sections. Tap on cell in random photos sections open full screen viewer, which works like Instgram stories: auto progress, scrolling, pausing and resuming. Tap on cell in popular sections open full screen viewer with only one photo.

## What I would improve if I had more time
* Displaying errors and loading states (in code these places marked as TODO) 
* Custom animation for presenting and dismissing full screen viewer
* Custom animation for scrolling photos in full screen viewer
* Localization
* Cache
* Dynamic sized fonts
* I don't test application on old devices (e.g iPhone 5s). So if FPS is bad, should use manual layout instead of autolayout.


## Restrictions
Application is in demo mode and is rate-limited to 50 requests per hour. After this limit, API will send response with error. But application will not show error states.

## Requirements
- iOS 11 or later
- Swift version 5.0
- A Mac with Xcode 11 or later
