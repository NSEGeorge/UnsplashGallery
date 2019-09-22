//
//  RandomPhotosPreview.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

protocol RandomPhotosPreviewDataSource: AnyObject {
    func numberOfPhotos(in randomPhotosPreview: RandomPhotosPreview) -> Int
    func randomPhotosPreview(_ randomPhotosPreview: RandomPhotosPreview, photoAt index: Int) -> UnsplashPhoto?
}

protocol RandomPhotosPreviewDelegate: AnyObject {
    func randomPhotosPreview(_ randomPhotosPreview: RandomPhotosPreview, didSelectPhotoAt index: Int)
}

final class RandomPhotosPreview: UIView {
    weak var dataSource: RandomPhotosPreviewDataSource!
    weak var delegate: RandomPhotosPreviewDelegate!
    
    lazy var layout: UICollectionViewLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 8.0
        flowLayout.itemSize = CGSize(width: 96, height: 170)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: self.bounds,
                                  collectionViewLayout: layout)
        
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        cv.decelerationRate = .fast
        cv.backgroundColor = UIColor.backgroundColor
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isPrefetchingEnabled = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        registerCells()
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RandomPhotosPreview: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.numberOfPhotos(in: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RandomPreviewCell.reuseIdentifier, for: indexPath) as! RandomPreviewCell
        cell.photoObject = self.dataSource.randomPhotosPreview(self, photoAt: indexPath.item)
        return cell
    }
}

extension RandomPhotosPreview: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.randomPhotosPreview(self, didSelectPhotoAt: indexPath.item)
    }
}

private extension RandomPhotosPreview {
    func configureLayout() {
        backgroundColor = .white
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func registerCells() {
        self.collectionView.register(RandomPreviewCell.self, forCellWithReuseIdentifier: RandomPreviewCell.reuseIdentifier)
    }
}
