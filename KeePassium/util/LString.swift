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

/// Common user-readable strings, localized.
internal enum LString {

    // Button/action titles
    public static let actionOK = NSLocalizedString("OK", comment: "Action/button: generic OK")
    public static let actionCancel = NSLocalizedString("Cancel", comment: "Action/button to cancel whatever is going on")
    public static let actionDismiss = NSLocalizedString("Dismiss", comment: "Action/button to close an error message.")
    public static let actionDiscard = NSLocalizedString("Discard", comment: "Action/button to discard any unsaved changes")
    public static let actionDelete = NSLocalizedString("Delete", comment: "Action/button to delete an item (destroys the item/file)")
    public static let actionReplace = NSLocalizedString("Replace", comment: "Action/button to replace an item with another one")
    public static let actionEdit = NSLocalizedString("Edit", comment: "Action/button to edit an item")
    public static let actionRename = NSLocalizedString("Rename", comment: "Action/button to rename an item (such as database)")
    public static let actionDone = NSLocalizedString("Done", comment: "Action/button to finish (editing) and keep changes")
    public static let actionShowDetails = NSLocalizedString("Show Details", comment: "Action/button to show additional information about an error or item")
    public static let actionExport = NSLocalizedString("Export", comment: "Action/button to export an item to another app")
    public static let actionDeleteFile = NSLocalizedString("Delete", comment: "Action/button to delete a file")
    public static let actionRemoveFile = NSLocalizedString("Remove", comment: "Action/button to remove file from the app (the file remains, but the app forgets about it)")
    public static let actionUnlock = NSLocalizedString("Unlock", comment: "Action/button to unlock the App Lock with passcode")
    public static let actionContactUs = NSLocalizedString("Contact Us", comment: "Action/button to write an email to support")
    

    // Error/warning messages
    public static let titleError = NSLocalizedString("Error", comment: "Title of an error message notification")
    public static let titleWarning = NSLocalizedString("Warning", comment: "Title of an warning message")
    public static let titleImportError = NSLocalizedString("Import Error", comment: "Title of an error message about file import")
//        public static let importErrorNotAFileURL = NSLocalizedString("Not a file URL", comment: "Error message: tried to import URL which does not point to a file")
    public static let titleKeychainError = NSLocalizedString("Keychain Error", comment: "Title of an error message about iOS system keychain")
    public static let titleExportError = NSLocalizedString("Export Error", comment: "Title of an error message about file export")
    public static let dontUseDatabaseAsKeyFile = NSLocalizedString("KeePass database should not be used as key file. Please pick a different file.", comment: "Warning message when the user tries to use a database as a key file")
    

    // DB progress status
    public static let databaseStatusLoading = NSLocalizedString("Loading...", comment: "Status message: loading a database")
    public static let databaseStatusSaving = NSLocalizedString("Saving...", comment: "Status message: saving a database")
    public static let databaseStatusSavingDone = NSLocalizedString("Done", comment: "Status message: finished saving a database")
//        public static let progressLoadingDatabaseFile = NSLocalizedString("Loading database file...", comment: "Status message: loading database file in progress")
//        public static let progressLoadingKeyFile = NSLocalizedString("Loading key file...", comment: "Status message: loading key file in progress")
//        public static let progressDone = NSLocalizedString("Done", comment: "Status message: operation completed")

    // Deletion
    public static let confirmDeleteAreYouSure = NSLocalizedString("Are you sure?", comment: "Message to confirm deletion of an item.")
    public static let messageUnsavedChanges = NSLocalizedString("There are unsaved changes", comment: "Title of a notification when the user tries to close a document with unsaved changes")
    public static let discardChangesConfirmation = NSLocalizedString("Discard unsaved changes?", comment: "Notification text when the user tries to close a document with unsaved changes")
    public static let confirmKeyFileDeletion = NSLocalizedString("Delete key file?\n Make sure you have a backup.", comment: "Message to confirm deletion of a key file.")
    public static let confirmDatabaseDeletion = NSLocalizedString("Delete database file?\n Make sure you have a backup.", comment: "Message to confirm deletion of a database file.")
    public static let confirmDatabaseRemoval = NSLocalizedString("Remove database from the list?\n The file will remain intact and you can add it again later.", comment: "Message to confirm removal of database file from the app.")

    // Database creation
    public static let titleCreateDatabase = NSLocalizedString("Create Database", comment: "Title of a form for creating a database")

