//
//  CALayer+Extensions.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import QuartzCore.CALayer

extension CALayer {
    static func performWithoutAnimation(_ action: () -> ()) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        action()
        CATransaction.commit()
    }
}
