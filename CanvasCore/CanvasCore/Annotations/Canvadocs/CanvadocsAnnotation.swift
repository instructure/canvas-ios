//
//  CanvadocsAnnotation.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 9/14/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import PSPDFKit
import SwiftSimplify

fileprivate var annotationDeletedAtKey: UInt8 = 0
fileprivate var annotationDeletedByKey: UInt8 = 0
fileprivate var annotationDeletedByIDKey: UInt8 = 0

extension PSPDFAnnotation {
    var deletedAt: Date? {
        get {
            return objc_getAssociatedObject(self, &annotationDeletedAtKey) as? Date
        }
        set(newValue) {
            objc_setAssociatedObject(self, &annotationDeletedAtKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var deletedBy: String? {
        get {
            return objc_getAssociatedObject(self, &annotationDeletedByKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &annotationDeletedByKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    var deletedByID: String? {
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

extension CanvadocsInkAnnotationGesturePoint {
    var cgPoint: CGPoint { return CGPoint(x: x, y: y) }
    init(cgPoint: CGPoint) {
        self.x = cgPoint.x
        self.y = cgPoint.y
        self.width = 1
        self.opacity = 1
    }
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
        
        case type
        case subject
        case contents
        case color
        case font
        case opacity
        case parent = "inreplyto"
        case coords
        case inklist
        case width
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
            let sizeStr = fontInfoStr?.matches(for: "^[^\\d]*(\\d+)").first ?? "12"
            let family = fontInfoStr?.matches(for: "\\b(\\w+)$").first ?? "Helvetica"
            let size = Int(sizeStr) ?? 12
            let text = try container.decodeIfPresent(String.self, forKey: .contents)
            let color = try container.decodeIfPresent(String.self, forKey: .color) ?? "#000000"
            let rect = try CanvadocsAnnotation.decodeRect(with: decoder, in: container)
            self.type = .freeText(fontInfo: (family: family, size: size), text: text ?? "", rect: rect, color: color)
        case "text": // point
            let color = try container.decodeIfPresent(String.self, forKey: .color) ?? CanvadocsAnnotationColor.blue.rawValue
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
                    let points = gesture.map { $0.cgPoint }
                    let simpleGesture = SwiftSimplify.simplify(points, tolerance: 0.4, highQuality: true).map { CanvadocsInkAnnotationGesturePoint(cgPoint: $0) }
                    try gesturesContainer.encode(simpleGesture)
                } else {
                    try gesturesContainer.encode(gesture)
                }
            }
            try container.encode(color, forKey: .color)
            try container.encode("ink", forKey: .type)
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
    
    init?(pspdfAnnotation: PSPDFAnnotation, onDocument document: PSPDFDocument) {
        self.id = pspdfAnnotation.name
        self.documentID = nil
        self.userID = nil
        self.userName = ""
        self.page = pspdfAnnotation.pageIndex
        self.createdAt = pspdfAnnotation.creationDate
        self.modifiedAt = pspdfAnnotation.lastModified
        self.isDeleted = pspdfAnnotation.isDeleted
        self.deletedAt = pspdfAnnotation.deletedAt
        self.deletedBy = pspdfAnnotation.deletedBy
        self.deletedByID = pspdfAnnotation.deletedByID

        switch pspdfAnnotation.type {
        case .highlight:
            let boundingBoxes = pspdfAnnotation.rects?.map { return $0.cgRectValue } ?? []
            guard let color = pspdfAnnotation.color?.hex else { return nil }
            self.type = .highlight(color: color, boundingBoxes: boundingBoxes, rect: pspdfAnnotation.boundingBox)
        case .strikeOut:
            let boundingBoxes = pspdfAnnotation.rects?.map { return $0.cgRectValue } ?? []
            guard let color = pspdfAnnotation.color?.hex else { return nil }
            self.type = .strikeout(color: color, boundingBoxes: boundingBoxes, rect: pspdfAnnotation.boundingBox)
        case .freeText:
            guard let freeTextAnnot = pspdfAnnotation as? PSPDFFreeTextAnnotation else { fallthrough }
            let fontFamily = freeTextAnnot.fontName ?? "Helvetica"
            let size = Int(freeTextAnnot.fontSize)
            let fontInfo = (family: fontFamily, size: size)
            let text = freeTextAnnot.contents ?? ""
            let rect = freeTextAnnot.boundingBox
            let color = freeTextAnnot.color?.hex ?? "#000000"
            self.type = .freeText(fontInfo: fontInfo, text: text, rect: rect, color: color)
        case .ink:
            guard let inkAnnot = pspdfAnnotation as? PSPDFInkAnnotation else { fallthrough }
            guard let color = pspdfAnnotation.color?.hex else { return nil }
            var gestures: [CanvadocsInkAnnotationGesture] = []
            for line in inkAnnot.lines {
                let points: [CanvadocsInkAnnotationGesturePoint] = line
                    .map { $0.pspdf_drawingPointValue }
                    .map { CanvadocsInkAnnotationGesturePoint(x: $0.location.x, y: $0.location.y, width: width(for: $0.intensity), opacity: 1) }
                gestures.append(points)
            }
            self.type = .ink(gestures: gestures, color: color, rect: inkAnnot.boundingBox)
        case .square:
            guard let squareAnnot = pspdfAnnotation as? PSPDFSquareAnnotation else { fallthrough }
            guard let color = pspdfAnnotation.color?.hex else { return nil }
            self.type = .square(color: color, width: squareAnnot.lineWidth, rect: squareAnnot.boundingBox)
        default:
            if let commentReplyAnnot = pspdfAnnotation as? CanvadocsCommentReplyAnnotation {
                self.type = .commentReply(parent: commentReplyAnnot.inReplyToName ?? "", text: commentReplyAnnot.contents ?? "")
            } else if let pointAnnot = pspdfAnnotation as? CanvadocsPointAnnotation {
                let color = pspdfAnnotation.color?.hex ?? CanvadocsAnnotationColor.blue.rawValue
                self.type = .point(color: color, rect: pointAnnot.boundingBox)
            } else if let noteAnnot = pspdfAnnotation as? PSPDFNoteAnnotation {
                let color = pspdfAnnotation.color?.hex ?? CanvadocsAnnotationColor.blue.rawValue
                self.type = .point(color: color, rect: noteAnnot.boundingBox)
            } else {
                return nil
            }
        }
    }
    
    func pspdfAnnotation(for document: PSPDFDocument) -> PSPDFAnnotation? {
        var pspdfAnnotation: PSPDFAnnotation?
        switch self.type {
        case .highlight(let color, let boundingBoxes, let rect), .strikeout(let color, let boundingBoxes, let rect):
            guard let pageInfo = document.pageInfoForPage(at: page) else { return nil }
            
            switch self.type {
            case .highlight:
                pspdfAnnotation = PSPDFHighlightAnnotation()
            case .strikeout:
                pspdfAnnotation = PSPDFStrikeOutAnnotation()
            default:
                break // should never get here
            }

            pspdfAnnotation?.rotation = pageInfo.rotation
            pspdfAnnotation?.pageIndex = page
            pspdfAnnotation?.rects = boundingBoxes.map { NSValue(cgRect: $0) }
            pspdfAnnotation?.boundingBox = rect
            pspdfAnnotation?.color = UIColor.colorFromHexString(color)
        case .freeText(let fontInfo, let text, let rect, let color):
            let freeTextAnnotation = PSPDFFreeTextAnnotation(contents: text)
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
            let inkAnnotation = PSPDFInkAnnotation()
            inkAnnotation.boundingBox = rect
            inkAnnotation.color = .colorFromHexString(color)
            var lines = [[NSValue]]()
            for gesture in gestures {
                let line = gesture.map { point in
                    return NSValue(cgPoint: CGPoint(x: point.x, y: point.y))
                }
                lines.append(line)
            }
            inkAnnotation.lines = lines
            pspdfAnnotation = inkAnnotation
        case .square(let color, let width, let rect):
            let squareAnnotation = PSPDFSquareAnnotation()
            squareAnnotation.color = .colorFromHexString(color)
            squareAnnotation.lineWidth = width
            squareAnnotation.boundingBox = rect
            pspdfAnnotation = squareAnnotation
        case .unsupported:
            return nil
        }
        
        pspdfAnnotation?.name = self.id
        pspdfAnnotation?.user = self.userName
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
                self.substring(with: Range($0.range, in: self)!)
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

fileprivate func width(for intensity: CGFloat) -> CGFloat {
    let minIntensity: CGFloat = 0.06
    let maxIntensity: CGFloat = 1

    // Tweak these to adjust parity with web
    let minimum: CGFloat = 1.0
    let maximum: CGFloat = 3.0

    let bounded = max(minIntensity, min(intensity, maxIntensity))
    let result = (((maximum - minimum) / (maxIntensity - minIntensity)) * (bounded - minIntensity)) + minimum
    return result
}
