//
//  ReactiveHelpers.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/9/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIGestureRecognizer {
    public var eventBegan: ControlEvent<Base> {
        return .init(events: event.filter { $0.state == .began })
    }
    
    public var eventBeganOrChanged: ControlEvent<Base> {
        return .init(events: event.filter { $0.state == .began || $0.state  == .changed })
    }
    
    public var eventEnded: ControlEvent<Base> {
        return .init(events: event.filter { $0.state == .ended })
    }
    
    public var eventEndedOrFailed: ControlEvent<Base> {
        return .init(events: event.filter { $0.state == .ended || $0.state == .failed })
    }
    
    public var eventRecognized: ControlEvent<Base> {
        return .init(events: event.filter { $0.state == .recognized })
    }
}
