//
//  ViewController.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/8/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class UITableViewCellWithSubtitle: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {
    var disposeBag = DisposeBag()
    var tableView = UITableView()
    
    let coordinator: SceneCoordinator
    
    init(coordinator: SceneCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func setUpTableView() {
        tableView.register(UITableViewCellWithSubtitle.self, forCellReuseIdentifier: "Cell")
        
        Observable
            .just(Scene.allCases)
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { index, model, cell in
                cell.textLabel?.text = model.name
                cell.detailTextLabel?.text = model.description
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(Scene.self)
            .map(coordinator.transition)
            .subscribe()
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { [unowned tableView] in tableView.deselectRow(at: $0, animated: true) }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func addSubviews() {
        view.addSubview(tableView)
    }
    
    func addConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Main"

        view.backgroundColor = UIColor.white
        
        setUpTableView()
        addSubviews()
        addConstraints()
    }
}
