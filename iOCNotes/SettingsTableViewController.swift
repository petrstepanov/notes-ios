//
//  SettingsTableViewController.swift
//  iOCNotes
//
//  Created by Peter Hedlund on 6/19/19.
//  Copyright © 2019 Peter Hedlund. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController {

    @IBOutlet var syncOnStartSwitch: UISwitch!
    @IBOutlet weak var offlineModeSwitch: UISwitch!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var extensionLabel: UILabel!
    @IBOutlet var folderLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(macCatalyst)
        navigationController?.navigationBar.isHidden = true
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.syncOnStartSwitch.isOn = KeychainHelper.syncOnStart
        offlineModeSwitch.isOn = KeychainHelper.offlineMode
        if NoteSessionManager.isConnectedToServer {
            self.statusLabel.text = NSLocalizedString("Logged In", comment:"A status label indicating that the user is logged in")
        } else {
            self.statusLabel.text =  NSLocalizedString("Not Logged In", comment: "A status label indicating that the user is not logged in")
        }
        extensionLabel.text = KeychainHelper.fileSuffix.description
        folderLabel.text = KeychainHelper.notesPath
        #if targetEnvironment(macCatalyst)
        self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isHidden = true
        #endif
    }
    
    #if targetEnvironment(macCatalyst)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.shared.sceneDidActivate(identifier: "Preferences")
    }
    #endif
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        #if targetEnvironment(macCatalyst)
        if indexPath.section == 0, indexPath.row == 0 {
            return 2.0
        }
        #endif
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            if indexPath.row == 1 {
                showNotesFolderAlert()
            }
        case 2:
            let email = "support@pbh.dev"
            let subject = NSLocalizedString("CloudNotes Support Request", comment: "Support email subject")
            let body = NSLocalizedString("<Please state your question or problem here>", comment: "Support email body placeholder")
            if MFMailComposeViewController.canSendMail() {
                let mailViewController = MFMailComposeViewController()
                mailViewController.mailComposeDelegate = self
                mailViewController.setToRecipients([email])
                mailViewController.setSubject(subject)
                mailViewController.setMessageBody(body, isHTML: false)
                mailViewController.modalPresentationStyle = .formSheet;
                present(mailViewController, animated: true, completion: nil)
            } else {
                var components = URLComponents()
                components.scheme = "mailto"
                components.path = email
                components.queryItems = [URLQueryItem(name: "subject", value: subject),
                                         URLQueryItem(name: "body", value: body)]
                if let mailURL = components.url {
                    if UIApplication.shared.canOpenURL(mailURL) {
                        UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
                    } else {
                        // No email client configured
                    }
                }
            }

        default:
            break
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        vc.navigationItem.rightBarButtonItem = nil
    }

    @IBAction func syncOnStartChanged(_ sender: Any) {
        KeychainHelper.syncOnStart = syncOnStartSwitch.isOn
    }
    
    @IBAction func offlineModeChanged(_ sender: Any) {
        KeychainHelper.offlineMode = offlineModeSwitch.isOn
    }

    @IBAction func onDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    private func showNotesFolderAlert() {
        var nameTextField: UITextField?
        let folderPath = KeychainHelper.notesPath
        let alertController = UIAlertController(title: NSLocalizedString("Notes Folder", comment: "Title of alert to change notes folder"),
                                                message: NSLocalizedString("Enter a name for the folder where notes should be saved on the server", comment: "Message of alert to change notes folder"),
                                                preferredStyle: .alert)
        alertController.addTextField { textField in
            nameTextField = textField
            textField.text = folderPath
            textField.keyboardType = .default
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Caption of Cancel button"), style: .cancel, handler: nil)
        let renameAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Caption of Save button"), style: .default) { _ in
            guard let newName = nameTextField?.text,
                !newName.isEmpty,
                newName != folderPath else {
                    return
            }
            KeychainHelper.notesPath = newName
            NoteSessionManager.shared.updateSettings { [weak self] in
                self?.folderLabel.text = KeychainHelper.notesPath
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(renameAction)
        present(alertController, animated: true, completion: nil)
    }




}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

}
