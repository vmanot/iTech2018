//
//  TapticEngine.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/8/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import AudioToolbox
import Foundation
import UIKit

public class TapticEngine {
    private var impactFeedbackGenerators: [UIImpactFeedbackGenerator.FeedbackStyle:  UIImpactFeedbackGenerator] = [:]
    private var selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private var notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    public init() {
        
    }
    
    public enum Feedback {
        case impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
        case selection
        case notification(type: UINotificationFeedbackGenerator.FeedbackType)
    }
    
    func impactFeedbackGenerator(for style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
        if let generator = impactFeedbackGenerators[style] {
            return generator
        } else {
            let generator = UIImpactFeedbackGenerator(style: style)
            impactFeedbackGenerators[style] = generator
            return generator
        }
    }
    
    func prepare(_ feedback: Feedback) {
        switch feedback  {
        case .impact(let style):
            impactFeedbackGenerator(for: style).prepare()
        case .selection:
            selectionFeedbackGenerator.prepare()
        case .notification:
            notificationFeedbackGenerator.prepare()
        }
    }
    
    func generate(_ feedback: Feedback) {
        switch feedback  {
        case .impact(let style):
            impactFeedbackGenerator(for: style).impactOccurred()
        case .selection:
            selectionFeedbackGenerator.selectionChanged()
        case .notification(let type):
            notificationFeedbackGenerator.notificationOccurred(type)
        }
    }
    
    func generatePrimitive() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
