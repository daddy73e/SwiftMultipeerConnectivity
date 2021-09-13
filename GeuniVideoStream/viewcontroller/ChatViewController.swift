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
    
    private var arrChatUser = [User]()
    private var arrMessage = [Message]()
    
    private var peerId:MCPeerID?
    private var mcSession:MCSession?
    private var mcAdAssistant:MCAdvertiserAssistant?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @IBAction func tapBtnSend(_ sender: Any) {
        guard let id = peerId else {
            return
        }
        
        guard let txtMsg = txtMessage.text else {
            return
        }
        
        let message = Message(id: id.displayName, message: txtMsg)
        if let msgData = message.toJSONString().data(using: String.Encoding.utf8,
                                                     allowLossyConversion: false) {
            do {
                try self.mcSession!.send(msgData, toPeers: self.mcSession!.connectedPeers, with: .unreliable)
                self.arrMessage.append(message)
                self.tableMessage.reloadData()
                txtMessage.text = ""
            }
            catch {
                print("Error sending message")
            }
        }
        
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
            let cell:MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell",
                                                                          for: indexPath) as! MessageTableViewCell
            let message = arrMessage[indexPath.row]
            cell.config(msg: message)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
}
