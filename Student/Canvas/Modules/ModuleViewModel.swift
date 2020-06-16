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

import ReactiveSwift
import CanvasCore

class ModuleViewModel {
    // Input
    let session: Session
    let courseID: String
    let moduleID: String
    let prerequisite = MutableProperty<Bool>(false)

    // Output
    let name: Property<String?>
    let prerequisiteModuleIDs: Property<[String]>
    lazy var unlockDate: Property<String?> = module.map { [weak self] module in
        guard module?.state == .locked,
            let unlockDate = module?.unlockDate,
            let formatter = self?.unlockDateFormatter else { return nil }
        let template = NSLocalizedString("Locked until %@", comment: "locked date")
        return String.localizedStringWithFormat(template, formatter.string(from: unlockDate))
    }

    // Private
    fileprivate let module: Property<Module?>
    fileprivate let observer: ManagedObjectObserver<Module>
    fileprivate let itemsCollection: FetchedCollection<ModuleItem>
    fileprivate let itemsUpdated: Property<[CollectionUpdate<ModuleItem>]>
    fileprivate let disposable = CompositeDisposable()
    fileprivate lazy var unlockDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    lazy var colorfulViewModel: ColorfulViewModel = {
        var vm = ColorfulViewModel(features: [.subtitle])
        vm.title <~ self.module.producer.map { $0?.name ?? "" }
        vm.subtitle <~ self.unlockDate.producer.map { $0 ?? "" }
        vm.icon <~ self.prerequisite.producer.map { $0 ? .icon(.prerequisite) : nil }
        vm.features <~ self.prerequisite.producer.map { $0 ? [.icon, .subtitle] : [.subtitle] }
        vm.accessibilityIdentifier.value = "module"
        vm.titleLineBreakMode = .byWordWrapping

        vm.color <~ self.session.enrollmentsDataSource.color(for: .course(self.courseID))

        let state = self.module.producer.map { $0?.state }
        vm.accessoryView <~ state.map { (state) -> UIView? in
            guard let state = state else { return nil }
            let imageView = UIImageView(image: state.image)
            let green = UIColor(red: 76.0/255.0, green: 174.0/255.0, blue: 78.0/255.0, alpha: 1.0)
            imageView.tintColor = state == .completed ? green : UIColor.prettyGray()
            return imageView
        }
        vm.accessibilityLabel <~ SignalProducer.combineLatest(vm.title.producer, vm.subtitle.producer, state)
            .map { title, detail, state -> String in
                let status: String?
                switch state {
                case .some(.locked):
                    status = NSLocalizedString("Status: Locked", comment: "Module status label when locked")
                case .some(.started):
                    status = NSLocalizedString("Status: Started", comment: "Module status label when started")
                case .some(.completed):
                    status = NSLocalizedString("Status: Completed", comment: "Module status label when completed")
                default:
                    status = nil
                }
                return [title, detail, status].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ". ")
            }

        return vm
    }()

    init(session: Session, courseID: String, moduleID: String) throws {
        self.session = session
        self.courseID = courseID
        self.moduleID = moduleID

        observer = try Module.observer(session: session, moduleID: moduleID)
        module = Property(initial:  observer.object, then: observer.signal.map { $0.1 })

        itemsCollection = try ModuleItem.allModuleItemsCollection(session, moduleID: moduleID)
        itemsUpdated = Property(initial:  [], then: itemsCollection.collectionUpdates)

        name = module.map { $0?.name }
        prerequisiteModuleIDs = module.map { $0?.prerequisiteModuleIDs ?? [] }
    }

    convenience init(session: Session, module: Module, prerequisite: Bool = false) throws {
        try self.init(session: session, courseID: module.courseID, moduleID: module.id)
        self.prerequisite.value = prerequisite
    }
}

extension ModuleViewModel: TableViewCellViewModel {
    static func tableViewDidLoad(_ tableView: UITableView) {
        ColorfulViewModel.tableViewDidLoad(tableView)
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
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
