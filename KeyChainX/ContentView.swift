//
//  ContentView.swift
//  keychain
//
//  Created by Bartolomeo Sorrentino on 06/11/2019.
//  Copyright © 2019 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var loginStates:LoginView.States
    
    @State private var selection = 0
 
    
    var body: some View {
        TabView(selection: self.$selection) {
            
            KeyItemList2()
                .tabItem {
                    VStack {
                        Image(systemName: "list.dash")
                        Text("test")
                    }
                }
            .tag(0)
//            KeyItemListContentView()
//                .tabItem {
//                    VStack {
//                        Image(systemName: "list.dash")
//                        Text("Key list")
//                    }
//                }
//            .tag(4)
            BackupKeysView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.down.doc")
                        Text("Backup keys")
                    }
                }
                .tag(1)
            RestoreKeysView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.up.doc")
                        Text("Restore keys")
                    }
                }
                .tag(2)
            PeerConnectionsView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "laptopcomputer")
                        Text("Connections")
                    }
                }
                .tag(3)

        }
        .sheet(isPresented: $loginStates.show) {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( loginStates: LoginView.States() )
    }
}
