//
//  PhotoCache.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

protocol UnsplashCache { }

class PhotosCache: UnsplashCache {
    static let cache = URLCache(memoryCapacity: PhotosCache.memoryCapacity,
                                diskCapacity: PhotosCache.memoryCapacity,
                                diskPath: "unsplashPhoto")

    static let memoryCapacity: Int = 50.megabytes
    static let diskCapacity: Int = 100.megabytes

}

class AvatarsCache: UnsplashCache {
    static let cache = URLCache(memoryCapacity: AvatarsCache.memoryCapacity,
                                diskCapacity: AvatarsCache.memoryCapacity,
                                diskPath: "unsplashAvatar")

    static let memoryCapacity: Int = 50.megabytes
    static let diskCapacity: Int = 100.megabytes

}

private extension Int {
    var megabytes: Int { return self * 1024 * 1024 }
}
