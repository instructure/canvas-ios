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

import Foundation
import CanvasKit1
import Reachability
import CanvasCore

class NetworkMonitor: NSObject {
    @objc static func engage() {
        NotificationCenter.default.addObserver(sharedMonitor, selector: #selector(networkActivityStarted), name: NSNotification.Name.CKCanvasNetworkRequestStarted, object: nil)
        NotificationCenter.default.addObserver(sharedMonitor, selector: #selector(networkActivityEnded), name: NSNotification.Name.CKCanvasNetworkRequestFinished, object: nil)
        
    }
    
    fileprivate static let sharedMonitor = NetworkMonitor()
    
    fileprivate var inflightNetworkOps = 0
    
    @objc func networkActivityStarted() {
        inflightNetworkOps += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    @objc func networkActivityEnded() {
        inflightNetworkOps -= 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = inflightNetworkOps > 0
    }
}
