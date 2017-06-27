//
//  Observable + Operations.swift
//  RxViewModel
//
//  Created by Esteban Torres on 16/7/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import Foundation

// Dependecies
import RxSwift

/**
 Throttles `next`s for which `predicate` returns `true`.

 When `valuesPassingTest` returns `true` for a `next`:

  1. If another `next` is received before `interval` seconds have passed, the
     prior value is discarded. This happens regardless of whether the new
     value will be throttled.
  2. After `interval` seconds have passed since the value was originally
     received, it will be forwarded on the scheduler that it was received
     upon.

 When `valuesPassingTest` returns NO for a `next`, it is forwarded immediately,
 without any throttling.

 - parameter interval: The number of seconds for which to buffer the latest value that
             passes `valuesPassingTest`.
 - parameter valuesPassingTest: Passed each `next` from the receiver, this closuer returns
             whether the given value should be throttled.

 - returns: Returns a signal which sends `next` events, throttled when `predicate`
returns `true`. Completion and errors are always forwarded immediately.
*/
extension ObservableType {
  public func throttle(_ interval: TimeInterval, valuesPassingTest predicate: @escaping (E) -> Bool) -> Observable<E> {
    return Observable.create { (obs: AnyObserver<E>) -> Disposable in
      let disposable = CompositeDisposable()
      let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
      let nextDisposable = SerialDisposable()
      var hasNextValue = false
      var nextValue: E?
      let parent = self.asObservable()
      
      let subscriptionDisposable = parent.subscribe(onNext: {
        /**
        Disposes the «last» `next` subscription if there was a previous value it gets
        flushed to the observable `o`.
        
        - parameter send: 	`Bool` flag indicating where or not the `next` value should be
        «flushed» to the `observable` `o` or not.
        */
        func flushNext(_ send: Bool) {
          nextDisposable.dispose()
          
          guard let nV = nextValue, hasNextValue, send else { return }
          
          nextValue = nil
          hasNextValue = false

          obs.on(.next(nV))
        }
        
        let shouldThrottle = predicate($0)
        flushNext(false)
        
        if !shouldThrottle {
          obs.on(.next($0))
          
          return
        }
        
        hasNextValue = true
        nextValue = $0
        
        let flush = flushNext
        let d = Observable<Int64>.timer(interval, scheduler: scheduler)
          .subscribe(onNext: { _ in
            flush(true)
          })
        
        _ = disposable.insert(d)
      })

      _ = disposable.insert(subscriptionDisposable)
      
      return disposable
    }
  }
}
