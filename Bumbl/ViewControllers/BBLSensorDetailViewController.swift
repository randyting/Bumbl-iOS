//
//  BBLSensorDetailViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 6/13/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit
import MapKit

class BBLSensorDetailViewController: UIViewController {
  
  // MARK: Public Variables
  
  internal var sensor: BBLSensor!
  
  // MARK: Interface Builder
  
  @IBOutlet weak var locationMapView: MKMapView!
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViewController()
    setupMapView(locationMapView)
    
  }
  
  // MARK: Setup
  
  private func setupViewController() {
    title = sensor.name
  }
  
  private func setupMapView(mapView: MKMapView) {
    // TODO: Grab location from sensor.
    let location = "1234 Ortega Street, San Francisco, CA 94122"
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(location) { (placemarks: [CLPlacemark]?, error: NSError?) in
      if let error = error {
        print(error.localizedDescription)
      } else {
        if let placemarks = placemarks where placemarks.count > 0 {
         let topResult = placemarks.first!
          let placemark = MKPlacemark(placemark: topResult)
          
          
          var region = mapView.region
          region.center = (placemark.region as! CLCircularRegion).center
          region.span.longitudeDelta /= 1000.0
          region.span.latitudeDelta /= 1000.0
          
          mapView.setRegion(region, animated: true)
          mapView.addAnnotation(placemark)
        }
      }
    }
  }
  
  
}
