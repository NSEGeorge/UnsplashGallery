//
//  GridCell.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

extension GridCell {
    static var reuseIdentifier: String = String(describing: GridCell.self)
}

final class GridCell: UICollectionViewCell {
    
    var photoObject: UnsplashPhoto? {
        didSet {
            guard let photo = photoObject else { return }
            downloadPhoto(by: photo)
            imageView.backgroundColor = photo.color
            dateView.date = photo.date
        }
    }
    
    private var photoDownloader = PhotoDownloader()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        view.backgroundColor = UIColor.blue
        
        return view
    }()
    
    private lazy var dateView: DateView = {
        let view = DateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        photoDownloader.cancel()
    }
    
    private func downloadPhoto(by photoObject: UnsplashPhoto) {
        guard let regularUrl = photoObject.urls[.regular] else { return }
        
        let sizedURL = regularUrl.sizedURL(width: frame.width,
                                           height: frame.width)
        
        photoDownloader.downloadPhoto(with: sizedURL, completion: { [weak self] (image, isCached) in
            guard
                let self = self,
                self.photoDownloader.isCancelled == false
            else { return }

            if isCached {
                self.imageView.image = image
            } else {
                UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    self.imageView.image = image
                }, completion: nil)
            }
        })
    }
}

private extension GridCell {
    func configureLayout() {
        contentView.addSubviews([imageView,
                                 dateView])
        
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            dateView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            dateView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateView.widthAnchor.constraint(equalToConstant: 32),
            dateView.heightAnchor.constraint(equalToConstant: 43),
        ])
    }
}
