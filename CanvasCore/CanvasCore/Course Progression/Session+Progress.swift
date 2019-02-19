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

import ReactiveSwift
import Result


extension Session {
    fileprivate enum Associated {
        fileprivate static var progressDispatcher: UInt8 = 1
    }
    
    @objc public var progressDispatcher: ProgressDispatcher {
        if let dispatcher: ProgressDispatcher = getAssociatedObject(&Associated.progressDispatcher) {
            return dispatcher
        }
        
        let dispatcher = ProgressDispatcher()
        setAssociatedObject(dispatcher, forKey: &Associated.progressDispatcher)
        return dispatcher
    }
    
    fileprivate func postProgress(_ kind: Progress.Kind, type: Progress.ItemType, context: ContextID.Context, contextID: String, itemID: String) {
        let contextID = ContextID(id: contextID, context: context)
        let progress = Progress(kind: kind, contextID: contextID, itemType: type, itemID: itemID)
        progressDispatcher.dispatch(progress)
    }

    
    // MARK: - Objective-C Compatability

    // MARK: Discussions
    @objc @available(*, deprecated: 1.0)
    public func postProgressDiscussionContributed(courseID: String, discussionTopicID: String) {
        postProgress(.contributed, type: .discussion, context: .course, contextID: courseID, itemID: discussionTopicID)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressDiscussionContributed(groupID: String, discussionTopicID: String) {
        postProgress(.contributed, type: .discussion, context: .group, contextID: groupID, itemID: discussionTopicID)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressDiscussionViewed(courseID: String, discussionTopicID: String) {
        postProgress(.viewed, type: .discussion, context: .course, contextID: courseID, itemID: discussionTopicID)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressDiscussionViewed(groupID: String, discussionTopicID: String) {
        postProgress(.viewed, type: .discussion, context: .group, contextID: groupID, itemID: discussionTopicID)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressDiscussionMarkedDone(courseID: String, discussionTopicID: String) {
        postProgress(.markedDone, type: .discussion, context: .course, contextID: courseID, itemID: discussionTopicID)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressDiscussionMarkedDone(groupID: String, discussionTopicID: String) {
        postProgress(.markedDone, type: .discussion, context: .group, contextID: groupID, itemID: discussionTopicID)
    }
    
    
    
    // MARK: Pages
    @objc @available(*, deprecated: 1.0)
    public func postProgressPageViewed(courseID: String, pageURL: String) {
        postProgress(.viewed, type: .page, context: .course, contextID: courseID, itemID: pageURL)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressPageViewed(groupID: String, pageURL: String) {
        postProgress(.viewed, type: .page, context: .group, contextID: groupID, itemID: pageURL)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressPageMarkedDone(courseID: String, pageURL: String) {
        postProgress(.markedDone, type: .page, context: .course, contextID: courseID, itemID: pageURL)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressPageViewedMarkedDone(groupID: String, pageURL: String) {
        postProgress(.markedDone, type: .page, context: .group, contextID: groupID, itemID: pageURL)
    }
    
    
    
    // MARK: LTI
    @objc @available(*, deprecated: 1.0)
    public func postProgressLTIViewed(courseID: String, toolURL: String) {
        postProgress(.viewed, type: .externalTool, context: .course, contextID: courseID, itemID: toolURL)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressLTIViewed(groupID: String, toolURL: String) {
        postProgress(.viewed, type: .externalTool, context: .group, contextID: groupID, itemID: toolURL)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressLTISubmitted(courseID: String, toolURL: String) {
        postProgress(.submitted, type: .externalTool, context: .course, contextID: courseID, itemID: toolURL)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressLTISubmitted(groupID: String, toolURL: String) {
        postProgress(.submitted, type: .externalTool, context: .group, contextID: groupID, itemID: toolURL)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressLTIMarkedDone(courseID: String, toolURL: String) {
        postProgress(.markedDone, type: .externalTool, context: .course, contextID: courseID, itemID: toolURL)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressLTIMarkedDone(groupID: String, toolURL: String) {
        postProgress(.markedDone, type: .externalTool, context: .group, contextID: groupID, itemID: toolURL)
    }
    
    
    
    // MARK: Files
    @objc @available(*, deprecated: 1.0)
    public func postProgressFileViewed(courseID: String, fileID: String) {
        postProgress(.viewed, type: .file, context: .course, contextID: courseID, itemID: fileID)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressFileViewed(groupID: String, fileID: String) {
        postProgress(.viewed, type: .file, context: .group, contextID: groupID, itemID: fileID)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressFileMarkedDone(courseID: String, fileID: String) {
        postProgress(.markedDone, type: .file, context: .course, contextID: courseID, itemID: fileID)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressFileViewedMarkedDone(groupID: String, fileID: String) {
        postProgress(.markedDone, type: .file, context: .group, contextID: groupID, itemID: fileID)
    }
    
    
    
    
    // MARK: External URLs
    @objc @available(*, deprecated: 1.0)
    public func postProgressURLViewed(courseID: String, url: String) {
        postProgress(.viewed, type: .url, context: .course, contextID: courseID, itemID: url)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressURLViewed(groupID: String, url: String) {
        postProgress(.viewed, type: .url, context: .group, contextID: groupID, itemID: url)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressURLMarkedDone(courseID: String, url: String) {
        postProgress(.markedDone, type: .url, context: .course, contextID: courseID, itemID: url)
    }
    
    @objc @available(*, deprecated: 1.0)
    public func postProgressURLViewedMarkedDone(groupID: String, url: String) {
        postProgress(.markedDone, type: .url, context: .group, contextID: groupID, itemID: url)
    }
    
}
