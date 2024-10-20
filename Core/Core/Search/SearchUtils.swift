//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import SwiftUI

// MARK: Measuring Size

private struct MeasuredSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {

    public func measuringSize(_ onMeasure: @escaping (CGSize) -> Void) -> some View {
        background {
            GeometryReader { g in
                Color.clear.preference(key: MeasuredSizeKey.self, value: g.size)
            }
            .onPreferenceChange(MeasuredSizeKey.self, perform: onMeasure)
        }
    }

    public func measuringSize(_ value: Binding<CGSize>) -> some View {
        measuringSize { newSize in
            value.wrappedValue = newSize
        }
    }

    @ViewBuilder
    public func measuringSizeOnce(_ value: Binding<CGSize>) -> some View {
        if value.wrappedValue.isZero {
            measuringSize { newSize in
                value.wrappedValue = newSize
            }
        } else {
            self
        }
    }
}

extension CGSize {
    public var isZero: Bool { width == 0 && height == 0 }
}

// MARK: - Deferred Value

public struct DeferredValue<Value: Equatable>: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.value == rhs.value
    }

    private class Box<V> {
        var value: V
        init(value: V) {
            self.value = value
        }
    }

    private let box: Box<Value>
    var value: Value
    var deferred: Value {
        get { box.value }
        set { box.value = newValue }
    }

    public init(value: Value) {
        self.box = Box(value: value)
        self.value = value
    }

    mutating func update() {
        value = box.value
    }
}

// MARK: - Helpers

extension String {
    var isSearchValid: Bool {
        return count >= 2
    }
}

protocol Customizable: AnyObject { }
extension NSObject: Customizable { }

extension Customizable {
    func with(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

// MARK: - Text Search Related Utils

public extension AttributedString {

    mutating func highlight(keyword: String,
                            with attributes: AttributeContainer,
                            options mask: String.CompareOptions = []) {
        let string = String(characters)
        for range in string.ranges(of: keyword, options: mask) {
            if let start = AttributedString.Index(range.lowerBound, within: self),
               let end = AttributedString.Index(range.upperBound, within: self) {
                self[start ..< end].setAttributes(attributes)
            }
        }
    }

    func numberOfCharacters(in size: CGSize, lineLimit: Int?) -> Int {
        let layoutManager = NSLayoutManager()
        let storage = NSTextStorage(self)
        storage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: CGSize(width: size.width, height: CGFloat.infinity))
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        var lines: Int = 0
        var lineRange: NSRange = NSRange(location: 0, length: 0)
        var index = 0
        while index < layoutManager.numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            lines += 1

            if let limit = lineLimit, lines == limit { return index }
        }

        return index
    }
}

public extension String {

    func truncated(around range: Range<String.Index>, maxLength: Int) -> String {
        guard maxLength < count else { return self }

        let length = maxLength - distance(from: range.lowerBound, to: range.upperBound)

        let word = self[range]
        var prefix = prefix(upTo: range.lowerBound)
        var suffix = suffix(from: range.upperBound)

        let prefixLength: Int
        let suffixLength: Int

        if prefix.count > suffix.count {
            prefixLength = min(prefix.count, length - min(length / 2, suffix.count))
            suffixLength = length - prefixLength
        } else {
            suffixLength = min(suffix.count, length - min(length / 2, prefix.count))
            prefixLength = length - suffixLength
        }

        let prefixEllipses = prefixLength < prefix.count
        let suffixEllipses = suffixLength < suffix.count

        let cPrefixLength = max(prefixLength - (prefixEllipses ? 3 : 0), 0)
        let cSuffixLength = max(suffixLength - (suffixEllipses ? 3 : 0), 0)

        prefix = prefix.suffix(cPrefixLength)
        suffix = suffix.prefix(cSuffixLength)

        return [
            prefixEllipses ? "..." : "",
            prefix,
            word,
            suffix,
            suffixEllipses ? "..." : ""
        ].joined()
    }

    func truncated(around word: String, maxLength: Int, options mask: CompareOptions = []) -> String {
        let ranges = ranges(of: word, options: mask)
        let start = ranges.map({ $0.lowerBound }).min()
        var end: String.Index?

        for range in ranges {
            guard let start else { continue }
            guard let setEnd = end else {
                end = range.upperBound
                continue
            }

            let distance = distance(from: start, to: range.upperBound)
            if range.upperBound > setEnd && distance <= maxLength {
                end = range.upperBound
            }
        }

        guard let start, let end else {
            let truncatesEnd = count > maxLength
            let newLength = truncatesEnd ? maxLength - 3 : maxLength
            let ellipses = truncatesEnd ? "..." : ""
            return String(prefix(newLength)) + ellipses
        }

        return truncated(around: start ..< end, maxLength: maxLength)
    }

    func ranges(of keyword: String, options mask: CompareOptions = []) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        var searchRange = startIndex ..< endIndex
        while let range = self.range(of: keyword, options: mask, range: searchRange) {
            ranges.append(range)
            searchRange = range.upperBound ..< endIndex
        }
        return ranges
    }
}