    // Group editing/creation
    public static let actionCreateGroup = NSLocalizedString("Create Group", comment: "Action/button to create a new sub-group in the current group")
    public static let defaultNewGroupName = NSLocalizedString("New Group", comment: "Default name of a new group")
    public static let titleCreateGroup = NSLocalizedString("Create Group", comment: "Title of a form for creating a group")
    public static let titleEditGroup = NSLocalizedString("Edit Group", comment: "Title of a form for editing a group")

    // Entry editing/creation
    public static let actionCreateEntry = NSLocalizedString("Create Entry", comment: "Action/button to create a new entry in the current group")
    public static let defaultNewEntryName = NSLocalizedString("New Entry", comment: "Default name of a new entry")
    public static let defaultNewCustomFieldName = NSLocalizedString("Field Name", comment: "Default name of a newly created entry field")
    
    // Entry view
    public static let fieldTitle = NSLocalizedString("Title", comment: "Name of an entry field, in an edit form")
    public static let fieldUserName = NSLocalizedString("User Name", comment: "Name of an entry field, in an edit form")
    public static let fieldPassword = NSLocalizedString("Password", comment: "Name of an entry field, in an edit form")
    public static let fieldURL      = NSLocalizedString("URL", comment: "Name of an entry field, in an edit form")
    public static let fieldNotes    = NSLocalizedString("Notes", comment: "Name of an entry field, in an edit form")
    public static let fieldCreditCardNumber = NSLocalizedString("Card Number", comment: "Name of an entry field: credit card number")
    public static let fieldCreditCardPIN = NSLocalizedString("PIN", comment: "Name of an entry field: credit card PIN code")
    public static let fieldCreditCardHolder = NSLocalizedString("Holder", comment: "Name of an entry field: credit card owner name")
    public static let fieldCreditCardExpires = NSLocalizedString("Expiry Date", comment: "Name of an entry field: credit card expiry date")
    public static let fieldCreditCardCVV2 = NSLocalizedString("CVV2", comment: "Name of an entry field: credit card 3-digit security code")
    
    public static let titleEntryAttachedFiles = NSLocalizedString("Attached Files", comment: "Title of a list with attached files")
    
    public static let itemCategoryDefault = NSLocalizedString("Default (KeePass)", comment: "Name of an entry/group category (visual style): default one, like in KeePass")
    public static let itemCategoryNotes = NSLocalizedString("Notes", comment: "Name of an entry/group category (visual style): show notes")
    public static let itemCategoryCreditCard = NSLocalizedString("Credit Card", comment: "Name of an entry/group category (visual style): credit card details")
    public static let itemCategoryFiles = NSLocalizedString("Files", comment: "Name of an entry/group category (visual style): viewing attached files")
    public static let itemCategoryOther = NSLocalizedString("Other", comment: "Name of an entry/group category (visual style): no specific style")
    
    // App Lock
    public static let statusAppLockIsDisabled  = NSLocalizedString("Disabled", comment: "Short status word shown in settings when the App Lock feature is disabled. Shown as 'App Lock: Disabled'")
    public static let statusPasscodeSet  = NSLocalizedString("Enabled", comment: "Short status word shown in settings when App Lock Passcode is correctly set. Shown as 'Passcode: Enabled'")
    public static let statusPasscodeNotSet  = NSLocalizedString("Disabled", comment: "Short status word shown in settings when App Lock Passcode has to be set by the user. Shown as 'Passcode: Disabled'")
    public static let titleTouchID  = NSLocalizedString("Unlock KeePassium", comment: "Hint/Description why the user is asked to provide their fingerprint")
    
    // Database adding/creation
    public static let titleChooseFileToOpen  = NSLocalizedString("Choose Database", comment: "Title of a window where the user selects a file to be opened/added to the app")
    public static let actionAddDatabase  = NSLocalizedString("Add Database", comment: "Action/button to add database to the app")
    public static let actionCreateDatabase  = NSLocalizedString("Create Database", comment: "Action/button to create a new database")
    public static let actionOpenDatabase  = NSLocalizedString("Open Database", comment: "Action/button")
    public static let actionImportDatabase  = NSLocalizedString("Import Database", comment: "Action/button")
    public static let defaultNewDatabaseName  = NSLocalizedString("MyPasswords", comment: "Default file name for a new password database")

    // Master key changing
    public static let masterKeySuccessfullyChanged = NSLocalizedString("Master key successfully changed", comment: "Notification message")
    
    // Diagnostics - Support email template
    public static let emailTemplateDescribeTheProblemHere  = NSLocalizedString("(Please describe the problem here)", comment: "Template text of a bug report")
}
