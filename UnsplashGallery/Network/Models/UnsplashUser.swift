//
//  UnsplashUser.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

struct UnsplashUser: Codable {
    enum AvatarSize: String, Codable {
        case small
        case medium
        case large
    }

    let identifier: String
    let username: String
    let name: String?
    let avatars: [AvatarSize: URL]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        username = try container.decode(String.self, forKey: .username)
        name = try? container.decode(String.self, forKey: .name)
        avatars = try container.decode([AvatarSize: URL].self, forKey: .avatars)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(username, forKey: .username)
        try container.encode(name, forKey: .name)
        try container.encode(avatars.convert({ ($0.key.rawValue, $0.value.absoluteString) }), forKey: .avatars)
    }
}

private extension UnsplashUser {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case username
        case name
        case avatars = "profile_image"
    }
}
