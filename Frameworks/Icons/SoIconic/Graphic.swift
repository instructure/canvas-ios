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
