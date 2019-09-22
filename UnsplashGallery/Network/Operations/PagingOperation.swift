//
//  PagingOperation.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

class PagingOperation: UnsplashOperation {
    struct PageObject {
        let page: Int
        let perPage: Int
    }
    
    let pageObject: PageObject
    
    var items: [Any]?

    init(pageObject: PageObject) {
        self.pageObject = pageObject
        super.init()
    }

    func nextPage() -> PageObject {
        return PageObject(page: pageObject.page + 1,
                          perPage: pageObject.perPage)
    }

    override func prepareParameters() -> [String: Any]? {
        var parameters = super.prepareParameters() ?? [String: Any]()
        parameters["page"] = pageObject.page
        parameters["per_page"] = pageObject.perPage
        return parameters
    }
}
