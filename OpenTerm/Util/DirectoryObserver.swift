//
//  DirectoryObserver.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 06/04/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//
// Adapted from https://github.com/dcvz/DirectoryObserver/blob/master/DirectoryObserver/Classes/DirectoryObserver.swift

import Foundation

public class DirectoryObserver {
	
	static let pollInterval: TimeInterval = 0.2
	static let pollRetryCount = 5
	
	// MARK: - Errors
	public enum DirectoryObserverError: Error {
		case alreadyObserving
		case failedToStartObserver
		case invalidPath
	}
	
	// MARK: - Attributes
	public let watchedPath: URL
	private(set) var isObserving = false
	
	
	// MARK: - Attributes (Private)
	private let completionHandler: (() -> Void)
	private var queue = DispatchQueue(label: "DCDirectoryWatcherQueue")
	private var retriesLeft = pollRetryCount
	private var isDirectoryChanging = false
	private var source: DispatchSourceFileSystemObject?
	
	// MARK: - Initializers
	public init(pathToWatch path: URL, callback: @escaping () -> Void) {
		watchedPath = path
		completionHandler = callback
	}
	
	deinit {
		try? stopObserving()
	}
	
	
	// MARK: - Public Interface
	/// Starts the observer
	public func startObserving() throws {
		if source != nil {
			throw DirectoryObserverError.alreadyObserving
		}
		
		let path = watchedPath.path
		
		// Open an event-only file descriptor associated with the directory
		let fd: CInt = open(path, O_EVTONLY)
		
		if fd < 0 {
			throw DirectoryObserverError.failedToStartObserver
		}
		
		let cleanup = {  }
		
		// Get a low priority queue
		let queue: DispatchQueue = DispatchQueue.global(qos: .background)
		
		// Monitor the directory for writes
		source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: [.write], queue: queue)
		
		if let source = source {
			// Call directoryDidChange on event callback
			source.setEventHandler { [weak self] in
				self?.directoryDidChange()
			}
			
			// Dispatch source destructor
			source.setCancelHandler {
				close(fd)
			}
			
			// Sources are create in suspended state, so resume it
			source.resume()
		} else {
			cleanup()
			throw DirectoryObserverError.failedToStartObserver
		}
		
		isObserving = true
	}
	
	
	/// Stops the observer
	public func stopObserving() throws {
		if source != nil {
			source!.cancel()
			source = nil
		}
		
		isObserving = false
	}
	
	
	// MARK: - Private Methods
	private func directoryDidChange() {
		if !isDirectoryChanging {
			isDirectoryChanging = true
			retriesLeft = DirectoryObserver.pollRetryCount
			checkForChangesAfterDelay()
		}
	}
	
	private func checkForChangesAfterDelay() {
		let metadata: [String] = directoryMetadata()
		
		let popTime = DispatchTime.now() + DirectoryObserver.pollInterval

		queue.asyncAfter(deadline: popTime, execute: { [weak self] in
			self?.pollDirectoryForChanges(metadata: metadata)
		})
		
	}
	
	private func directoryMetadata() -> [String] {
		
		let fm = FileManager.default
		
		let contents = try? fm.contentsOfDirectory(at: watchedPath, includingPropertiesForKeys: nil, options: [])
		var directoryMetadata: [String] = []
		
		if let contents = contents {
			for file in contents {
				autoreleasepool {
					if let fileAttributes = try? fm.attributesOfItem(atPath: file.path) {
						let fileSize = fileAttributes[FileAttributeKey.size] as! Int
						let fileHash = "\(file.lastPathComponent)\(fileSize)"
						directoryMetadata.append(fileHash)
					}
				}
			}
		}
		
		return directoryMetadata
	}
	
	private func pollDirectoryForChanges(metadata oldDirectoryMetadata: [String]) {
		let newDirectoryMetadata = directoryMetadata()
		
		isDirectoryChanging = !(newDirectoryMetadata == oldDirectoryMetadata)
		retriesLeft = isDirectoryChanging ? DirectoryObserver.pollRetryCount : retriesLeft
		
		if isDirectoryChanging || (retriesLeft > 0) {
			retriesLeft -= 1
			checkForChangesAfterDelay()
		} else {
			DispatchQueue.main.async { [weak self] in
				self?.completionHandler()
			}
		}
	}
}
