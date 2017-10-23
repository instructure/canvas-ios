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
    
    

import Foundation

import ReactiveSwift
import Result


extension Session {
    fileprivate enum Associated {
        fileprivate static var progressDispatcher: UInt8 = 1
    }
    
    public var progressDispatcher: ProgressDispatcher {
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
    @available(*, deprecated: 1.0)
    public func postProgressDiscussionContributed(courseID: String, discussionTopicID: String) {
        postProgress(.contributed, type: .discussion, context: .course, contextID: courseID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressDiscussionContributed(groupID: String, discussionTopicID: String) {
        postProgress(.contributed, type: .discussion, context: .group, contextID: groupID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressDiscussionViewed(courseID: String, discussionTopicID: String) {
        postProgress(.viewed, type: .discussion, context: .course, contextID: courseID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressDiscussionViewed(groupID: String, discussionTopicID: String) {
        postProgress(.viewed, type: .discussion, context: .group, contextID: groupID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressDiscussionMarkedDone(courseID: String, discussionTopicID: String) {
        postProgress(.markedDone, type: .discussion, context: .course, contextID: courseID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressDiscussionMarkedDone(groupID: String, discussionTopicID: String) {
        postProgress(.markedDone, type: .discussion, context: .group, contextID: groupID, itemID: discussionTopicID)
    }
    
    
    
    // MARK: Pages
    @available(*, deprecated: 1.0)
    public func postProgressPageViewed(courseID: String, pageURL: NSURL) {
        postProgress(.viewed, type: .page, context: .course, contextID: courseID, itemID: pageURL.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressPageViewed(groupID: String, pageURL: NSURL) {
        postProgress(.viewed, type: .page, context: .group, contextID: groupID, itemID: pageURL.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressPageMarkedDone(courseID: String, pageURL: NSURL) {
        postProgress(.markedDone, type: .page, context: .course, contextID: courseID, itemID: pageURL.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressPageViewedMarkedDone(groupID: String, pageURL: NSURL) {
        postProgress(.markedDone, type: .page, context: .group, contextID: groupID, itemID: pageURL.absoluteString!)
    }
    
    
    
    // MARK: LTI
    @available(*, deprecated: 1.0)
    public func postProgressLTIViewed(courseID: String, toolURL: NSURL) {
        postProgress(.viewed, type: .externalTool, context: .course, contextID: courseID, itemID: toolURL.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressLTIViewed(groupID: String, toolURL: NSURL) {
        postProgress(.viewed, type: .externalTool, context: .group, contextID: groupID, itemID: toolURL.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressLTISubmitted(courseID: String, toolURL: NSURL) {
        postProgress(.submitted, type: .externalTool, context: .course, contextID: courseID, itemID: toolURL.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressLTISubmitted(groupID: String, toolURL: NSURL) {
        postProgress(.submitted, type: .externalTool, context: .group, contextID: groupID, itemID: toolURL.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressLTIMarkedDone(courseID: String, toolURL: NSURL) {
        postProgress(.markedDone, type: .externalTool, context: .course, contextID: courseID, itemID: toolURL.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressLTIMarkedDone(groupID: String, toolURL: NSURL) {
        postProgress(.markedDone, type: .externalTool, context: .group, contextID: groupID, itemID: toolURL.absoluteString!)
    }
    
    
    
    // MARK: Files
    @available(*, deprecated: 1.0)
    public func postProgressFileViewed(courseID: String, fileID: String) {
        postProgress(.viewed, type: .file, context: .course, contextID: courseID, itemID: fileID)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressFileViewed(groupID: String, fileID: String) {
        postProgress(.viewed, type: .file, context: .group, contextID: groupID, itemID: fileID)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressFileMarkedDone(courseID: String, fileID: String) {
        postProgress(.markedDone, type: .file, context: .course, contextID: courseID, itemID: fileID)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressFileViewedMarkedDone(groupID: String, fileID: String) {
        postProgress(.markedDone, type: .file, context: .group, contextID: groupID, itemID: fileID)
    }
    
    
    
    
    // MARK: External URLs
    @available(*, deprecated: 1.0)
    public func postProgressURLViewed(courseID: String, url: NSURL) {
        postProgress(.viewed, type: .url, context: .course, contextID: courseID, itemID: url.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressURLViewed(groupID: String, url: NSURL) {
        postProgress(.viewed, type: .url, context: .group, contextID: groupID, itemID: url.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressURLMarkedDone(courseID: String, url: NSURL) {
        postProgress(.markedDone, type: .url, context: .course, contextID: courseID, itemID: url.absoluteString!)
    }
    
    @available(*, deprecated: 1.0)
    public func postProgressURLViewedMarkedDone(groupID: String, url: NSURL) {
        postProgress(.markedDone, type: .url, context: .group, contextID: groupID, itemID: url.absoluteString!)
    }
    
}
