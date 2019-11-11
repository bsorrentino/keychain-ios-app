//
//  ContentView.swift
//  keychain
//
//  Created by Bartolomeo Sorrentino on 06/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showLogin = true
    
    @State private var selection = 0
 
    var body: some View {
        TabView(selection: $selection){
            
            KeyItemListContentView()
                .tabItem {
                    VStack {
                        Image("first")
                        Text("first")
                    }
                }
                .tag(0)
            Text("Second View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image("second")
                        Text("Second")
                    }
                }
                .tag(1)
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( )
    }
}
