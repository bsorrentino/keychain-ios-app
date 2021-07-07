//
//  PeerConnectionsView.swift
//  KeyChainX
//
//  Created by softphone on 28/06/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import SwiftUI


struct DisconnectButtonStyle: ButtonStyle {
    var disabled = false
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
        .foregroundColor(disabled ? Color.gray : Color.red)
    }
}

struct PeerConnectionsView: View {
    @State private var showingAlert = false
    
    @EnvironmentObject var mcSecretsService:MCSecretsService
    
    var isDisconnected:Bool {
        mcSecretsService.connectedPeers.isEmpty
    }
    
    func disconnectSession() -> Void {
        mcSecretsService.session.disconnect()
    }
    var Disconnect:some View {
        Button {
            showingAlert = true
        } label: {
            Label("disconnect", systemImage: "xmark.circle")
        }
        .buttonStyle(DisconnectButtonStyle( disabled: isDisconnected) )
        .disabled( isDisconnected )
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Disconnect"),
                  message: Text("Do you want disconnect Devices?"),
                  primaryButton: .destructive(Text("OK"), action: disconnectSession ),
                  secondaryButton: .cancel(Text("Cancel")))
         }

    }
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach( self.mcSecretsService.foundPeers, id: \.id ) { peer in
                    
                    VStack(alignment: .leading) {
                        Text( "\(peer.peerID.displayName)" ).font(.title2)
                        Text( "\(peer.state.description)").font(.body)
                    }
                }
            }
            .navigationBarTitle( Text("Device Nearby"),  displayMode: .large )
            .navigationBarItems(trailing: Disconnect)
        }
        
    }
}

struct PeerConnectionsView_Previews: PreviewProvider {
    static var previews: some View {
        PeerConnectionsView()
            .environmentObject(MCSecretsService())
    }
}
