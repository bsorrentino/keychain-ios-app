//
//  PeerConnectionsView.swift
//  KeyChainX
//
//  Created by softphone on 28/06/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI

struct PeerConnectionsView: View {
    
    @EnvironmentObject var mcSecretsService:MCSecretsService
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach( self.mcSecretsService.foundPeers, id: \.id ) { peer in
                    
                    Text( "\(peer.description)" )
                }
            }
            .navigationBarTitle( Text("Device Nearby"),  displayMode: .large )
        }
        
    }
}

struct PeerConnectionsView_Previews: PreviewProvider {
    static var previews: some View {
        PeerConnectionsView()
            .environmentObject(MCSecretsService())
    }
}
