//
//  PagingCell.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

extension PagingCell {
    static var reuseIdentifier: String = String(describing: PagingCell.self)
}

final class PagingCell: UICollectionViewCell {
    private lazy var activityIndicator: ActivityIndicatorView = {
        let view = ActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 44, height: 44), lineWidth: 2, color: .lightGray)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        activityIndicator.startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PagingCell {
    func configureLayout() {
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 44),
            activityIndicator.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}
