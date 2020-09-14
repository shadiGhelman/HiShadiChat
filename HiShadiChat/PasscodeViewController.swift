//
//  PasscodeViewController.swift
//  HiShadiChat
//
//  Created by Shadi Ghelman on 9/14/20.
//  Copyright © 2020 Shadi Ghelman. All rights reserved.
//

import UIKit
import Network
class PasscodeViewController: UIViewController {

	
	var prePage : ViewController?
	@IBOutlet weak var passcodeTextField: UITextField!
	var browseResult: NWBrowser.Result?
	var hasJoinChat = false
    override func viewDidLoad() {
        super.viewDidLoad()
		if let browseResult = browseResult,
			case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = browseResult.endpoint {
			title = "Join \(name)"
		}
	}

	override func viewWillAppear(_ animated: Bool) {
			super.viewWillAppear(animated)

			if hasJoinChat {
				navigationController?.popToRootViewController(animated: false)
				hasJoinChat = false
			}
		}
		func joinPressed() {
			hasJoinChat = true
			// check The passcode and the connection
			if let passcode = passcodeTextField.text,
				let browseResult = browseResult,
				let prePage = prePage {
				dismiss(animated: true) {
					sharedConnection = PeerConnection(endpoint: browseResult.endpoint,
					interface: browseResult.interfaces.first,
					passcode: passcode,
					delegate: prePage)
				}
				
			}
		}
//join button press to check the passcode
	@IBAction func joinButtonDidTouch(_ sender: Any) {
		joinPressed()
	}
	
        

}
