//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import PSPDFKit
import Core

fileprivate var annotationUserNameKey: UInt8 = 0
fileprivate var annotationDeletedAtKey: UInt8 = 0
fileprivate var annotationDeletedByKey: UInt8 = 0
fileprivate var annotationDeletedByIDKey: UInt8 = 0

extension Annotation {
    @objc var userName: String? {
        get {
            return objc_getAssociatedObject(self, &annotationUserNameKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &annotationUserNameKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    @objc var deletedAt: Date? {
        get {
            return objc_getAssociatedObject(self, &annotationDeletedAtKey) as? Date
        }
        set(newValue) {
            objc_setAssociatedObject(self, &annotationDeletedAtKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    @objc var deletedBy: String? {
        get {
            return objc_getAssociatedObject(self, &annotationDeletedByKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &annotationDeletedByKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    @objc var deletedByID: String? {
        get {
            return objc_getAssociatedObject(self, &annotationDeletedByIDKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &annotationDeletedByIDKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
}

enum CanvadocsAnnotationType {
    case highlight(color: String, boundingBoxes: [CGRect], rect: CGRect)
    case strikeout(color: String, boundingBoxes: [CGRect], rect: CGRect)
    case freeText(fontInfo: (family: String, size: Int), text: String, rect: CGRect, color: String)
    case point(color: String, rect: CGRect)
    case commentReply(parent: String, text: String)
    case ink(gestures: [CanvadocsInkAnnotationGesture], color: String, rect: CGRect)
    case square(color: String, width: CGFloat, rect: CGRect)
    case unsupported
}

struct CanvadocsInkAnnotationGesturePoint: Codable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat?
    let opacity: CGFloat?
}

typealias CanvadocsInkAnnotationGesture = [CanvadocsInkAnnotationGesturePoint]

struct CanvadocsAnnotationList: Codable {
    let data: [CanvadocsAnnotation]
}

struct CanvadocsAnnotation: Codable {
    let id: String?
    let documentID: String?
    let userID: String?
    let userName: String
    let createdAt: Date?
    let modifiedAt: Date?
    let page: PageIndex
    let type: CanvadocsAnnotationType
    let isDeleted: Bool
    let deletedAt: Date?
    let deletedBy: String?
    let deletedByID: String?
    let width: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case documentID = "document_id"
        case userID = "user_id"
        case userName = "user_name"
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
        case page
        case deleted
        case deletedAt = "deleted_at"
        case deletedBy = "deleted_by"
        case deletedByID = "deleted_by_id"
        case width
        
        case type
        case subject
        case contents
        case color
        case font
        case opacity
        case parent = "inreplyto"
        case coords
        case inklist
        case rect
        case icon
    }
    
    enum InklistCodingKeys: String, CodingKey {
        case gestures
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.documentID = try container.decode(String.self, forKey: .documentID)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.modifiedAt = try container.decodeIfPresent(Date.self, forKey: .modifiedAt)
        self.page = try container.decode(PageIndex.self, forKey: .page)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .deleted) ?? false
        self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        self.deletedBy = try container.decodeIfPresent(String.self, forKey: .deletedBy)
        self.deletedByID = try container.decodeIfPresent(String.self, forKey: .deletedByID)
        self.width = try container.decodeIfPresent(Double.self, forKey: .width)
        
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "highlight":
            let boxes = try CanvadocsAnnotation.decodeCoords(with: decoder, in: container)
            let color = try container.decode(String.self, forKey: .color)
            let rect = try CanvadocsAnnotation.decodeRect(with: decoder, in: container)
            self.type = .highlight(color: color, boundingBoxes: boxes, rect: rect)
        case "strikeout":
            let boxes = try CanvadocsAnnotation.decodeCoords(with: decoder, in: container)
            let color = try container.decode(String.self, forKey: .color)
            let rect = try CanvadocsAnnotation.decodeRect(with: decoder, in: container)
            self.type = .strikeout(color: color, boundingBoxes: boxes, rect: rect)
        case "freetext":
            let fontInfoStr = try container.decodeIfPresent(String.self, forKey: .font)
            let sizeStr = fontInfoStr?.matches(for: "^[^\\d]*(\\d+)").first ?? "14"
            let family = fontInfoStr?.matches(for: "\\b(\\w+)$").first ?? "Verdana"
            let size = Int(sizeStr) ?? 14
            let text = try container.decodeIfPresent(String.self, forKey: .contents)
            let color = try container.decodeIfPresent(String.self, forKey: .color) ?? "#000000"
            let rect = try CanvadocsAnnotation.decodeRect(with: decoder, in: container)
            self.type = .freeText(fontInfo: (family: family, size: size), text: text ?? "", rect: rect, color: color)
        case "text": // point
            let color = try container.decodeIfPresent(String.self, forKey: .color) ?? DocViewerAnnotationColor.blue.rawValue
            let rect = try CanvadocsAnnotation.decodeRect(with: decoder, in: container)
            self.type = .point(color: color, rect: rect)
        case "commentReply":
            let parent = try container.decode(String.self, forKey: .parent)
            let text = try container.decodeIfPresent(String.self, forKey: .contents)
            self.type = .commentReply(parent: parent, text: text ?? "")
        case "ink":
            let gestures = try CanvadocsAnnotation.decodeInklist(with: decoder, in: container)
            let rect = try CanvadocsAnnotation.decodeRect(with: decoder, in: container)
            let color = try container.decodeIfPresent(String.self, forKey: .color) ?? "#000000"
            self.type = .ink(gestures: gestures, color: color, rect: rect)
        case "square":
            let color = try container.decodeIfPresent(String.self, forKey: .color) ?? "#000000"
            let width: CGFloat = try container.decodeIfPresent(CGFloat.self, forKey: .width) ?? 1.0
            let rect = try CanvadocsAnnotation.decodeRect(with: decoder, in: container)
            self.type = .square(color: color, width: width, rect: rect)
        default:
            self.type = .unsupported
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        func encodeRect(rect: CGRect) throws {
            var rectContainer = container.nestedUnkeyedContainer(forKey: .rect)
            let points: [CGPoint] = [rect.origin, CGPoint(x: rect.origin.x+rect.size.width, y: rect.origin.y+rect.size.height)]
            for point in points {
                var pointContainer = rectContainer.nestedUnkeyedContainer()
                try pointContainer.encode(point.x)
                try pointContainer.encode(point.y)
            }
        }
        
        try container.encode(page, forKey: .page)
        
        switch type {
        case .highlight(let color, let boundingBoxes, let rect), .strikeout(let color, let boundingBoxes, let rect):
            try container.encode(color, forKey: .color)
            var boxesContainer = container.nestedUnkeyedContainer(forKey: .coords)
            for boundingBox in boundingBoxes {
                var pointsContainer = boxesContainer.nestedUnkeyedContainer()
                let points: [CGPoint] = [
                    boundingBox.origin,
                    CGPoint(x: boundingBox.origin.x+boundingBox.size.width, y: boundingBox.origin.y),
                    CGPoint(x: boundingBox.origin.x, y: boundingBox.origin.y+boundingBox.size.height),
                    CGPoint(x: boundingBox.origin.x+boundingBox.size.width, y: boundingBox.origin.y+boundingBox.size.height)
                ]
                for point in points {
                    var pointContainer = pointsContainer.nestedUnkeyedContainer()
                    try pointContainer.encode(point.x)
                    try pointContainer.encode(point.y)
                }
            }
            try encodeRect(rect: rect)
            switch type {
            case .highlight:
                try container.encode("highlight", forKey: .type)
            case .strikeout:
                try container.encode("strikeout", forKey: .type)
            default:
                break
            }
        case .freeText(let fontInfo, let text, let rect, let color):
            let font = "\(fontInfo.size) pt \(fontInfo.family)"
            try container.encode(font, forKey: .font)
            try container.encode(text, forKey: .contents)
            try container.encode(color, forKey: .color)
            try container.encode("freetext", forKey: .type)
            try encodeRect(rect: rect)
        case .point(let color, let rect):
            try encodeRect(rect: rect)
            try container.encode("text", forKey: .type) // means "point"
            try container.encode("point", forKey: .contents) // still required
            try container.encode(color, forKey: .color)
            try container.encode("Comment", forKey: .icon)
        case .commentReply(let parent, let text):
            try container.encode(text, forKey: .contents)
            try container.encode(parent, forKey: .parent)
            try container.encode("commentReply", forKey: .type)
        case .ink(let gestures, let color, let rect):
            var inklist = container.nestedContainer(keyedBy: InklistCodingKeys.self, forKey: .inklist)
            var gesturesContainer = inklist.nestedUnkeyedContainer(forKey: .gestures)
            for gesture in gestures {
                if gesture.count > 10 {
                    let points = gesture.map { APIDocViewerInkPoint(
                        x: Double($0.x),
                        y: Double($0.y),
                        width: $0.width.flatMap(Double.init),
                        opacity: $0.opacity.flatMap(Double.init)
                    ) }
                    let simpleGesture = simplify(points, within: 0.5)
                    try gesturesContainer.encode(simpleGesture)
                } else {
                    try gesturesContainer.encode(gesture)
                }
            }
            try container.encode(color, forKey: .color)
            try container.encode("ink", forKey: .type)
            try container.encode(width, forKey: .width)
            try encodeRect(rect: rect)
        case .square(let color, let width, let rect):
            try container.encode(color, forKey: .color)
            try container.encode(width, forKey: .width)
            try container.encode("square", forKey: .type)
            try encodeRect(rect: rect)
        case .unsupported:
            throw NSError(domain: "com.instructure.annotations", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "can't encode an unsupported type yo"])
        }
    }
    
    init?(pspdfAnnotation: Annotation, onDocument document: Document) {
        self.id = pspdfAnnotation.name
        self.documentID = nil
        self.userID = pspdfAnnotation.user
        self.userName = pspdfAnnotation.userName ?? ""
        self.page = pspdfAnnotation.pageIndex
        self.createdAt = pspdfAnnotation.creationDate
        self.modifiedAt = pspdfAnnotation.lastModified
        self.isDeleted = pspdfAnnotation.isDeleted
        self.deletedAt = pspdfAnnotation.deletedAt
        self.deletedBy = pspdfAnnotation.deletedBy
        self.deletedByID = pspdfAnnotation.deletedByID
        var width: Double?

        switch pspdfAnnotation.type {
        case .highlight:
            let boundingBoxes = pspdfAnnotation.rects ?? []
            guard let color = pspdfAnnotation.color?.hex else { return nil }
            self.type = .highlight(color: color, boundingBoxes: boundingBoxes, rect: pspdfAnnotation.boundingBox)
        case .strikeOut:
            let boundingBoxes = pspdfAnnotation.rects ?? []
            guard let color = pspdfAnnotation.color?.hex else { return nil }
            self.type = .strikeout(color: color, boundingBoxes: boundingBoxes, rect: pspdfAnnotation.boundingBox)
        case .freeText:
            guard let freeTextAnnot = pspdfAnnotation as? FreeTextAnnotation else { fallthrough }
            let fontFamily = freeTextAnnot.fontName ?? "Helvetica"
            let size = Int(freeTextAnnot.fontSize)
            let fontInfo = (family: fontFamily, size: size)
            let text = freeTextAnnot.contents ?? ""
            let rect = freeTextAnnot.boundingBox
            let color = freeTextAnnot.color?.hex ?? "#000000"
            self.type = .freeText(fontInfo: fontInfo, text: text, rect: rect, color: color)
        case .ink:
            guard let inkAnnot = pspdfAnnotation as? InkAnnotation else { fallthrough }
            guard let color = pspdfAnnotation.color?.hex else { return nil }
            var gestures: [CanvadocsInkAnnotationGesture] = []
            for line in inkAnnot.lines ?? [] {
                let points: [CanvadocsInkAnnotationGesturePoint] = line
                    .map { point in
                        return CanvadocsInkAnnotationGesturePoint(
                            x: point.location.x,
                            y: point.location.y,
                            width: inkAnnot.lineWidth,
                            opacity: 1
                        )
                    }
                gestures.append(points)
            }
            self.type = .ink(gestures: gestures, color: color, rect: inkAnnot.boundingBox)
            width = Double(inkAnnot.lineWidth)
        case .square:
            guard let squareAnnot = pspdfAnnotation as? SquareAnnotation else { fallthrough }
            guard let color = pspdfAnnotation.color?.hex else { return nil }
            self.type = .square(color: color, width: squareAnnot.lineWidth, rect: squareAnnot.boundingBox)
        default:
            if let commentReplyAnnot = pspdfAnnotation as? CanvadocsCommentReplyAnnotation {
                self.type = .commentReply(parent: commentReplyAnnot.inReplyToName ?? "", text: commentReplyAnnot.contents ?? "")
            } else if let pointAnnot = pspdfAnnotation as? CanvadocsPointAnnotation {
                let color = pspdfAnnotation.color?.hex ?? DocViewerAnnotationColor.blue.rawValue
                self.type = .point(color: color, rect: pointAnnot.boundingBox)
            } else if let noteAnnot = pspdfAnnotation as? NoteAnnotation {
                let color = pspdfAnnotation.color?.hex ?? DocViewerAnnotationColor.blue.rawValue
                self.type = .point(color: color, rect: noteAnnot.boundingBox)
            } else {
                return nil
            }
        }
        self.width = width
    }
    
    func pspdfAnnotation(for document: Document) -> Annotation? {
        var pspdfAnnotation: Annotation?
        switch self.type {
        case .highlight(let color, let boundingBoxes, let rect), .strikeout(let color, let boundingBoxes, let rect):
            switch self.type {
            case .highlight:
                pspdfAnnotation = HighlightAnnotation()
            case .strikeout:
                pspdfAnnotation = StrikeOutAnnotation()
            default:
                break // should never get here
            }

            pspdfAnnotation?.pageIndex = page
            pspdfAnnotation?.rects = boundingBoxes
            pspdfAnnotation?.boundingBox = rect
            pspdfAnnotation?.color = UIColor.colorFromHexString(color)
        case .freeText(let fontInfo, let text, let rect, let color):
            let freeTextAnnotation = FreeTextAnnotation(contents: text)
            freeTextAnnotation.fontName = fontInfo.family
            freeTextAnnotation.fontSize = CGFloat(fontInfo.size)
            freeTextAnnotation.boundingBox = rect
            freeTextAnnotation.fillColor = .white
            freeTextAnnotation.color = UIColor.colorFromHexString(color)
            pspdfAnnotation = freeTextAnnotation
        case .point(let color, let rect):
            let pointAnnotation = CanvadocsPointAnnotation()
            pointAnnotation.color = UIColor.colorFromHexString(color)
            pointAnnotation.boundingBox = rect
            pspdfAnnotation = pointAnnotation
        case .commentReply(let parent, let text):
            let replyAnnot = CanvadocsCommentReplyAnnotation(contents: text)
            replyAnnot.inReplyToName = parent
            pspdfAnnotation = replyAnnot
        case .ink(let gestures, let color, let rect):
            let inkAnnotation = InkAnnotation()
            inkAnnotation.color = .colorFromHexString(color)
            var lines = [PDFLine]()
            for gesture in gestures {
                let line = gesture.map { (point: CanvadocsInkAnnotationGesturePoint) -> DrawingPoint in
                    let drawingPoint = DrawingPoint(cgPoint: CGPoint(x: point.x, y: point.y))
                    return drawingPoint
                }
                lines.append(line)
            }

            inkAnnotation.lines = lines
            if let width = self.width {
                inkAnnotation.lineWidth = CGFloat(width)
            }
            inkAnnotation.setBoundingBox(rect, transformLines: false)
            pspdfAnnotation = inkAnnotation
        case .square(let color, let width, let rect):
            let squareAnnotation = SquareAnnotation()
            squareAnnotation.color = .colorFromHexString(color)
            squareAnnotation.lineWidth = width
            squareAnnotation.boundingBox = rect
            pspdfAnnotation = squareAnnotation
        case .unsupported:
            return nil
        }
        
        pspdfAnnotation?.name = self.id
        pspdfAnnotation?.user = self.userID
        pspdfAnnotation?.userName = self.userName
        pspdfAnnotation?.pageIndex = self.page
        pspdfAnnotation?.creationDate = self.createdAt
        pspdfAnnotation?.lastModified = self.modifiedAt
        pspdfAnnotation?.isDeleted = self.isDeleted // makes most annotations not render
        pspdfAnnotation?.deletedAt = self.deletedAt
        pspdfAnnotation?.deletedBy = self.deletedBy
        pspdfAnnotation?.deletedByID = self.deletedByID

        return pspdfAnnotation
    }
    
    var isEmpty: Bool {
        get {
            switch self.type {
            case .commentReply(_, let text):
                return text.isEmpty
            case .freeText(_, let text, _, _):
                return text.isEmpty
            default:
                return false
            }
        }
    }
    
    private static func decodeCoords(with decoder: Decoder, in container: KeyedDecodingContainer<CanvadocsAnnotation.CodingKeys>) throws -> [CGRect] {
        // Each coords has: a list of bounding boxes that encompasses this annotation
        // Each box has: a list of 4 points to represent each corner.
        // Each point has: an x and y value, (represented from the api as a list)
        var boxesContainer = try container.nestedUnkeyedContainer(forKey: .coords)
        var boundingBoxes: [CGRect] = []
        while (!boxesContainer.isAtEnd) {
            var pointsContainer = try boxesContainer.nestedUnkeyedContainer()
            var points: [CGPoint] = []
            while (!pointsContainer.isAtEnd) {
                var pointContainer = try pointsContainer.nestedUnkeyedContainer()
                var vals: [CGFloat] = []
                while (!pointContainer.isAtEnd) {
                    let val = try pointContainer.decode(CGFloat.self)
                    vals.append(val)
                }
                guard vals.count == 2 else { continue }
                let point = CGPoint(x: vals[0], y: vals[1])
                points.append(point)
            }
            let boundingBox = pointsToRect(points)
            boundingBoxes.append(boundingBox)
        }
        return boundingBoxes
    }
    
    private static func decodeInklist(with decoder: Decoder, in container: KeyedDecodingContainer<CanvadocsAnnotation.CodingKeys>) throws -> [CanvadocsInkAnnotationGesture] {
        let inklist = try container.nestedContainer(keyedBy: InklistCodingKeys.self, forKey: .inklist)
        var gesturesContainer = try inklist.nestedUnkeyedContainer(forKey: .gestures)
        var gestures: [CanvadocsInkAnnotationGesture] = []
        while (!gesturesContainer.isAtEnd) {
            var pointsContainer = try gesturesContainer.nestedUnkeyedContainer()
            var gesturePoints: [CanvadocsInkAnnotationGesturePoint] = []
            while (!pointsContainer.isAtEnd) {
                let point = try pointsContainer.decode(CanvadocsInkAnnotationGesturePoint.self)
                gesturePoints.append(point)
            }
            gestures.append(gesturePoints)
        }
        return gestures
    }
    
    private static func decodeRect(with decoder: Decoder, in container: KeyedDecodingContainer<CanvadocsAnnotation.CodingKeys>) throws -> CGRect {
        var rectContainer = try container.nestedUnkeyedContainer(forKey: .rect)
        var points: [CGPoint] = []
        while (!rectContainer.isAtEnd) {
            var pointContainer = try rectContainer.nestedUnkeyedContainer()
            var vals: [CGFloat] = []
            while (!pointContainer.isAtEnd) {
                let val = try pointContainer.decode(CGFloat.self)
                vals.append(val)
            }
            guard vals.count == 2 else { continue }
            points.append(CGPoint(x: vals[0], y: vals[1]))
        }
        guard points.count == 2 else { return .zero }
        let rect = CGRect(origin: points[0], size: CGSize(width: points[1].x - points[0].x, height: points[1].y - points[0].y))
        return rect
    }
    
    private static func pointsToRect(_ points: [CGPoint]) -> CGRect {
        guard points.count == 4 else { return .zero }
        
        var greatestXValue = points[0].x
        var greatestYValue = points[0].y
        var smallestXValue = points[0].x
        var smallestYValue = points[0].y
        for point in points {
            greatestXValue = max(greatestXValue, point.x);
            greatestYValue = max(greatestYValue, point.y);
            smallestXValue = min(smallestXValue, point.x);
            smallestYValue = min(smallestYValue, point.y);
        }
        let origin = CGPoint(x: smallestXValue, y: smallestYValue)
        let size = CGSize(width: greatestXValue - smallestXValue, height: greatestYValue - smallestYValue)
        return CGRect(origin: origin, size: size)
    }
}

extension String {
    fileprivate func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
