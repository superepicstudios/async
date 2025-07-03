//
//  AsyncPropertyWrapperView.swift
//  Demo
//
//  Created by Mitch Treece on 6/11/25.
//

import Async
import SwiftUI

fileprivate final class ViewModel: ObservableObject {
    
    @Streamed var value = 0
    @StreamedPipe var pipeValue = 0
    
    @Streaming<Int>(0) var currentValueStream
    @Streaming<Int> var passthroughStream
    @StreamingSignal var signalStream
    
    private let pipeSubject = AsyncCurrentValueSubject<Int>(0)
    
    init() {

        self.$pipeValue.connect(
            to: self.pipeSubject
        )
        
    }
    
    @MainActor
    func update() {
        
        self.value = .random(in: 0...100)
        self.pipeSubject.send(.random(in: 0...100))
        
        self.$currentValueStream.send(.random(in: 0...100))
        self.$passthroughStream.send(.random(in: 0...100))
        self.$signalStream.send()
        
    }
    
}

struct AsyncPropertyWrapperView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var currentValue: Int = 0
    @State private var passthroughValue: Int?
    @State private var signalCount: Int = 0
    
    var body: some View {
        
        Form {
            
            Group {
                
                Section("@Streamed") {
                    Text("**Value**: \(self.viewModel.value)")
                }
                
                Section("@StreamedPipe") {
                    Text("**Value**: \(self.viewModel.pipeValue)")
                }
                
                Section("@Streaming") {
                    Text("**Current**: \(self.currentValue)")
                    Text("**Passthrough**: \(self.passthroughValue != nil ? String(self.passthroughValue!) : "-")")
                }
                
                Section("@StreamingSignal") {
                    Text("**Count**: \(self.signalCount)")
                }
                
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
        .navigationTitle("Async Property Wrappers")
        .onStream(self.viewModel.currentValueStream) { self.currentValue = $0 }
        .onStream(self.viewModel.passthroughStream) { self.passthroughValue = $0 }
        .onStream(self.viewModel.signalStream) { self.signalCount += 1 }

    }
    
}
