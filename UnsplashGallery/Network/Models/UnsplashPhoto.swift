//
//  UnsplashPhoto.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation
import UIKit.UIColor

struct UnsplashPhoto: Codable {
    
    enum URLKind: String, Codable {
        case raw
        case full
        case regular
        case small
        case thumb
    }
    
    let identifier: String
    let height: Int
    let width: Int
    let color: UIColor?
    let user: UnsplashUser
    let urls: [URLKind: URL]
    let date: Date?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        height = try container.decode(Int.self, forKey: .height)
        width = try container.decode(Int.self, forKey: .width)
        color = try container.decode(UIColor.self, forKey: .color)
        user = try container.decode(UnsplashUser.self, forKey: .user)
        urls = try container.decode([URLKind: URL].self, forKey: .urls)
        
        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter.unsplashFormat
        if let formattedDate = formatter.date(from: dateString) {
            date = formattedDate
        } else {
            throw DecodingError.dataCorruptedError(forKey: .date,
                  in: container,
                  debugDescription: "Date string does not match format expected by formatter.")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(height, forKey: .height)
        try container.encode(width, forKey: .width)
        try? container.encode(color?.hexString, forKey: .color)
        try container.encode(user, forKey: .user)
        try container.encode(urls.convert({ ($0.key.rawValue, $0.value.absoluteString) }), forKey: .urls)
    }
}

private extension UnsplashPhoto {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case height
        case width
        case color
        case user
        case urls
        case date = "created_at"
    }
}
