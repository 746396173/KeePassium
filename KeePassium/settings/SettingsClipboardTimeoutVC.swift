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

class SettingsClipboardTimeoutVC: UITableViewController, Refreshable {
    private let cellID = "Cell"
    
    public static func make() -> UIViewController {
        return SettingsClipboardTimeoutVC.instantiateFromStoryboard()
    }

    func refresh() {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings.ClipboardTimeout.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("When you copy some text from an entry, the app will automatically clear your clipboard (pasteboard) after this time.", comment: "[Settings/Pasteboard Timeout/Footer]")
    }
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let timeout = Settings.ClipboardTimeout.allValues[indexPath.row]
        cell.textLabel?.text = timeout.fullTitle
        if timeout == Settings.current.clipboardTimeout {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let timeout = Settings.ClipboardTimeout.allValues[indexPath.row]
        Settings.current.clipboardTimeout = timeout
        refresh()
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
