//
//  PasscodeViewController.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/8/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class PasscodeViewController: DemoViewController, UIGestureRecognizerDelegate {
    static let name = "Taptic Passcode"
    static let description = "A passcode input with an extra layer of security."
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let passcodeView = TapticPasscodeView()
        view.addSubview(passcodeView)
        
        passcodeView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

