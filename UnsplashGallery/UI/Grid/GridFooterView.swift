//
//  GridFooterView.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

extension GridFooterView {
    static var reuseIdentifier: String = String(describing: GridFooterView.self)
}

final class GridFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.footerColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
