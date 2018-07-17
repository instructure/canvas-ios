//
// Copyright (C) 2018-present Instructure, Inc.
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

public func registerSharedNativeViewControllers() {
    HelmManager.shared.registerNativeViewController(for: "/support/:type", factory: { props in
        guard let type = props["type"] as? String else { return nil }
        
        let storyboard = UIStoryboard(name: "SupportTicket", bundle: Bundle(for: SupportTicketViewController.self))
        let controller = storyboard.instantiateInitialViewController()!.childViewControllers[0] as! SupportTicketViewController
        if type == "feature" {
            controller.ticketType = SupportTicketTypeFeatureRequest
        } else {
            controller.ticketType = SupportTicketTypeProblem
        }
        return UINavigationController(rootViewController: controller)
    })
}
