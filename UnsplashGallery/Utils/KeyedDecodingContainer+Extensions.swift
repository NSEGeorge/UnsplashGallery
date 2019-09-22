//
//  KeyedDecodingContainer+Extensions.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation
import UIKit.UIColor

extension KeyedDecodingContainer {
    func decode(_ type: UIColor.Type, forKey key: Key) throws -> UIColor {
        let hexColor = try self.decode(String.self, forKey: key)
        return UIColor(hexString: hexColor)
    }

    func decode(_ type: [UnsplashPhoto.URLKind: URL].Type, forKey key: Key) throws -> [UnsplashPhoto.URLKind: URL] {
        let urlsDictionary = try self.decode([String: String].self, forKey: key)
        var result = [UnsplashPhoto.URLKind: URL]()
        for (key, value) in urlsDictionary {
            if let kind = UnsplashPhoto.URLKind(rawValue: key),
                let url = URL(string: value) {
                result[kind] = url
            }
        }
        return result
    }

    func decode(_ type: [UnsplashUser.AvatarSize: URL].Type, forKey key: Key) throws -> [UnsplashUser.AvatarSize: URL] {
        let sizesDictionary = try self.decode([String: String].self, forKey: key)
        var result = [UnsplashUser.AvatarSize: URL]()
        for (key, value) in sizesDictionary {
            if let size = UnsplashUser.AvatarSize(rawValue: key),
                let url = URL(string: value) {
                result[size] = url
            }
        }
        return result
    }
}
