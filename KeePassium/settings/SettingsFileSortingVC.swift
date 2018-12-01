//
//  SettingsFileSortingVC.swift
//  KeePassium
//
//  Created by Andrei Popleteev on 2018-06-08.
//  Copyright © 2018 Andrei Popleteev. All rights reserved.
//

import UIKit
import KeePassiumLib

class SettingsBackupFileVisibilityCell: UITableViewCell {
    fileprivate static let storyboardID = "BackupVisibilityCell"
    @IBOutlet weak var theSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        theSwitch.isOn = Settings.current.isBackupFilesVisible
        theSwitch.addTarget(self, action: #selector(didToggleSwitch), for: .valueChanged)
    }
    
    @objc private func didToggleSwitch(_ sender: UISwitch) {
        Settings.current.isBackupFilesVisible = theSwitch.isOn
    }
}

class SettingsFileSortingVC: UITableViewController {
    private let sortingCellID = "SortingCell"
    
    static func make(popoverFromBar barButtonSource: UIBarButtonItem?=nil) -> UIViewController {
        let vc = SettingsFileSortingVC.instantiateFromStoryboard()
        let contentHeight = 45 * (Settings.FilesSortOrder.allValues.count + 1) +
            18 * 2 + // section headers
            18 * 2 // section footers
        vc.preferredContentSize = CGSize(width: 320, height: contentHeight)
        vc.modalPresentationStyle = .popover
        if let popover = vc.popoverPresentationController {
            popover.barButtonItem = barButtonSource
            popover.delegate = vc
        }
        return vc
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String?
    {
        if section == 0 {
            return NSLocalizedString("Backup", comment: "Title of a settings section about making backup files")
        } else {
            return NSLocalizedString("Sorting", comment: "Title of a settings section about file order in lists")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // backup visibility switch
            return 1
        } else {
            // sorting options
            return Settings.FilesSortOrder.allValues.count
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsBackupFileVisibilityCell.storyboardID,
                for: indexPath)
                as! SettingsBackupFileVisibilityCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: sortingCellID, for: indexPath)
        let cellValue = Settings.FilesSortOrder.allValues[indexPath.row]
        cell.textLabel?.text = cellValue.longTitle
        if Settings.current.filesSortOrder == cellValue {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellValue = Settings.FilesSortOrder.allValues[indexPath.row]
        Settings.current.filesSortOrder = cellValue
        tableView.reloadData()
        dismissPopover()
    }
}
extension SettingsFileSortingVC: UIPopoverPresentationControllerDelegate {
    func presentationController(
        _ controller: UIPresentationController,
        viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle
        ) -> UIViewController?
    {
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissPopover))
        let nav = UINavigationController(rootViewController: controller.presentedViewController)
        nav.topViewController?.navigationItem.rightBarButtonItem = doneButton
        return nav
    }

    @objc
    private func dismissPopover() {
        dismiss(animated: true, completion: nil)
    }
}


