//
//  AsyncOperation.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {

    private(set) var error: Error?
    
    @objc
    private enum State: Int {
        case ready
        case executing
        case finished
    }
    
    private var _state = State.ready
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".op.state", attributes: .concurrent)
    
    @objc
    private dynamic var state: State {
        get { return stateQueue.sync { _state } }
        set { stateQueue.sync(flags: .barrier) { _state = newValue } }
    }
    
    override var isAsynchronous: Bool { return true }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady",  "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    override func start() {
        if isCancelled {
            self.state = .finished
            return
        }
        
        self.state = .executing
        main()
    }
    
    override func main() {
        assertionFailure("Subclasses must implement `main`.")
    }
    
    final func finish(with error: Error? = nil) {
        if isExecuting {
            self.error = error
            self.state = .finished
            
            DispatchQueue.main.async {
                self.completed()
            }
        }
    }
    
    func completed() {
      if isExecuting {
          self.state = .finished
      }
  }
}
