//
//  AvatarDownloader.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

class AvatarDownloader {

    private var avatarDataTask: URLSessionDataTask?
    private let avatarsCache = AvatarsCache.cache

    private(set) var isCancelled = false

    func downloadPhoto(with url: URL, completion: @escaping ((UIImage?, Bool) -> Void)) {
        guard avatarDataTask == nil else { return }

        isCancelled = false

        if let cachedResponse = avatarsCache.cachedResponse(for: URLRequest(url: url)),
            let image = UIImage(data: cachedResponse.data) {
            completion(image, true)
            return
        }

        avatarDataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.avatarDataTask = nil

            guard
                let data = data,
                let response = response,
                let image = UIImage(data: data),
                error == nil
            else { return }

            let cachedResponse = CachedURLResponse(response: response, data: data)
            self.avatarsCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))

            DispatchQueue.main.async {
                completion(image, false)
            }
        }

        avatarDataTask?.resume()
    }

    func cancel() {
        isCancelled = true
        avatarDataTask?.cancel()
    }
}
