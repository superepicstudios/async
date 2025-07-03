//
//  AsyncExampleView.swift
//  Demo
//
//  Created by Mitch Treece on 6/22/25.
//

import Async
import SwiftUI

fileprivate final class ViewModel: ObservableObject {
    
    @StreamedPipe var isLoading: Bool = false
    @StreamedPipe var word: String? = nil
    
    private let service: any AsyncServiceProtocol = AsyncService()
    
    init() {
        
        self.$isLoading.connect(
            to: self.service.isLoadingStream
        )
        
        self.$word.connect(
            to: self.service.wordStream
        )
        
    }
    
    // @MainActor
    func update() {
        
        print("ViewModel.update() - main: \(Thread.current.isMainThread)")
        self.service.update()
        
    }
    
}

struct AsyncExampleView: View {
    
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        
        Form {
            
            Section {
                
                if self.viewModel.isLoading {
                    
                    HStack {
                        
                        Text("**Word**:")
                        
                        ProgressView()
                            .id(UUID())
                        
                    }
                    
                }
                else {
                    Text("**Word**: \(self.viewModel.word != nil ? self.viewModel.word! : "-")")
                }
                
            }
            
            Section {
                
                CenteredButton(title: "Update") {
                    self.viewModel.update()
                }
                .disabled(self.viewModel.isLoading)
                
            }
            
        }
        .navigationTitle("Async Example")
        
    }
    
}
