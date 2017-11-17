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


import CoreData

import CanvasCore

struct AccountDomainViewModel: TableViewCellViewModel {

    let name: String
    let domain: String

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(UINib(nibName: "AccountDomainTableViewCell", bundle: Bundle(for: SelectSessionTableViewCell.self)), forCellReuseIdentifier: "AccountDomainViewModel")
    }
    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountDomainViewModel", for: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = domain
        return cell
    }
}

import ReactiveSwift
import CoreData

open class AccountDomainListViewController: UITableViewController {

    var collection: FetchedCollection<AccountDomain>
    open var dataSource: TableViewDataSource?

    let syncProducer: SignalProducer<[AccountDomain], NSError>
    var disposable: Disposable?
    var pickedDomainAction: ((AccountDomain)->Void)?
    var collectionUpdatesDisposable: Disposable?

    let context: NSManagedObjectContext = {
        let bundle = Bundle(for: AccountDomain.self)
        guard let model = NSManagedObjectModel(named: "Keymaster", inBundle:bundle) else { ❨╯°□°❩╯⌢"problems?" }

        let storeURL = AccountDomainListViewController.localStoreDirectoryURL().appendingPathComponent("account_domains.sqlite")

        let context = try! NSManagedObjectContext(storeURL: storeURL, model: model, cacheReset: {})
        return context
    }()

    static func localStoreDirectoryURL() -> URL {
        guard let lib = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else { ❨╯°□°❩╯⌢"GASP! There were no user library search paths" }
        let fileURL = URL(fileURLWithPath: lib)
        return fileURL
    }

    var searchTerm: String = "" {
        didSet {
            collection = try! AccountDomain.collectionBySearchTerm(context, searchTerm: searchTerm)
            tableView.reloadData()
        }
    }

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    public init() {
        self.collection = try! AccountDomain.collection(context)
        let remote = try! AccountDomain.getAccountDomains()
        self.syncProducer = AccountDomain.syncSignalProducer(inContext: context, fetchRemote: remote)

        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"initWithCoder not implemented"
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()

        dataSource?.viewDidLoad(self)

        AccountDomainViewModel.tableViewDidLoad(tableView)
        collectionUpdatesDisposable = collection.collectionUpdates.observe(on: UIScheduler()).observeValues { [unowned self] updates in
            self.handleUpdates(updates)
        }.map(ScopedDisposable.init)

        refresh(nil)

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(AccountDomainListViewController.refresh(_:)), for: .valueChanged)
    }

    func refresh(_ refreshContol: UIRefreshControl?) {
        disposable = syncProducer.start { event in
            switch event {
            case .completed, .interrupted, .failed:
                refreshContol?.endRefreshing()
            default: break
            }
        }
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountDomain = collection[indexPath]

        let viewModel = AccountDomainViewModel(name: accountDomain.name, domain: accountDomain.domain)
        let cell = viewModel.cellForTableView(tableView, indexPath: indexPath)
        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            cell.roundCorners([.bottomRight, .bottomLeft], radius: 10.0)
        } else {
            cell.layer.mask = nil
        }
        return cell
    }

    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collection.titleForSection(section)
    }

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return collection.numberOfSections()
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.numberOfItemsInSection(section)
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pickedDomainAction?(collection[indexPath])
    }

    fileprivate func handleUpdates(_ updates: [CollectionUpdate<AccountDomain>]) {
        tableView.reloadData()
    }
}
