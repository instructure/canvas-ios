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

import UIKit
import CoreData
import SoPersistent
import Result
import ReactiveSwift
import ReactiveCocoa

struct BagelVM: TableViewCellViewModel {
    let name: String
    let isFavorite: Bool
    
    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "bagel")
    }
    
    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bagel", for: indexPath)
        
        cell.textLabel?.text = name
        cell.accessoryType = isFavorite ? .checkmark : .none
        
        return cell
    }
}

class AllBagelsViewController: Bagel.TableViewController {
    let container = NSPersistentContainer(name: "Bagels")
    let context: NSManagedObjectContext
    
    lazy var dismiss: Action<(), (), NoError> = {
        return Action() { [weak self] _ in
            self?.dismiss(animated: false)
            return .empty
        }
    }()
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init(style: .plain)
        self.prepare(try Bagel.allByFavorite(in: context), refresher: Bagel.refresh(in: context)) { bagel in
            return BagelVM(name: bagel.name, isFavorite: bagel.isFavorite)
        }
        
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        dismissButton.reactive.pressed = CocoaAction(dismiss)
        navigationItem.rightBarButtonItem = dismissButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Nope nope nope")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bagel = collection[indexPath]
        bagel.isFavorite = !bagel.isFavorite
        try! context.saveFRD()
    }
}
