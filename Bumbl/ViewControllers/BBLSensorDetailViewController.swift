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
  @IBOutlet weak var tareButton: UIButton!
  @IBOutlet weak var batteryPercentLabel: UILabel!
  @IBOutlet weak var delayTimeLabel: UILabel!
  @IBOutlet weak var sensorValueGaugeView: BBLSensorValueGaugeView!
  @IBOutlet weak var emptySpacerView: UIView!
  
  @IBOutlet weak var babyNameLabel: UILabel!
  @IBOutlet weak var statusTitleLabel: UILabel!
  @IBOutlet weak var assignTitleLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var connectedParentLabel: UILabel!
  
  @IBAction func didTapTareButton(sender: UIButton) {
    sensor.rebaseline()
  }
  
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViewController()
    setupMapView(locationMapView)
    setupAppearanceForSensorValueGaugeView(sensorValueGaugeView)
    setupAppearanceForTareButton(tareButton)
    setupAppearanceForInformationLabel(batteryPercentLabel)
    setupAppearanceForInformationLabel(delayTimeLabel)
    
    setupAppearanceForTitleLabel(statusTitleLabel)
    setupAppearanceForTitleLabel(assignTitleLabel)
    setupAppearanceForTextLabel(babyNameLabel)
    setupAppearanceForTextLabel(statusLabel)
    setupAppearanceForTextLabel(connectedParentLabel)
    
    setupNavigationItem(navigationItem)
    
    updateAllInformation()
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
  
  private func setupAppearanceForSensorValueGaugeView(sensorValueGaugeView: BBLSensorValueGaugeView) {
    sensorValueGaugeView.setGaugeBackgroundColor(UIColor.BBLYellowColor())
    sensorValueGaugeView.gaugeFillNormalized = 0.2
  }
  
  private func setupAppearanceForTareButton(button: UIButton) {
    button.titleEdgeInsets = UIEdgeInsets(top: button.bounds.height/3.0,
                                          left: 0.0,
                                          bottom: 0.0,
                                          right: 0.0)
    button.tintColor = UIColor.whiteColor()
  }
  
  private func setupAppearanceForInformationLabel(label: UILabel) {
    label.backgroundColor = UIColor.clearColor()
    label.textColor = UIColor.whiteColor()
  }
  
  private func setupAppearanceForTitleLabel(titleLabel: UILabel) {
    titleLabel.textColor = UIColor.BBLBrightTealGreenColor()
  }
  
  private func setupAppearanceForTextLabel(textLabel: UILabel) {
    textLabel.textColor = UIColor.BBLDarkBlueColor()
  }
  
  private func setupNavigationItem(navItem: UINavigationItem) {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(BBLSensorDetailViewController.didTapEditButton))
  }
  
  // Navigation
  
  internal func didTapEditButton(sender: UIBarButtonItem) {
    // TODO: Push edit sensor VC on nav controller.
  }
  
  // MARK: Update
  
  private func updateAllInformation() {
    batteryPercentLabel.text = "50%"
    delayTimeLabel.text = String(sensor.delayInSeconds)
    
    babyNameLabel.text = sensor.name
    statusLabel.text = sensor.stateAsString
    connectedParentLabel.text = sensor.connectedParent?.username
  }
  
}
