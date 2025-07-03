//
//  CombineSubjectView.swift
//  Demo
//
//  Created by Mitch Treece on 6/12/25.
//

import Async
import SwiftUI

fileprivate final class ViewModel: ObservableObject {
    
    private let currentValueSubject = GuaranteeCurrentValueSubject(0)
    var currentValuePublisher: GuaranteePublisher<Int> {
        self.currentValueSubject.eraseToAnyPublisher()
    }
    
    private let passthroughSubject = GuaranteePassthroughSubject<Int>()
    var passthroughPublisher: GuaranteePublisher<Int> {
        self.passthroughSubject.eraseToAnyPublisher()
    }
    
    private let signalSubject = SignalSubject()
    var signalPublisher: GuaranteePublisher<Void> {
        self.signalSubject.eraseToAnyPublisher()
    }
    
    @MainActor
    func update() {
        
        self.currentValueSubject.send(.random(in: 0...100))
        self.passthroughSubject.send(.random(in: 0...100))
        self.signalSubject.send()
        
    }
    
}

struct CombineSubjectView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var currentValue: Int = 0
    @State private var passthroughValue: Int?
    @State private var signalCount: Int = 0
    
    var body: some View {
        
        Form {
            
            Section {
                
                Group {
                    
                    Section {
                        
                        Text("**Current**: \(self.currentValue)")
                        Text("**Passthrough**: \(self.passthroughValue != nil ? String(self.passthroughValue!) : "-")")
                        Text("**Signals**: \(self.signalCount)")

                    }
                    
                }
                .contentTransition(.numericText())

            }
            
            Section {
                
                CenteredButton(title: "Update") {
                    withAnimation {
                        self.viewModel.update()
                    }
                }
                
            }
            
        }
        .navigationTitle("Combine Subjects")
        .onReceive(self.viewModel.currentValuePublisher) { self.currentValue = $0 }
        .onReceive(self.viewModel.passthroughPublisher) { self.passthroughValue = $0 }
        .onReceive(self.viewModel.signalPublisher) { self.signalCount += 1 }

    }
    
}
