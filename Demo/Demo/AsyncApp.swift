//
//  AsyncApp.swift
//  Demo
//
//  Created by Mitch Treece on 5/12/25.
//

import SwiftUI

@main
struct CronoApp: App {
    
    var body: some Scene {
        
        WindowGroup {

            NavigationStack {
                
                RootView()
                    .navigationBarTitleDisplayMode(.inline)
                
            }
            
        }
        
    }
    
}
