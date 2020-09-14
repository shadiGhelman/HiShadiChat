//
//  ChatViewController.swift
//  HiShadiChat
//
//  Created by Shadi Ghelman on 9/14/20.
//  Copyright © 2020 Shadi Ghelman. All rights reserved.
//

import UIKit
import Network
class ChatViewController: UIViewController {

	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var messageTextField: UITextField!
	override func viewDidLoad() {
        super.viewDidLoad()
		if let connection = sharedConnection {
			// Take over being the connection delegate from the main view controller.
			connection.delegate = self
			
		}

        
    }
    
	@IBAction func sendButtonDidTouch(_ sender: Any) {
		// send message after button Touched
		sharedConnection?.sendMessage(messageTextField.text!)
		messageTextField.text = ""
	}
	
    

}
// acc peerConnectionDelegate
extension ChatViewController: PeerConnectionDelegate {
	func connectionReady() {
		// Ignore, since the game was already started in the main view controller.
	}
	func displayAdvertiseError(_ error: NWError) {
		// Ignore, since the game is already in progress.
	}

	// when connection failed close the chatRoom
	func connectionFailed() {
	 
		dismiss(animated: true)
	}

	func receivedMessage(content: Data?) {
		guard let content = content else {
			return
		}
		ShowMessage(content: content)

	}
	func ShowMessage(content : Data){

		let message = String(data: content, encoding: .unicode)
		messageLabel.text = message
		
		
	}

	

	
		
	
}

