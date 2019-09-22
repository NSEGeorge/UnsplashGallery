//
//  OperationQueue+Extensions.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

extension OperationQueue {
    convenience init(with name: String) {
        self.init()
        self.name = name
    }
}
