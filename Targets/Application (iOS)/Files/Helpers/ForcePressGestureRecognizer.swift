//
//  ForceTouchGestureRecognizer.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/8/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import UIKit

extension UIGestureRecognizer.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .possible:
            return "possible"
        case .began:
            return "began"
        case .changed:
            return "changed"
        case .ended:
            return "ended"
        case .cancelled:
            return "cancelled"
        case .failed:
            return "failed"
        }
    }
}

class ForcePressGestureRecognizer: UIGestureRecognizer {
    let threshold: CGFloat
    
    public private(set) var force: CGFloat?
    
    required init(target: AnyObject?, action: Selector?, threshold: CGFloat) {
        self.threshold = threshold
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        touches.first.map(handle)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        touches.first.map(handle)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = (force != nil) ? UIGestureRecognizer.State.ended : UIGestureRecognizer.State.failed
    }
}

extension ForcePressGestureRecognizer {
    private func handle(touch: UITouch) {
        guard touch.force != 0 && touch.maximumPossibleForce != 0 else {
            return
        }
        
        if force == nil && touch.normalizedForce >= threshold {
            state = UIGestureRecognizer.State.began
            force = touch.force
        }
            
        else if (force != nil) && touch.normalizedForce < threshold {
            state = UIGestureRecognizer.State.ended
            force = nil
        }
    }
}

extension UITouch {
    fileprivate var normalizedForce: CGFloat {
        return force / maximumPossibleForce
    }
}
