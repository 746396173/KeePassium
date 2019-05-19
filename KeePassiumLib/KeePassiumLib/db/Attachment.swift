//  KeePassium Password Manager
//  Copyright © 2018–2019 Andrei Popleteev <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import Foundation

/// A file attached to an entry
public class Attachment: Eraseable {
    public var name: String
    public internal(set) var isCompressed: Bool
    public internal(set) var data: ByteArray {
        didSet {
            uncompressedSize = -1
        }
    }
    public internal(set) var uncompressedSize: Int

    /// Size of _uncompressed_ data
    public var size: Int {
        if uncompressedSize < 0 {
            if isCompressed {
                uncompressedSize = (try? data.gunzipped().count) ?? 0
            } else {
                uncompressedSize = data.count
            }
        }
        return uncompressedSize
    }
    
    public init(name: String, isCompressed: Bool, data: ByteArray) {
        self.name = name
        self.isCompressed = isCompressed
        self.data = data.clone()
        self.uncompressedSize = -1
    }
    deinit {
        erase()
    }
    
    /// Creates a clone of this instance
    public func clone() -> Attachment {
        return Attachment(
            name: self.name,
            isCompressed: self.isCompressed,
            data: self.data
        )
    }
    
    public func erase() {
        name.erase()
        isCompressed = false
        data.erase()
        uncompressedSize = -1
    }
}
