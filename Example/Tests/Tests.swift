// https://github.com/Quick/Quick

// Testing Frameworks
import Quick
import Nimble

// Required Frameworks
import RxSwift
import RxCocoa

// Framework To Be Test
import RxViewModel

class RxViewModelSpec: QuickSpec {
  var viewModel: RxViewModel?
  
  override func spec() {
    beforeEach {
      self.viewModel = RxViewModel()
    }
    
    describe("active property") {
      it("should default to NO") {
        if let vm = self.viewModel {
          expect(vm.active).to(beFalsy())
        } else {
          fail("• RxViewModel property not initialized.")
        }
      }
    
      it("should send on didBecomeActiveSignal when set to true") {
        if let vm = self.viewModel {
          var nextSteps = 0
          vm.didBecomeActive >- subscribeNext { model in
            expect(model).to(equal(vm))
            
            nextSteps++
          }
          
          expect(nextSteps).to(equal(0))
          
          vm.active = true
          expect(nextSteps).to(equal(1))
          
          // Indistinct changes should not trigger the signal again.
          vm.active = true
          expect(nextSteps).to(equal(1))
          
          vm.active = false
          vm.active = true
          expect(nextSteps).to(equal(2))
        } else {
          fail("• RxViewModel property not initialized.")
        }
      }
    
      it("should forward a signal") {
        if let vm = self.viewModel {
          vm.active = true
          var values = [String]()
          var completed = false
          
          let input = create { (o: ObserverOf<String>) -> Disposable in
            o.on(.Next(RxBox<String>("1")))
            o.on(.Next(RxBox<String>("2")))
            
            return AnonymousDisposable {}
          } as Observable<String>
          
          vm.forwardSignalWhileActive(input) >- subscribe(next: { (value: String) in
            values.append(value)
          }, error: { _ in }, completed: {
            completed = true
          })
          
          var expectedValues = ["1", "2"]
          expect(values).to(equal(expectedValues))
          expect(completed).to(beFalsy())
          
          vm.active = false
          expect(values).to(equal(expectedValues))
          expect(completed).to(beFalsy())
          
          vm.active = true
          expectedValues = ["1", "2", "1", "2"]
          expect(values).to(equal(expectedValues))
          expect(completed).to(beFalsy())
        } else {
          fail("• RxViewModel property not initialized.")
        }
      }
      
      it("should throttle a signal") {
        if let vm = self.viewModel {
          vm.active = true
          var values = [String]()
          var completed = false
          let subject = ReplaySubject<String>(bufferSize: 1)
          subject.on(.Next(RxBox<String>("0")))
          
          vm.throttleSignalWhileInactive(subject)
            >- subscribe(next: { (value: String) in
              values.append(value)
              }, error: { _ in  }, completed: {
                completed = true
            })
          
          var expectedValues = ["0"]
          expect(values).to(equal(expectedValues))
          expect(completed).to(beFalsy())
          
          subject.on(.Next(RxBox<String>("1")))
          expectedValues = ["0", "1"]
          expect(values).to(equal(expectedValues))
          expect(completed).to(beFalsy())
          
          vm.active = false
          
          // Since the VM is inactive, these events should be throttled.
          subject.on(.Next(RxBox<String>("2")))
          subject.on(.Next(RxBox<String>("3")))
          
          expect(values).to(equal(expectedValues))
          expect(completed).to(beFalsy())
          
          expectedValues = ["0", "1", "3"]
          expect(values).toEventually(equal(expectedValues), timeout: 4, pollInterval: 2)
          expect(completed).to(beFalsy())
          
          // After reactivating, we should still get this event.
          subject.on(.Next(RxBox<String>("4")))
          vm.active = true
          
          expectedValues = ["0", "1", "3", "4"]
          expect(values).toEventually(equal(expectedValues))
          expect(completed).to(beFalsy())
          
          // And now new events should be instant.
          subject.on(.Next(RxBox<String>("5")))
          
          expectedValues = ["0", "1", "3", "4", "5"]
          expect(values).to(equal(expectedValues))
          expect(completed).to(beFalsy())
          
          subject.on(.Completed)
          
          expect(values).to(equal(expectedValues))
          expect(completed).to(beTruthy())
        } else {
          fail("• RxViewModel property not initialized.")
        }
      }
    }
  }
}