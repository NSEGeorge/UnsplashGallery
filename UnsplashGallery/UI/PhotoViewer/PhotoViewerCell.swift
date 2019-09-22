//
//  PhotoViewerCell.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

protocol PhotoViewerCellDelegate: AnyObject {
    func photoViewerCellReadyToScrollForward(_ cell: PhotoViewerCell)
    func photoViewerCellReadyToScrollBackward(_ cell: PhotoViewerCell)
    func photoViewerCellDidTapOnCloseButton(_ cell: PhotoViewerCell)
}

extension PhotoViewerCell {
    static var reuseIdentifier: String = String(describing: PhotoViewerCell.self)
}

private let photoShowingDuration: TimeInterval = 15

final class PhotoViewerCell: UICollectionViewCell {
    weak var delegate: PhotoViewerCellDelegate!
    
    private var photoDownloader = PhotoDownloader()
    private var unsplashPhoto: UnsplashPhoto?
    
    private lazy var containerView: UIView = {
        let y: CGFloat
        let height: CGFloat
        if UIDevice.current.hasNotch {
            y = LayoutConfig.containerMaxTopOffset
            height = self.bounds.height - LayoutConfig.containerMaxTopOffset - LayoutConfig.footerViewHeight
        } else {
            y = 0
            height = self.bounds.height
        }
        
        let view: UIView = UIView(frame: CGRect(x: 0,
                                                y: y,
                                                width: self.bounds.width,
                                                height: height))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = UIDevice.current.hasNotch ? 12 : 0
        view.layer.masksToBounds = UIDevice.current.hasNotch
        return view
    }()
    
    private lazy var headerView: PhotoViewerHeader = {
        let view = PhotoViewerHeader()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onCloseButtonTap = { [unowned self] in
            self.delegate.photoViewerCellDidTapOnCloseButton(self)
        }
        return view
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: self.containerView.bounds)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = self.containerView.bounds
        return blurView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.containerView.bounds)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var activityIndicator: ActivityIndicatorView = {
        let view = ActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 44, height: 44), lineWidth: 2, color: .white)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tg.cancelsTouchesInView = false;
        tg.numberOfTapsRequired = 1
        tg.delegate = self
        return tg
    }()
    
    private lazy var longTapGesture: UILongPressGestureRecognizer = {
        let lg = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lg.minimumPressDuration = 0.2
        lg.delegate = self
        return lg
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetContent()
    }

    func resetContent() {
        headerView.prepareForReuse()
        imageView.image = nil
        photoDownloader.cancel()
    }

    func configureWith(_ photo: UnsplashPhoto) {
        layoutIfNeeded()
        self.unsplashPhoto = photo
        headerView.photosCount = 1
        backgroundImageView.image = nil
        imageView.image = nil
        backgroundImageView.backgroundColor = photo.color
        headerView.updateWith(photo)
        configureImageViewsWith(photo)
        downloadPhotoBy(photo)
    }
    
    func pause() {
        headerView.pause()
    }
    
    func resume() {
        headerView.resume()
    }
    
    func start() {
        self.headerView.start(with: 0,
                              duration: photoShowingDuration,
                              completion: { [weak self] index in
                                self?.photoWasSeen()
        })
    }
    
    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(ofTouch: 0, in: self.contentView)
        headerView.reset()
        if touchLocation.x < self.contentView.bounds.width / 2 {
            delegate.photoViewerCellReadyToScrollForward(self)
        } else {
            delegate.photoViewerCellReadyToScrollBackward(self)
        }
    }
    
    @objc
    private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began || sender.state == .ended {
            if sender.state == .began {
                pause()
            }else {
                resume()
            }
        }
    }
    
    private func downloadPhotoBy(_ photoObject: UnsplashPhoto) {
        showActivityIndicator()
        guard let regularUrl = photoObject.urls[.regular] else { return }

        let sizedURL = regularUrl.sizedURL(width: imageView.bounds.width,
                                           height: imageView.bounds.width)

        photoDownloader.downloadPhoto(with: sizedURL, completion: { [weak self] (image, isCached) in
            guard
                let self = self,
                self.photoDownloader.isCancelled == false
            else { return }

            self.backgroundImageView.image = image
            if isCached {
                self.imageView.image = image
            } else {
                UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    self.imageView.image = image
                }, completion: nil)
            }

            self.hideActivityIndicator()
            self.start()
        })
    }

    private func configureImageViewsWith(_ photo: UnsplashPhoto) {
        if photo.height > photo.width {
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    private func photoWasSeen() {
        self.delegate.photoViewerCellReadyToScrollBackward(self)
    }
    
    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimation()
    }
    
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimation()
    }
}

extension PhotoViewerCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}

extension PhotoViewerCell {
    private func configureLayout() {
        contentView.addGestureRecognizer(tapGesture)
        contentView.addGestureRecognizer(longTapGesture)
        
        contentView.addSubview(containerView)
        containerView.addSubviews([backgroundImageView,
                                   imageView,
                                   headerView,
                                   activityIndicator])
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: UIDevice.current.hasNotch ? LayoutConfig.containerMaxTopOffset : 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: UIDevice.current.hasNotch ? -LayoutConfig.footerViewHeight : 0),
        ])
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        backgroundImageView.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor),
            blurView.topAnchor.constraint(equalTo: backgroundImageView.topAnchor),
            blurView.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: LayoutConfig.headerViewHeight)
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 44),
            activityIndicator.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}

private struct LayoutConfig {
    static var containerMaxTopOffset: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        } else {
            return 0
        }
    }
    
    static let headerViewHeight: CGFloat = 106
    static let footerViewHeight: CGFloat = 76
}

extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            return false
        }
    }
}
