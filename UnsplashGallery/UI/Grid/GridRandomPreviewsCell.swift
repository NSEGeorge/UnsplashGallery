//
//  GridRandomPreviewsCell.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

extension GridRandomPreviewsCell {
    static var reuseIdentifier: String = String(describing: GridRandomPreviewsCell.self)
}

final class GridRandomPreviewsCell: UICollectionViewCell {
    
    weak var dataSource: RandomPhotosPreviewDataSource! {
        didSet {
            previewsView.dataSource = dataSource
        }
    }
    weak var delegate: RandomPhotosPreviewDelegate! {
        didSet {
            previewsView.delegate = delegate
        }
    }
    
    private lazy var previewsView: RandomPhotosPreview = {
        let view = RandomPhotosPreview()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    func reload() {
        previewsView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GridRandomPreviewsCell {
    func configureLayout() {
        self.contentView.addSubview(previewsView)
        
        NSLayoutConstraint.activate([
            previewsView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            previewsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            previewsView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            previewsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
