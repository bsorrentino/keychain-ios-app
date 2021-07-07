//
//  ContentView.swift
//  MacKeyChainX
//
//  Created by Bartolomeo Sorrentino on 28/09/20.
//  Copyright © 2020 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mcSecretsService:MCSecretsService
    
    var DeviceNearByView: some View {
        HStack(alignment: .center) {
            Image( systemName: "bonjour")
            Text("Keychain Device nearby: ")
                HStack(alignment: .center) {
                    ForEach( self.mcSecretsService.foundPeers, id: \.id ) { peer in
                        Button( action: {
                            mcSecretsService.invitePeer(peer)
                        } ){
                            Text("\(peer.description)")
                        }
                  Divider()
                }
            }
        }
        .frame(height: 40)
        .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)

    }
    
    
    var body: some View {
        VStack(alignment: .leading ) {
            KeyItemListView()
            
            DeviceNearByView
            
        }.frame(minWidth: 700, maxHeight: 500)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           ContentView()
              .environment(\.colorScheme, .light)

           ContentView()
              .environment(\.colorScheme, .dark)
        }.environmentObject( MCSecretsService() )
        
    }
}
