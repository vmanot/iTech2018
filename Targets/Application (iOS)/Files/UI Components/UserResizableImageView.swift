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

extension UIGestureRecognizer {
    func cancel() {
        state = .failed
        isEnabled = false
        isEnabled = true
    }
}

class UserResizableImageView: UIImageView {
    var scale: CGFloat = 1
    let disposeBag = DisposeBag()
    let tapticEngine = TapticEngine()
    var previousLocation = CGPoint.zero
    
    enum State {
        case panning
        case zoomingUp
        case zoomingDown
        case heldAfterZoom
        case none
        
        var isZooming: Bool {
            return self == .zoomingUp || self == .zoomingDown
        }
    }
    
    var state: State = .none
    
    let cancelSubject = PublishSubject<Void>()
    let panGestureRecognizer = UIPanGestureRecognizer(target: nil, action: nil)
    let pinchGestureRecognizer = UIPinchGestureRecognizer(target: nil, action: nil)
    let forcePressGestureRecognizer = ForcePressGestureRecognizer(target: nil, action: nil, threshold: 0.3)

    override init(image: UIImage!) {
        super.init(image: image)
        self.initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    func initialSetup() {
        self.isUserInteractionEnabled = true
        configurePanRecognizer()
        configurePinchRecognizer()
        configureRotationRecognizer()
        configureForcePressRecognizer()
    }

    func configurePanRecognizer() {
        panGestureRecognizer.delegate = self
        
        panGestureRecognizer.rx.eventBeganOrChanged.map { [unowned self] recognizer in
            if self.state == .zoomingUp || self.state == .zoomingDown {
                let yVelocity = recognizer.velocity(in: self).y
                if yVelocity > -2 {
                    self.state = .zoomingDown
                } else if yVelocity < -2 {
                    self.state = .zoomingUp
                }
            } else if self.state != .heldAfterZoom {
                self.state = .panning
                let translation = recognizer.translation(in: self.superview!)
                self.center = CGPoint(x: self.previousLocation.x + translation.x, y: self.previousLocation.y + translation.y)
            }
        }
        .subscribe()
        .disposed(by: disposeBag)
        
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    func configureRotationRecognizer() {
        let recognizer = UIRotationGestureRecognizer(target: nil, action: nil)
        recognizer.delegate = self
        recognizer.rx.eventBeganOrChanged
            .map { recognizer in
                recognizer.view!.transform = recognizer.view!.transform.rotated(by: recognizer.rotation)
                recognizer.rotation = 0
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        self.addGestureRecognizer(recognizer)
    }

    func configurePinchRecognizer() {
        pinchGestureRecognizer.delegate = self
        pinchGestureRecognizer.rx.eventBeganOrChanged
            .map { [unowned self] recognizer in
                self.zoom(by: recognizer.scale)
                recognizer.scale = 1
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        self.addGestureRecognizer(pinchGestureRecognizer)
    }

    func configureForcePressRecognizer() {
        forcePressGestureRecognizer.rx.eventBegan
            .map { [unowned self] _ in
                self.state = self.scale >= 2.0 ? .zoomingDown : .zoomingUp

                Observable<Int>
                    .interval(0.05, scheduler: MainScheduler.instance)
                    .takeUntil(Observable.merge(self.forcePressGestureRecognizer.rx.eventEndedOrFailed.map { _ in () }, self.cancelSubject))
                    .observeOn(MainScheduler.asyncInstance)
                    .map {
                        [unowned self] count in self.zoom()
                        if (count % 2) == 0 {
                            self.tapticEngine.generate(.selection)
                        }
                    }
                    .subscribe(onDisposed: { self.state = .heldAfterZoom })
                    .disposed(by: self.disposeBag)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        addGestureRecognizer(forcePressGestureRecognizer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.bringSubviewToFront(self)
        if state == .heldAfterZoom {
            state = .none
        }
        previousLocation = self.center
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if state.isZooming {
            state = .none
        }
    }
}

extension UserResizableImageView {
    private func zoom() {
        let factor: CGFloat
        
        if state == .zoomingDown {
            factor = 0.95
        } else {
            factor = 1.05
        }
        
        self.zoom(by: factor)
    }
    
    private func zoom(by factor: CGFloat) {
        let newScale = max(min(scale * factor, 2), 0.5)
        self.scale = newScale
        guard newScale < 2.0 && newScale > 0.5 else {
            cancelSubject.onNext(())
            forcePressGestureRecognizer.cancel()
            panGestureRecognizer.cancel()
            pinchGestureRecognizer.cancel()
            tapticEngine.generate(.notification(type: .error))
            return
        }
        
        transform = transform.scaledBy(x: factor, y: factor)
    }
}

extension UserResizableImageView: UIGestureRecognizerDelegate {
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
