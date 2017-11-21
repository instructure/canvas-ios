//
//  LTIViewController.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 11/7/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation
import UIKit
import Marshal

public class LTIViewController: CanvasWebViewController {
    let session: Session
    let context: ContextID?
    let launchURL: URL
    let toolName: String
    
    public init(toolName: String, courseID: String?, launchURL: URL, in session: Session, showDoneButton: Bool) {
        self.session = session
        self.toolName = toolName
        self.launchURL = launchURL
        self.context = courseID.map { .course(withID: $0) }
        super.init(showDoneButton: showDoneButton)
        
        initiateLTISession()
    }
    
    private func initiateLTISession() {
        let request = URLRequest(url: launchURL).authorized(with: session)
        let cache = session.URLSession.configuration.urlCache
        cache?.removeCachedResponse(for: request)
        
        session.JSONSignalProducer(request).start { [weak self] event in
            DispatchQueue.main.async {
                guard let me = self else { return }
                switch event {
                case .value(let ltiLaunch):
                    guard
                        let toolURL: URL = try? ltiLaunch <| "url",
                        let mobileURL = toolURL.appending(value: "mobile", forQueryParameter: "platform")
                    else {
                        me.webView.load(source:
                            .error(NSLocalizedString("Error retrieving tool launch URL", comment: "LTI Launch failed"))
                        )
                        return
                    }
                    
                    me.webView.load(source: .url(mobileURL))
                    if let context = me.context {
                        me.session.progressDispatcher.dispatch(
                            Progress(
                                kind: .viewed,
                                contextID: context,
                                itemType: Progress.ItemType.externalTool,
                                itemID: me.launchURL.absoluteString
                            )
                        )
                    }
                case .failed(let error):
                    me.webView.load(source: .error(error.localizedDescription))
                default:
                    break
                }
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }
}
