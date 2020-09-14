//
//  ViewController.swift
//  HiShadiChat
//
//  Created by Shadi Ghelman on 9/14/20.
//  Copyright © 2020 Shadi Ghelman. All rights reserved.
//

import UIKit
import Network
class ViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var nameTextField: UITextField!
	
	@IBOutlet weak var searchIndicator: UIActivityIndicatorView!
	@IBOutlet weak var passcodeLabel: UILabel!
	var results: [NWBrowser.Result] = [NWBrowser.Result]()
	var sections: [ChatFinderSection] = [.host, .join]
	enum ChatFinderSection {
		case host
		case passcode
		case join
	}
	
	// rows of TableView
	func resultRows() -> Int {
	
		
		return min(results.count, 6)
		
	}
	// generate passcode for connect to another device
	func generatePasscode() -> String {
		return String("\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))")
	}
	var passcode : String?
	
	@IBAction func hostNameButtonDidTouch(_ sender: Any) {
		
		hostChatButton()
	}
	
	@IBAction func searchButtonDidTouch(_ sender: Any) {
		searchIndicator.alpha = 1
		searchIndicator.startAnimating()
		if sharedBrowser == nil {
			sharedBrowser = PeerBrowser(delegate: self)
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		searchIndicator.alpha = 0
		passcode = generatePasscode()
		passcodeLabel.text = passcode!
	}
	var name : String?
	
	func hostChatButton() {
		// Dismiss the keyboard when the user starts hosting.
		view.endEditing(true)

		// Validate that the user's entered name is not empty.
		guard let name = nameTextField.text,
			!name.isEmpty else {
			return
		}

		self.name = name
		if let listener = sharedListener {
			// If the app is already listening, just update the name.
			listener.resetName(name)
		} else {
			// If the app is not yet listening, start a new listener.
			sharedListener = PeerListener(name: name, passcode: passcode!, delegate: self)
		}

		
		sections = [.host, .passcode, .join]
		tableView.reloadData()
	}
	


}
// acc delegate and dataSource of tabelView
extension ViewController : UITableViewDelegate,UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return resultRows()
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// make cell for show hosts
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let peerEndpoint = results[indexPath.row].endpoint
		if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = peerEndpoint {
			cell.textLabel?.text = name
		} else {
			cell.textLabel?.text = "Unknown Endpoint"
		}
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// select one host to connect
			let result = results[indexPath.row]
			let nextPage = storyboard?.instantiateViewController(identifier: "PasscodeViewController") as! PasscodeViewController
		nextPage.browseResult = result
		nextPage.prePage = self
			present(nextPage, animated: true)
			
		
	}
	
	
}
extension ViewController: PeerBrowserDelegate {
	// When the discovered peers change, update the list.
	func refreshResults(results: Set<NWBrowser.Result>) {
		self.results = [NWBrowser.Result]()
		for result in results {
			if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = result.endpoint {
				if name != self.name {
					self.results.append(result)
				}
			}
		}
		searchIndicator.alpha = 0
		searchIndicator.stopAnimating()
		tableView.reloadData()
	}

	// Show an error if peer discovery failed.
	func displayBrowseError(_ error: NWError) {
		var message = "Error \(error)"
		if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_NoAuth)) {
			message = "Not allowed to access the network"
		}
		let alert = UIAlertController(title: "Cannot discover other players",
									  message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}
}
extension ViewController: PeerConnectionDelegate {
	// When a connection becomes ready, move into chatRoom.
	func connectionReady() {
		let nextPage = storyboard?.instantiateViewController(identifier: "ChatViewController")
		present(nextPage!, animated: true)
	}

	// When the a chat cannot be advertised, show an error
	func displayAdvertiseError(_ error: NWError) {
		var message = "Error \(error)"
		if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_NoAuth)) {
			message = "Not allowed to access the network"
		}
		let alert = UIAlertController(title: "Cannot host game",
									  message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}

	// Ignore connection failures and messages prior to starting a chat.
	func connectionFailed() { }
	func receivedMessage(content: Data?) { }
}

