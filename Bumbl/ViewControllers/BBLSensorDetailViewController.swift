//
//  BBLSensorDetailViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 6/13/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit
import MapKit

class BBLSensorDetailViewController: BBLViewController {
  
  // MARK: Public Variables
  
  internal var sensor: BBLSensor!
  
  // MARK: Interface Builder
  
  @IBOutlet weak var locationMapView: MKMapView!
  @IBOutlet weak var batteryPercentLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var statusTitleLabel: UILabel!
  @IBOutlet weak var assignTitleLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var connectedParentLabel: UILabel!
  
  @IBOutlet weak var topLevelStackViewBottomToSuperviewBottomConstraint: NSLayoutConstraint!
  
  @IBAction func didTapTareButton(_ sender: UIButton) {
    sensor.rebaseline()
  }
  
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViewController()
    setupMapView(locationMapView)
    setupAppearanceForInformationLabel(batteryPercentLabel)
    
    setupAppearanceForTitleLabel(statusTitleLabel)
    setupAppearanceForTitleLabel(assignTitleLabel)
    setupAppearanceForTextLabel(statusLabel)
    setupAppearanceForTextLabel(connectedParentLabel)
    setupAppearanceForTextLabel(batteryPercentLabel)
    setupAppearanceForTextLabel(temperatureLabel)
    
    setupNavigationItem(navigationItem)
    
    updateAllInformation()
  }
  
  // MARK: Setup
  
  fileprivate func setupViewController() {
    title = sensor.name
    topLevelStackViewBottomToSuperviewBottomConstraint.constant = tabBarController!.tabBar.frame.height
  }
  
  fileprivate func setupMapView(_ mapView: MKMapView) {
    // TODO: Grab location from sensor.
    
    CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: 37.3318, longitude: -122.0312), completionHandler: {(placemarks, error) -> Void in
      
      if let error = error {
        print("Reverse geocoder failed with error" + error.localizedDescription)
        return
      }
      
      if let placemarks = placemarks , placemarks.count > 0 {
        let pm = MKPlacemark(placemark: placemarks[0])
        
        var region = mapView.region
        region.center = pm.coordinate
        region.span.longitudeDelta /= 1000.0
        region.span.latitudeDelta /= 1000.0
        
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(pm)
      }
      else {
        print("Problem with the data received from geocoder")
      }
    })
    
  }
  
  fileprivate func setupAppearanceForSensorValueGaugeView(_ sensorValueGaugeView: BBLSensorValueGaugeView) {
    sensorValueGaugeView.setGaugeBackgroundColor(UIColor.BBLYellowColor())
    sensorValueGaugeView.gaugeFillNormalized = 0.2
  }
  
  fileprivate func setupAppearanceForInformationLabel(_ label: UILabel) {
    label.backgroundColor = UIColor.clear
    label.textColor = UIColor.white
  }
  
  fileprivate func setupAppearanceForTitleLabel(_ titleLabel: UILabel) {
    titleLabel.textColor = UIColor.BBLGrayTextColor()
  }
  
  fileprivate func setupAppearanceForTextLabel(_ textLabel: UILabel) {
    textLabel.textColor = UIColor.BBLDarkBlueColor()
  }
  
  fileprivate func setupNavigationItem(_ navItem: UINavigationItem) {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(BBLSensorDetailViewController.didTapEditButton))
  }
  
  // Navigation
  
  internal func didTapEditButton(_ sender: UIBarButtonItem) {
    let editSensorVC = BBLEditSensorViewController()
    editSensorVC.delegate = self
    editSensorVC.sensor = sensor
    
    navigationController?.pushViewController(editSensorVC, animated: true)
  }
  
  // MARK: Update
  
  fileprivate func updateAllInformation() {
    batteryPercentLabel.text = "50%"
    
    statusLabel.text = sensor.stateAsString
    connectedParentLabel.text = sensor.connectedParent?.username
    
    title = sensor.name
    
    avatarImageView.image = BBLAvatarsInfo.BBLAvatarType(rawValue: sensor.avatar)?.image()
  }
  
}

extension BBLSensorDetailViewController: BBLEditSensorViewControllerDelegate {
  
  func BBLEditSensorVC(_ vc: BBLEditSensorViewController, didTapBottomButton bottomButton: BBLModalBottomButton) {
    _ = navigationController?.popViewController(animated: true)
    tabBarController?.tabBar.isHidden = false
    updateAllInformation()
  }
  
}
