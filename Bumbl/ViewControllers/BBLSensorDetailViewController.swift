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
  @IBOutlet weak var batteryPercentLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var statusTitleLabel: UILabel!
  @IBOutlet weak var assignTitleLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var connectedParentLabel: UILabel!
  
  @IBOutlet weak var topLevelStackViewBottomToSuperviewBottomConstraint: NSLayoutConstraint!
  
  @IBAction func didTapTareButton(sender: UIButton) {
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
  
  private func setupViewController() {
    title = sensor.name
    topLevelStackViewBottomToSuperviewBottomConstraint.constant = tabBarController!.tabBar.frame.height
  }
  
  private func setupMapView(mapView: MKMapView) {
    // TODO: Grab location from sensor.
    
    CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: 37.3318, longitude: -122.0312), completionHandler: {(placemarks, error) -> Void in
      
      if let error = error {
        print("Reverse geocoder failed with error" + error.localizedDescription)
        return
      }
      
      if let placemarks = placemarks where placemarks.count > 0 {
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
  
  private func setupAppearanceForSensorValueGaugeView(sensorValueGaugeView: BBLSensorValueGaugeView) {
    sensorValueGaugeView.setGaugeBackgroundColor(UIColor.BBLYellowColor())
    sensorValueGaugeView.gaugeFillNormalized = 0.2
  }
  
  private func setupAppearanceForInformationLabel(label: UILabel) {
    label.backgroundColor = UIColor.clearColor()
    label.textColor = UIColor.whiteColor()
  }
  
  private func setupAppearanceForTitleLabel(titleLabel: UILabel) {
    titleLabel.textColor = UIColor.BBLGrayTextColor()
  }
  
  private func setupAppearanceForTextLabel(textLabel: UILabel) {
    textLabel.textColor = UIColor.BBLDarkBlueColor()
  }
  
  private func setupNavigationItem(navItem: UINavigationItem) {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(BBLSensorDetailViewController.didTapEditButton))
  }
  
  // Navigation
  
  internal func didTapEditButton(sender: UIBarButtonItem) {
    let editSensorVC = BBLEditSensorViewController()
    editSensorVC.delegate = self
    editSensorVC.sensor = sensor
    
    let navController = UINavigationController(rootViewController: editSensorVC)
    presentViewController(navController, animated: true, completion: nil)
  }
  
  // MARK: Update
  
  private func updateAllInformation() {
    batteryPercentLabel.text = "50%"
    
    statusLabel.text = sensor.stateAsString
    connectedParentLabel.text = sensor.connectedParent?.username
    
    title = sensor.name
    
    avatarImageView.image = BBLAvatarsInfo.BBLAvatarType(rawValue: sensor.avatar)?.image()
  }
  
}

extension BBLSensorDetailViewController: BBLEditSensorViewControllerDelegate {
  
  func BBLEditSensorVC(vc: BBLEditSensorViewController, didTapBottomButton bottomButton: BBLModalBottomButton) {
    dismissViewControllerAnimated(true, completion: nil)
    updateAllInformation()
  }
  
  func BBLEditSensorVC(vc: BBLEditSensorViewController, didTapCancelButton bottomButton: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
