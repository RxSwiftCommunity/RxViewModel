//
//  Activable.swift
//  Pods
//
//  Created by Chris Jimenez on 3/25/16.
//
//

import Foundation
// Dependencies
import RxSwift
import RxCocoa

/**
 *  Activable protocol providing RX functionality
 */
public protocol Activable: class{
    
     // MARK: Constants
    var ThrottleTime: NSTimeInterval {get set}
    
    var active : Bool {get set}
    
    /// Underlying variable that we'll listen to for changes
    var _active: Bool {get set}
    
    /// The subject for active «signals»
    var activeSubject: ReplaySubject<RxViewModel>? {get set}
    
    /// The subject for the inactive «signals»
    var inactiveSubject: ReplaySubject<RxViewModel>? {get set}
    
}


extension Activable where Self: NSObject {
    
    public var active: Bool{
        
        get { return _active }
        set {
            // Skip KVO notifications when the property hasn't actually changed. This is
            // especially important because self.active can have very expensive
            // observers attached.
            if newValue == _active { return }
            
            _active = newValue
        }
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
