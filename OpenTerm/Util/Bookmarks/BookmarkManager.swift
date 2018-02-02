//
//  BookmarkManager.swift
//  OpenTerm
//
//  Created by Maximilian Katzmann on 02.02.18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

protocol BookmarkManagerDelegate {
    func bookmarksWereUpdated()
}

class BookmarkManager {
    
    /// The file name of the start directory bookmark. It is stored as a static
    /// constant so we can access it when saving or loading the bookmark and
    /// such that the settings view controller can access is as well.
    static let bookmarkDirectory = ".bookmarks"
    
    var delegate: BookmarkManagerDelegate? = nil
    
    /// Gets the URLs of the bookmarks that were previously saved.
    ///
    /// - Returns: The URLs of the saved bookmarks. If something fails, the returned array will be empty.
    func savedBookmarkURLs() -> [URL] {
        //  Get the document directory of the app.
        let dir = DocumentManager.shared.activeDocumentsFolderURL
            
        // Get the directory where the bookmarks are saved.
        let bookmarkDirectoryURL = dir.appendingPathComponent(BookmarkManager.bookmarkDirectory,
                                                              isDirectory: true)
        
        //  Create the bookmarks directory (if it doesn't exist)
        do {
            try FileManager.default.createDirectory(at: bookmarkDirectoryURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            
            //  Get all files that are in the bookmarks directory.
            let bookmarkFiles = try FileManager.default.contentsOfDirectory(atPath: bookmarkDirectoryURL.path)
            
            //  The array that will hold the obtained URLs. This will be returned eventually.
            var bookmarkURLs = [URL]()
            
            // Iterate all bookmark filenames.
            for bookmarkFileName in bookmarkFiles {
                
                // Get the url of the current bookmark file.
                let bookmarkDataURL = bookmarkDirectoryURL.appendingPathComponent(bookmarkFileName)
                
                //  We try to load the bookmark from the file.
                let loadedBookmark = try URL.bookmarkData(withContentsOf: bookmarkDataURL)
                
                /**
                 *  This variable will indicate whether the bookmark is stale.
                 *  If the bookmark is stale we create a new bookmark with the
                 *  obtained URL and save the new one instead of the old one.
                 */
                var isStale = true
                
                // Try to obtain the URL from the bookmark.
                if let loadedBookmarkURL = try URL(resolvingBookmarkData: loadedBookmark, bookmarkDataIsStale: &isStale) {
                    
                    /**
                     *  If the bookmark is stale, we create a new bookmark
                     *  from the obtained URL.
                     */
                    if isStale {
                        do {
                            try self.saveBookmarkURL(url: loadedBookmarkURL)
                        }
                    }
                    
                    // Append the loaded URLs.
                    bookmarkURLs.append(loadedBookmarkURL)
                }
            }
            
            return bookmarkURLs
        } catch {
            return []
        }
    }
    
    /// Determines the current directory and saves the corresponding path as
    /// bookmark.
    ///
    /// - Parameter sender: The view controller that asks to save the current directory. (Might be used to display alerts.)
    func saveBookmarkForCurrentDirectory(sender: UIViewController) {
        
        // Get the path of the current directory and create the corresponding URL.
        let currentDirectoryPath = DocumentManager.shared.fileManager.currentDirectoryPath
        let currentDirectoryURL = URL(fileURLWithPath: currentDirectoryPath)
        
        //  If saving the URL fails, we show an alert with the error.
        do {
            try self.saveBookmarkURL(url: currentDirectoryURL)
        } catch {
            
            //  We inform the user that the bookmark could not be saved.
            let alertController = UIAlertController(title: "Could not save bookmark.",
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil)
            
            alertController.addAction(cancelAction)
            
            sender.present(alertController,
                           animated: true,
                           completion: nil)
        }
    }
    
    /// Saves the passed url as a bookmark.
    ///
    /// - Parameter url: The url to be saved as a bookmark.
    func saveBookmarkURL(url: URL) throws {
        /**
         *  Getting the bookmark data for the current URL can fail. E.g.,
         *  when we don't have access to the corresponding security scoped
         *  resource. However, since the user can only save a directory URL
         *  that is currently accessed, this should not happen.
         *
         *  We now get the bookmark data for the URL making sure it is suitable
         *  to be saved as a file.
         */
        let bookmark = try url.bookmarkData(options: .suitableForBookmarkFile,
                                            includingResourceValuesForKeys: nil,
                                            relativeTo: nil)
        
        /**
         *  Get the document directory of the app. The bookmarks will be saved
         *  in a hidden folder there.
         */
        let dir = DocumentManager.shared.activeDocumentsFolderURL
        
        //  Get the URL of the bookmark directory (where the bookmarks are saved).
        let bookmarkDirectoryURL = dir.appendingPathComponent(BookmarkManager.bookmarkDirectory,
                                                              isDirectory: true)
        
        //  Create the bookmarks directory (if it doesn't exist)
        try FileManager.default.createDirectory(at: bookmarkDirectoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        
        //  The URL for where the bookmark data will be saved.
        let bookmarkDataURL = bookmarkDirectoryURL.appendingPathComponent(url.lastPathComponent,
                                                                          isDirectory: false)
        
        //  Actually saving the bookmark data.
        try URL.writeBookmarkData(bookmark, to: bookmarkDataURL)
        
        //  Tell the bookmark view controller that the bookmarks were updated.
        self.delegate?.bookmarksWereUpdated()
    }
    
    /// Deletes a URL from the bookmarks.
    ///
    /// - Parameter bookmarkURL: The URL to be deleted.
    func deleteBookmarkURL(bookmarkURL: URL) {
        //  Get the document directory of the app.
        let dir = DocumentManager.shared.activeDocumentsFolderURL
        
        //  Get the directory of where the bookmarks are saved.
        let bookmarkDirectoryURL = dir.appendingPathComponent(BookmarkManager.bookmarkDirectory,
                                                              isDirectory: true)
        
        //  Create the bookmarks directory (if it doesn't exist)
        do {
            try FileManager.default.createDirectory(at: bookmarkDirectoryURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            
            //  The URL for where the bookmark data was saved to.
            let bookmarkFileURL = bookmarkDirectoryURL.appendingPathComponent(bookmarkURL.lastPathComponent,
                                                                              isDirectory: false)
            
            //  Actually deleting the file.
            try FileManager.default.removeItem(at: bookmarkFileURL)
        } catch {
            
        }
    }
    
}
