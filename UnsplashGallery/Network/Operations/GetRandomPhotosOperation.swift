//
//  GetRandomPhotosOperation.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

final class GetRandomPhotosOperation: PagingOperation {
    
    public var getRandomPhotosCompletion: (Result<[UnsplashPhoto], Error>) -> Void = { _ in }
    
    convenience init(page: Int, perPage: Int) {
        self.init(pageObject: PageObject(page: page, perPage: perPage))
    }
    
    override var endpoint: String {
        return "/photos/random"
    }

    override func prepareParameters() -> [String: Any]? {
        var parameters = super.prepareParameters()
        parameters?["count"] = pageObject.perPage
        return parameters
    }

    override func processResponseData(_ data: Data?) {
        if let photos = photosFromResponseData(data) {
            self.items = photos
        }
        super.processResponseData(data)
    }

    private func photosFromResponseData(_ data: Data?) -> [UnsplashPhoto]? {
        guard let data = data else { return nil }

        do {
            return try JSONDecoder().decode([UnsplashPhoto].self, from: data)
        } catch {
            finish(with: error)
            return nil
        }
    }
    
    override func completed() {
        if let error = self.error {
            self.getRandomPhotosCompletion(.failure(error))
        } else if let items = self.items as? [UnsplashPhoto] {
            self.getRandomPhotosCompletion(.success(items))
        }
        super.completed()
    }
}
