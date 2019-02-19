//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation

public extension UIImage {
    @objc public func resizedImage(_ targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    // https://stackoverflow.com/a/5427890
    @objc public static func fixOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }

        var transform = CGAffineTransform.identity
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: .pi / 2 * -1)
        case .up, .upMirrored:
            break
        }

        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }

        guard let cgImage = image.cgImage, let colorSpace = cgImage.colorSpace else {
            return image
        }

        let context = CGContext(data: nil,
                                width: Int(image.size.width),
                                height: Int(image.size.height),
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: 0,
                                space:  colorSpace,
                                bitmapInfo: cgImage.bitmapInfo.rawValue)
        context?.concatenate(transform)

        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }

        if let result = context?.makeImage() {
            return UIImage(cgImage: result)
        }

        return image
    }
    
    /// Creates an image that has RTL support if available
    public static func RTLImage(_ named: String, renderingMode: UIImage.RenderingMode? = nil) -> UIImage? {
        var image = UIImage(named: named)
        if let mode = renderingMode {
            image = image?.withRenderingMode(mode)
        }
        
        if #available(iOS 9.0, *) {
            return image?.imageFlippedForRightToLeftLayoutDirection()
        }
        
        return image
     }
}
