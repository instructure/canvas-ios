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
import TooLegit
import Pathetic

class Route {
    enum Presentation {
        case master
        case detail
        case modal(UIModalPresentationStyle)
    }
    
    let presentation: Presentation
    let factory: (URL, Session, Navigator) throws -> UIViewController?
    
    init<P>(presentation: Presentation, path: PathTemplate<P>, factory: @escaping (P, Session, Navigator) throws -> UIViewController?) {
        self.presentation = presentation
        self.factory = { (url, session, navigator) -> UIViewController? in
            return try path.match(url.path)
                .flatMap { try factory($0, session, navigator) }
        }
    }
    
    func constructViewController(for url: URL, in session: Session, navigator: Navigator) throws -> UIViewController? {
        return try factory(url, session, navigator)
    }
}

typealias RouteAction = (UIViewController, URL) throws -> ()
