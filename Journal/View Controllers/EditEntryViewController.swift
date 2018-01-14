//
//  EditEntryViewController.swift
//  Journal
//
//  Created by Edward Huang on 1/7/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit
import MessageUI

class EditEntryViewController: UIViewController {
    
    // MARK: Properties
    var editingANewEntry = true
    var entryHistorian: EntryHistorian = EntryHistorian.historian
    var indexToEdit: Int!
    var newJournal: Journal!
    
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var toolBarStackView: UIStackView!
    
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a "Done" button for the keyboard
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(resignKeyboard))
        
        
        toolBar.setItems([flexibleSpace, doneItem], animated: true)
        
        textView.inputAccessoryView = toolBar
        
        // Pay attention to when keyboard is shown and hidden
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // If editing an old entry, add a delete button
        if !editingANewEntry {
            let deleteButton = UIButton()
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.setTitleColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteEntry), for: .touchUpInside)
            toolBarStackView.addArrangedSubview(deleteButton)
        }
        
        // Setup the entry
        let entry = entryHistorian.getEntry(forIndex: indexToEdit)
        
        // Setup the new journal
        newJournal = entry.journal
        
        // Setup the new date
        datePicker.date = entry.date
        // We don't want the user to modify the date. If they really want, they can do that later by editing it
        if editingANewEntry {
            datePicker.isUserInteractionEnabled = false
        }
        
        // Setup the new title
        titleTextView.text = entry.title
        
        // Setup the new text
        textView.text = entry.text
        
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let dateChangerVC = segue.destination as? DateChangerViewController {
            dateChangerVC.indexToEdit = indexToEdit
        }
        
    }
 
    
    // MARK: IBActions
    
    /// If this VC was editing a new entry, it removes that new entry from the data base. Otherwise it is editing an old entry, in which case it simply dismisses the VC, not committing any changes made to the text view to the entry's text
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func cancelPressed(_ sender: Any) {
        
        if editingANewEntry {
            // Remove that entry
            entryHistorian.deleteEntry(atIndex: indexToEdit)
        }
        
        // Dismiss
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        
        // Dismiss
        textView.resignFirstResponder()
        
        // Commit changes made from text view to entry's text
        
        let newDate = datePicker.date
        
        let newText = textView.text
        
        let newTitle = titleTextView.text
        
        entryHistorian.editEntry(index: indexToEdit, title: newTitle, text: newText, date: newDate, journal: newJournal)
        
        let mailVC = Exporter.getExportJournalMailComposerVC(delegate: self)
        if let mailVC = mailVC {
            present(mailVC, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func changeJournalPressed(_ sender: Any) {
        
        // Display a table view of journals to select from
        
    }
    
    // MARK: Private Functions
    
    @objc
    private func keyboardDidShow(aNotification: NSNotification) {
        guard let info = aNotification.userInfo as NSDictionary? else {
            fatalError("Could not get NSDictionary")
        }
        
        guard let kbRect = info.object(forKey: UIKeyboardFrameEndUserInfoKey) as? CGRect else {
            fatalError("Could not get keyboard rect")
        }
        let kbSize = kbRect.size
        
        // TODO: Make this dynamic
        let textViewBottomOffset: CGFloat = 80
        
        let contentInsets = UIEdgeInsetsMake(0, 0, kbSize.height - textViewBottomOffset, 0)
        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
    }
    
    @objc
    private func keyboardWillHide() {
        let contentInsets = UIEdgeInsets.zero
        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
    }
    
    @objc
    private func deleteEntry() {
        // Present an alert VC to confirm.
        // If confirmed, delete entry and then dismiss
        let confirmAlertVC = UIAlertController(title: "Are you sure you want to delete this entry?", message: "This action cannot be undone", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            confirmAlertVC.dismiss(animated: true, completion: nil)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            // Delete the entry
            self.entryHistorian.deleteEntry(atIndex: self.indexToEdit)
            
            // Dismiss the edit entry VC
            self.dismiss(animated: true, completion: {
                // TODO: Also dismiss the view entry VC
            })
        }
        
        confirmAlertVC.addAction(cancelAction)
        confirmAlertVC.addAction(deleteAction)
        
        present(confirmAlertVC, animated: true, completion: nil)
    }
    
    private func updateUI() {
        navigationItem.title = newJournal.name
    }
    
    @objc
    private func resignKeyboard() {
        let result = textView.resignFirstResponder()
        assert(result)
        
        guard let text = textView.text else {
            fatalError("Could not get text from text field")
        }
        
        entryHistorian.editEntry(index: indexToEdit, text: text)
    }
}

extension EditEntryViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        // Dismiss the edit entry VC itself
        dismiss(animated: true, completion: nil)
    }
}
