// https://github.com/Quick/Quick

// Testing Frameworks
import Quick
import Nimble

// Required Frameworks
import RxSwift

// Framework To Be Test
import RxViewModel

class RxViewModelSpec: QuickSpec {
  var viewModel: RxViewModel?
  let disposable = DisposeBag()
  
  override func spec() {
    beforeEach {
      self.viewModel = RxViewModel()
    }
    
    describe("active property") {
      it("should default to NO") {
        guard let vm = self.viewModel else {
          fail("• RxViewModel property not initialized.")
          
          /// Added to silence compiler warning
          return
        }
        
        expect(vm.active).to(beFalsy())
      }
    }
    
    it("should send on didBecomeActiveSignal when set to true") {
      guard let vm = self.viewModel else {
        fail("• RxViewModel property not initialized.")
        
        /// Added to silence compiler warning
        return
      }
      
      var nextSteps = 0
      vm.didBecomeActive.subscribeNext { model in
        expect(model).to(equal(vm))
        
        nextSteps += 1
      }.addDisposableTo(self.disposable)
      
      expect(nextSteps).to(equal(0))
      
      vm.active = true
      expect(nextSteps).to(equal(1))
      
      // Indistinct changes should not trigger the signal again.
      vm.active = true
      expect(nextSteps).to(equal(1))
      
      vm.active = false
      vm.active = true
      expect(nextSteps).to(equal(2))
    }
    
    it("should forward a signal") {
      guard let vm = self.viewModel else {
        fail("• RxViewModel property not initialized.")
        
        /// Added to silence compiler warning
        return
      }
      
      vm.active = true
      var values = [String]()
      var completed = false
      
      let input = Observable.create { o -> Disposable in
        o.on(.Next("1"))
        o.on(.Next("2"))
        
        return AnonymousDisposable {}
      } as Observable<String?>
      
      vm.forwardSignalWhileActive(input).subscribe( onNext: { value in
        values.append(value!)
      }, onError: { _ in }, onCompleted: {
        completed = true
      }).addDisposableTo(self.disposable)
      
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
    }
    
    it("should throttle a signal") {
      guard let vm = self.viewModel else {
        fail("• RxViewModel property not initialized.")
        
        /// Added to silence compiler warning
        return
      }
      
      vm.active = true
      var values = [String]()
      var completed = false
      let subject = ReplaySubject<String>.create(bufferSize: 5)
      subject.on(.Next("0"))
      
      vm.throttleSignalWhileInactive(subject).subscribe( onNext: { value in
        values.append(value)
      }, onError: { _ in  }, onCompleted: {
        completed = true
      }).addDisposableTo(self.disposable)
      
      var expectedValues = ["0"]
      expect(values).to(equal(expectedValues))
      expect(completed).to(beFalsy())
      
      subject.on(.Next("1"))
      expectedValues = ["0", "1"]
      expect(values).to(equal(expectedValues))
      expect(completed).to(beFalsy())
      
      vm.active = false
      
      // Since the VM is inactive, these events should be throttled.
      subject.on(.Next("2"))
      subject.on(.Next("3"))
      
      expect(values).to(equal(expectedValues))
      expect(completed).to(beFalsy())
      
      expectedValues = ["0", "1", "3"]
      expect(values).toEventually(equal(expectedValues), timeout: 2.2, pollInterval: 0.7)
      expect(completed).to(beFalsy())
      
      // After reactivating, we should still get this event.
      subject.on(.Next("4"))
      vm.active = true
      
      expectedValues = ["0", "1", "3", "4"]
      expect(values).toEventually(equal(expectedValues))
      expect(completed).to(beFalsy())
      
      // And now new events should be instant.
      subject.on(.Next("5"))
      
      expectedValues = ["0", "1", "3", "4", "5"]
      expect(values).to(equal(expectedValues))
      expect(completed).to(beFalsy())
      
      subject.on(.Completed)
      
      expect(values).to(equal(expectedValues))
      expect(completed).to(beTruthy())
    }
  }
}