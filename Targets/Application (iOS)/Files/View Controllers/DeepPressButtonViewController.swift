//
//  ValueStepperViewController.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/9/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class DeepPressButtonViewController: DemoViewController, UIGestureRecognizerDelegate {
    static let name = "Taptic Button"
    static let description = "A button enriched with 3D touch capabilities."
    
    let disposeBag = DisposeBag()
    var confettiView = SAConfettiView().then {
        $0.intensity = 1
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white

        let button = TapticButton()
        button.threshold = 0.5
        button.textLabel.text = "Button"
        button.textLabel.textColor = UIColor.white
        button.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        button.insertSubview(blurEffectView, at: 0)
        view.addSubview(button)
        
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(confettiView)
        confettiView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }

        button.rx.deepPress
            .map { [unowned self] in
                self.confettiView.startConfetti()
            }
            .observeOn(MainScheduler.asyncInstance)
            .delay(0.5, scheduler: MainScheduler.instance)
            .map {
                self.confettiView.stopConfetti()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

