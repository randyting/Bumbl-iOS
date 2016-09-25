//
//  BBLStateMachine.swift
//  Bumbl
//
//  Created by Randy Ting on 2/6/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//
//  Taken from: https://gist.github.com/jemmons/c9434cc09831a276003e
//

import Foundation

class BBLStateMachine<P:BBLStateMachineDelegateProtocol>{
  fileprivate unowned let delegate:P
  
  fileprivate var _state:P.StateType{
    didSet{
      delegate.didTransitionFrom(oldValue, to:_state)
    }
  }
  
  var state:P.StateType{
    get{ return _state }
    set{
      if delegate.shouldTransitionFrom(_state, to:newValue){
        _state = newValue
      }
    }
  }
  
  
  init(initialState:P.StateType, delegate:P){
    _state = initialState
    self.delegate = delegate
  }
}



protocol BBLStateMachineDelegateProtocol: class{
  associatedtype StateType
  func shouldTransitionFrom(_ from:StateType, to:StateType)->Bool
  func didTransitionFrom(_ from:StateType, to:StateType)
}
