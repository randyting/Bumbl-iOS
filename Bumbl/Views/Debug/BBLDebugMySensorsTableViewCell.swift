//
//  BBLDebugMySensorsTableViewCell.swift
//  Bumbl
//
//  Created by Randy Ting on 1/23/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol BBLDebugMySensorsTableViewCellDelegate: class {
  optional func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didSaveThreshold threshold: Int, andName name: String?)
  optional func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didChangeThreshold threshold: Int)
  optional func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool)
  optional func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didChangeDelayValue value: Int)
  optional func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didTapRebaselineButton: Bool)
}

class BBLDebugMySensorsTableViewCell: UITableViewCell {
  
  // MARK: Constants
  
  private struct BBLDebugMySensorsTableViewCellConstants {
    private static let defaultMaxSliderValue = 100
    private static let defaultSliderValue = 50
  }
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLDebugMySensorsTableViewCellDelegate?
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
  @IBOutlet weak var delayInSecondsLabel: UILabel!
  @IBOutlet weak var delayInSecondsStepper: UIStepper!
  @IBOutlet private weak var valueLabel: UILabel!
  @IBOutlet private weak var thresholdSlider: UISlider!
  @IBOutlet private weak var thresholdTextField: UITextField!
  @IBOutlet private weak var sensorStateLabel: UILabel!
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
  
  @IBAction func stepperValueDidChange(sender: UIStepper) {
    delegate?.tableViewCell?(self, didChangeDelayValue: Int(sender.value))
  }
  
  @IBAction func didTapRebaselineButton(sender: UIButton) {
    delegate?.tableViewCell?(self, didTapRebaselineButton: true)
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
    slider.maximumValue = Float(BBLDebugMySensorsTableViewCellConstants.defaultMaxSliderValue)
    slider.minimumValue = 0
    slider.value = Float(BBLDebugMySensorsTableViewCellConstants.defaultSliderValue)
  }
  
  private func resetValues() {
    maxSliderValue = BBLDebugMySensorsTableViewCellConstants.defaultMaxSliderValue
  }
  
  // MARK: Update
  
  internal func updateValuesWithSensor(sensor: BBLSensor) {
    nameTextField.text = sensor.name
    uuidLabel.text = sensor.uuid
    delayInSecondsLabel.text = String(sensor.delayInSeconds)
    delayInSecondsStepper.value = Double(sensor.delayInSeconds)
    
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
    
    switch (sensor.stateMachine.state as BBLSensorState) {
    case .Activated:
      backgroundColor = UIColor.BBLYellowColor()
      sensorStateLabel.text = "Activated"
    case .Deactivated:
      backgroundColor = UIColor.BBLYellowColor()
      sensorStateLabel.text = "Deactivated"
    case .Disconnected:
      backgroundColor = UIColor.BBLGrayColor()
      sensorStateLabel.text = "Disconnected"
    case .WaitingToBeActivated:
      backgroundColor = UIColor.BBLYellowColor()
      sensorStateLabel.text = "Waiting To Be Activated"
    case .WaitingToBeDeactivated:
      backgroundColor = UIColor.BBLYellowColor()
      sensorStateLabel.text = "Waiting To Be Deactivated"
    }
    
  }

}
