//
//  LeftAlignedCollectionViewFlowLayout
//  iCanvas
//
//  Created by Ben Kraus on 8/7/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

// *Adapted from http://stackoverflow.com/questions/13017257/how-do-you-determine-spacing-between-cells-in-uicollectionview-flowlayout/13258495#13258495
public class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributesToReturn: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElementsInRect(rect) {
            for attributes in attributesToReturn {
                if attributes.representedElementKind == nil {
                    let indexPath = attributes.indexPath
                    attributes.frame = layoutAttributesForItemAtIndexPath(indexPath)!.frame
                }
            }
            return attributesToReturn
        }
        return nil
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let currentItemAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)!
        let sectionInset = (self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(self.collectionView!, layout: self, insetForSectionAtIndex: currentItemAttributes.indexPath.section) ?? UIEdgeInsetsZero
        
        if indexPath.item == 0 { // first item of section
            var frame = currentItemAttributes.frame
            frame.origin.x = sectionInset.left
            currentItemAttributes.frame = frame
            
            return currentItemAttributes
        }
        
        let previousIndexPath = NSIndexPath(forItem: indexPath.item-1, inSection: indexPath.section)
        let previousFrame = self.layoutAttributesForItemAtIndexPath(previousIndexPath)!.frame
        
        let minItemSpacing = (self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAtIndex: currentItemAttributes.indexPath.section) ?? 0.0
        let previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width + minItemSpacing
        
        let currentFrame = currentItemAttributes.frame
        let stretchedCurrentFrame = CGRect(x: 0, y: currentFrame.origin.y, width: collectionView?.frame.size.width ?? 0, height: currentFrame.size.height)
        
        if !CGRectIntersectsRect(previousFrame, stretchedCurrentFrame) { // if current item is the first item on the line
            // the approach here is to take the current frame, left align it to the edge of the view
            // then stretch it the width of the collection view, if it intersects with the previous frame then that means it
            // is on the same line, otherwise it is on it's own new line
            var frame = currentItemAttributes.frame
            frame.origin.x = sectionInset.left
            currentItemAttributes.frame = frame
            return currentItemAttributes
        }
        
        var frame = currentItemAttributes.frame
        frame.origin.x = previousFrameRightPoint
        currentItemAttributes.frame = frame
        return currentItemAttributes
    }
}