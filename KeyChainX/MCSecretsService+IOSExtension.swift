//
//  MCSecretsService+Extension.swift
//  KeyChainX
//
//  Created by softphone on 20/06/21.
//  Copyright © 2021 Bartolomeo Sorrentino. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import Shared

extension MCSecretsService {
    public func start() {
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    public func stop() {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }

}


extension MCSecretsService : MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        logger.trace("peer \(peerID) didChangeState: \(state.rawValue)")
        
        if let index = self.peerIndex( of: peerID ) {
        
            DispatchQueue.main.async {
                self.foundPeers[index].state = state
                self.objectWillChange.send()
            }
        }
        
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        if let msg = String(data:data, encoding: .utf8) {
            logger.trace("didReceiveData string: \(msg)")
            
            
            if let uri = URL(string:msg) {
                
                logger.trace("didReceiveData uri: \(uri.path)")
                let index = uri.path.index(uri.path.startIndex, offsetBy: 1)
                let mnemonic = String(uri.path[index...])
                logger.trace("didReceiveData mnemonic: \(mnemonic)")
                
//                let managedContext = UIApplication.shared.managedObjectContext
//
//                do {
//                    let entity = try SharedModule.fetchSingle(context: managedContext,
//                                         entity: KeyEntity.entity(),
//                                         predicateFormat: "mnemonic = @%", key: String(mnemonic))
//                }
//                catch {
//
//                }
                
                    do {
                        logger.trace("didReceiveData getSecret: [\(mnemonic)] wait ... ")
                        if let secret = try SharedModule.appSecrets.getSecret(forKey: mnemonic) {
                            
                            logger.trace("didReceiveData getSecret: [\(mnemonic)] done ... " )
                            let encoder = JSONEncoder()
                            let encoded = try encoder.encode( secret )
                            
                            try session.send( encoded , toPeers: [peerID], with: .unreliable )
                        }
                        else {
                            logger.trace("didReceiveData getSecret: [\(mnemonic)] not found ... " )
                        }

                    }
                    catch {
                        logger.error( "error getting key: \(mnemonic)\n\(error.localizedDescription)" )
                    }
            }
        }
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

    
    public func keyWindow() -> UIWindow? {
       
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
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        logger.trace("didNotStartAdvertisingPeer: \(error.localizedDescription)")
    }

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        logger.trace("didReceiveInvitationFromPeer \(peerID)")
        
//        invitationHandler( true, self.session )

        
        
        if let keyWindow = keyWindow(),
           let topController = keyWindow.rootViewController
        {
            let peerIndex = self.peerIndex(of: peerID)

            let alert = UIAlertController(title: "\((peerIndex != nil) ? "New " : "")Request from \(peerID.displayName)",
                                          message: "Do you trust \((peerIndex != nil) ? "Again the " : "")request from \(peerID.displayName) ?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default ) {_ in
                
                invitationHandler( true, self.session )
                if( peerIndex == nil ) {
                    self.foundPeers.append( Peer(peerID: peerID))
                }

            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel ) {_ in
                
                invitationHandler( false, self.session )
                
            })

            topController.present( alert, animated: true )
        }
            
    }
    
}

