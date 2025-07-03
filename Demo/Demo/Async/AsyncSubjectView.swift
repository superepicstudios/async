//
//  AsyncSubjectView.swift
//  Demo
//
//  Created by Mitch Treece on 6/13/25.
//

import Async
import SwiftUI

fileprivate final class ViewModel: ObservableObject {
    
    static let replayCount: UInt = 3
    
    private let replaySubject: AsyncReplaySubject<Int>
    var replaySequence: AnyAsyncSequence<Int> {
        self.replaySubject.eraseToAnyAsyncSequence()
    }
    
    private let currentValueSubject = AsyncCurrentValueSubject(0)
    var currentValueSequence: AnyAsyncSequence<Int> {
        self.currentValueSubject.eraseToAnyAsyncSequence()
    }
    
    private let passthroughSubject = AsyncPassthroughSubject<Int>()
    var passthroughSequence: AnyAsyncSequence<Int> {
        self.passthroughSubject.eraseToAnyAsyncSequence()
    }
    
    private let signalSubject = AsyncSignalSubject()
    var signalSequence: AnyAsyncSequence<Void> {
        self.signalSubject.eraseToAnyAsyncSequence()
    }
    
    init() {
        
        self.replaySubject = .init(Self.replayCount)
        self.replaySubject.send(1)
        self.replaySubject.send(2)
        self.replaySubject.send(3)
        
    }
    
    @MainActor
    func update() {
        
        self.replaySubject.send(.random(in: 0...100))
        self.currentValueSubject.send(.random(in: 0...100))
        self.passthroughSubject.send(.random(in: 0...100))
        self.signalSubject.send()
        
    }
    
}

struct AsyncSubjectView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var replayValues = [Int]()
    @State private var currentValue: Int = 0
    @State private var passthroughValue: Int?
    @State private var signalCount: Int = 0
    
    var body: some View {
        
        Form {
            
            Section {
                
                Text("**Replay**: \(replayValueString())")
                Text("**Current**: \(self.currentValue)")
                Text("**Passthrough**: \(self.passthroughValue != nil ? String(self.passthroughValue!) : "-")")
                Text("**Signals**: \(self.signalCount)")
                
            }
            .contentTransition(.numericText())

            Section {

                CenteredButton(title: "Update") {
                    withAnimation {
                        self.viewModel.update()
                    }
                }

            }
            
        }
        .navigationTitle("Async Subjects")
        .onStream(self.viewModel.replaySequence) { self.replayValues.append($0) }
        .onStream(self.viewModel.currentValueSequence) { self.currentValue = $0 }
        .onStream(self.viewModel.passthroughSequence) { self.passthroughValue = $0 }
        .onStream(self.viewModel.signalSequence) { self.signalCount += 1 }
        
    }
    
    private func replayValueString() -> String {
        
        let values = self.replayValues
            .suffix(Int(ViewModel.replayCount))
        
        return String(describing: values)
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
        
    }
    
}
