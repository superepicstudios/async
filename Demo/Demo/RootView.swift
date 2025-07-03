//
//  RootView.swift
//  Demo
//
//  Created by Mitch Treece on 5/12/25.
//

import SFSafeSymbols
import SwiftUI

struct RootView: View {
    
    var body: some View {
        
        Form {
            
            Section("Async") {
                
                rowView(symbol: .book, title: "Subjects") {
                    AsyncSubjectView()
                }
                
                rowView(symbol: .gift, title: "Property Wrappers") {
                    AsyncPropertyWrapperView()
                }
                
                rowView(symbol: .star, title: "Example") {
                    AsyncExampleView()
                }
                
            }
            
            Section("Combine") {
                
                rowView(symbol: .book, title: "Subjects") {
                    CombineSubjectView()
                }
                
                rowView(symbol: .gift, title: "Property Wrappers") {
                    CombinePropertyWrapperView()
                }
                
                rowView(symbol: .star, title: "Example") {
                    CombineExampleView()
                }
                
            }
            
        }
        .navigationTitle("Async")
        
    }
    
    // MARK: Private
    
    private func rowView(
        symbol: SFSymbol,
        title: String,
        destination: () -> some View
    ) -> some View {
        
        HStack {
            
            Image(systemSymbol: symbol)
                .frame(width: 24, height: 12)
            
            NavigationLink(
                title,
                destination: destination
            )
            
        }
        
    }
    
}

#Preview {
    NavigationStack {
        RootView().navigationBarTitleDisplayMode(.inline)
    }
}
