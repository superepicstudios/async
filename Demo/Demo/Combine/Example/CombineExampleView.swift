//
//  CombineExampleView.swift
//  Demo
//
//  Created by Mitch Treece on 5/12/25.
//

import Async
import SwiftUI

fileprivate final class ViewModel: ObservableObject {
    
    @PublishedPipe var isLoading: Bool = false
    @PublishedPipe var word: String? = nil
    
    private let service: any CombineServiceProtocol = CombineService()
    private var bag = CancellableBag()
    
    init() {
        
        self.$word.connect(
            to: self.service.wordPublisher
        )
        
        self.$isLoading.connect(
            to: self.service.isLoadingPublisher
        )
        
    }
    
    @MainActor
    func update() {
        self.service.update()
    }
    
}

struct CombineExampleView: View {
    
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
        .navigationTitle("Combine Example")
        
    }
    
}
