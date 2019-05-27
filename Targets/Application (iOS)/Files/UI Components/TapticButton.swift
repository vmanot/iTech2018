//
//  TapticButton.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/9/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: TapticButton {
    var deepPress: Observable<Void> {
        return base.rx_unthrottledDeepPress
            .asObservable()
            .throttle(1, scheduler: MainScheduler.instance)
    }
}

extension UITouch {
    fileprivate var normalizedForce: CGFloat {
        return force / maximumPossibleForce
    }
}

///
/// Loosely based on https://github.com/BalestraPatrick/HapticButton
///
class TapticButton: UIControl {
    var tapticEngine = TapticEngine()
    var disposeBag = DisposeBag()
    var threshold: CGFloat = 0.4
    var rx_unthrottledDeepPress = PublishSubject<Void>()

    var textLabel = UILabel().then {
        $0.isUserInteractionEnabled = true
        $0.font = UIFont.systemFont(ofSize: 20)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        addSubview(textLabel)
        
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        rx.deepPress
            .map { [unowned self] in self.tapticEngine.generate(.impact(style: .medium)) }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func zoom(force: CGFloat) {
        let scaling = 1.0 + (force / 4) + 0.15
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: scaling, y: scaling)
        }
    }

    var isHeld: Bool = false
    
    private func animateIdentitiyTransform() {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10.0, options: [], animations: {
            self.transform = .identity
        })
    }

    private func fireDeepPress() {
        guard !isHeld else {
            return
        }
        rx_unthrottledDeepPress.onNext(())
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        tapticEngine.prepare(.impact(style: .medium))
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            let force = touch.normalizedForce
            zoom(force: force)
            if force >= threshold {
                fireDeepPress()
                isHeld = true
            } else {
                isHeld = false
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateIdentitiyTransform()
        isHeld = false
    }
}

