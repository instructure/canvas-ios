//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation

// *Adapted from http://stackoverflow.com/questions/13017257/how-do-you-determine-spacing-between-cells-in-uicollectionview-flowlayout/13258495#13258495
open class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributesToReturn: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) {
            for attributes in attributesToReturn {
                if attributes.representedElementKind == nil {
                    let indexPath = attributes.indexPath
                    attributes.frame = layoutAttributesForItem(at: indexPath)!.frame
                }
            }
            return attributesToReturn
        }
        return nil
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)!
        let sectionInset = (self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(self.collectionView!, layout: self, insetForSectionAt: currentItemAttributes.indexPath.section) ?? UIEdgeInsets.zero
        
        if indexPath.item == 0 { // first item of section
            var frame = currentItemAttributes.frame
            frame.origin.x = sectionInset.left
            currentItemAttributes.frame = frame
            
            return currentItemAttributes
        }
        
        let previousIndexPath = IndexPath(item: indexPath.item-1, section: indexPath.section)
        let previousFrame = self.layoutAttributesForItem(at: previousIndexPath)!.frame
        
        let minItemSpacing = (self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: currentItemAttributes.indexPath.section) ?? 0.0
        let previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width + minItemSpacing
        
        let currentFrame = currentItemAttributes.frame
        let stretchedCurrentFrame = CGRect(x: 0, y: currentFrame.origin.y, width: collectionView?.frame.size.width ?? 0, height: currentFrame.size.height)
        
        if !previousFrame.intersects(stretchedCurrentFrame) { // if current item is the first item on the line
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
