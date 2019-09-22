//
//  PhotoViewerView.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

protocol PhotoViewerViewDataSource: AnyObject {
    func numberOfItems() -> Int
    func itemAt(_ index: Int) -> UnsplashPhoto?
}

protocol PhotoViewerViewDelegate: AnyObject {
    func photoViewerViewCanBeClosed(_ view: PhotoViewerView)
}

class PhotoViewerView: UIView {
    weak var dataSource: PhotoViewerViewDataSource?
    weak var delegate: PhotoViewerViewDelegate?
    var currentIndex: Int = 0
    
    private var isExecutedOnce: Bool = false
    
    lazy var layout: PhotoViewerViewLayout = {
        let flowLayout = PhotoViewerViewLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .init(x: 0, y: 0,
                                               width: UIScreen.main.bounds.width,
                                               height: UIScreen.main.bounds.height),
                                  collectionViewLayout: layout)
        
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.bounces = false
        cv.dataSource = self
        cv.delegate = self
        cv.decelerationRate = .fast
        cv.backgroundColor = .black
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isPrefetchingEnabled = false
        return cv
    }()
    
    func pause() {
        collectionView.visibleCells.forEach { ($0 as? PhotoViewerCell)?.pause() }
    }
    
    func resume() {
        collectionView.visibleCells.forEach { ($0 as? PhotoViewerCell)?.resume() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCells()
        configureLayout()
        addObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc
    func willResignActive() {
        pause()
    }
    
    @objc
    func didBecomeActive() {
        resume()
    }
}

extension PhotoViewerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else { return 0 }
        return dataSource.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let dataSource = self.dataSource,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewerCell.reuseIdentifier, for: indexPath) as? PhotoViewerCell,
            let unsplashPhoto = dataSource.itemAt(indexPath.item)
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        cell.configureWith(unsplashPhoto)

        return cell
    }
}

extension PhotoViewerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isExecutedOnce else {
            self.collectionView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0),
                                             at: .centeredHorizontally,
                                             animated: false)
            isExecutedOnce = true
            return
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? PhotoViewerCell)?.resetContent()
    }
}

extension PhotoViewerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

extension PhotoViewerView: PhotoViewerCellDelegate {
    func photoViewerCellReadyToScrollForward(_ cell: PhotoViewerCell) {
        guard let indexPath: IndexPath = collectionView.indexPath(for: cell) else { return }
        if indexPath.row != 0 {
            self.collectionView.scrollToItem(at: IndexPath(item: indexPath.row - 1, section: 0),
                                             at: .centeredHorizontally,
                                             animated: true)
        } else {
            cell.start()
        }
    }

    func photoViewerCellReadyToScrollBackward(_ cell: PhotoViewerCell) {
        guard let dataSource = self.dataSource else { return }
        if let indexPath: IndexPath = collectionView.indexPath(for: cell),
            indexPath.row != dataSource.numberOfItems() - 1 {
                self.collectionView.scrollToItem(at: IndexPath(item: indexPath.row + 1, section: 0),
                                                 at: .centeredHorizontally,
                                                 animated: true)
        } else {
            delegate?.photoViewerViewCanBeClosed(self)
        }
    }
    
    func photoViewerCellDidTapOnCloseButton(_ cell: PhotoViewerCell) {
        delegate?.photoViewerViewCanBeClosed(self)
    }
}

private extension PhotoViewerView {
    func configureLayout() {
        self.backgroundColor = .black
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    func registerCells() {
        self.collectionView.register(PhotoViewerCell.self, forCellWithReuseIdentifier: PhotoViewerCell.reuseIdentifier)
    }
}
