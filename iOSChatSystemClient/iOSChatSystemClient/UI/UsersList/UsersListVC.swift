//
//  UsersListVC.swift
//  iOSChatSystemClient
//
//  Created by Dmitrii Titov on 03.03.2018.
//  Copyright © 2018 Dmitriy Titov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UsersListVC: UIViewController {
    
    let users = Variable<[User]>([User]())
//    let users = Variable<[String]>([String]())
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var tableView: UITableView!
    
    var userSelectedAction: ((User) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBindings()
        
        UsersManager.shared.loadUsers()
    }
    
    func initBindings() {
        
        UsersManager.shared.users.asObservable()
            .map({ $0.filter({ $0.id != LocalServer.shared.serverURLString.value }) })
            .bind(to: self.users)
            .disposed(by: self.disposeBag)

        self.users.asObservable()
            .subscribe(onNext: { _ in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
}

extension UsersListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < users.value.count,
            let action = userSelectedAction {
            let selectedUser = users.value[indexPath.row]
            action(selectedUser)
            navigationController?.popViewController(animated: true)
            RoomsManager.shared.updateRooms()
        }
    }
    
}

extension UsersListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user_cell")!
        
        if indexPath.row < users.value.count {
            let user = users.value[indexPath.row]
            cell.textLabel?.text = user.name.count > 0
                ? user.name
                : user.id
        }
        
        return cell
    }
    
}

