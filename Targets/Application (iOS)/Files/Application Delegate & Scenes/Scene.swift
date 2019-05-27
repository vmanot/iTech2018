//
//  Scene.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/8/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import Foundation
import UIKit

protocol _DemoViewController {
    static var name: String { get }
    static var description: String { get }
}

typealias DemoViewController = UIViewController & _DemoViewController

enum Scene: CaseIterable {
    static let allCases: [Scene] = [.demo(PhotoViewController.self), .demo(PasscodeViewController.self), .demo(DeepPressButtonViewController.self), .demo(MapViewController.self)]
    
    case demo(DemoViewController.Type)
    
    var name: String {
        switch self {
        case .demo(let type):
            return type.name
        }
    }
    
    var description: String {
        switch self {
        case .demo(let type):
            return type.description
        }
    }
}

public struct SceneCoordinator {
    let controller: UINavigationController
    
    init(_ controller: UINavigationController) {
        self.controller = controller
    }
    
    func transition(to scene: Scene) {
        let targetController: UIViewController
        switch scene {
        case .demo(let type):
            targetController = type.init()
        }
        targetController.title = scene.name
        targetController.view.backgroundColor = UIColor.white
        controller.pushViewController(targetController, animated: true)
    }
}

