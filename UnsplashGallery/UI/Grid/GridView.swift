//
//  GridView.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

protocol RefreshingDelegate {
    func refresh()
    func fetchNextPage()
}

protocol PopularPhotosDataSource: AnyObject {
    func numberOfPhotos(in gridView: GridView) -> Int
    func gridView(_ gridView: GridView, photoAt index: Int) -> UnsplashPhoto?
    func canLoadNext(in gridView: GridView) -> Bool
}

protocol PopularPhotosDelegate: AnyObject {
    func gridView(_ gridView: GridView, didSelectPhotoAt index: Int)
}

typealias GridViewDataSource = PopularPhotosDataSource & RandomPhotosPreviewDataSource
typealias GridViewDelegate = PopularPhotosDelegate & RandomPhotosPreviewDelegate & RefreshingDelegate

final class GridView: UIView {
    weak var dataSource: GridViewDataSource!
    weak var delegate: GridViewDelegate!
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }()
    
    private lazy var layout: UICollectionViewLayout = UICollectionViewFlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: self.bounds,
                                  collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        cv.decelerationRate = .normal
        cv.backgroundColor = UIColor.backgroundColor
        cv.showsVerticalScrollIndicator = true
        cv.isPrefetchingEnabled = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        registerCells()
        collectionView.refreshControl = refreshControl
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertCells(_ count: Int) {
        let numberOfItems = self.dataSource.numberOfPhotos(in: self)
        let newIndexes = (0..<count).map{ IndexPath(item: numberOfItems + $0, section: SectionType.popularPhotos.rawValue)}
        
        collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: newIndexes)
        }, completion: nil)
    }

    func refreshPopularSection() {
        collectionView.reloadSections(IndexSet(integersIn: 1...1))
    }
    
    func reloadRandomSection() {
        collectionView.reloadSections(IndexSet(integersIn: 0...0))
    }
    
    func endRefreshing() {
        self.refreshControl.endRefreshing()
    }
    
    @objc
    private func refresh() {
        delegate.refresh()
    }
}

extension GridView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = SectionType(rawValue: section) else { return 0 }
        switch sectionType {
        case .randomPhotos:
            return 1
        case .popularPhotos:
            return self.dataSource.numberOfPhotos(in: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = SectionType(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch sectionType {
        case .randomPhotos:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridRandomPreviewsCell.reuseIdentifier, for: indexPath) as! GridRandomPreviewsCell
            cell.dataSource = self.dataSource
            cell.delegate = self.delegate
            cell.reload()
            return cell
            
        case .popularPhotos:
            if isPagingCellAt(indexPath) {
                return collectionView.dequeueReusableCell(withReuseIdentifier: PagingCell.reuseIdentifier, for: indexPath) as! PagingCell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.reuseIdentifier, for: indexPath) as! GridCell
            cell.photoObject = self.dataSource.gridView(self, photoAt: indexPath.item)
            return cell
        }
    }
    
    private func isPagingCellAt(_ indexPath: IndexPath) -> Bool {
        return dataSource.canLoadNext(in: self) && indexPath.item == self.dataSource.numberOfPhotos(in: self) - 1
    }
}

extension GridView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.gridView(self, didSelectPhotoAt: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let sectionType = SectionType(rawValue: indexPath.section) else { return false }
        switch sectionType {
        case .randomPhotos:
            return false
        case .popularPhotos:
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionType = SectionType(rawValue: indexPath.section) else { assert(false, "Invalid indexPath") }
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: GridHeaderView.reuseIdentifier,
                                                                             for: indexPath) as! GridHeaderView
            if sectionType == .randomPhotos {
                headerView.configureWith(title: "Random Photos", subtitle: "Dream bigger. Do bigger")
            } else {
                headerView.configureWith(title: "Popular Photos", subtitle: "Powered by creators everywhere")
            }
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: GridFooterView.reuseIdentifier,
                                                                             for: indexPath) as! GridFooterView
            return footerView
            
        default:
            assert(false, "Unknown element type")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let sectionType = SectionType(rawValue: indexPath.section) else { return }
        switch sectionType {
        case .randomPhotos:
            break
        case .popularPhotos:
            if indexPath.item == dataSource.numberOfPhotos(in: self) - 3 && dataSource.canLoadNext(in: self) {
                delegate.fetchNextPage()
            }
        }
    }
}

extension GridView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionType = SectionType(rawValue: indexPath.section) else { return .zero }
        
        switch sectionType {
        case .randomPhotos:
            return CGSize(width: collectionView.frame.width, height: LayoutConfig.randomPhotosCellHeight)
        case .popularPhotos:
            if isPagingCellAt(indexPath) {
                return CGSize(width: collectionView.frame.width-24, height: LayoutConfig.pagingCellHeight)
            }
            
            let width = collectionView.bounds.width
            let offsets = CGFloat(4 * LayoutConfig.horizontalOffset)
            let w = (width - offsets) / LayoutConfig.numberOfLinearCellsInPopularSection
            let h = w * LayoutConfig.aspectRatio
            
            return CGSize(width: w, height: h)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let sectionType = SectionType(rawValue: section) else { return .zero }
        
        switch sectionType {
        case .randomPhotos:
            return UIEdgeInsets(top:LayoutConfig.horizontalOffset, left: 0, bottom: LayoutConfig.horizontalOffset, right: 0)
        case .popularPhotos:
            return UIEdgeInsets(top:LayoutConfig.topOffset, left: LayoutConfig.horizontalOffset, bottom: LayoutConfig.bottomOffset, right: LayoutConfig.horizontalOffset)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: LayoutConfig.sectionHeaderHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let sectionType = SectionType(rawValue: section) else { return .zero }
        switch sectionType {
        case .randomPhotos:
            return CGSize(width: collectionView.frame.width, height: LayoutConfig.sectionFooterHeight)
        case .popularPhotos:
            return .zero
        }
    }
}

private extension GridView {
    enum SectionType: Int {
        case randomPhotos
        case popularPhotos
    }
}

private extension GridView {
    func configureLayout() {
        backgroundColor = UIColor.backgroundColor
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func registerCells() {
        self.collectionView.register(GridCell.self, forCellWithReuseIdentifier: GridCell.reuseIdentifier)
        self.collectionView.register(GridRandomPreviewsCell.self, forCellWithReuseIdentifier: GridRandomPreviewsCell.reuseIdentifier)
        self.collectionView.register(GridHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GridHeaderView.reuseIdentifier)
        self.collectionView.register(GridFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: GridFooterView.reuseIdentifier)
        self.collectionView.register(PagingCell.self, forCellWithReuseIdentifier: PagingCell.reuseIdentifier)
    }
}

private struct LayoutConfig {
    static let numberOfLinearCellsInPopularSection: CGFloat = 3
    static let horizontalOffset: CGFloat = 12
    static let topOffset: CGFloat = 12
    static let bottomOffset: CGFloat = 12
    static let aspectRatio: CGFloat = 1.78
    static let sectionHeaderHeight: CGFloat = 52
    static let sectionFooterHeight: CGFloat = 12
    static let randomPhotosCellHeight: CGFloat = 170
    static let pagingCellHeight: CGFloat = 54
}
