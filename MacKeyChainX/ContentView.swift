//
//  ContentView.swift
//  MacKeyChainX
//
//  Created by Bartolomeo Sorrentino on 28/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            KeyItemList()
                
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           ContentView()
              .environment(\.colorScheme, .light)

           ContentView()
              .environment(\.colorScheme, .dark)
        }
        
    }
}
