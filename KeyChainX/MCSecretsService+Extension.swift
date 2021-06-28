//
//  MCSecretsService+Extension.swift
//  KeyChainX
//
//  Created by softphone on 20/06/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension MCSecretsService {
    func start() {
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    func stop() {
        self.serviceAdvertiser.stopAdvertisingPeer()
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
        
        let msg = String(data:data, encoding: .utf8)
        logger.trace("didReceiveData: \(msg!)")
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


extension MCSecretsService : MCNearbyServiceAdvertiserDelegate {

    
    func keyWindow() -> UIWindow? {
       
       return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?
                .windows
                .filter({$0.isKeyWindow})
                .first
        // UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        logger.trace("didNotStartAdvertisingPeer: \(error.localizedDescription)")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        logger.trace("didReceiveInvitationFromPeer \(peerID)")
        
//        invitationHandler( true, self.session )

        if let keyWindow = keyWindow(),
           let topController = keyWindow.rootViewController
        {
            let alert = UIAlertController(title: "Request from \(peerID.displayName)",
                                          message: "Do you trust request from \(peerID.displayName) ?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default ) {_ in
                
                invitationHandler( true, self.session )
                self.foundPeers.append( Peer(peerID: peerID))

            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel ) {_ in
                
                invitationHandler( false, self.session )
                
            })

            topController.present( alert, animated: true )
        }
            
    }
    
}
