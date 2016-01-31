//
//  BBLMySensorsTableViewCell.swift
//  Bumbl
//
//  Created by Randy Ting on 1/23/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol BBLMySensorsTableViewCellDelegate: class {
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didSaveThreshold threshold: Int, andName name: String?)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didChangeThreshold threshold: Int)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool)
}

class BBLMySensorsTableViewCell: UITableViewCell {
  
  // MARK: Constants
  private struct BBLMySensorsTableViewCellConstants {
    private static let defaultMaxSliderValue = 100
    private static let defaultSliderValue = 50
  }
  
  // MARK: Public Variables
  internal weak var delegate: BBLMySensorsTableViewCellDelegate?
  internal var sensor: BBLSensor! {
    didSet (newSensor){
      if let newSensor = newSensor {
        if newSensor !== sensor
          || maxSliderValue == nil {
            resetValues()
        }
      }
      updateValuesWithSensor(sensor)
    }
  }
  
  // MARK: Private Variables
  private var maxSliderValue: Int!
  
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
    delegate?.tableViewCell?(self, didChangeThreshold: Int(sender.value))
  }
  @IBAction func didEndEditingThresholdTextField(sender: UITextField) {
    thresholdSlider.value = Float((sender.text! as NSString).integerValue)
    delegate?.tableViewCell?(self, didChangeThreshold: Int((sender.text! as NSString).integerValue))
  }
  
  @IBAction private func didTapRemoveFromProfileButton(sender: UIButton) {
    delegate?.tableViewCell?(self, didTapRemoveFromProfileButton: true)
  }
  
  @IBAction private func didTapSaveSettingsButton(sender: UIButton) {
    thresholdTextField.resignFirstResponder()
    nameTextField.resignFirstResponder()
    delegate?.tableViewCell?(self, didSaveThreshold: Int(thresholdSlider.value), andName: nameTextField.text)
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
    selectionStyle = .None
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  // MARK: Setup
  private func setupSlider(slider: UISlider) {
    slider.maximumValue = Float(BBLMySensorsTableViewCellConstants.defaultMaxSliderValue)
    slider.minimumValue = 0
    slider.value = Float(BBLMySensorsTableViewCellConstants.defaultSliderValue)
  }
  
  private func resetValues() {
    maxSliderValue = BBLMySensorsTableViewCellConstants.defaultMaxSliderValue
  }
  
  // MARK: Update
  internal func updateValuesWithSensor(sensor: BBLSensor) {
    if let _ = sensor.peripheral {
      if sensor.peripheral?.state == .Connected {
        backgroundColor = UIColor.BBLYellowColor()
      } else {
        backgroundColor = UIColor.BBLGrayColor()
      }
    } else {
      backgroundColor = UIColor.BBLGrayColor()
    }
    
    nameTextField.text = sensor.name
    uuidLabel.text = sensor.uuid
    
    if let capSenseValue = sensor.capSenseValue {
      if capSenseValue > maxSliderValue {
        maxSliderValue = capSenseValue
        thresholdSlider.maximumValue = Float(maxSliderValue)
      }
      valueLabel.text = String(format: "%i", capSenseValue)
      valueForegroundViewWidthConstraint.constant = CGFloat(capSenseValue)/CGFloat(maxSliderValue) * valueBackgroundView.frame.width
    } else {
      valueLabel.text = ""
    }
    thresholdTextField.text = String(format: "%02d", sensor.capSenseThreshold)
    thresholdSlider.value = Float(sensor.capSenseThreshold)
    if sensor.hasBaby {
      babyDetectedLabel.textColor = UIColor.BBLWetAsphaltColor()
    } else {
      babyDetectedLabel.textColor = UIColor.clearColor()
    }
  }
  
}
