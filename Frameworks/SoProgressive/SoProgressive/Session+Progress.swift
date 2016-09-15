//
//  Session+Progress.swift
//  SoProgressive
//
//  Created by Derrick Hathaway on 4/4/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import ReactiveCocoa
import Result


extension Session {
    private enum Associated {
        private static var progressDispatcher: UInt8 = 1
    }
    
    public var progressDispatcher: ProgressDispatcher {
        if let dispatcher: ProgressDispatcher = getAssociatedObject(&Associated.progressDispatcher) {
            return dispatcher
        }
        
        let dispatcher = ProgressDispatcher()
        setAssociatedObject(dispatcher, forKey: &Associated.progressDispatcher)
        return dispatcher
    }
    
    private func postProgress(kind: Progress.Kind, type: Progress.ItemType, context: ContextID.Context, contextID: String, itemID: String) {
        let contextID = ContextID(id: contextID, context: context)
        let progress = Progress(kind: kind, contextID: contextID, itemType: type, itemID: itemID)
        progressDispatcher.dispatch(progress)
    }
    
    
    // MARK: - Objective-C Compatability
    
    // MARK: Discussions
    @available(*, deprecated=1.0)
    public func postProgressDiscussionContributed(courseID courseID: String, discussionTopicID: String) {
        postProgress(.Contributed, type: .Discussion, context: .Course, contextID: courseID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressDiscussionContributed(groupID groupID: String, discussionTopicID: String) {
        postProgress(.Contributed, type: .Discussion, context: .Group, contextID: groupID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressDiscussionViewed(courseID courseID: String, discussionTopicID: String) {
        postProgress(.Viewed, type: .Discussion, context: .Course, contextID: courseID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressDiscussionViewed(groupID groupID: String, discussionTopicID: String) {
        postProgress(.Viewed, type: .Discussion, context: .Group, contextID: groupID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressDiscussionMarkedDone(courseID courseID: String, discussionTopicID: String) {
        postProgress(.MarkedDone, type: .Discussion, context: .Course, contextID: courseID, itemID: discussionTopicID)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressDiscussionMarkedDone(groupID groupID: String, discussionTopicID: String) {
        postProgress(.MarkedDone, type: .Discussion, context: .Group, contextID: groupID, itemID: discussionTopicID)
    }
    
    
    
    // MARK: Pages
    @available(*, deprecated=1.0)
    public func postProgressPageViewed(courseID courseID: String, pageURL: NSURL) {
        postProgress(.Viewed, type: .Page, context: .Course, contextID: courseID, itemID: pageURL.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressPageViewed(groupID groupID: String, pageURL: NSURL) {
        postProgress(.Viewed, type: .Page, context: .Group, contextID: groupID, itemID: pageURL.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressPageMarkedDone(courseID courseID: String, pageURL: NSURL) {
        postProgress(.MarkedDone, type: .Page, context: .Course, contextID: courseID, itemID: pageURL.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressPageViewedMarkedDone(groupID groupID: String, pageURL: NSURL) {
        postProgress(.MarkedDone, type: .Page, context: .Group, contextID: groupID, itemID: pageURL.absoluteString)
    }
    
    
    
    // MARK: LTI
    @available(*, deprecated=1.0)
    public func postProgressLTIViewed(courseID courseID: String, toolURL: NSURL) {
        postProgress(.Viewed, type: .ExternalTool, context: .Course, contextID: courseID, itemID: toolURL.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressLTIViewed(groupID groupID: String, toolURL: NSURL) {
        postProgress(.Viewed, type: .ExternalTool, context: .Group, contextID: groupID, itemID: toolURL.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressLTISubmitted(courseID courseID: String, toolURL: NSURL) {
        postProgress(.Submitted, type: .ExternalTool, context: .Course, contextID: courseID, itemID: toolURL.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressLTISubmitted(groupID groupID: String, toolURL: NSURL) {
        postProgress(.Submitted, type: .ExternalTool, context: .Group, contextID: groupID, itemID: toolURL.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressLTIMarkedDone(courseID courseID: String, toolURL: NSURL) {
        postProgress(.MarkedDone, type: .ExternalTool, context: .Course, contextID: courseID, itemID: toolURL.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressLTIMarkedDone(groupID groupID: String, toolURL: NSURL) {
        postProgress(.MarkedDone, type: .ExternalTool, context: .Group, contextID: groupID, itemID: toolURL.absoluteString)
    }
    
    
    
    // MARK: Files
    @available(*, deprecated=1.0)
    public func postProgressFileViewed(courseID courseID: String, fileID: String) {
        postProgress(.Viewed, type: .File, context: .Course, contextID: courseID, itemID: fileID)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressFileViewed(groupID groupID: String, fileID: String) {
        postProgress(.Viewed, type: .File, context: .Group, contextID: groupID, itemID: fileID)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressFileMarkedDone(courseID courseID: String, fileID: String) {
        postProgress(.MarkedDone, type: .File, context: .Course, contextID: courseID, itemID: fileID)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressFileViewedMarkedDone(groupID groupID: String, fileID: String) {
        postProgress(.MarkedDone, type: .File, context: .Group, contextID: groupID, itemID: fileID)
    }
    
    
    
    
    // MARK: External URLs
    @available(*, deprecated=1.0)
    public func postProgressURLViewed(courseID courseID: String, url: NSURL) {
        postProgress(.Viewed, type: .URL, context: .Course, contextID: courseID, itemID: url.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressURLViewed(groupID groupID: String, url: NSURL) {
        postProgress(.Viewed, type: .URL, context: .Group, contextID: groupID, itemID: url.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressURLMarkedDone(courseID courseID: String, url: NSURL) {
        postProgress(.MarkedDone, type: .URL, context: .Course, contextID: courseID, itemID: url.absoluteString)
    }
    
    @available(*, deprecated=1.0)
    public func postProgressURLViewedMarkedDone(groupID groupID: String, url: NSURL) {
        postProgress(.MarkedDone, type: .URL, context: .Group, contextID: groupID, itemID: url.absoluteString)
    }
    
}
