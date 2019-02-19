//
// Copyright (C) 2018-present Instructure, Inc.
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

import PSPDFKit

private var annotationUserNameKey: UInt8 = 0
private var annotationDeletedAtKey: UInt8 = 0
private var annotationDeletedByKey: UInt8 = 0
private var annotationDeletedByIDKey: UInt8 = 0

extension PSPDFAnnotation {
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

    var isEmpty: Bool {
        return (self is PSPDFFreeTextAnnotation || self is DocViewerCommentReplyAnnotation) && contents?.isEmpty != false
    }

    static func from(_ apiAnnotation: APIDocViewerAnnotation, metadata: APIDocViewerAnnotationsMetadata) -> PSPDFAnnotation? {
        let annotation: PSPDFAnnotation
        switch apiAnnotation.type {
        case .highlight:
            let highlight = PSPDFHighlightAnnotation()
            highlight.rects = apiAnnotation.coords?.map { NSValue(cgRect: rectFrom($0)) }
            annotation = highlight
        case .strikeout:
            let strikeout = PSPDFStrikeOutAnnotation()
            strikeout.rects = apiAnnotation.coords?.map { NSValue(cgRect: rectFrom($0)) }
            annotation = strikeout
        case .freetext:
            let freeText = PSPDFFreeTextAnnotation(contents: apiAnnotation.contents ?? "")
            let fontInfo = apiAnnotation.font?.split(separator: " ")
            let fontSizeStr = apiAnnotation.font?.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted) ?? ""
            freeText.fontName = fontInfo?.last.flatMap { String($0) } ?? "Verdana"
            freeText.fontSize = CGFloat(Int(fontSizeStr) ?? 14)
            freeText.fillColor = .white
            freeText.sizeToFit()
            annotation = freeText
        case .text: // legacy name for point
            let point = DocViewerPointAnnotation()
            annotation = point
        case .commentReply:
            let reply = DocViewerCommentReplyAnnotation(contents: apiAnnotation.contents ?? "")
            reply.inReplyToName = apiAnnotation.inreplyto
            annotation = reply
        case .ink:
            let ink = PSPDFInkAnnotation()
            ink.lines = apiAnnotation.inklist?.gestures.map { $0.map { (point: APIDocViewerInkPoint) -> NSValue in
                let intensity = interpolate(value: CGFloat(point.width ?? 1), fromMin: 1, fromMax: 3, toMin: 0.06, toMax: 1)
                return NSValue.pspdf_value(with: PSPDFDrawingPoint(location: CGPoint(x: point.x, y: point.y), intensity: intensity))
            } }
            annotation = ink
        case .square:
            let square = PSPDFSquareAnnotation()
            square.lineWidth = CGFloat(apiAnnotation.width ?? 1.0)
            annotation = square
        }

        annotation.boundingBox = apiAnnotation.rect.flatMap(rectFrom) ?? .zero
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
        switch self {
        case is PSPDFHighlightAnnotation:
            type = .highlight
        case is PSPDFStrikeOutAnnotation:
            type = .strikeout
        case is PSPDFFreeTextAnnotation:
            type = .freetext
        case is PSPDFInkAnnotation:
            type = .ink
            let lines = (self as? PSPDFInkAnnotation)?.lines ?? []
            inklist = APIDocViewerInklist(gestures: lines.map { simplify($0.map { (value: NSValue) -> APIDocViewerInkPoint in
                let point = value.pspdf_drawingPointValue
                let width = interpolate(value: point.intensity, fromMin: 0.06, fromMax: 1, toMin: 1, toMax: 3)
                return APIDocViewerInkPoint(x: Double(point.location.x), y: Double(point.location.y), width: Double(width), opacity: 1)
            }) })
        case is PSPDFSquareAnnotation:
            type = .square
        case is DocViewerCommentReplyAnnotation:
            type = .commentReply
            inreplyto = (self as? DocViewerCommentReplyAnnotation)?.inReplyToName
        case is DocViewerPointAnnotation, is PSPDFNoteAnnotation:
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
            icon: type == .text ? "Comment" : nil,
            contents: contents,
            inreplyto: inreplyto,
            coords: rects?.map { pointsFrom($0.cgRectValue) },
            rect: pointsFrom(boundingBox),
            font: fontName.flatMap { "\(Int(fontSize))pt \($0)" },
            inklist: inklist,
            width: type == .square ? Double(lineWidth) : nil
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

private func interpolate(value: CGFloat, fromMin: CGFloat, fromMax: CGFloat, toMin: CGFloat, toMax: CGFloat) -> CGFloat {
    let bounded = max(fromMin, min(value, fromMax))
    return (((toMax - toMin) / (fromMax - fromMin)) * (bounded - fromMin)) + toMin
}

internal func simplify(_ points: [APIDocViewerInkPoint], within epsilon: Double = 1.0) -> [APIDocViewerInkPoint] {
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
