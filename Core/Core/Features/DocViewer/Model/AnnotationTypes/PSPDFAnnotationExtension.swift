//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import PSPDFKit

private var annotationUserNameKey: UInt8 = 0
private var annotationDeletedAtKey: UInt8 = 0
private var annotationDeletedByKey: UInt8 = 0
private var annotationDeletedByIDKey: UInt8 = 0
private var annotationHasRepliesKey: UInt8 = 0
private var fontSizeTransform: CGFloat = 0.85

extension Annotation {
    /** Returns true if the annotation is loaded from the pdf file. */
    @objc // For mocking purposes
    var isFileAnnotation: Bool {
        let annotationProvider: DocViewerAnnotationProvider? = {
            let result = documentProvider?.annotationManager.annotationProviders.first { $0 is DocViewerAnnotationProvider }
            return result as? DocViewerAnnotationProvider
        }()

        guard let annotationProvider = annotationProvider else { return false }

        return annotationProvider.isFileAnnotation(self)
    }

    var userName: String? {
        get { return objc_getAssociatedObject(self, &annotationUserNameKey) as? String }
        set { objc_setAssociatedObject(self, &annotationUserNameKey, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    var deletedAt: Date? {
        get { return objc_getAssociatedObject(self, &annotationDeletedAtKey) as? Date }
        set { objc_setAssociatedObject(self, &annotationDeletedAtKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    var deletedBy: String? {
        get { return objc_getAssociatedObject(self, &annotationDeletedByKey) as? String }
        set { objc_setAssociatedObject(self, &annotationDeletedByKey, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    var deletedByID: String? {
        get { return objc_getAssociatedObject(self, &annotationDeletedByIDKey) as? String }
        set { objc_setAssociatedObject(self, &annotationDeletedByIDKey, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    var hasReplies: Bool? {
        get { return objc_getAssociatedObject(self, &annotationHasRepliesKey) as? Bool }
        set { objc_setAssociatedObject(self, &annotationHasRepliesKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }

    var isEmpty: Bool {
        return (self is FreeTextAnnotation || self is DocViewerCommentReplyAnnotation) && contents?.isEmpty != false
    }

    static func from(_ apiAnnotation: APIDocViewerAnnotation, metadata: APIDocViewerAnnotationsMetadata) -> Annotation? {
        let annotation: Annotation
        switch apiAnnotation.type {
        case .highlight:
            let highlight = DocViewerHighlightAnnotation()
            highlight.rects = apiAnnotation.coords?.map { rectFrom($0) }
            annotation = highlight
        case .strikeout:
            let strikeout = DocViewerStrikeOutAnnotation()
            strikeout.rects = apiAnnotation.coords?.map { rectFrom($0) }
            annotation = strikeout
        case .freetext:
            let freeText = DocViewerFreeTextAnnotation(contents: apiAnnotation.contents ?? "")
            let fontSizeStr = apiAnnotation.font?.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted) ?? ""
            freeText.fontName = "Lato-Regular"
            freeText.fontSize = CGFloat(Float(fontSizeStr) ?? 14) * fontSizeTransform
            freeText.fillColor = apiAnnotation.bgColor == "transparent" ? .clear
                : UIColor(hexString: apiAnnotation.bgColor) ?? .textLightest.variantForLightMode
            annotation = freeText
        case .text: // legacy name for point
            let point = DocViewerPointAnnotation()
            annotation = point
        case .commentReply:
            let reply = DocViewerCommentReplyAnnotation(contents: apiAnnotation.contents ?? "")
            reply.inReplyToName = apiAnnotation.inreplyto
            annotation = reply
        case .ink:
            let ink = DocViewerInkAnnotation()
            ink.lines = apiAnnotation.inklist?.gestures.map { $0.map { (point: APIDocViewerInkPoint) -> DrawingPoint in
                return DrawingPoint(cgPoint: CGPoint(x: point.x, y: point.y))
            } }
            if let width = apiAnnotation.width {
                ink.lineWidth = CGFloat(width)
            }
            annotation = ink
        case .square:
            let square = DocViewerSquareAnnotation()
            square.lineWidth = CGFloat(apiAnnotation.width ?? 1.0)
            annotation = square
        }

        let boundingBox = apiAnnotation.rect.flatMap(rectFrom) ?? .zero
        // Don't transform lines so that we match web
        annotation.setBoundingBox(boundingBox, transform: false, includeOptional: false)
        annotation.color = UIColor(hexString: apiAnnotation.color)
        annotation.name = apiAnnotation.id
        annotation.user = apiAnnotation.user_id
        annotation.userName = apiAnnotation.user_name
        annotation.pageIndex = apiAnnotation.page
        annotation.creationDate = apiAnnotation.created_at
        annotation.lastModified = apiAnnotation.modified_at
        annotation.isDeleted = apiAnnotation.deleted ?? false // makes most annotations not render
        annotation.deletedAt = apiAnnotation.deleted_at
        annotation.deletedBy = apiAnnotation.deleted_by
        annotation.deletedByID = apiAnnotation.deleted_by_id

        annotation.flags.remove(.readOnly) // Always allow user to view and add comments
        annotation.isEditable = apiAnnotation.user_id == metadata.user_id &&
            (metadata.permissions == .readwritemanage || metadata.permissions == .readwrite)

        return annotation
    }

    func apiAnnotation() -> APIDocViewerAnnotation? {
        guard let name = name else { return nil }
        let type: APIDocViewerAnnotationType
        var inreplyto: String?
        var inklist: APIDocViewerInklist?
        var width: Double? = Double(lineWidth)
        var rect: [[Double]]? = pointsFrom(boundingBox)

        switch self {
        case is HighlightAnnotation:
            type = .highlight
        case is StrikeOutAnnotation:
            type = .strikeout
        case is FreeTextAnnotation:
            type = .freetext
        case is InkAnnotation:
            type = .ink
            let lines = (self as? InkAnnotation)?.lines ?? []
            let gestures = lines.map { (drawingPoints: [DrawingPoint]) -> [APIDocViewerInkPoint] in
                simplify(
                    drawingPoints.map {
                        let x = Double($0.location.x)
                        let y = Double($0.location.y)
                        let w = Double(self.lineWidth)
                        return APIDocViewerInkPoint(x: x, y: y, width: w, opacity: 1)
                    },
                    within: 0.5)
            }
            inklist = APIDocViewerInklist(gestures: gestures)
        case is SquareAnnotation:
            type = .square
        case is DocViewerCommentReplyAnnotation:
            type = .commentReply
            inreplyto = (self as? DocViewerCommentReplyAnnotation)?.inReplyToName
            width = nil
            rect = nil
        case is DocViewerPointAnnotation, is NoteAnnotation:
            type = .text // point
        default:
            return nil
        }
        return APIDocViewerAnnotation(
            id: name,
            document_id: nil,
            user_id: user,
            user_name: userName ?? "",
            page: UInt(pageIndex),
            created_at: creationDate,
            modified_at: lastModified,
            deleted: isDeleted,
            deleted_at: deletedAt,
            deleted_by: deletedBy,
            deleted_by_id: deletedByID,
            type: type,
            color: color?.hexString,
            bgColor: fillColor?.hexString ?? "transparent",
            icon: type == .text ? "Comment" : nil,
            contents: contents,
            inreplyto: inreplyto,
            coords: rects?.map { coordsFrom($0) },
            rect: rect,
            font: fontName.flatMap { "\(Int(fontSize / fontSizeTransform))pt \($0)" },
            inklist: inklist,
            width: width
        )
    }
}

// MARK: helper functions

private func rectFrom(_ points: [[Double]]) -> CGRect {
    var minX = Double.infinity, minY = Double.infinity, maxX = 0.0, maxY = 0.0
    for point in points {
        guard point.count == 2 else { continue }
        minX = min(minX, point[0])
        minY = min(minY, point[1])
        maxX = max(maxX, point[0])
        maxY = max(maxY, point[1])
    }
    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

private func pointsFrom(_ rect: CGRect) -> [[Double]] {
    return [ [ Double(rect.minX), Double(rect.minY) ], [ Double(rect.maxX), Double(rect.maxY) ] ]
}

private func coordsFrom(_ rect: CGRect) -> [[Double]] {
    return [
        [ Double(rect.minX), Double(rect.minY) ],
        [ Double(rect.maxX), Double(rect.minY) ],
        [ Double(rect.minX), Double(rect.maxY) ],
        [ Double(rect.maxX), Double(rect.maxY) ]
    ]
}

private func interpolate(value: CGFloat, fromMin: CGFloat, fromMax: CGFloat, toMin: CGFloat, toMax: CGFloat) -> CGFloat {
    let bounded = max(fromMin, min(value, fromMax))
    return (((toMax - toMin) / (fromMax - fromMin)) * (bounded - fromMin)) + toMin
}

public func simplify(_ points: [APIDocViewerInkPoint], within epsilon: Double = 1.0) -> [APIDocViewerInkPoint] {
    guard let first = points.first, let last = points.last, points.count > 2 else { return points }
    var simplified = [ first ]
    check(points[0...], simplified: &simplified, epsilon: epsilon)
    simplified.append(last)
    return simplified
}

// https://en.wikipedia.org/wiki/Ramer–Douglas–Peucker_algorithm
private func check(_ segment: ArraySlice<APIDocViewerInkPoint>, simplified: inout [APIDocViewerInkPoint], epsilon: Double) {
    guard let first = segment.first, let last = segment.last, segment.count > 2 else { return }
    var maxDistance = 0.0, maxIndex = 0
    for i in segment.indices {
        let distance = perpendicularDistance(segment[i], toLine: (first, last))
        if distance > maxDistance {
            maxDistance = distance
            maxIndex = i
        }
    }
    // only significant points get appended
    if (maxDistance > epsilon) {
        check(segment[...maxIndex], simplified: &simplified, epsilon: epsilon)
        simplified.append(segment[maxIndex])
        check(segment[maxIndex...], simplified: &simplified, epsilon: epsilon)
    }
}

// https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
private func perpendicularDistance(_ point: APIDocViewerInkPoint, toLine line: (APIDocViewerInkPoint, APIDocViewerInkPoint)) -> Double {
    let x1 = line.0.x, y1 = line.0.y, x2 = line.1.x, y2 = line.1.y
    let dy = y2 - y1, dx = x2 - x1
    return abs((y2 - y1) * point.x - (x2 - x1) * point.y + x2 * y1 - y2 * x1) / sqrt(dy * dy + dx * dx)
}
