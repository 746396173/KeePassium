//
//  ChangeMasterKeyVC.swift
//  KeePassium
//
//  Created by Andrei Popleteev on 2018-09-27.
//  Copyright © 2018 Andrei Popleteev. All rights reserved.
//

import UIKit
import KeePassiumLib

class ChangeMasterKeyVC: UIViewController {
    @IBOutlet weak var keyboardAdjView: UIView!
    @IBOutlet weak var databaseNameLabel: UILabel!
    @IBOutlet weak var databaseIcon: UIImageView!
    @IBOutlet weak var passwordField: ValidatingTextField!
    @IBOutlet weak var keyFileField: ValidatingTextField!
    
    private var databaseManagerNotifications: DatabaseManagerNotifications!
    private var databaseRef: URLReference!
    private var keyFileRef: URLReference?
    
    static func make(dbRef: URLReference) -> UIViewController {
        let vc = ChangeMasterKeyVC.instantiateFromStoryboard()
        vc.databaseRef = dbRef
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        return navVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseManagerNotifications = DatabaseManagerNotifications(observer: self)
        
        databaseNameLabel.text = databaseRef.info.fileName
        databaseIcon.image = UIImage.databaseIcon(for: databaseRef)
        
        passwordField.invalidBackgroundColor = nil
        keyFileField.invalidBackgroundColor = nil
        passwordField.delegate = self
        passwordField.validityDelegate = self
        keyFileField.delegate = self
        keyFileField.validityDelegate = self
        
        // make background image
        view.backgroundColor = UIColor(patternImage: UIImage(asset: .backgroundPattern))
        view.layer.isOpaque = false
        
        // Initially all fields are empty, so disable the Doen button.
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressSaveChanges(_ sender: Any) {
        guard let db = DatabaseManager.shared.database else {
            assertionFailure()
            return
        }
        
        DatabaseManager.createCompositeKey(
            keyHelper: db.keyHelper,
            password: passwordField.text ?? "",
            keyFile: keyFileRef,
            success: {
                [weak self] (_ newCompositeKey: SecureByteArray) -> Void in
                guard let _self = self else { return }
                let dbm = DatabaseManager.shared
                dbm.changeCompositeKey(to: newCompositeKey)
                try? dbm.rememberDatabaseKey(onlyIfExists: true) // throws KeychainError, ignored
                _self.databaseManagerNotifications.startObserving()
                dbm.startSavingDatabase()
            },
            error: {
                [weak self] (_ errorMessage: String) -> Void in
                guard let _self = self else { return }
                Diag.error("Failed to create new composite key [message: \(errorMessage)]")
                let errorAlert = UIAlertController.make(
                    title: LString.titleError,
                    message: errorMessage)
                _self.present(errorAlert, animated: true, completion: nil)
            }
        )
    }
    
    // MARK: - Progress tracking
    
    private var progressOverlay: ProgressOverlay?
    fileprivate func showProgressOverlay() {
        progressOverlay = ProgressOverlay.addTo(
            view, title: LString.databaseStatusSaving, animated: true)
        progressOverlay?.isCancellable = true
        
        // Temporarily disable navigation
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.hidesBackButton = true
    }
    
    fileprivate func hideProgressOverlay() {
        UIView.animateKeyframes(
            withDuration: 0.2,
            delay: 0.0,
            options: [.beginFromCurrentState],
            animations: {
                [weak self] in
                self?.progressOverlay?.alpha = 0.0
            },
            completion: {
                [weak self] finished in
                guard let _self = self else { return }
                _self.progressOverlay?.removeFromSuperview()
                _self.progressOverlay = nil
            }
        )
        // Enable navigation
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.hidesBackButton = false
    }
}

extension ChangeMasterKeyVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === passwordField {
            didPressSaveChanges(self)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === keyFileField {
            passwordField.becomeFirstResponder()
            let keyFileChooserVC = ChooseKeyFileVC.make(
                popoverSourceView: keyFileField,
                delegate: self)
            present(keyFileChooserVC, animated: true, completion: nil)
        }
    }
}

extension ChangeMasterKeyVC: ValidatingTextFieldDelegate {
    func validatingTextFieldShouldValidate(_ sender: ValidatingTextField) -> Bool {
        let gotPassword = passwordField.text?.isNotEmpty ?? false
        let gotKeyFile = keyFileRef != nil
        return gotPassword || gotKeyFile
    }
    
    func validatingTextField(_ sender: ValidatingTextField, validityDidChange isValid: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isValid
    }
}

extension ChangeMasterKeyVC: KeyFileChooserDelegate {
    func onKeyFileSelected(urlRef: URLReference?) {
        // can be nil, can have error, can be ok
        keyFileRef = urlRef
        Settings.current.setKeyFileForDatabase(databaseRef: databaseRef, keyFileRef: keyFileRef)
        
        guard let keyFileRef = urlRef else {
            keyFileField.text = ""
            return
        }
        
        if let errorMessage = keyFileRef.info.errorMessage {
            keyFileField.text = ""
            let errorAlert = UIAlertController.make(
                title: LString.titleError,
                message: errorMessage)
            present(errorAlert, animated: true, completion: nil)
        } else {
            keyFileField.text = keyFileRef.info.fileName
        }
    }
}

extension ChangeMasterKeyVC: DatabaseManagerObserver {
    func databaseManager(willSaveDatabase urlRef: URLReference) {
        showProgressOverlay()
    }
    
    func databaseManager(didSaveDatabase urlRef: URLReference) {
        databaseManagerNotifications.stopObserving()
        hideProgressOverlay()
        let parentVC = presentingViewController
        dismiss(animated: true, completion: {
            let alert = UIAlertController.make(
                title: LString.databaseStatusSavingDone,
                message: LString.masterKeySuccessfullyChanged,
                cancelButtonTitle: LString.actionOK)
            parentVC?.present(alert, animated: true, completion: nil)
        })
    }
    
    func databaseManager(progressDidChange progress: ProgressEx) {
        progressOverlay?.update(with: progress)
    }
    
    func databaseManager(database urlRef: URLReference, isCancelled: Bool) {
        Diag.info("Master key change cancelled")
        databaseManagerNotifications.stopObserving()
        hideProgressOverlay()
    }
    
    func databaseManager(
        database urlRef: URLReference,
        savingError message: String,
        reason: String?)
    {
        let errorAlert = UIAlertController.make(title: message, message: reason)
        present(errorAlert, animated: true, completion: nil)
        
        databaseManagerNotifications.stopObserving()
        hideProgressOverlay()
    }
}
