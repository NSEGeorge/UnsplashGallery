//
//  RandomPreviewCell.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

extension RandomPreviewCell {
    static var reuseIdentifier: String = String(describing: RandomPreviewCell.self)
}

final class RandomPreviewCell: UICollectionViewCell {
    
    var photoObject: UnsplashPhoto? {
        didSet {
            guard let photo = photoObject else { return }
            downloadPhoto(by: photo)
            downloadAvatar(by: photo.user)
            imageView.backgroundColor = photo.color
            userNameLabel.text = photo.user.username
        }
    }
    
    private var photoDownloader = PhotoDownloader()
    private var avatarDownloader = AvatarDownloader()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var overlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.overlayColor
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: LayoutConfig.avatarSize.width, height: LayoutConfig.avatarSize.height))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = LayoutConfig.avatarSize.height / 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var userNameLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.font = UIFont.footnoteBoldFont
        view.textColor = UIColor.white
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
        avatarImageView.image = nil
        photoDownloader.cancel()
        avatarDownloader.cancel()
    }
}

private extension RandomPreviewCell {
    func downloadPhoto(by photoObject: UnsplashPhoto) {
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
    
    func downloadAvatar(by user: UnsplashUser) {
        guard let url = user.avatars[.medium] else { return }
        
        avatarDownloader.downloadPhoto(with: url, completion: { [weak self] (image, isCached) in
            guard
                let self = self,
                self.avatarDownloader.isCancelled == false
            else { return }

            if isCached {
                self.avatarImageView.image = image
            } else {
                UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    self.avatarImageView.image = image
                }, completion: nil)
            }
        })
    }
    
    func configureLayout() {
        contentView.addSubviews([imageView,
                                 overlay,
                                 avatarImageView,
                                 userNameLabel])
        
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            overlay.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            overlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlay.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            overlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            userNameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: LayoutConfig.userNameLabelHorizontalInset),
            userNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -LayoutConfig.userNameLabelHorizontalInset),
            userNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -LayoutConfig.userNameLabelBottomInset),
        ])
        
        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: LayoutConfig.avatarSize.width),
            avatarImageView.heightAnchor.constraint(equalToConstant: LayoutConfig.avatarSize.height),
            avatarImageView.bottomAnchor.constraint(equalTo: userNameLabel.topAnchor, constant: -LayoutConfig.avatarBottomInset),
        ])
    }
}

private struct LayoutConfig {
    static let avatarSize: CGSize = .init(width: 32, height: 32)
    static let userNameLabelHorizontalInset: CGFloat = 2
    static let userNameLabelBottomInset: CGFloat = 8
    static let avatarBottomInset: CGFloat = 12
}
