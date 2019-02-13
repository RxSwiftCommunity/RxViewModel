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

/**
Implements behaviors that drive the UI, and/or adapts a domain model to be 
user-presentable.
*/
open class RxViewModel: NSObject {
  // MARK: Constants
  let throttleTime: TimeInterval = 2
  
  // MARK: Properties
  /// Scope dispose to avoid leaking
  public private(set) var disposeBag = DisposeBag()
    
  /// Underlying variable that we'll listen to for changes
  @objc private dynamic var _active: Bool = false
  
  /// Public «active» variable
  @objc public dynamic var active: Bool {
    get { return _active }
    set {
      // Skip KVO notifications when the property hasn't actually changed. This is
      // especially important because self.active can have very expensive
      // observers attached.
      if newValue == _active { return }
      
      _active = newValue
      self.activeObservable.on(.next(_active))
    }
  }
   
   // Private
   private lazy var activeObservable: BehaviorSubject<Bool?> = {
      let ao = BehaviorSubject(value: Bool?(self.active))
      
      return ao
   }()
  
  // MARK: Life cycle
  
  /**
  Initializes a `RxViewModel` a attaches to observe changes in the `active` flag.
  */
  public override init() {
    super.init()
  }
  
  /**
  Rx `Observable` for the `active` flag. (when it becomes `true`).
  
  Will send messages only to *new* & *different* values.
  */
  public lazy var didBecomeActive: Observable<RxViewModel> = { [unowned self] in
    return self.activeObservable
        .filter { $0 == true }
        .map { _ in return self }
  }()
  
  /**
  Rx `Observable` for the `active` flag. (when it becomes `false`).
  
  Will send messages only to *new* & *different* values.
  */
  public lazy var didBecomeInactive: Observable<RxViewModel> = { [unowned self] in
    return self.activeObservable
        .filter { $0 == false }
        .map { _ in return self }
  }()
  
  /**
  Subscribes (or resubscribes) to the given signal whenever
  `didBecomeActiveSignal` fires.

  When `didBecomeInactiveSignal` fires, any active subscription to `signal` is
  disposed.

  Returns a signal which forwards `next`s from the latest subscription to
  `signal`, and completes when the receiver is deallocated. If `signal` sends
  an error at any point, the returned signal will error out as well.
  */
  public func forwardSignalWhileActive<T>(_ observable: Observable<T>) -> Observable<T> {
    let signal = self.activeObservable
    
    return Observable.create { (obs: AnyObserver<T>) -> Disposable in
      let disposable = CompositeDisposable()
      var signalDisposable: Disposable? = nil
      var disposeKey: CompositeDisposable.DisposeKey?
    
      let activeDisposable = signal.subscribe( onNext: { active in
        if active == true {
          signalDisposable = observable.subscribe( onNext: { value in
            obs.on(.next(value))
            }, onError: { error in
              obs.on(.error(error))
            }, onCompleted: {})
          
          if let sd = signalDisposable { disposeKey = disposable.insert(sd) }
        } else {
          if let sd = signalDisposable {
            sd.dispose()
            if let dk = disposeKey {
                disposable.remove(for: dk)
            }
          }
        }
      }, onError: { error in
        obs.on(.error(error))
      }, onCompleted: {
        obs.on(.completed)
      })

      _ = disposable.insert(activeDisposable)
      
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
  public func throttleSignalWhileInactive<T>(_ observable: Observable<T>) -> Observable<T> {
    let result = ReplaySubject<T>.create(bufferSize: 1)
    
    let activeSignal = self.activeObservable.takeUntil(Observable.create { (_: AnyObserver<T>) -> Disposable in
      observable.subscribe(onCompleted: {
        defer { result.dispose() }
        
        result.on(.completed)
      })
    })

    _ = Observable.combineLatest(activeSignal, observable) { (active, obs) -> (Bool?, T) in (active, obs) }
      .throttle(throttleTime) { (active: Bool?, _: T) -> Bool in
      return active == false
    }.subscribe(onNext: { (value: (Bool?, T)) in
      result.on(.next(value.1))
    }, onError: { _ in }, onCompleted: {
      result.on(.completed)
    })

    return result
  }
}
