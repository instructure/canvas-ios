//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Foundation

public enum DiscussionCheckpointStep: Equatable {
    case replyToTopic
    case requiredReplies(Int)

    public init?(tag: String?, requiredReplyCount: Int?) {
        switch tag {
        case "reply_to_topic":
            self = .replyToTopic
        case "reply_to_entry":
            if let requiredReplyCount {
                self = .requiredReplies(requiredReplyCount)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

// MARK: - CoreData support

private extension DiscussionCheckpointStep {
    var tag: String {
        switch self {
        case .replyToTopic: "reply_to_topic"
        case .requiredReplies: "reply_to_entry"
        }
    }

    var requiredReplyCount: Int? {
        switch self {
        case .replyToTopic: nil
        case .requiredReplies(let count): count
        }
    }
}

final class DiscussionCheckpointStepWrapper: NSObject, NSSecureCoding {
    private enum Key {
        static let tag = "tag"
        static let requiredReplyCount = "requiredReplyCount"
    }

    static var supportsSecureCoding: Bool { true }

    let value: DiscussionCheckpointStep

    init(value: DiscussionCheckpointStep) {
        self.value = value
    }

    init?(value: DiscussionCheckpointStep?) {
        guard let value else { return nil }
        self.value = value
    }

    required init?(coder: NSCoder) {
        guard let tag = coder.decodeObject(of: NSString.self, forKey: Key.tag) as? String else {
            return nil
        }

        // optional parameters
        let requiredReplyCount = coder.decodeObject(of: NSNumber.self, forKey: Key.requiredReplyCount)?.intValue

        guard let value = DiscussionCheckpointStep(tag: tag, requiredReplyCount: requiredReplyCount) else {
            return nil
        }

        self.value = value
    }

    func encode(with coder: NSCoder) {
        coder.encode(value.tag, forKey: Key.tag)
        coder.encode(value.requiredReplyCount, forKey: Key.requiredReplyCount)
    }
}

final class DiscussionCheckpointStepTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: DiscussionCheckpointStepTransformer.self))
    override static var allowedTopLevelClasses: [AnyClass] { [DiscussionCheckpointStepWrapper.self] }

    static func register() {
        let transformer = DiscussionCheckpointStepTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
