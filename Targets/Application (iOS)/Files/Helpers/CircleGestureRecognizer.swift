//
//  RotationGestureRecognizer.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/9/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import UIKit

extension CGFloat {
    fileprivate var degrees: CGFloat {
        return self * 180 / CGFloat.pi
    }
    fileprivate var radians: CGFloat {
        return self * CGFloat.pi / 180
    }
}

/// Based on XMCircleGestureRecognizer
class CircleGestureRecognizer: UIGestureRecognizer {
    var threshold: CGFloat = 0.25
    var midPoint = CGPoint.zero
    var innerRadius: CGFloat?
    var outerRadius: CGFloat?
    
    var rotation: CGFloat? {
        if let currentPoint = self.currentPoint {
            if let previousPoint = self.previousPoint {
                var rotation = angleBetween(pointA: currentPoint, andPointB: previousPoint)
                if rotation > CGFloat.pi {
                    rotation -= CGFloat.pi * 2
                } else if rotation < -CGFloat.pi {
                    rotation += CGFloat.pi * 2
                }
                return rotation
            }
        }
        
        return nil
    }
    
    var angle: CGFloat? {
        if let nowPoint = self.currentPoint {
            return self.angleForPoint(point: nowPoint)
        }
        
        return nil
    }
    
    var distance: CGFloat? {
        if let nowPoint = self.currentPoint {
            return distanceBetween(pointA: self.midPoint, andPointB: nowPoint)
        }
        
        return nil
    }
    
    private var currentPoint: CGPoint?
    private var previousPoint: CGPoint?
    
    init(midPoint: CGPoint, innerRadius: CGFloat?, outerRadius: CGFloat?, target:AnyObject?, action: Selector?) {
        super.init(target: target, action: action)
        self.midPoint = midPoint
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
    }
    
    convenience init(midPoint: CGPoint, target: AnyObject?, action: Selector?) {
        self.init(midPoint:midPoint, innerRadius: nil, outerRadius: nil, target:target, action: action)
    }
    
    
    private func distanceBetween(pointA:CGPoint, andPointB pointB:CGPoint) -> CGFloat {
        let dx = Float(pointA.x - pointB.x)
        let dy = Float(pointA.y - pointB.y)
        
        return CGFloat(sqrtf(dx * dx + dy * dy))
    }
    
    private func angleForPoint(point:CGPoint) -> CGFloat {
        var angle = CGFloat(-atan2f(Float(point.x - midPoint.x), Float(point.y - midPoint.y))) + (CGFloat.pi / 2)
        
        if angle < 0 {
            angle += CGFloat.pi * 2
        }
        return angle
    }
    
    private func angleBetween(pointA:CGPoint, andPointB pointB:CGPoint) -> CGFloat {
        return angleForPoint(point: pointA) - angleForPoint(point: pointB)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        if let firstTouch = touches.first, firstTouch.normalizedForce >= threshold {
            currentPoint = firstTouch.location(in: self.view)
            var newState:UIGestureRecognizer.State = .began
            
            if let innerRadius = self.innerRadius, let distance = self.distance {
                if distance < innerRadius {
                    newState = .failed
                }
            }
            
            if let outerRadius = self.outerRadius, let distance = self.distance {
                if distance > outerRadius {
                    newState = .failed
                }
            }
            
            state = newState
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if state == .failed {
            return
        }
        
        if let firstTouch = touches.first, firstTouch.normalizedForce >= threshold {
            currentPoint = firstTouch.location(in: self.view)
            previousPoint = firstTouch.previousLocation(in: self.view)
            state = .changed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
        currentPoint = nil
        previousPoint = nil
    }
}

extension UITouch {
    fileprivate var normalizedForce: CGFloat {
        return force / maximumPossibleForce
    }
}
