//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit
import CoreData
import ReactiveSwift
import Core

extension File {
    public static func observer(_ session: Session, backgroundSessionID: String) throws -> ManagedObjectObserver<FileUpload> {
        let pred = NSPredicate(format: "%K == %@", "backgroundSessionID", backgroundSessionID)
        let context = try session.filesManagedObjectContext()
        return try ManagedObjectObserver<FileUpload>(predicate: pred, inContext: context)
    }
    
    static func collectionCacheKey(_ context: NSManagedObjectContext, contextID: ContextID, folderID: String?) -> String {
        return cacheKey(context, [contextID.canvasContextID, folderID].compactMap { $0 })
    }
    
    open class DetailViewController: UIViewController {
        fileprivate let session: Session
        fileprivate let file: File
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        @objc public init(session: Session, file: File) {
            self.file = file
            self.session = session
            super.init(nibName: nil, bundle: nil)
       }
        
        override open func viewDidLoad() {
            super.viewDidLoad()

            let webView = CanvasWebView()
            webView.load(source: .url(file.url))
            webView.backgroundColor = .named(.backgroundLightest)
            self.view = webView
            self.edgesForExtendedLayout = UIRectEdge()
        }
    }
}
