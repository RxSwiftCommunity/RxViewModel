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
  // MARK: Constants
  let ThrottleTime: NSTimeInterval = 2
  
  // MARK: Properties
  /// Scope dispose to avoid leaking
  var disposeBag = DisposeBag()
  
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
  
  /**
  Rx `Observable` for the `active` flag. (when it becomes `true`).
  
  Will send messages only to *new* & *different* values.
  */
  public var didBecomeActive: Observable<RxViewModel> {
    get {
      return Observable.deferred { [weak self] () -> Observable<RxViewModel> in
        if let weakSelf = self
          where weakSelf.activeSubject == nil {
            weakSelf.activeSubject = ReplaySubject.create(bufferSize: 1)
            
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
      return Observable.deferred { [weak self] () -> Observable<RxViewModel> in
        if let weakSelf = self
          where weakSelf.inactiveSubject == nil {
            weakSelf.inactiveSubject = ReplaySubject.create(bufferSize: 1)
            
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
    let signal = self.rx_observe(Bool.self, "_active", options: [.Initial, .New]) as Observable<Bool?>
    
    return Observable.create { (o: AnyObserver<T>) -> Disposable in
      let disposable = CompositeDisposable()
      var signalDisposable: Disposable? = nil
      var disposeKey: Bag<Disposable>.KeyType?
    
      let activeDisposable = signal.subscribe( onNext: { active in
        if active == true {
          signalDisposable = observable.subscribe( onNext: { value in
            o.on(.Next(value))
            }, onError: { error in
              o.on(.Error(error))
            }, onCompleted: {})
          
          if let sd = signalDisposable { disposeKey = disposable.addDisposable(sd) }
        } else {
          if let sd = signalDisposable {
            sd.dispose()
            if let dk = disposeKey {
              disposable.removeDisposable(dk)
            }
          }
        }
      }, onError: { error in
        o.on(.Error(error))
      }, onCompleted: {
        o.on(.Completed)
      })
      
      disposable.addDisposable(activeDisposable)
      
      return disposable
    }
  }
  
  /**
   Throttles events on the given `observable` while the receiver is inactive.
  
   Unlike `forwardSignalWhileActive:`, this method will stay subscribed to
   `observable` the entire time, except that its events will be throttled when the
   receiver becomes inactive.
  
  - parameter observable: The `Observable` to which this method will stay 
  subscribed the entire time.
  
  - returns: Returns an `observable` which forwards events from `observable` (throttled while the
  receiver is inactive), and completes when `observable` completes or the receiver
  is deallocated.
  */
  public func throttleSignalWhileInactive<T>(observable: Observable<T>) -> Observable<T> {
//    observable.replay(1)
    let result = ReplaySubject<T>.create(bufferSize: 1)
    
    let activeSignal = (self.rx_observe(Bool.self, "_active", options: [.Initial, .New]) as Observable<Bool?>).takeUntil(Observable.create { (o: AnyObserver<T>) -> Disposable in
      observable.subscribeCompleted {
        defer { result.dispose() }
        
        result.on(.Completed)
      }
    })

    let _ = Observable.combineLatest(activeSignal, observable) { (active, o) -> (Bool?, T) in (active, o) }
      .throttle(ThrottleTime) { (active: Bool?, value: T) -> Bool in
      return active == false
    }.subscribe(onNext: { (value:(Bool?, T)) in
      result.on(.Next(value.1))
    }, onError: { _ in }, onCompleted: {
      result.on(.Completed)
    })

    return result
  }
}