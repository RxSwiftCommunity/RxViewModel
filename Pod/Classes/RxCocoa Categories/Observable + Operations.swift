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
import RxCocoa
import RxSwift

/**
 Throttles `next`s for which `predicate` returns `true`.

 When `valuePassingTest` returns `true` for a `next`:

  1. If another `next` is received before `interval` seconds have passed, the
     prior value is discarded. This happens regardless of whether the new
     value will be throttled.
  2. After `interval` seconds have passed since the value was originally
     received, it will be forwarded on the scheduler that it was received
     upon.

 When `valuePassingTest` returns NO for a `next`, it is forwarded immediately,
 without any throttling.

 - parameter interval: The number of seconds for which to buffer the latest value that
             passes `valuePassingTest`.
 - parameter valuePassingTest: Passed each `next` from the receiver, this closuer returns
             whether the given value should be throttled.

 - returns: Returns a signal which sends `next` events, throttled when `valuePassingTest`
returns `true`. Completion and errors are always forwarded immediately.
*/
public func throttle<E>(interval: NSTimeInterval, valuePassingTest predicate:(E) -> Bool) -> (Observable<E> -> Observable<E>) {
  return { source in
    create { (o: ObserverOf<E>) -> Disposable in
      let disposable = CompositeDisposable()
      
      let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Low)
      let nextDisposable = SerialDisposable()
      var hasNextValue = false
      var nextValue:E?
      
      let subscriptionDisposable = source >- subscribeNext {
        func flushNext(send: Bool) -> Void {
          nextDisposable.dispose()
          
          if !hasNextValue { return }
          if let nV = nextValue
            where send == true {
              o.on(.Next(RxBox<E>(nV)))
          }
          
          nextValue = nil
          hasNextValue = false
        }
        
        let shouldThrottle = predicate($0)
        flushNext(false)
        
        if !shouldThrottle {
          o.on(.Next(RxBox<E>($0)))
          
          return
        }
        
        hasNextValue = true
        nextValue = $0
        
        let flush = flushNext
        timer(dueTime: interval, scheduler) >- subscribeNext { _ in
          flush(true)
        }
      }
      
      disposable.addDisposable(subscriptionDisposable)
      
      return disposable
    }
  }
}