//
//  TapticMapView.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/9/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import MapKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

extension FloatingPoint {
    fileprivate var radiansToDegrees: Self { return self * 180 / .pi }
}

class TapticMapView: MKMapView, UIGestureRecognizerDelegate {
    var disposeBag = DisposeBag()
    var tapticEngine = TapticEngine()
    lazy var rotationGestureRecognizer = CircleGestureRecognizer(midPoint: self.center, target: nil, action: nil)
    init() {
        super.init(frame: CGRect.zero)
        configureRotationGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rotationGestureRecognizer.midPoint = center
    }
    
    func configureRotationGestureRecognizer() {
        rotationGestureRecognizer.delegate = self
        rotationGestureRecognizer.rx.eventBeganOrChanged
            .map { [unowned self] recognizer in
                if let rotation = recognizer.rotation {
                    var newHeading = self.camera.heading + Double(rotation.radiansToDegrees)
                    if newHeading > 360 {
                        newHeading -= 360
                    }
                    self.camera.heading = newHeading
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        rotationGestureRecognizer.rx.eventBegan
            .map { [unowned self] recognizer in
                Observable<Int>
                    .interval(0.05, scheduler: MainScheduler.instance)
                    .takeUntil(recognizer.rx.eventEndedOrFailed)
                    .map { count in
                        if (count % 2) == 0 {
                            self.tapticEngine.generate(.selection)
                        }
                    }
                    .subscribe()
                    .disposed(by: self.disposeBag)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        addGestureRecognizer(rotationGestureRecognizer)
        
    }
}
