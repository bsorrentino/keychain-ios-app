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

struct Peer : Identifiable, Equatable, CustomStringConvertible {
    let id = UUID()
    var peerID:MCPeerID
    var state:MCSessionState = .notConnected
    
    // Equatable
    static func ==(lhs: Peer, rhs: Peer) -> Bool {
        return lhs.peerID == rhs.peerID
    }
    
    public var description: String {
    
        var stateDescription = ""
        switch state {
            case .connected:
                stateDescription = "Connected"
            case .notConnected:
                stateDescription = "Not connected"
            case .connecting:
                stateDescription = "Connecting"
            @unknown default:
                stateDescription = "\(state)"
        }
        
        return "\(peerID.displayName) - (\(stateDescription))"
    }
    
}

class MCSecretsService : NSObject, ObservableObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let ServiceType = "my-secrets"


    #if os(macOS)
    private let myPeerId = MCPeerID(displayName: Host.current().name ?? "Unknow macOS Host Name")
    private let serviceBrowser : MCNearbyServiceBrowser
    #endif

    #if os(iOS)
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    #endif
    
    @Published var foundPeers = [Peer]()
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()

    
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

        
        if isInPreviewMode() {
            foundPeers.append( Peer(peerID: MCPeerID(displayName: "Preview Peer ID")))
        }
    }

    func start() {
        #if os(macOS)
        self.serviceBrowser.startBrowsingForPeers()
        #endif
        
        #if os(iOS)
        self.serviceAdvertiser.startAdvertisingPeer()
        #endif
        
    }
    
    func invitePeer( _ peer:Peer ) {
        #if os(macOS)
        self.serviceBrowser.invitePeer(peer.peerID, to: self.session, withContext: nil, timeout: 10)
        #endif
    }
    
    func stop() {
        #if os(macOS)
        self.serviceBrowser.stopBrowsingForPeers()
        #endif
        
        #if os(iOS)
        self.serviceAdvertiser.stopAdvertisingPeer()
        #endif
    }

    
    deinit {
        self.stop()
    }

}


extension MCSecretsService : MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        logger.trace("didNotStartAdvertisingPeer: \(error.localizedDescription)")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        logger.trace("didReceiveInvitationFromPeer \(peerID)")
        
        invitationHandler( true, self.session )

    }
    
}

extension MCSecretsService : MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        logger.trace("didNotStartBrowsingForPeers: \(error.localizedDescription)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        logger.trace("foundPeer: \(peerID)")
        
        self.foundPeers.append(Peer(peerID: peerID))
        
        
//        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        logger.trace("lostPeer: \(peerID)")
        
        guard let index = self.foundPeers.firstIndex(of: Peer(peerID: peerID)) else { return }
        
        self.foundPeers.remove( at: index )
    }

}


extension MCSecretsService : MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        logger.trace("peer \(peerID) didChangeState: \(state.rawValue)")
        
        guard let index = self.foundPeers.firstIndex(of: Peer(peerID: peerID)) else { return }
        
        DispatchQueue.main.async {
            self.foundPeers[index].state = state
            self.objectWillChange.send()
        }
        
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        logger.trace("didReceiveData: \(data)")
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        logger.trace("didReceiveStream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        logger.trace("didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        logger.trace("didFinishReceivingResourceWithName")
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
