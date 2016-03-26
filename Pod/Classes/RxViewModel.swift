//
//  RxViewModel.swift
//  RxViewModel
//
//  Created by Esteban Torres on 7/14/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import Foundation

// Dependencies
import RxSwift
import RxCocoa

/**
Implements behaviors that drive the UI, and/or adapts a domain model to be 
user-presentable.
*/
public class RxViewModel: NSObject, Activable {
  // MARK: Constants
  public var ThrottleTime: NSTimeInterval = 2
  
  // MARK: Properties
  /// Scope dispose to avoid leaking
  var disposeBag = DisposeBag()
  
  /// The subject for active «signals»
  public var activeSubject: ReplaySubject<RxViewModel>?
  
  /// The subject for the inactive «signals»
  public var inactiveSubject: ReplaySubject<RxViewModel>?
  
  /// Underlying variable that we'll listen to for changes
  public dynamic var _active: Bool = false
  
  
  /**
  Initializes a `RxViewModel` a attaches to observe changes in the `active` flag.
  */
  public override init() {
    super.init()
    
    let observable = self.rx_observe(Bool.self, "_active") as Observable<Bool?>
    /// Start observing changes on our underlying `_active` property.
    observable.subscribeNext { active in
        /// If we have an active subject and the flag is true send ourselves
        /// as the next value in the stream to the active subject; else send
        /// ourselves to the inactive one.
        if let actSub = self.activeSubject
          where active == true {
            actSub.on(.Next(self))
        } else if let inactSub = self.inactiveSubject
          where active == false {
            inactSub.on(.Next(self))
        }
    }.addDisposableTo(disposeBag)
  }
  
}