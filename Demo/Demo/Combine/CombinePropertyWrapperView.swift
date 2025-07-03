//
//  CombinePropertyWrapperView.swift
//  Demo
//
//  Created by Mitch Treece on 5/12/25.
//

import Async
import SwiftUI

fileprivate final class ViewModel: ObservableObject {
    
    @Published private(set) var value: Int = 0
    @PublishedPipe var pipeValue: Int = 0
    
    @Publishing<Int>(0) var currentValuePublisher
    @Publishing<Int> var passthroughPublisher
    @PublishingError<Int, Never>(0) var currentValueErrorPublisher
    @PublishingError<Int, Never> var passthroughErrorPublisher
    @PublishingSignal var signalPublisher
    
    private let pipeSubject = GuaranteeCurrentValueSubject(0)
        
    init() {
        
        self.$pipeValue.connect(
            to: self.pipeSubject
        )
        
    }
    
    @MainActor
    func update() {
        
        self.value = .random(in: 1...100)
        self.pipeSubject.send(.random(in: 0...100))
        
        self.$currentValuePublisher.send(.random(in: 1...100))
        self.$passthroughPublisher.send(.random(in: 1...100))
        self.$currentValueErrorPublisher.send(.random(in: 1...100))
        self.$passthroughErrorPublisher.send(.random(in: 1...100))
        self.$signalPublisher.send()
        
    }
    
}

struct CombinePropertyWrapperView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var currentValue: Int = 0
    @State private var passthroughValue: Int?
    @State private var currentErrorValue: Int = 0
    @State private var passthroughErrorValue: Int?
    @State private var signalCount: Int = 0
    
    var body: some View {
        
        Form {
            
            Group {
                
                Section("@Published") {
                    Text("**Value**: \(self.viewModel.value)")
                }
                
                Section("@PublishedPipe") {
                    Text("**Value**: \(self.viewModel.pipeValue)")
                }
                
                Section("@Publishing") {
                    Text("**Current**: \(self.currentValue)")
                    Text("**Passthrough**: \(self.passthroughValue != nil ? String(self.passthroughValue!) : "-")")
                }
                
                Section("@PublishingError") {
                    Text("**Current**: \(self.currentErrorValue)")
                    Text("**Passthrough**: \(self.passthroughErrorValue != nil ? String(self.passthroughErrorValue!) : "-")")
                }
                
                Section("@PublishingSignal") {
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
        .navigationTitle("Combine Property Wrappers")
        .onReceive(self.viewModel.currentValuePublisher) { self.currentValue = $0 }
        .onReceive(self.viewModel.passthroughPublisher) { self.passthroughValue = $0 }
        .onReceive(self.viewModel.currentValueErrorPublisher) { self.currentErrorValue = $0 }
        .onReceive(self.viewModel.passthroughErrorPublisher) { self.passthroughErrorValue = $0 }
        .onReceive(self.viewModel.signalPublisher) { self.signalCount += 1 }

    }
    
}
