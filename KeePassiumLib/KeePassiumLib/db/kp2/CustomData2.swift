//  KeePassium Password Manager
//  Copyright © 2018 Andrei Popleteev <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
//import AEXML

/// Dictionary for custom data of KP2 database (v3+v4), groups (v4) and entries (v4)
public class CustomData2: Collection, Eraseable {
    public typealias Dict = Dictionary<String, String>
    
    public var startIndex: Dict.Index { return dict.startIndex }
    public var endIndex: Dict.Index { return dict.endIndex }
    public subscript(position: Dict.Index) -> Dict.Iterator.Element { return dict[position] }
    public subscript(bounds: Range<Dict.Index>) -> Dict.SubSequence { return dict[bounds] }
    public var indices: Dict.Indices { return dict.indices }
    public subscript(key: String) -> String? {
        get { return dict[key] }
        set { dict[key] = newValue }
    }
    public func index(after i: Dict.Index) -> Dict.Index {
        return dict.index(after: i)
    }
    public func makeIterator() -> Dict.Iterator {
        return dict.makeIterator()
    }
    
    private var dict: Dict
    init() {
        dict = [:]
    }
    deinit {
        erase()
    }
    public func erase() {
        dict.removeAll() // erase()
    }
    internal func clone() -> CustomData2 {
        let copy = CustomData2()
        copy.dict = self.dict // swift dicts, so value types, so makes a copy-on-write copy
        return copy
    }
    
    /// - Parameter: xmlParentName - Machine-readable name of CustomData's parent XML item,
    ///                              for more informative error messages.
    ///                              (for example, "Meta" or "Group")
    /// - Throws: Xml2.ParsingError
    func load(xml: AEXMLElement, streamCipher: StreamCipher, xmlParentName: String) throws {
        assert(xml.name == Xml2.customData)
        Diag.verbose("Loading XML: custom data")
        erase()
        for tag in xml.children {
            switch tag.name {
            case Xml2.item:
                try loadItem(xml: tag, streamCipher: streamCipher)
                Diag.verbose("Item loaded OK")
            default:
                Diag.error("Unexpected XML tag in CustomData: \(tag.name)")
                throw Xml2.ParsingError.unexpectedTag(
                    actual: tag.name,
                    expected: xmlParentName + "/CustomData/*")
            }
        }
    }
    
    /// - Throws: Xml2.ParsingError
    private func loadItem(xml: AEXMLElement, streamCipher: StreamCipher,
                          xmlParentName: String = "?") throws {
        assert(xml.name == Xml2.item)
        var key: String?
        var value: String?
        for tag in xml.children {
            switch tag.name {
            case Xml2.key:
                key = tag.value ?? ""
            case Xml2.value:
                value = tag.value ?? "" 
            default:
                Diag.error("Unexpected XML tag in CustomData/Item: \(tag.name)")
                throw Xml2.ParsingError.unexpectedTag(
                    actual: tag.name,
                    expected: xmlParentName + "/CustomData/Item/*")
            }
        }
        guard key != nil else {
            Diag.error("Missing /CustomData/Item/Key")
            throw Xml2.ParsingError.malformedValue(
                tag: xmlParentName + "/CustomData/Item/Key",
                value: nil)
        }
        guard value != nil else {
            Diag.error("Missing /CustomData/Item/Value")
            throw Xml2.ParsingError.malformedValue(
                tag: xmlParentName + "/CustomData/Item/Value",
                value: nil)
        }
        dict[key!] = value!
    }
    
    
    /// - Returns: `customData` as an XML element (possibly empty)
    func toXml() -> AEXMLElement {
        Diag.verbose("Generating XML: custom data")
        let xml = AEXMLElement(name: Xml2.customData)
        if dict.isEmpty {
            return xml
        }
        
        for dictItem in dict {
            let xmlItem = xml.addChild(name: Xml2.item)
            xmlItem.addChild(name: Xml2.key, value: dictItem.key)
            xmlItem.addChild(name: Xml2.value, value: dictItem.value)
        }
        return xml
    }
}
