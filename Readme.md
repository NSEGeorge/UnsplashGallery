# UnsplashGallery
<h1 align="center">
  <p align="center">
    <img src="https://img.shields.io/badge/Language-Swift-blue.svg">
    <a href="LICENSE.md"><img src="https://img.shields.io/badge/License-MIT-brightgreen.svg"></a>
    <img src="https://img.shields.io/badge/Type-Entrance test-orange.svg">
  </p>
</h1>
<p align="center"><img src="Resources/IMG_3753.PNG" height="400"> <img src="Resources/IMG_3754.PNG" height="400"></p>

## Description
iOS client for Unsplash(https://unsplash.com/). 

Two screens: feed and full screen viewer. Feed contains two sections: random photos (horizontal scroll) and popular photos (vertical scroll). Application supports pagination and refreshing.
Pagination work only for popular photos. But refreshing content refresh both sections. Tap on cell in random photos sections open full screen viewer, which works like Instgram stories: auto progress, scrolling, pausing and resuming. Tap on cell in popular sections open full screen viewer with only one photo.


## Restrictions
Application is in demo mode and is rate-limited to 50 requests per hour. After this limit, API will send response with error. But application will not show error states.

## Requirements
- iOS 11 or later
- Swift version 5.0
- A Mac with Xcode 11 or later
