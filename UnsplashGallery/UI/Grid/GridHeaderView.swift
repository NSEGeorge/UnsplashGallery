//
//  GridHeaderView.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

extension GridHeaderView {
    static var reuseIdentifier: String = String(describing: GridHeaderView.self)
}

final class GridHeaderView: UICollectionReusableView {
    func configureWith(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.subheadlineSemiboldFont
        view.textColor = UIColor.headerTitleColor
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.footnoteFont
        view.textColor = UIColor.lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GridHeaderView {
    func configureLayout() {
        self.addSubviews([titleLabel, subtitleLabel])
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: LayoutConfig.titleLabelHorizontalInset),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConfig.titleLabelTopInset),
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -LayoutConfig.titleLabelHorizontalInset),
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: LayoutConfig.subtitleLabelHorizontalInset),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: LayoutConfig.subtitleLabelTopInset),
            subtitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -LayoutConfig.subtitleLabelHorizontalInset),
        ])
    }
}

private struct LayoutConfig {
    static let titleLabelTopInset: CGFloat = 13
    static let titleLabelHorizontalInset: CGFloat = 12
    
    static let subtitleLabelTopInset: CGFloat = 3
    static let subtitleLabelHorizontalInset: CGFloat = 12
}

