//
//  UIColor+Extensions.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
    static var overlayColor: UIColor {
        return UIColor(white: 0, alpha: 0.32)
    }
    
    static var footerColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray5
        } else {
            return UIColor(hexString: "#F0F0F0")
        }
    }
    
    static var headerTitleColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }
    
    static var backgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }
}

extension UIColor {
    var redComponent: CGFloat { return cgColor.components?[0] ?? 0 }
    var greenComponent: CGFloat { return cgColor.components?[1] ?? 0 }
    var blueComponent: CGFloat { return cgColor.components?[2] ?? 0 }
    var alpha: CGFloat {
        guard let components = cgColor.components else { return 1 }
        return components[cgColor.numberOfComponents-1]
    }
}

extension UIColor {
    convenience init(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1

        switch chars.count {
        case 3:
            chars = [chars[0], chars[0], chars[1], chars[1], chars[2], chars[2]]
            fallthrough
        case 6:
            chars = ["F", "F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            alpha = 0
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    var hexString: String {
        return NSString(format: "%02X%02X%02X%02X", Int(round(redComponent * 255)), Int(round(greenComponent * 255)), Int(round(blueComponent * 255)), Int(round(alpha * 255))) as String
    }
}
