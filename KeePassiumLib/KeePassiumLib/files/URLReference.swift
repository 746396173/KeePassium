//
//  FileURLBookmark.swift
//  KeePassium
//
//  Created by Andrei Popleteev on 2018-08-28.
//  Copyright © 2018 Andrei Popleteev. All rights reserved.
//

import UIKit

/// General info about file URL: file name, timestamps, etc.
public struct FileInfo {
    public var fileName: String
    public var hasError: Bool { return errorMessage != nil}
    public var errorMessage: String?
    
    public var fileSize: Int64?
    public var creationDate: Date?
    public var modificationDate: Date?
}

/// Represents a URL as a URL bookmark. Useful for handling external (cloud-based) files.
public class URLReference: Equatable, Codable {

    /// Specifies possible storage locations of files.
    public enum Location: Int, Codable, CustomStringConvertible {
        public static let allValues: [Location] =
            [.internalDocuments, .internalBackup, .internalInbox, .external]
        
        public static let allInternal: [Location] =
            [.internalDocuments, .internalBackup, .internalInbox]
        
        /// Files stored in app sandbox/Documents dir.
        case internalDocuments = 0
        /// Files stored in app sandbox/Documents/Backup dir.
        case internalBackup = 1
        /// Files temporarily imported via Documents/Inbox dir.
        case internalInbox = 2
        /// Files stored outside the app sandbox (e.g. in cloud)
        case external = 100
        
        /// True if the location is in app sandbox
        public var isInternal: Bool {
            return self != .external
        }
        
        /// Human-readable description of the location
        public var description: String {
            switch self {
            case .internalDocuments:
                return NSLocalizedString("Local (in-app copy)", comment: "Human-readable file location. 'Local' means the file is inside app sandbox.")
            case .internalInbox:
                return NSLocalizedString("Local (in-app copy): Inbox", comment: "Human-readable file location. 'Local' means the file is inside app sandbox.")
            case .internalBackup:
                return NSLocalizedString("Local (in-app copy): Backup", comment: "Human-readable file location. 'Local' means the file is inside app sandbox.")
            case .external:
                return NSLocalizedString("Another App / Cloud Storage", comment: "Human-readable file location. The file is situated in some other app or in cloud storage.")
            }
        }
    }
    
    /// Bookmark data
    private let data: Data
    /// sha256 hash of `data`
    lazy private(set) var hash: ByteArray = CryptoManager.sha256(of: ByteArray(data: data))
    /// Location type of the original URL
    public let location: Location
    
    private enum CodingKeys: String, CodingKey {
        case data = "data"
        case location = "location"
    }
    
    init(from url: URL, location: Location) throws {
        let resourceKeys = Set<URLResourceKey>(
            [.canonicalPathKey, .nameKey, .fileSizeKey,
            .creationDateKey, .contentModificationDateKey]
        )
        data = try url.bookmarkData(
            options: [], //.minimalBookmark,
            includingResourceValuesForKeys: resourceKeys,
            relativeTo: nil)
        self.location = location
    }

    public static func == (lhs: URLReference, rhs: URLReference) -> Bool {
        guard lhs.location == rhs.location else { return false }
        if lhs.location.isInternal {
            // For internal files, URL references are generated dynamically
            // and same URL can have different refs. So we compare by URL.
            guard let leftURL = try? lhs.resolve(),
                let rightURL = try? rhs.resolve() else { return false }
            return leftURL == rightURL
        } else {
            // For external files, URL references are stored, so same refs
            // will have same hash.
            return lhs.hash == rhs.hash
        }
    }
    
    public func serialize() -> Data {
        return try! JSONEncoder().encode(self)
    }
    public static func deserialize(from data: Data) -> URLReference? {
        return try? JSONDecoder().decode(URLReference.self, from: data)
    }
    
    public func resolve() throws -> URL {
        var isStale = false
        let url = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
        return url
    }
    
    /// Cached information about resolved URL.
    /// Cached after first call; use `getInfo()` to update.
    /// In case of trouble, only `hasError` and `errorMessage` fields are valid.
    public lazy var info: FileInfo = getInfo()
    
    /// Returns information about resolved URL (also updates the `info` property).
    /// Might be slow, as it needs to resolve the URL.
    /// In case of trouble, only `hasError` and `errorMessage` fields are valid.
    public func getInfo() -> FileInfo {
        let result: FileInfo
        do {
            let url = try resolve()
            // without secruity scoping, won't get file attributes
            let isAccessed = url.startAccessingSecurityScopedResource()
            defer {
                if isAccessed {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            result = FileInfo(
                fileName: url.lastPathComponent,
                errorMessage: nil,
                fileSize: url.fileSize,
                creationDate: url.fileCreationDate,
                modificationDate: url.fileModificationDate)
        } catch {
            result = FileInfo(
                fileName: "?",
                errorMessage: error.localizedDescription,
                fileSize: nil,
                creationDate: nil,
                modificationDate: nil)
        }
        self.info = result
        return result
    }
}
