//
//  Observable+Async.swift
//  AsyncExperiments
//
//  Created by Mitch Treece on 8/3/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

//#if canImport(Observation) // iOS 26+
//
//import Observation
//
//extension Observable {
//    
//    func sequence<Value: Sendable>(of keyPath: KeyPath<Self, Value>) -> any AsyncSequence<Value, Never> {
//        Observations {
//            self[keyPath: keyPath]
//        }
//    }
//    
//}
//
//#endif

//@Observable
//final class Store {
//    var items = [String]()
//}
//
//let store = Store()
//
//for await items in store.sequence(of: \.items) {
//    ...
//}
