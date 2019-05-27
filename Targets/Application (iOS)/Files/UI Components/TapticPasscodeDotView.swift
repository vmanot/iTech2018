//
//  TapticPasscodeDotView.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/8/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class TapticPasscodeDotView: UIView {
    var disposeBag = DisposeBag()
    
    let indexPath: IndexPath
    
    unowned let parent: TapticPasscodeView
    
    init(indexPath: IndexPath, parent: TapticPasscodeView) {
        self.indexPath = indexPath
        self.parent = parent
        super.init(frame: .zero)
        configure()
    }
    
    func configure() {
        configureAppearance()
        configureGestureRecognizers()
    }
    
    func configureAppearance() {
        self.layer.cornerRadius = (80 / 2)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.5
        self.backgroundColor = .white
        
        let label = UILabel()
        label.text = String(indexPath.numberForPasscodeDot)
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 32)
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
    }
    
    func highlight() {
        self.backgroundColor = UIColor.lightGray
    }
    func unhighlight() {
        self.backgroundColor = UIColor.white
    }
    func configureGestureRecognizers() {
        var tapForHighlight = UILongPressGestureRecognizer(target: nil, action: nil)
        tapForHighlight.minimumPressDuration = 0.0
        tapForHighlight.rx.event
            .do(onNext: { [unowned self] recognizer in
                if recognizer.state == .began {
                    self.highlight()
                }
            })
            .filter { $0.state == .recognized }
            .map { [unowned self] _ in (self.indexPath, false) }
            .do(onNext: { [unowned self] _ in self.unhighlight() })
            .subscribe()
            .disposed(by: disposeBag)

        var tap = UILongPressGestureRecognizer(target: nil, action: nil)
        tap.minimumPressDuration = 0.0
        tap.rx.event
            .do(onNext: { [unowned self] recognizer in
                if recognizer.state == .began {
                    self.parent.tapticEngine.generate(.impact(style: .light))
                }
            })
            .filter { $0.state == .recognized }
            .map { [unowned self] _ in (self.indexPath, false) }
            .do(onNext: { [unowned self] recognizer in
                self.parent.tapticEngine.generate(.impact(style: .light))
            })
            .bind(to: parent.rx.indexPathSelected)
            .disposed(by: disposeBag)
        
        var forceTap = ForcePressGestureRecognizer(target: nil, action: nil, threshold: 0.4)
        
        forceTap.rx.event
            .do(onNext: { [unowned self] recognizer in
                if recognizer.state == .began {
                    self.parent.tapticEngine.generate(.impact(style: .heavy))
                }
            })
            .filter { $0.state == .recognized }
            .map { [unowned self] _ in (self.indexPath, true) }
            .do(onNext: { [unowned self] recognizer in
                self.parent.tapticEngine.generate(.impact(style: .heavy))
            })
            .bind(to: parent.rx.indexPathSelected)
            .disposed(by: disposeBag)
        
        tap.delegate = self
        forceTap.delegate = self
        
        addGestureRecognizer(tapForHighlight)
        addGestureRecognizer(tap)
        addGestureRecognizer(forceTap)
        
        tap.require(toFail: forceTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TapticPasscodeDotView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
