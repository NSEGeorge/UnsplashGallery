//
//  OperationsFactory.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

class OperationsFactory {
    func randomOperation(with pageObject: PagingOperation.PageObject) -> GetRandomPhotosOperation {
        return GetRandomPhotosOperation(page: pageObject.page, perPage: pageObject.perPage)
    }
    
    func popularOperation(with pageObject: PagingOperation.PageObject) -> GetPopularPhotosOperation {
        return GetPopularPhotosOperation(page: pageObject.page, perPage: pageObject.perPage)
    }
}
