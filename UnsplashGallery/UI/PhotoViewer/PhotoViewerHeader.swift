//
//  PhotoViewerHeader.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

final class PhotoViewerHeader: UIView {

    var onCloseButtonTap: (()->())?
    
    var photosCount: Int = 0 {
        didSet { progressView.photosCount = photosCount }
    }

    private var avatarDownloader = AvatarDownloader()
    
    func updateWith(_ unsplashPhoto: UnsplashPhoto) {
        downloadAvatar(by: unsplashPhoto.user)
        usernameLabel.text = unsplashPhoto.user.name
    }

    private lazy var progressView: ProgressContainer = {
        let view = ProgressContainer()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor,
                           UIColor.clear.cgColor]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0);
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradient
    }()
    
    private lazy var avatarView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: LayoutConfig.avatarSize.width, height: LayoutConfig.avatarSize.height))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = LayoutConfig.avatarSize.height / 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.subheadlineSemiboldFont
        label.textColor = UIColor.white
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.setImage(Assets.icClose24, for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        addSublayers()
        addSubviews()
        configureLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start(with index: Int, duration: TimeInterval, completion: @escaping ProgressViewCompletion) {
        progressView.start(with: index, duration: duration, completion: completion)
    }
    
    func reset() {
        progressView.reset(at: 0)
    }
    
    func pause() {
        progressView.pause(at: 0)
    }
    
    func resume() {
        progressView.resume(at: 0)
    }
    
    func prepareForReuse() {
        reset()
        avatarView.image = nil
        avatarDownloader.cancel()
    }
    
    func downloadAvatar(by user: UnsplashUser) {
        guard let url = user.avatars[.medium] else { return }
        
        avatarDownloader.downloadPhoto(with: url, completion: { [weak self] (image, isCached) in
            guard
                let self = self,
                self.avatarDownloader.isCancelled == false
            else { return }

            if isCached {
                self.avatarView.image = image
            } else {
                UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    self.avatarView.image = image
                }, completion: nil)
            }
        })
    }
}

private extension PhotoViewerHeader {
    func addSublayers() {
        self.layer.addSublayer(gradient)
    }
    
    func addSubviews() {
        self.addSubviews([
            progressView,
            avatarView,
            usernameLabel,
            closeButton,
        ])
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: LayoutConfig.progressViewHorizontalOffset),
            progressView.topAnchor.constraint(equalTo: self.topAnchor, constant: LayoutConfig.progressViewVerticalOffset),
            progressView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -LayoutConfig.progressViewHorizontalOffset),
            progressView.heightAnchor.constraint(equalToConstant: LayoutConfig.progressViewHeight)
        ])
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: LayoutConfig.avatarHorizontalOffset),
            avatarView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: LayoutConfig.avatarVerticalOffset),
            avatarView.widthAnchor.constraint(equalToConstant: LayoutConfig.avatarSize.width),
            avatarView.heightAnchor.constraint(equalToConstant: LayoutConfig.avatarSize.height)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -LayoutConfig.closeHorizontalOffset),
            closeButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: LayoutConfig.closeVerticalOffset),
            closeButton.widthAnchor.constraint(equalToConstant: LayoutConfig.closeSize.width),
            closeButton.heightAnchor.constraint(equalToConstant: LayoutConfig.closeSize.height)
        ])
        
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: LayoutConfig.usernameLabelHorizontalOffset),
            usernameLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -LayoutConfig.usernameLabelHorizontalOffset),
        ])
    }

    @objc
    func closeButtonTapped() {
        onCloseButtonTap?()
    }
}

private struct LayoutConfig {
    static let progressViewHorizontalOffset: CGFloat = 12
    static let progressViewVerticalOffset: CGFloat = 10
    static let progressViewHeight: CGFloat = 4
    
    static let avatarSize: CGSize = CGSize(width: 32, height: 32)
    static let avatarHorizontalOffset: CGFloat = 12
    static let avatarVerticalOffset: CGFloat = 14
    
    static let usernameLabelHorizontalOffset: CGFloat = 12
    static let usernameLabelVerticalOffset: CGFloat = 10
    
    static let closeSize: CGSize = CGSize(width: 44, height: 44)
    static let closeHorizontalOffset: CGFloat = 2
    static let closeVerticalOffset: CGFloat = 10
}
