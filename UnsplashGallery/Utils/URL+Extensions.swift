//
//  URL+Extensions.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

extension URL {
    func sizedURL(width: CGFloat, height: CGFloat) -> URL {
        let str = self.absoluteString.appending("&max-w=\(width)&max-h=\(height)")
        return URL(string: str)!
    }
}
