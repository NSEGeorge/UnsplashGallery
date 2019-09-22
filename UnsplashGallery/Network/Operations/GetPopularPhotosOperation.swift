//
//  GetPopularPhotosOperation.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

final class GetPopularPhotosOperation: PagingOperation {
    public var getPopularPhotosCompletion: (Result<[UnsplashPhoto], Error>) -> Void = { _ in }
    
    convenience init(page: Int, perPage: Int) {
        self.init(pageObject: PageObject(page: page, perPage: perPage))
    }
    
    override var endpoint: String {
        return "/photos/"
    }

    override func prepareParameters() -> [String: Any]? {
        var parameters = super.prepareParameters()
        parameters?["order_by"] = "popular"
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
            self.getPopularPhotosCompletion(.failure(error))
        } else if let items = self.items as? [UnsplashPhoto] {
            self.getPopularPhotosCompletion(.success(items))
        }
        super.completed()
    }
}
