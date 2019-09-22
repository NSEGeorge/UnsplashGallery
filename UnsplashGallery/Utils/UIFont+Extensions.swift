//
//  UIFont+Extensions.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit.UIFont

extension UIFont {
    static var footnoteFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    static var footnoteBoldFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .bold)
    }
    
    static var subheadlineSemiboldFont: UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
    
    static var subheadlineBoldFont: UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .bold)
    }
    
    static var captionFont: UIFont {
        return UIFont.systemFont(ofSize: 11, weight: .regular)
    }
}
