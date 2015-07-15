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
      
      let input = create { o -> Disposable in
        o.on(.Next("1"))
        o.on(.Next("2"))
        
        return AnonymousDisposable {}
      } as Observable<String?>
      
      vm.forwardSignalWhileActive(input) >- subscribe({ value in
        values.append(value!)
      }, error: { err in
          
      }, completed: {
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
    }
  }
}