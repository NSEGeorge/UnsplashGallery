//
//  PhotoDownloader.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

class PhotoDownloader {

    private var photoDataTask: URLSessionDataTask?
    private let photosCache = PhotosCache.cache

    private(set) var isCancelled = false

    func downloadPhoto(with url: URL, completion: @escaping ((UIImage?, Bool) -> Void)) {
        guard photoDataTask == nil else { return }

        isCancelled = false

        if let cachedResponse = photosCache.cachedResponse(for: URLRequest(url: url)),
            let image = UIImage(data: cachedResponse.data) {
            completion(image, true)
            return
        }

        photoDataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.photoDataTask = nil

            guard
                let data = data,
                let response = response,
                let image = UIImage(data: data),
                error == nil
            else { return }

            let cachedResponse = CachedURLResponse(response: response, data: data)
            self.photosCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))

            DispatchQueue.main.async {
                completion(image, false)
            }
        }

        photoDataTask?.resume()
    }

    func cancel() {
        isCancelled = true
        photoDataTask?.cancel()
    }
}
