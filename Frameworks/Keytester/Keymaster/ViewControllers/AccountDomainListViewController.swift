//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation

import TooLegit
import CoreData
import SoPersistent
import SoLazy

struct AccountDomainViewModel: TableViewCellViewModel {

    let name: String
    let domain: String

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(UINib(nibName: "AccountDomainTableViewCell", bundle: NSBundle(forClass: SelectSessionTableViewCell.self)), forCellReuseIdentifier: "AccountDomainViewModel")
    }
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountDomainViewModel", forIndexPath: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = domain
        return cell
    }
}

import ReactiveCocoa
import CoreData

public class AccountDomainListViewController: UITableViewController {

    var collection: FetchedCollection<AccountDomain>
    public var dataSource: TableViewDataSource?

    let syncProducer: ReactiveCocoa.SignalProducer<[AccountDomain], NSError>
    var disposable: Disposable?
    var pickedDomainAction: ((NSURL)->Void)?
    var collectionUpdatesDisposable: Disposable?

    let context: NSManagedObjectContext = {
        let bundle = NSBundle(forClass: AccountDomain.self)
        guard let model = NSManagedObjectModel(named: "Keymaster", inBundle:bundle) else { ❨╯°□°❩╯⌢"problems?" }

        let storeURL = AccountDomainListViewController.localStoreDirectoryURL().URLByAppendingPathComponent("account_domains.sqlite")

        let context = try! NSManagedObjectContext(storeURL: storeURL!, model: model, cacheReset: {})
        return context
    }()

    static func localStoreDirectoryURL() -> NSURL {
        guard let lib = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first else { ❨╯°□°❩╯⌢"GASP! There were no user library search paths" }
        let fileURL = NSURL(fileURLWithPath: lib)
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

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = UIView()

        dataSource?.viewDidLoad(self)

        AccountDomainViewModel.tableViewDidLoad(tableView)
        collectionUpdatesDisposable = collection.collectionUpdates.observeOn(UIScheduler()).observeNext { [unowned self] updates in
            self.handleUpdates(updates)
        }.map(ScopedDisposable.init)

        refresh(nil)

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(AccountDomainListViewController.refresh(_:)), forControlEvents: .ValueChanged)
    }

    func refresh(refreshContol: UIRefreshControl?) {
        disposable = syncProducer.start { event in
            print(event)
            switch event {
            case .Completed, .Interrupted, .Failed:
                refreshContol?.endRefreshing()
            default: break
            }
        }
    }

    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let accountDomain = collection[indexPath]

        let viewModel = AccountDomainViewModel(name: accountDomain.name, domain: accountDomain.domain)
        let cell = viewModel.cellForTableView(tableView, indexPath: indexPath)
        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            cell.roundCorners([.BottomRight, .BottomLeft], radius: 10.0)
        } else {
            cell.layer.mask = nil
        }
        return cell
    }

    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collection.titleForSection(section)
    }

    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return collection.numberOfSections()
    }

    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.numberOfItemsInSection(section)
    }

    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let domain = collection[indexPath].domain
        if let url = NSURL(string: "https://\(domain)") {
            pickedDomainAction?(url)
        }
    }

    private func handleUpdates(updates: [CollectionUpdate<AccountDomain>]) {
        tableView.reloadData()
    }
}
