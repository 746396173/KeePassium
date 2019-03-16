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

import UIKit
import KeePassiumLib

class ViewEntryHistoryVC: UITableViewController, Refreshable {
    private weak var entry: Entry?
    private var isHistoryMode = false

    private let numberOfFixedTimestamps = 4 // expiry, creation, last modification, last access
    private enum Section: Int { // indices of table sections
        case expiryTime = 0
        case creationTime = 1
        case lastModificationTime = 2
        case lastAccessTime = 3
        case previousVersions = 4
    }
    private enum CellID { // cells' reuse IDs
        static let fixedTimestamp = "FixedTimestampCell"
        static let emptyHistory = "EmptyHistoryCell"
        static let historyItem = "HistoryItemCell"
    }
    private let dateFormatter = DateFormatter()
    
    static func make(with entry: Entry?, historyMode: Bool) -> ViewEntryHistoryVC {
        let viewEntryHistoryVC = ViewEntryHistoryVC.instantiateFromStoryboard()
        viewEntryHistoryVC.entry = entry
        viewEntryHistoryVC.isHistoryMode = historyMode
        return viewEntryHistoryVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = nil
        refresh()
    }
    
    func refresh() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if entry is Entry1 {
            return numberOfFixedTimestamps
        } else if entry is Entry2 {
            if isHistoryMode {
                // a historical entry does not have other historical entries
                return numberOfFixedTimestamps
            } else {
                // add a section for history items
                return numberOfFixedTimestamps + 1
            }
        } else { // entry == nil
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < numberOfFixedTimestamps {
            return 1
        } else {
            let entry2 = entry as! Entry2
            return max(1, entry2.history.count) // need at least one to show "there's no history"
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { assertionFailure(); return nil }
        switch section {
        case .expiryTime:
            return NSLocalizedString("Expiry Date", comment: "Title of a field with date and time when tthe entry will no longer be valid. 'Never' is also a possible value")
        case .creationTime:
            return NSLocalizedString("Creation Date", comment: "Title of a field with entry creation date and time")
        case .lastModificationTime:
            return NSLocalizedString("Last Modification Date", comment: "Title of a field with entry's last modification date and time")
        case .lastAccessTime:
            return NSLocalizedString("Last Access Date", comment: "Title of a field with date and time when the entry was last accessed/viewed")
        case .previousVersions:
            return NSLocalizedString("Previous Versions", comment: "Title of a list with previous versions/revisions of an entry.")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.horizontalSizeClass == .compact {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
        } else {
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .long
        }
        tableView.reloadData()
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell
    {
        guard let entry = entry else { fatalError() }
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unexpected section ID")
        }
        
        let cell: UITableViewCell
        switch section {
        case .expiryTime:
            cell = tableView.dequeueReusableCell(withIdentifier: CellID.fixedTimestamp, for: indexPath)
            if entry.canExpire {
                cell.textLabel?.text = dateFormatter.string(from: entry.expiryTime)
            } else {
                cell.textLabel?.text = NSLocalizedString("Never", comment: "Expiry Date of an entry which does not expire.")
            }
        case .creationTime:
            cell = tableView.dequeueReusableCell(withIdentifier: CellID.fixedTimestamp, for: indexPath)
            cell.textLabel?.text = dateFormatter.string(from: entry.creationTime)
        case .lastModificationTime:
            cell = tableView.dequeueReusableCell(withIdentifier: CellID.fixedTimestamp, for: indexPath)
            cell.textLabel?.text = dateFormatter.string(from: entry.lastModificationTime)
        case .lastAccessTime:
            cell = tableView.dequeueReusableCell(withIdentifier: CellID.fixedTimestamp, for: indexPath)
            cell.textLabel?.text = dateFormatter.string(from: entry.lastAccessTime)
        case .previousVersions:
            let entry2 = entry as! Entry2
            if entry2.history.count > 0 {
                let historyItem = entry2.history[indexPath.row]
                cell = tableView.dequeueReusableCell(withIdentifier: CellID.historyItem, for: indexPath)
                cell.textLabel?.text = historyItem.title
                cell.detailTextLabel?.text = dateFormatter.string(from: historyItem.lastModificationTime)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: CellID.emptyHistory, for: indexPath)
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show previous entry versions (only Entry2 have them)
        guard let entry2 = entry as? Entry2 else { return }
        guard let section = Section(rawValue: indexPath.section),
            section == .previousVersions else { return }
        
        let entryIndex = indexPath.row
        guard entryIndex < entry2.history.count else { return }
        
        let historyEntry = entry2.history[entryIndex]
        let vc = ViewEntryVC.make(with: historyEntry, historyMode: true)
        self.show(vc, sender: self)
    }
}
