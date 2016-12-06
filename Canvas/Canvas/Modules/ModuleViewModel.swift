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

import SoEdventurous
import SoPersistent
import TooLegit
import SoPretty
import ReactiveCocoa
import Result
import SoIconic
import EnrollmentKit
import SoLazy
import SoProgressive

class ModuleViewModel {
    // Input
    let session: Session
    let courseID: String
    let moduleID: String
    let prerequisite = MutableProperty<Bool>(false)

    // Output
    let name: AnyProperty<String?>
    let prerequisiteModuleIDs: AnyProperty<[String]>
    lazy var unlockDate: AnyProperty<String?> = {
        return self.module
            .map { $0?.unlockDate }
            .map { $0.flatMap(self.unlockDateFormatter.stringFromDate) }
            .map {
                $0.flatMap {
                    let template = NSLocalizedString("Locked until %@", comment: "locked date")
                    return String.localizedStringWithFormat(template, $0)
                }
        }
    }()

    // Private
    private let module: AnyProperty<Module?>
    private let observer: ManagedObjectObserver<Module>
    private let itemsCollection: FetchedCollection<ModuleItem>
    private let itemsUpdated: AnyProperty<[CollectionUpdate<ModuleItem>]>
    private let disposable = CompositeDisposable()
    private lazy var unlockDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        return formatter
    }()
    lazy var colorfulViewModel: ColorfulViewModel = {
        var vm = ColorfulViewModel(style: .Subtitle)
        vm.title <~ self.module.producer.map { $0?.name ?? "" }
        vm.detail <~ self.unlockDate.producer.map { $0 ?? "" }
        vm.icon <~ self.prerequisite.producer.map { $0 ? .icon(.prerequisite) : nil }
        vm.accessibilityIdentifier.value = "module"
        vm.titleLineBreakMode = .ByWordWrapping

        let enrollmentDataSource = self.session.enrollmentsDataSource.producer(ContextID(id: self.courseID, context: .Course))
        vm.color <~ enrollmentDataSource.map { $0?.color ?? .prettyGray() }

        let state = self.module.producer.map { $0?.state }
        vm.accessoryView <~ state.map { state in
            guard let state = state else { return nil }
            let imageView = UIImageView(image: state.image)
            let green = UIColor(red: 76.0/255.0, green: 174.0/255.0, blue: 78.0/255.0, alpha: 1.0)
            imageView.tintColor = state == .completed ? green : UIColor.prettyGray()
            return imageView
        }
        vm.accessibilityLabel <~ combineLatest(vm.title.producer, vm.detail.producer, state)
            .map { title, detail, state in
                let status: String?
                switch state {
                case .Some(.locked):
                    status = NSLocalizedString("Status: Locked", comment: "Module status label when locked")
                case .Some(.started):
                    status = NSLocalizedString("Status: Started", comment: "Module status label when started")
                case .Some(.completed):
                    status = NSLocalizedString("Status: Completed", comment: "Module status label when completed")
                default:
                    status = nil
                }
                return [title, detail, status].flatMap { $0 }.filter { !$0.isEmpty }.joinWithSeparator(". ")
            }

        return vm
    }()

    init(session: Session, courseID: String, moduleID: String) throws {
        self.session = session
        self.courseID = courseID
        self.moduleID = moduleID

        observer = try Module.observer(session, moduleID: moduleID)
        module = AnyProperty(initialValue: observer.object, signal: observer.signal.map { $0.1 })

        itemsCollection = try ModuleItem.allModuleItemsCollection(session, moduleID: moduleID)
        itemsUpdated = AnyProperty(initialValue: [], signal: itemsCollection.collectionUpdates)

        name = module.map { $0?.name }
        prerequisiteModuleIDs = module.map { $0?.prerequisiteModuleIDs ?? [] }
    }

    convenience init(session: Session, module: Module, prerequisite: Bool = false) throws {
        try self.init(session: session, courseID: module.courseID, moduleID: module.id)
        self.prerequisite.value = prerequisite
    }
}

extension ModuleViewModel: TableViewCellViewModel {
    static func tableViewDidLoad(tableView: UITableView) {
        ColorfulViewModel.tableViewDidLoad(tableView)
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        return colorfulViewModel.cellForTableView(tableView, indexPath: indexPath)
    }
}

extension Module.State {
    var image: UIImage {
        switch self {
        case .locked:       return .icon(.lock, size: .small)
        case .unlocked:     return .icon(.unlock, size: .small)
        case .started:      return .icon(.empty, size: .small)
        case .completed:    return .icon(.complete, filled: true, size: .small)
        }
    }
}
