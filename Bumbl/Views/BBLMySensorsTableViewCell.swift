//
//  BBLMySensorsTableViewCell.swift
//  Bumbl
//
//  Created by Randy Ting on 1/23/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol BBLMySensorsTableViewCellDelegate: class {
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didSaveThreshold threshold: Float, andName name: String?)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool)
}

class BBLMySensorsTableViewCell: UITableViewCell {
  
  // MARK: Public Variables
  internal weak var delegate: BBLMySensorsTableViewCellDelegate?
  internal var sensor: BBLSensor! {
    didSet{
        updateValuesWithSensor(sensor)
    }
  }
  
  // MARK: Interface Builder
  @IBOutlet private weak var nameTextField: UITextField!
  @IBOutlet private weak var uuidLabel: UILabel!

  @IBOutlet private weak var valueLabel: UILabel!
  @IBOutlet private weak var thresholdSlider: UISlider!
  @IBOutlet private weak var thresholdTextField: UITextField!
  @IBOutlet private weak var babyDetectedLabel: UILabel!
  
  @IBOutlet weak var valueBackgroundView: UIView!
  
  @IBOutlet weak var valueForegroundViewWidthConstraint: NSLayoutConstraint!
  @IBAction private func didChangeThresholdSliderValue(sender: UISlider) {
    thresholdTextField.text = String(sender.value)
  }
  @IBAction func didEndEditingThresholdTextField(sender: UITextField) {
    thresholdSlider.value = Float((sender.text! as NSString).integerValue)
  }
  
  @IBAction private func didTapRemoveFromProfileButton(sender: UIButton) {
    delegate?.tableViewCell?(self, didTapRemoveFromProfileButton: true)
  }
  
  @IBAction private func didTapSaveSettingsButton(sender: UIButton) {
    thresholdTextField.resignFirstResponder()
    nameTextField.resignFirstResponder()
    delegate?.tableViewCell?(self, didSaveThreshold: thresholdSlider.value, andName: nameTextField.text)
  }
  
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
    setupSlider(thresholdSlider)
  }
  
  // MARK: Setup
  private func setupSlider(slider: UISlider) {
    slider.maximumValue = Float(BBLSensorInfo.kMaxCapSenseValue)
    slider.minimumValue = 0
  }
  
  // MARK: Update
  internal func updateValuesWithSensor(sensor: BBLSensor) {
    if let _ = sensor.peripheral {
      backgroundColor = UIColor.BBLYellowColor()
    } else {
      backgroundColor = UIColor.BBLGrayColor()
    }
    
    nameTextField.text = sensor.uuid
    uuidLabel.text = sensor.uuid
    valueForegroundViewWidthConstraint.constant = CGFloat(sensor.capSenseValuePercentage) * valueBackgroundView.frame.width
    
    if let capSenseValue = sensor.capSenseValue {
      valueLabel.text = String(format: "%i", capSenseValue)
    } else {
      valueLabel.text = ""
    }
    thresholdTextField.text = String(format: "%02d", sensor.capSenseThreshold)
    if sensor.hasBaby {
      babyDetectedLabel.textColor = UIColor.BBLWetAsphaltColor()
    } else {
      babyDetectedLabel.textColor = UIColor.clearColor()
    }
  }
  
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
