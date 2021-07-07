//
//  MCSercretsService+Extension.swift
//  MacKeyChainX
//
//  Created by softphone on 20/06/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension MCSecretsService {
    
    func start() {
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func invitePeer( _ peer:Peer ) {
        self.serviceBrowser.invitePeer(peer.peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func stop() {
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func requestSecret( forMnemonic id: String, completionHandler handler: @escaping (Result<String?,MCSecretsServiceError>) -> Void  ) {

        guard let peer = connectedPeer else {
            handler( .failure(.NoPeerConnected) )
            return
        }
        
        guard let cmd = "keychainx://get/\(id)".data(using: .utf8) else {
            handler( .failure(.Internal("error composing command")) )
            return
        }
        
        
        let name = Notification.Name( "\(peer.peerID).didReceiveData")

        var observer: NSObjectProtocol?
        
        observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            
            handler( .success( notification.object as? String ))
            
            NotificationCenter.default.removeObserver(observer!)
        }

        dispatchPeerGroup.enter()

        do {
            
            try self.session.send( cmd, toPeers: [peer.peerID], with: .unreliable)
            
            
            let waitResult = dispatchPeerGroup.wait(timeout: .now() + 10)
            
            if waitResult == .timedOut  {
                handler( .failure(.RequestSecretTimeout) )
            }

        }
        catch( let error ) {
            dispatchPeerGroup.leave()
            
            handler( .failure( .FromCause(error) ) )
            
            return
        }
        

        
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
        
        dispatchPeerGroup.leave()
        
        let name = Notification.Name( "\(peerID).didReceiveData")
        
        NotificationCenter.default.post( name:name, object:data )
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
