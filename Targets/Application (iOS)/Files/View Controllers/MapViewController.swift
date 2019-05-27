//
//  MapViewController.swift
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

class MapViewController: DemoViewController {
    static let name = "Taptic Map View"
    static let description = "A map view enriched with 3D touch capabilities."
    
    let disposeBag = DisposeBag()
    lazy var locationManager = CLLocationManager().then {
        $0.distanceFilter = kCLDistanceFilterNone
        $0.desiredAccuracy = kCLLocationAccuracyHundredMeters
        $0.delegate = self
        $0.requestAlwaysAuthorization()
        $0.startUpdatingLocation()
    }
    let mapView = TapticMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coordinate = locationManager.location?.coordinate{
            mapView.setCenter(coordinate, animated: false)
        }
        
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let first = locations.first {
            mapView.setCenterCoordinate(first.coordinate, withZoomLevel: 13, animated: true)
        }
    }
}
