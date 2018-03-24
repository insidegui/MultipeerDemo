//
//  PeerService.swift
//  MultipeerDemo
//
//  Created by Guilherme Rambo on 23/03/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit
import MultipeerConnectivity

final class PeerService: NSObject {

    var didFindDevice: ((_ name: String) -> Void)?

    var didConnectToDevice: ((_ name: String) -> Void)?

    var didReceiveFile: ((_ url: URL) -> Void)?

    // MD1
    lazy var me: MCPeerID = {
        let peer: MCPeerID

        if let peerData = UserDefaults.standard.data(forKey: "mePeerID") {
            guard let unarchivedPeer = NSKeyedUnarchiver.unarchiveObject(with: peerData) as? MCPeerID else {
                fatalError("mePeerID in user defaults is not a MCPeerID. WHAT?")
            }

            peer = unarchivedPeer
        } else {
            peer = MCPeerID(displayName: UIDevice.current.name)

            let peerData = NSKeyedArchiver.archivedData(withRootObject: peer)
            UserDefaults.standard.set(peerData, forKey: "mePeerID")
            UserDefaults.standard.synchronize()
        }

        return peer
    }()

    // MD2
    lazy var session: MCSession = {
        let s = MCSession(peer: me, securityIdentity: nil, encryptionPreference: .none)

        s.delegate = self

        return s
    }()

    // MD4
    lazy var advertiser: MCNearbyServiceAdvertiser = {
        let a = MCNearbyServiceAdvertiser(peer: me, discoveryInfo: ["demo": "data"], serviceType: "MultipeerDemo")

        a.delegate = self

        return a
    }()

    // MD7
    lazy var browser: MCNearbyServiceBrowser = {
        let b = MCNearbyServiceBrowser(peer: me, serviceType: "MultipeerDemo")

        b.delegate = self

        return b
    }()

    func startAdvertising() {
        // MD6
        advertiser.startAdvertisingPeer()
    }

    func startListening() {
        // MD9
        browser.startBrowsingForPeers()
    }

    private var devices: [String: MCPeerID] = [:]

    func connectToDevice(named name: String) {
        // MD10
        guard let peer = devices[name] else { return }

        browser.invitePeer(peer, to: session, withContext: nil, timeout: 10)
    }

    func sendPicture(with data: Data, completion: @escaping (Error?) -> Void) {
        // MD11
        guard let peer = session.connectedPeers.last else {
            NSLog("No connected peers to send to")
            return
        }

        guard let baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("No caches directory. WHAT?!")
        }

        let filename = UUID().uuidString + ".png"

        let fileURL = baseURL.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL, options: .atomicWrite)

            session.sendResource(at: fileURL,
                                 withName: filename,
                                 toPeer: peer,
                                 withCompletionHandler: completion)
        } catch {
            completion(error)
        }
    }

}

// MD8
extension PeerService: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard devices[peerID.displayName] == nil else { return }

        devices[peerID.displayName] = peerID

        DispatchQueue.main.async {
            self.didFindDevice?(peerID.displayName)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("Puke")
    }

}

// MD5
extension PeerService: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // This is insecure! We should verify that the peer is valid and etc etc
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("Woops! Advertising failed with error \(String(describing: error))")
    }

}

// MD3
extension PeerService: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Now connected to \(peerID.displayName)")
            DispatchQueue.main.async {
                self.didConnectToDevice?(peerID.displayName)
            }
        case .connecting:
            print("Connecting to \(peerID.displayName)")
        case .notConnected:
            print("NOT connected to \(peerID.displayName)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("Started resource download: \(resourceName)")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("Finished resource download: \(resourceName)")
    }

}
