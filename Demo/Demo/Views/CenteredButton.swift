//
//  CenteredButton.swift
//  Demo
//
//  Created by Mitch Treece on 5/12/25.
//

import SwiftUI

struct CenteredButton: View {
    
    private let title: String
    private let action: () -> Void
    
    init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        
        Button {
            self.action()
        } label: {
            
            HStack {
                
                Spacer()
                Text(self.title)
                Spacer()
                
            }
            
        }
        .foregroundStyle(.link)
        
    }
    
}
