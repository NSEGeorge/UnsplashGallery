//
//  PhotoViewerViewLayout.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

final class PhotoViewerViewLayout: UICollectionViewFlowLayout {
    
    private var focusedIndexPath: IndexPath?
    
    override class var layoutAttributesClass: AnyClass { return AnimatedCollectionViewLayoutAttributes.self }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        return attributes.compactMap { $0.copy() as? AnimatedCollectionViewLayoutAttributes }.map { self.transformLayoutAttributes($0) }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        focusedIndexPath = collectionView?.indexPathsForVisibleItems.first
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard
            let indexPath = focusedIndexPath,
            let attributes = layoutAttributesForItem(at: indexPath),
            let collectionView = collectionView
        else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        return CGPoint(x: attributes.frame.origin.x - collectionView.contentInset.left,
                       y: attributes.frame.origin.y - collectionView.contentInset.top)
    }
    
    override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        focusedIndexPath = nil
    }
    
    private func transformLayoutAttributes(_ attributes: AnimatedCollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        guard let collectionView = self.collectionView else { return attributes }
        
        let tempAttributes = attributes
        
        let distance: CGFloat
        let itemOffset: CGFloat
        
        if scrollDirection == .horizontal {
            distance = collectionView.frame.width
            itemOffset = tempAttributes.center.x - collectionView.contentOffset.x
            tempAttributes.startOffset = (tempAttributes.frame.origin.x - collectionView.contentOffset.x) / tempAttributes.frame.width
            tempAttributes.endOffset = (tempAttributes.frame.origin.x - collectionView.contentOffset.x - collectionView.frame.width) / tempAttributes.frame.width
        } else {
            distance = collectionView.frame.height
            itemOffset = tempAttributes.center.y - collectionView.contentOffset.y
            tempAttributes.startOffset = (tempAttributes.frame.origin.y - collectionView.contentOffset.y) / tempAttributes.frame.height
            tempAttributes.endOffset = (tempAttributes.frame.origin.y - collectionView.contentOffset.y - collectionView.frame.height) / tempAttributes.frame.height
        }
        
        tempAttributes.scrollDirection = scrollDirection
        tempAttributes.middleOffset = itemOffset / distance - 0.5
        
        if tempAttributes.contentView == nil,
            let c = collectionView.cellForItem(at: attributes.indexPath)?.contentView {
            tempAttributes.contentView = c
        }
        return tempAttributes
    }
}

final class AnimatedCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var contentView: UIView?
    var scrollDirection: UICollectionView.ScrollDirection = .vertical

    var startOffset: CGFloat = 0
    var middleOffset: CGFloat = 0
    
    var endOffset: CGFloat = 0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! AnimatedCollectionViewLayoutAttributes
        copy.contentView = contentView
        copy.scrollDirection = scrollDirection
        copy.startOffset = startOffset
        copy.middleOffset = middleOffset
        copy.endOffset = endOffset
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? AnimatedCollectionViewLayoutAttributes else { return false }
        
        return super.isEqual(o)
            && o.contentView == contentView
            && o.scrollDirection == scrollDirection
            && o.startOffset == startOffset
            && o.middleOffset == middleOffset
            && o.endOffset == endOffset
    }
}

