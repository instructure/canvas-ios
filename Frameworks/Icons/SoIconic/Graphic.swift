//
//  Graphic.swift
//  Icons
//
//  Created by Nathan Armstrong on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

public struct Graphic {
    public let icon: Icon
    public let filled: Bool
    public let size: Icon.Size

    public init(icon: Icon, filled: Bool = false, size: Icon.Size = .standard) {
        self.icon = icon
        self.filled = filled
        self.size = size
    }

    public var image: UIImage {
        return .icon(icon, filled: filled, size: size)
    }
}

extension Graphic: Equatable {}
public func ==(lhs: Graphic, rhs: Graphic) -> Bool {
    return lhs.icon == rhs.icon &&
        lhs.filled == rhs.filled &&
        lhs.size == rhs.size
}
