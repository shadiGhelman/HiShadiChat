/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implement a TLS connection that supports the custom GameProtocol framing protocol.
*/

import Foundation
import Network

var sharedConnection: PeerConnection?

protocol PeerConnectionDelegate: class {
	func connectionReady()
	func connectionFailed()
	func receivedMessage(content: Data?)
	func displayAdvertiseError(_ error: NWError)
}

class PeerConnection {
	
	weak var delegate: PeerConnectionDelegate?
	var connection: NWConnectionInterface?
	let initiatedConnection: Bool
	
	// Create an outbound connection when the user initiates a game.
	init(endpoint: NWEndpoint, interface: NWInterface?, passcode: String, delegate: PeerConnectionDelegate) {
		self.delegate = delegate
		self.initiatedConnection = true
		
		let connection = NWConnection(to: endpoint, using: NWParameters(passcode: passcode))
		self.connection = connection
		
		startConnection()
	}
	
	// Handle an inbound connection when the user receives a game request.
	init(connection: NWConnectionInterface, delegate: PeerConnectionDelegate) {
		self.delegate = delegate
		self.connection = connection
		self.initiatedConnection = false
		
		startConnection()
	}
	
	// Handle the user exiting the game.
	func cancel() {
		guard let connection = self.connection else { return }
		connection.cancel()
		self.connection = nil
	}
	
	// Handle starting the peer-to-peer connection for both inbound and outbound connections.
	func startConnection() {
		guard let connection = connection else { return }
		
		connection.stateUpdateHandler = { newState in
			switch newState {
			case .ready:
				print("\(connection) established")
				
				// When the connection is ready, start receiving messages.
				self.receiveNextMessage()
				
				// Notify your delegate that the connection is ready.
				if let delegate = self.delegate {
					delegate.connectionReady()
				}
			case .failed(let error):
				print("\(connection) failed with \(error)")
				
				// Cancel the connection upon a failure.
				connection.cancel()
				
				// Notify your delegate that the connection failed.
				if let delegate = self.delegate {
					delegate.connectionFailed()
				}
			default:
				break
			}
		}
		
		// Start the connection establishment.
		connection.start(queue: .main)
	}
	
	// Handle sending a message.
	func sendMessage(_ message: String) {
		guard let connection = connection else { return }
		
		// Create a message object to hold the command type.
		let context = NWConnection.ContentContext(identifier: "Message",
												  metadata: [])
		
		// Send the application content along with the message.
		connection.send(content: message.data(using: .unicode), contentContext: context, isComplete: true, completion: .idempotent)
	}
	
	// Receive a message, deliver it to your delegate, and continue receiving more messages.
	func receiveNextMessage() {
		guard let connection = connection else { return }
		
		connection.receiveMessage { (content, context, isComplete, error) in
			// Extract your message type from the received context.
			self.delegate?.receivedMessage(content: content)
			//}
			if error == nil {
				// Continue to receive more messages until you receive and error.
				self.receiveNextMessage()
			}
		}
	}
}

typealias NWConnectionInterface = SendingContent & Cancelable & UpdateHandler & ReceiveMessage & Startable
extension NWConnection: NWConnectionInterface { }

protocol SendingContent {
	func send(content: Data?, contentContext: NWConnection.ContentContext, isComplete: Bool, completion: NWConnection.SendCompletion)
}


protocol Cancelable {
	func cancel()
}

protocol UpdateHandler: class {
	var stateUpdateHandler: ((NWConnection.State) -> Void)? { set get }
}

protocol ReceiveMessage {
	func receiveMessage(completion: @escaping (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void)
}

protocol Startable {
	func start(queue: DispatchQueue)
}
