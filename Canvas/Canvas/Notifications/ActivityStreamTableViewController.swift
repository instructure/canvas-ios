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
import ReactiveCocoa
import ReactiveSwift
import CanvasCore

extension Activity {
    var icon: UIImage? {
        switch type {
        case .discussion:       return .icon(.discussion)
        case .announcement:     return .icon(.announcement)
        case .conversation:     return .icon(.email)
        case .message:          return .icon(.assignment)
        case .submission:       return .icon(.assignment)
        case .conference:       return .icon(.conference)
        case .collaboration:    return .icon(.collaboration)
        case .assessmentRequest:return .icon(.quiz)
        }
    }
}

private func colorfulActivity(session: Session) -> ((Activity) -> ColorfulViewModel) {
    return { activity in
        var vm: ColorfulViewModel
        if activity.context.context == .course {
            vm = ColorfulViewModel(features: [.icon, .subtitle, .token])
        } else if activity.type != .conversation {
            vm = ColorfulViewModel(features: [.icon, .subtitle])
        } else {
            vm = ColorfulViewModel(features: [.icon])
        }

        let courseProducer = session
            .enrollmentsDataSource
            .producer(activity.context)

        if activity.type == .conversation {
            vm.title.value = NSLocalizedString("New Message", comment: "")
        } else {
            vm.title.value = activity.title
        }
        vm.titleLineBreakMode = .byWordWrapping
        vm.subtitle.value = " "
        vm.subtitle <~ courseProducer.map { $0?.name ?? "" }
        vm.icon.value = activity.icon

        vm.color <~ session.enrollmentsDataSource.color(for: activity.context)
        vm.tokenViewText <~ courseProducer.map { $0?.shortName ?? "" }

        return vm
    }
}

class ActivityStreamTableViewController: FetchedTableViewController<Activity> {
    let route: (UIViewController, URL)->()

    init(session: Session, context: ContextID = .currentUser, route: @escaping (UIViewController, URL)->()) throws {
        self.route = route
        super.init()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0

        prepare(try Activity.collection(session: session, context: context), refresher: try Activity.refresher(session: session, context: context), viewModelFactory: colorfulActivity(session: session))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activity = collection[indexPath]
        route(self, activity.url)
    }
}
