//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import ViewInspector

@available(iOS 13.0, *)
public struct ErasedView {
    public let view: Any
    public let viewType: KnownViewType.Type
    public let subViews: [ErasedView]?
    public var isUnknown: Bool { subViews == nil }

    public init(_ view: Any, viewType: KnownViewType.Type = ViewType.ClassifiedView.self, subViews: [ErasedView]?) {
        self.view = view
        self.viewType = viewType
        self.subViews = subViews
    }

    public init<V: View, Body: View>(_ view: V, body: Body) {
        self.init(view, subViews: [ErasedView(body)])
    }

    public init?(_ view: Any?) {
        guard let view = view else { return nil }
        self.init(view)
    }

    public init(_ view: Any) {
        if let view = view as? CustomErasable {
            self = view.erased
        } else {
            self.view = view
            self.viewType = ViewType.ClassifiedView.self
            self.subViews = nil
        }
    }

    public init<T: SingleViewContent>(_ view: Any, _ viewType: T.Type) {
        self.init(try! viewType.child(Content(view)).view)
    }

    public init<T: KnownViewType>(_ view: Any, _ viewType: T.Type) where T: MultipleViewContent {
        self.view = view
        self.viewType = viewType
        if let group = try? viewType.children(Content(view)) {
            var subviews: [ErasedView] = []
            for i in 0 ..< group.count {
                do {
                    subviews.append(try ErasedView(group.element(at: i).view))
                } catch InspectionError.viewNotFound {
                } catch _ {
                    fatalError()
                }
            }
            self.subViews = subviews
        } else {
            self.subViews = nil
        }
    }

    public var lazy: AnySequence<ErasedView> {
        AnySequence<ErasedView>([
            [self],
            (subViews ?? []).flatMap { $0.lazy },
        ].lazy.joined())
    }

    public func findAll<V: View>(_: V.Type = V.self) -> [V] {
        Array(compactMap { $0.view as? V })
    }

    public func findAll<V: KnownViewType>(_ type: V.Type) -> [ErasedView] {
        filter { $0.viewType == type }
    }

    public func first<V: View>(_: V.Type = V.self) -> V? {
        compactMap { $0.view as? V }.first
    }

    public func first<V: KnownViewType>(_ type: V.Type) -> ErasedView? {
        filter { $0.viewType == type }.first
    }

    public var allTexts: [String?] {
        findAll(Text.self).map {
            try? $0.inspect().text().string()
        }
    }

    public var allImageNames: [String?] {
        findAll(Image.self).map {
            try? $0.inspect().image().imageName()
        }
    }

    public func forEach(_ callback: (ErasedView) -> Void) {
        callback(self)
        for view in subViews ?? [] {
            view.forEach(callback)
        }
    }

    public var unknownTypes: Set<String> {
        var types = Set<String>()
        forEach { view in
            if view.isUnknown {
                types.insert("\(type(of: view.view))")
            }
        }
        return types
    }
}

@available(iOS 13.0, *)
extension ErasedView: Sequence {
    public typealias Element = ErasedView
    public typealias Iterator = AnySequence<ErasedView>.Iterator

    public __consuming func makeIterator() -> AnySequence<ErasedView>.Iterator {
        lazy.makeIterator()
    }
}

@available(iOS 13.0, *)
public protocol CustomErasable {
    var erased: ErasedView { get }
}

@available(iOS 13.0, *)
extension _ConditionalContent: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.ConditionalContent.self)
    }
}

@available(iOS 13.0, *)
extension HStack: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.HStack.self)
    }
}

@available(iOS 13.0, *)
extension TupleView: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.Tuple.self)
    }
}

@available(iOS 13.0, *)
extension VStack: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.VStack.self)
    }
}

@available(iOS 13.0, *)
extension ZStack: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.ZStack.self)
    }
}

@available(iOS 13.0, *)
extension List: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.List.self)
    }
}

@available(iOS 13.0, *)
extension Form: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.Form.self)
    }
}

@available(iOS 13.0, *)
extension Section: CustomErasable {
    public var erased: ErasedView {
        let header = [Mirror(reflecting: self).descendant("header")].compactMap { ErasedView($0) }
        let contents = ErasedView(self, ViewType.Section.self)
        return ErasedView(contents.view, viewType: contents.viewType, subViews: header + (contents.subViews ?? []))
    }
}

@available(iOS 13.0, *)
extension ForEach: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.ForEach.self)
    }
}

@available(iOS 13.0, *)
extension Button: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.Button.self)
    }
}

@available(iOS 13.0, *)
extension AnyView: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.AnyView.self)
    }
}

@available(iOS 13.0, *)
extension Group: CustomErasable {
    public var erased: ErasedView {
        ErasedView(self, ViewType.Group.self)
    }
}

@available(iOS 13.0, *)
extension ModifiedContent: CustomErasable {
    public var erased: ErasedView {
        ErasedView(content)
    }
}

// fallback
@available(iOS 13.0, *)
extension View {
    public var erased: ErasedView {
        ErasedView(self)
    }
}

extension ViewType {
    struct Tuple: ViewInspector.KnownViewType, MultipleViewContent {
        static let typePrefix: String = "Tuple"

        static func children(_ content: Content) throws -> LazyGroup<Content> {
            try Inspector.viewsInContainer(view: content.view)
        }
    }
}
