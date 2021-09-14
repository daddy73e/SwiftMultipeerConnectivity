//
//  ChatViewController.swift
//  GeuniVideoStream
//
//  Created by Yeongeun Song on 2021/09/13.
//

import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableUser: UITableView!
    @IBOutlet weak var tableMessage: UITableView!
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var btnHost: UIButton!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var stackBottomMsg: UIStackView!
    @IBOutlet weak var viewMsgBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private let serviceType = "geunistream"
    private let originMarginBottomMsg:CGFloat = 5
    private let myMessageId = UIDevice.current.identifierForVendor!.uuidString
    
    private var arrChatUser = [MCPeerID]()
    private var arrMessage = [Message]()
    
    private var peerId:MCPeerID!
    private var mcSession:MCSession!
    private var mcAdAssistant:MCAdvertiserAssistant!
    private var isHosting:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNotificaton()
        configChat()
    }
    
    private func configChat() {
        peerId = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerId!, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    private func configNotificaton() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.viewMsgBottomMargin.constant = keyboardSize.height + originMarginBottomMsg
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.viewMsgBottomMargin.constant = originMarginBottomMsg
    }
    
    private func updateMessage(msg:Message) {
        arrMessage.append(msg)
        DispatchQueue.main.async {
            self.tableMessage.reloadData()
            if self.arrMessage.count != 0 {
                self.tableMessage.scrollToBottom(isAnimated: true)
            }
        }
    }
    
    private func updateUser(user:MCPeerID) {
        arrChatUser.append(user)
        DispatchQueue.main.async {
            self.tableUser.reloadData()
            if self.arrChatUser.count != 0 {
                self.tableUser.scrollToBottom(isAnimated: true)
            }
        }
    }
    
    private func leaveUser(user:MCPeerID) {
        self.arrChatUser.removeAll{$0 == user}
        DispatchQueue.main.async {
            self.tableUser.reloadData()
            if self.arrChatUser.count != 0 {
                self.tableUser.scrollToBottom(isAnimated: true)
            }
        }
        
    }
    
    private func showLoading() {
        DispatchQueue.main.async {
            self.indicator.isHidden = false
        }
    }
    
    private func hideLoading() {
        DispatchQueue.main.async {
            self.indicator.isHidden = true
        }
    }
    
}

//MARK: - IBAction
extension ChatViewController {
    @IBAction func tapBg(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func tapBtnHost(_ sender: Any) {
        isHosting = !isHosting
        if isHosting {
            mcAdAssistant = MCAdvertiserAssistant(serviceType: serviceType,
                                                  discoveryInfo: nil,
                                                  session: mcSession)
            mcAdAssistant.start()
            showLoading()
            btnHost.setTitle("CANCEL", for: .normal)
        } else {
            mcAdAssistant.stop()
            hideLoading()
            btnHost.setTitle("HOST", for: .normal)
        }
    }
    
    @IBAction func tapBtnJoin(_ sender: Any) {
        let mcBrowser = MCBrowserViewController(serviceType: serviceType,
                                                session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    @IBAction func tapBtnSend(_ sender: Any) {
        guard let id = peerId else {
            return
        }
        
        guard let txtMsg = txtMessage.text else {
            return
        }
        
        let message = Message(id: myMessageId, displayName: id.displayName, message: txtMsg)
        if let msgData = message.toJSONString().data(using: String.Encoding.utf8,
                                                     allowLossyConversion: false) {
            do {
                try self.mcSession!.send(msgData, toPeers: self.mcSession!.connectedPeers, with: .unreliable)
                updateMessage(msg: message)
                txtMessage.text = ""
            }
            catch {
                print("Error sending message")
            }
        }
    }
}

//MARK: - MCBrowserViewControllerDelegate
extension ChatViewController:MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}

//MARK: - MCSessionDelegate
extension ChatViewController:MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        hideLoading()
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
            updateUser(user: peerID)
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
            leaveUser(user: peerID)
        @unknown default:
            print("fatal error")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            do {
                let message:Message = try JSONDecoder().decode(Message.self, from: data)
                self.updateMessage(msg: message)
            } catch {
                print(error)
            }
            
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

//MARK: - UITableViewDataSource
extension ChatViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case tableUser:
            return arrChatUser.count
        case tableMessage :
            return arrMessage.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case tableUser:
            let cell:UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell",
                                                                       for: indexPath) as! UserTableViewCell
            let user = arrChatUser[indexPath.row]
            cell.config(user: user)
            return cell
        case tableMessage :
            let message = arrMessage[indexPath.row]
            if message.id == myMessageId {
                let cell:MessageTableMyViewCell = tableView.dequeueReusableCell(withIdentifier: "MessageTableMyViewCell",
                                                                              for: indexPath) as! MessageTableMyViewCell
                cell.config(msg: message)
                return cell
            } else {
                let cell:MessageTableOtherViewCell = tableView.dequeueReusableCell(withIdentifier: "MessageTableOtherViewCell",
                                                                              for: indexPath) as! MessageTableOtherViewCell
                cell.config(msg: message)
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
}

extension UITableView {
    func scrollToBottom(isAnimated:Bool){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}
