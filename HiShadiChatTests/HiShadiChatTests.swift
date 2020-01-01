//
//  HiShadiChatTests.swift
//  HiShadiChatTests
//
//  Created by Shadi Ghelman on 9/14/20.
//  Copyright © 2020 Shadi Ghelman. All rights reserved.
//

import XCTest
import Network
@testable import HiShadiChat

fileprivate class NWConnectionMock: NWConnectionInterface {
	private(set) var canceled = false
	private(set) var lastMessage: String?
	private(set) var didReceiveMessage = false

	private(set) var startCount = 0
	func cancel() {
		canceled = true
	}
	
	func receiveMessage(completion: @escaping (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void) {
		didReceiveMessage = true
	}
	
	func send(content: Data?, contentContext: NWConnection.ContentContext, isComplete: Bool, completion: NWConnection.SendCompletion) {
		guard let data = content else { lastMessage = nil; return }
		lastMessage = String(data: data, encoding: .unicode)
	}
	
	func start(queue: DispatchQueue) {
		startCount += 1
	}
	
	var stateUpdateHandler: ((NWConnection.State) -> Void)?
}

class HiShadiChatTests: XCTestCase {
	
	func testCancel() {
		let connectionMock = NWConnectionMock()
		let peerConnection = PeerConnection(connection: connectionMock, delegate: self)
		
		XCTAssertNotNil(peerConnection.connection)
		
		XCTAssertFalse(connectionMock.canceled)
		peerConnection.cancel()
		XCTAssert(connectionMock.canceled)
		
		XCTAssertNil(peerConnection.connection)
	}
	
	func testNilConnectionCancel() {
		let connectionMock = NWConnectionMock()
		let peerConnection = PeerConnection(connection: connectionMock, delegate: self)
		XCTAssertNotNil(peerConnection.connection)
		peerConnection.connection = nil
		XCTAssertNil(peerConnection.connection)
		peerConnection.cancel()
		XCTAssertFalse(connectionMock.canceled)
	}
	
	func testStart() {
		let connectionMock = NWConnectionMock()
		let peerConnection = PeerConnection(connection: connectionMock, delegate: self)

		let initialCount = connectionMock.startCount
		peerConnection.startConnection()
		XCTAssertEqual(initialCount, connectionMock.startCount - 1)
	}
	
	func testNilStartConnection(){
		let connectionMock = NWConnectionMock()
		let peerConnection = PeerConnection(connection: connectionMock, delegate: self)
		
		XCTAssertNotNil(peerConnection.connection)
		peerConnection.connection = nil
		XCTAssertNil(peerConnection.connection)
		
		let initialCount = connectionMock.startCount
		peerConnection.startConnection()
		XCTAssertEqual(initialCount, connectionMock.startCount)
	}
	
	let testingMessages = ["Hello", "😍", "سلام"]
	func testMessage() {
		let connectionMock = NWConnectionMock()
		let peerConnection = PeerConnection(connection: connectionMock, delegate: self)
		
		for message in testingMessages {
			peerConnection.sendMessage(message)
			XCTAssertEqual(connectionMock.lastMessage, message)
		}
	}

	func testRecieveNextMessage() {
		let connectionMock = NWConnectionMock()
		let peerConnection = PeerConnection(connection: connectionMock, delegate: self)

		XCTAssertFalse(connectionMock.didReceiveMessage)
		peerConnection.receiveNextMessage()
		XCTAssert(connectionMock.didReceiveMessage)
	}
	
	func testNilConnectionRecieveNextMessage() {
		let connectionMock = NWConnectionMock()
		let peerConnection = PeerConnection(connection: connectionMock, delegate: self)
		XCTAssertNotNil(peerConnection.connection)
		peerConnection.connection = nil
		XCTAssertNil(peerConnection.connection)
		
		peerConnection.receiveNextMessage()
		XCTAssertFalse(connectionMock.didReceiveMessage)
	}
}

extension HiShadiChatTests: PeerConnectionDelegate {
	func connectionReady() {
			
	}
	
	func connectionFailed() {
		
	}
	
	func receivedMessage(content: Data?) {

	}
	
	func displayAdvertiseError(_ error: NWError) {
		
	}
	
			
}
