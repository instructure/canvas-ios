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
    
    

import UIKit


import CoreData
import ReactiveSwift

extension File {
    public static func observer(_ session: Session, backgroundSessionID: String) throws -> ManagedObjectObserver<FileUpload> {
        let pred = NSPredicate(format: "%K == %@", "backgroundSessionID", backgroundSessionID)
        let context = try session.filesManagedObjectContext()
        return try ManagedObjectObserver<FileUpload>(predicate: pred, inContext: context)
    }
    
    static func collectionCacheKey(_ context: NSManagedObjectContext, contextID: ContextID, folderID: String?) -> String {
        return cacheKey(context, [contextID.canvasContextID, folderID].flatMap { $0 })
    }
    
    open class DetailViewController: UIViewController {
        fileprivate let session: Session
        fileprivate let file: File
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        public init(session: Session, file: File) {
            self.file = file
            self.session = session
            super.init(nibName: nil, bundle: nil)
       }
        
        override open func viewDidLoad() {
            super.viewDidLoad()

            let webView: UIWebView = UIWebView()
            webView.scalesPageToFit = true
            let request: URLRequest = URLRequest(url: self.file.url as URL)
            webView.loadRequest(request)
            webView.backgroundColor = UIColor.white
            self.view = webView
            self.automaticallyAdjustsScrollViewInsets = false
            self.edgesForExtendedLayout = UIRectEdge()
        }
    }
}
