//
//  MCSecretService.swift
//  KeyChainX
//
//  Created by softphone on 15/06/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

extension MCSessionState : CustomStringConvertible {
    
    public var description: String {
    
        var stateDescription = ""
        switch self {
            case .connected:
                stateDescription = "Connected"
            case .notConnected:
                stateDescription = "Not connected"
            case .connecting:
                stateDescription = "Connecting"
            @unknown default:
                stateDescription = "\(self)"
        }
        
        return stateDescription
    }

}


struct Peer : Identifiable, Equatable, CustomStringConvertible {
    let id = UUID()
    var peerID:MCPeerID
    var state:MCSessionState = .notConnected
    
    // Equatable
    static func ==(lhs: Peer, rhs: Peer) -> Bool {
        return lhs.peerID == rhs.peerID
    }
    
    public var isConnected:Bool {
        state == .connected
    }
    
    public var description: String {
        "\(peerID.displayName) - (\(state.description))"
    }
    
}

enum MCSecretsServiceError: Error {
    case RequestSecretTimeout
    case Internal(String)
    case NoPeerConnected
    case FromCause(Error)
}


class MCSecretsService : NSObject, ObservableObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let ServiceType = "my-secrets"
    
    #if os(macOS)
    
    let myPeerId = MCPeerID(displayName: Host.current().name ?? "Unknow macOS Host Name")
    let serviceBrowser : MCNearbyServiceBrowser
    let dispatchPeerGroup = DispatchGroup()
    
    #endif

    #if os(iOS)
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    let serviceAdvertiser : MCNearbyServiceAdvertiser
    #endif
    
    @Published var foundPeers = [Peer]()
    
    @inlinable
    var connectedPeers:[Peer] {
        foundPeers.filter { $0.state == .connected }
    }
        
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()

    @inlinable
    func peerIndex( of peerID: MCPeerID ) -> Int? {
        self.foundPeers.map( { $0.peerID }).firstIndex(of: peerID )
    }
    
    override init() {
        #if os(macOS)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ServiceType)
        #endif
        
        #if os(iOS)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ServiceType)
        #endif

        super.init()

        #if os(macOS)
        self.serviceBrowser.delegate = self
        #endif
        
        #if os(iOS)
        self.serviceAdvertiser.delegate = self
        #endif

        
        if isInPreviewMode {
            //foundPeers.append( Peer(peerID: MCPeerID(displayName: "Preview Peer ID"), state: .connected) )
            foundPeers.append( Peer(peerID: MCPeerID(displayName: "Preview Peer ID")) )
        }
    }

    deinit {
        self.stop()
    }

}





//extension Shared  {
//
//    
//    static let mcSecretService = MCSecretsService()
//    
//}

// MARK: Custom @Environment  MCSecretService Session
// @see https://medium.com/@SergDort/custom-environment-keys-in-swiftui-49f54a13d140

//struct MCSecretServiceSessionKey: EnvironmentKey {
//    //static let defaultValue: Keychain = Keychain(service: "keychainx.userpreferences")
//    static let defaultValue:MCSession = {
//        Shared.mcSecretService.session
//    }()
//}
//
//extension EnvironmentValues {
//    var MCSecretServiceSession: MCSession {
//        get {
//            return self[MCSecretServiceSessionKey.self]
//        }
//        set {
//            self[MCSecretServiceSessionKey.self] = newValue
//        }
//    }
//}
