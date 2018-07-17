//
// Copyright (C) 2017-present Instructure, Inc.
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


extension Assignment {
    public class func arcSubmissionLTILaunchURL(session: Session, context: ContextID, assignmentID: String, arcLTIToolID: String) -> URL? {
        guard context.context == .course || context.context == .group else { return nil }
        
        var url: URL? = session.baseURL
        url?.appendPathComponent(context.htmlPath/"external_tools"/arcLTIToolID/"resource_selection")
        url = url?.appending(URLQueryItem(name: "launch_type", value: "homework_submission"))?.appending(URLQueryItem(name: "assignment_id", value: assignmentID))
        
        return url
    }
    
    /// Helper for Objective-C compatability
    ///
    /// - parameter session:        The session to build the URL off of
    /// - parameter contextType:    The context string type, use either "course" or "group" for now
    /// - parameter contextID:      The id for the context being used
    /// - parameter assignmentID:   The assignment id this submission URL is being created for
    /// - parameter arcLTIToolID:   The id of the lti tool to use
    public class func arcSubmissionLTILaunchURL(session: Session, contextType: String, contextID: String, assignmentID: String, arcLTIToolID: String) -> URL? {
        let context: ContextID
        switch contextType {
        case "course":
            context = ContextID(id: contextID, context: .course)
        case "group":
            context = ContextID(id: contextID, context: .group)
        default:
            return nil
        }
        
        return Assignment.arcSubmissionLTILaunchURL(session: session, context: context, assignmentID: assignmentID, arcLTIToolID: arcLTIToolID)
    }
}
