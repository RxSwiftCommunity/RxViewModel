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
public class RxViewModel: NSObject {
  // MARK: Properties
  /// Scope dispose to avoid leaking
  internal var dispose: ScopedDispose? = nil
  
  /// The subject for active «signals»
  private var activeSubject: ReplaySubject<RxViewModel>?
  
  /// The subject for the inactive «signals»
  private var inactiveSubject: ReplaySubject<RxViewModel>?
  
  /// Underlying variable that we'll listen to for changes
  private dynamic var _active: Bool = false
  
  /// Public «active» variable
  public dynamic var active: Bool {
    get { return _active }
    set {
      // Skip KVO notifications when the property hasn't actually changed. This is
      // especially important because self.active can have very expensive
      // observers attached.
      if newValue == _active { return }
      
      _active = newValue
    }
  }
  
  // MARK: Life cycle
  
  /**
  Initializes a `RxViewModel` a attaches to observe changes in the `active` flag.
  */
  public override init() {
    super.init()
    
    /// Start observing changes on our underlying `_active` property.
    self.dispose = self.rx_observe("_active", options: .New) as Observable<Bool?>
      >- subscribeNext { active in
        /// If we have an active subject and the flag is true send ourselves
        /// as the next value in the stream to the active subject; else send
        /// ourselves to the inactive one.
        if let actSub = self.activeSubject
          where active == true {
            sendNext(actSub, self)
        } else if let inactSub = self.inactiveSubject
          where active == false {
            sendNext(inactSub, self)
        }
    } >- scopedDispose
  }
  
  deinit {
    self.dispose = nil
  }
  
  /**
  Rx `Observable` for the `active` flag. (when it becomes `true`).
  
  Will send messages only to *new* & *different* values.
  */
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
  
  /**
  Rx `Observable` for the `active` flag. (when it becomes `false`).
  
  Will send messages only to *new* & *different* values.
  */
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
  
  /**
  Subscribes (or resubscribes) to the given signal whenever
  `didBecomeActiveSignal` fires.

  When `didBecomeInactiveSignal` fires, any active subscription to `signal` is
  disposed.

  Returns a signal which forwards `next`s from the latest subscription to
  `signal`, and completes when the receiver is deallocated. If `signal` sends
  an error at any point, the returned signal will error out as well.
  */
  public func forwardSignalWhileActive<T>(observable: Observable<T>) -> Observable<T> {
    let signal = self.rx_observe("_active", options: [.Initial, .New]) as Observable<Bool?>
    
    return create { (o: ObserverOf<T>) -> Disposable in
      let disposable = CompositeDisposable()
      var signalDisposable: Disposable? = nil
      var disposeKey: Bag<Disposable>.KeyType?
    
      let activeDisposable = signal >- subscribe( { active in
        if active == true {
          signalDisposable = observable >- subscribe( { value in
            o.on(.Next(value))
            }, error: { error in
              o.on(.Error(error))
            }, completed: {})
          
          if let sd = signalDisposable { disposeKey = disposable.addDisposable(sd) }
        } else {
          if let sd = signalDisposable {
            sd.dispose()
            if let dk = disposeKey {
              disposable.removeDisposable(dk)
            }
          }
        }
      }, error: { error in
        o.on(.Error(error))
      }, completed: {
        o.on(.Completed)
      })
      
      disposable.addDisposable(activeDisposable)
      
      return disposable
    }
  }
}