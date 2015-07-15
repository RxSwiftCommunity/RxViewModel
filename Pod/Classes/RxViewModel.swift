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

public class RxViewModel: NSObject {
  private var activeSubject: ReplaySubject<RxViewModel>?
  private var inactiveSubject: ReplaySubject<RxViewModel>?
  
  public var active: Bool = false {
    /// Had to resort to this horrible black voodoo magic
    /// because self.rx_observe("active") NEVER compiled…
    /// Will have to revisit this on future versions of RxCocoa
    /// TODO: Review this at some point.
    willSet {
      // Skip KVO notifications when the property hasn't actually changed. This is
      // especially important because self.active can have very expensive
      // observers attached.
      if self.active == newValue { return }
      
      if let actSub = self.activeSubject
      where newValue == true {
        sendNext(actSub, self)
      }
      
      if let inactSub = self.inactiveSubject
        where newValue == false {
          sendNext(inactSub, self)
      }
    }
  }
  
  public var didBecomeActive: Observable<RxViewModel> {
    get {
      return deferred { [weak self] () -> Observable<RxViewModel> in
        if let weakSelf = self
          where weakSelf.activeSubject == nil {
            weakSelf.activeSubject = ReplaySubject(bufferSize: 1)
            
            return weakSelf.activeSubject!
        }
        
        return self!.activeSubject!
      }
    }
  }
  
  public var didBecomeInactive: Observable<RxViewModel> {
    get {
      return deferred { [weak self] () -> Observable<RxViewModel> in
        if let weakSelf = self
          where weakSelf.inactiveSubject == nil {
            weakSelf.inactiveSubject = ReplaySubject(bufferSize: 1)
            
            return weakSelf.inactiveSubject!
        }
        
        return self!.inactiveSubject!
      }
    }
  }
}