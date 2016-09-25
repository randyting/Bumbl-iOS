//
//  BBLSensorValueGaugeView.swift
//  Bumbl
//
//  Created by Randy Ting on 6/13/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLSensorValueGaugeView: UIView {

  
  // MARK: Interface Builder
  
  @IBOutlet var view: UIView!
  @IBOutlet var stackView: UIStackView!
  @IBOutlet weak var stackViewBarsWidthConstraint: NSLayoutConstraint!
  
  // MARK: Public Variables
  internal var gaugeFillNormalized: Double! = 0.0 {
    willSet(newValue) {
      
      if newValue > 1.0 {
        self.gaugeFillNormalized = 1.0
        return
      } else if newValue < 0.0 {
        self.gaugeFillNormalized = 0.0
        return
      }
      
      self.gaugeFillNormalized = newValue
      updateGaugeFillNormalized(self.gaugeFillNormalized)
    }
  }
  
  // MARK: Lifecycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initViews()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    
    Bundle.main.loadNibNamed("BBLSensorValueGaugeView", owner: self, options: nil)
    addSubview(view)
    view.frame = bounds
    
    initViews()
  }
  
  func initViews() {
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupAppearanceForStackView(stackView)
  }
  
  // MARK: Initial Setup
  
  fileprivate func setupAppearanceForStackView(_ stackView: UIStackView) {
    stackViewBarsWidthConstraint.constant = bounds.width/50
    stackView.spacing = bounds.width/300
    for view in stackView.arrangedSubviews {
      view.backgroundColor = UIColor.white
    }
    updateGaugeFillNormalized(gaugeFillNormalized)
  }
  
  // MARK: Accessors
  
  internal func setGaugeBackgroundColor(_ color: UIColor) {
    view.backgroundColor = color
  }
  
  // MARK: Private Methods
  
  fileprivate func updateGaugeFillNormalized(_ filledValueNormalized: Double) {
    
    if filledValueNormalized.isNaN {
      return
    }
    
    let numberOfSubviewsToFill = filledValueNormalized * Double(stackView.arrangedSubviews.count)
    
    for (index, view) in stackView.arrangedSubviews.enumerated() {
      if index < Int(numberOfSubviewsToFill) {
        view.backgroundColor = UIColor.BBLDarkBlueColor()
      } else {
        view.backgroundColor = UIColor.white
      }

    }
  }
  

}
