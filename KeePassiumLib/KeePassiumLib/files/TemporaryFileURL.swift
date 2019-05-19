//  KeePassium Password Manager
//  Copyright © 2018–2019 Andrei Popleteev <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import Foundation

/// Creates a file URL in app's `tmp` directory,
/// and removes the file on `deinit`.
public class TemporaryFileURL {
    public private(set) var url: URL
    
    public init(fileName: String) throws {
        let fileManager = FileManager.default
        let tmpFileDir = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        url = tmpFileDir.appendingPathComponent(fileName, isDirectory: false)
        do {
            try fileManager.createDirectory(
                at: tmpFileDir,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            Diag.error("Failed to create temporary file [error: \(error.localizedDescription)]")
            throw error
        }
    }
    
    deinit {
        cleanup()
    }
    
    private func cleanup() {
        Diag.verbose("Will remove temporary file")
        try? FileManager.default.removeItem(at: url)
        Diag.debug("Temporary file removed")
    }
}
