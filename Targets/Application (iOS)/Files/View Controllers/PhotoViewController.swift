//
//  PhotoViewController.swift
//  iTech2018
//
//  Created by Vatsal Manot on 12/8/18.
//  Copyright © 2018 Vatsal Manot. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class PhotoViewController: DemoViewController, UIGestureRecognizerDelegate {
    static let name = "Taptic Photo View"
    static let description = "A photo view enriched with 3D touch capabilities."
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let imageView = UserResizableImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        imageView.image = UIImage(named: "Cat")
        view.addSubview(imageView)
        
        imageView.center = view.center
    }
}
