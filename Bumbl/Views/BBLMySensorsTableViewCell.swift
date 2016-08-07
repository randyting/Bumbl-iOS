//
//  BBLMySensorsTableViewCell.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol BBLMySensorsTableViewCellDelegate: class {
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didSaveThreshold threshold: UInt, andName name: String?)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didChangeThreshold threshold: UInt)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didChangeDelayValue value: Int)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRebaselineButton: Bool)
}

class BBLMySensorsTableViewCell: UITableViewCell {
  
  
  // MARK: Constants
  
  private struct BBLMySensorsTableViewCellConstants {
    private static let defaultMaxCapsenseValue: UInt = 100
    private static let defaultCapsenseValue = 0
    
    private static let kNoConnectedParentName = "Nobody"
  }
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLMySensorsTableViewCellDelegate?
  internal var sensor: BBLSensor! {
    didSet (newSensor){
      if let newSensor = newSensor {
        if newSensor !== sensor
          || maxCapsenseValue == nil {
          resetValues()
        }
      }
      
      updateValuesWithSensor(sensor)
    }
  }
  
  // MARK: Private Variables
  
  private var maxCapsenseValue: UInt! = 0
  
  
  // MARK: Interface Builder
  
  @IBOutlet weak var sensorStatusBackgroundView: UIView!
  @IBOutlet weak var batteryLevelBackgroundView: UIView!
  @IBOutlet weak var avatarBackgroundView: UIView!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var babyNameLabel: UILabel!
  @IBOutlet weak var statusTitleLabel: UILabel!
  @IBOutlet weak var assignTitleLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var connectedParentLabel: UILabel!
  @IBOutlet weak var sensorValueGaugeView: BBLSensorValueGaugeView!
  
  // MARK: Lifecycle
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    initViews()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    initViews()
  }
  
  func initViews() {
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setupAppearanceForTitleLabel(statusTitleLabel)
    setupAppearanceForTitleLabel(assignTitleLabel)
    setupAppearanceForTextLabel(babyNameLabel)
    setupAppearanceForTextLabel(statusLabel)
    setupAppearanceForTextLabel(connectedParentLabel)
    setupAppearanceForSensorValueGaugeView(sensorValueGaugeView)
    
  }
  
  // MARK: Initial Setup
  
  private func setupAppearanceForTitleLabel(titleLabel: UILabel) {
    titleLabel.textColor = UIColor.whiteColor()
  }
  
  private func setupAppearanceForTextLabel(textLabel: UILabel) {
    textLabel.textColor = UIColor.BBLDarkBlueColor()
  }
  
  private func setupAppearanceForSensorValueGaugeView(sensorValueGaugeView: BBLSensorValueGaugeView) {
    sensorValueGaugeView.setGaugeBackgroundColor(UIColor.BBLYellowColor())
    sensorValueGaugeView.gaugeFillNormalized = 0.2
  }
  
  private func resetValues() {
    maxCapsenseValue = BBLMySensorsTableViewCellConstants.defaultMaxCapsenseValue
  }
  
  
  // MARK: Update
  
  internal func updateValuesWithSensor(sensor: BBLSensor) {
    babyNameLabel.text = sensor.name
    
    if let connectedParentName = sensor.connectedParent?.username {
      connectedParentLabel.text = connectedParentName
    } else {
      connectedParentLabel.text = BBLMySensorsTableViewCellConstants.kNoConnectedParentName
    }
    
    statusLabel.text = sensor.stateAsString
    
    if let capSenseValue = sensor.capSenseValue {
      if capSenseValue > maxCapsenseValue {
        maxCapsenseValue = capSenseValue
      }
      sensorValueGaugeView.gaugeFillNormalized = Double(capSenseValue)/Double(maxCapsenseValue)
    } else {
      sensorValueGaugeView.gaugeFillNormalized = 0.0
    }
    
    avatarImageView.image = BBLAvatarsInfo.BBLAvatarType(rawValue: sensor.avatar)?.image()
    
    updateBackgroundViews(withColor: (BBLAvatarsInfo.BBLAvatarType(rawValue: sensor.avatar)?.color())!)
    
  }
  
  private func updateBackgroundViews(withColor color: UIColor) {
    
    var avatarColorHue = CGFloat()
    var avatarColorSaturation = CGFloat()
    var avatarColorBrightness = CGFloat()
    var avatarColorAlpha = CGFloat()
    
    color.getHue(&avatarColorHue,
                saturation: &avatarColorSaturation,
                brightness: &avatarColorBrightness,
                alpha: &avatarColorAlpha)
    
    avatarBackgroundView.backgroundColor = UIColor(hue: avatarColorHue,
                                                   saturation: avatarColorSaturation,
                                                   brightness: avatarColorBrightness,
                                                   alpha: avatarColorAlpha)
    
    sensorStatusBackgroundView.backgroundColor = UIColor(hue: avatarColorHue,
                                                         saturation: avatarColorSaturation * 3.0,
                                                         brightness: avatarColorBrightness,
                                                         alpha: avatarColorAlpha)
    
    batteryLevelBackgroundView.backgroundColor = UIColor(hue: avatarColorHue,
                                                         saturation: avatarColorSaturation * 5.0,
                                                         brightness: avatarColorBrightness,
                                                         alpha: avatarColorAlpha)
    
    sensorValueGaugeView.setGaugeBackgroundColor(UIColor(hue: avatarColorHue,
      saturation: avatarColorSaturation * 8.0,
      brightness: avatarColorBrightness,
      alpha: avatarColorAlpha))
    
    


  }
  
  
  
}

