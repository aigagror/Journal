//
//  JournalTableViewController.swift
//  Journal
//
//  Created by Edward Huang on 1/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class JournalTableViewController: UIViewController {

    // MARK: Properties
    let journalLibrarian = JournalLibrarian()
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set the title
        let currentJournal = JournalLibrarian.getCurrentJournal()
        navigationItem.title = currentJournal.name
        
        // Watch for any changes to the journals
        NotificationCenter.default.addObserver(self, selector: #selector(receivedJournalChangeNotification), name: .journalChanged, object: nil)
        journalLibrarian.update()
        
        // Setup the table view
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: IBActions
    
    @IBAction func addJournalPressed(_ sender: Any) {
        let alertVC = UIAlertController(title: "New Journal", message: nil, preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            
            guard let textField = alertVC.textFields?.first else {
                fatalError("Could not get text field")
            }
            guard let text = textField.text else {
                fatalError("Could not get text")
            }
            
            self.journalLibrarian.addJournal(name: text)
            
            alertVC.dismiss(animated: true, completion: nil)
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(saveAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: Private Functions
    @objc
    private func receivedJournalChangeNotification() {
        let currentJournal = JournalLibrarian.getCurrentJournal()
        navigationItem.title = currentJournal.name
    }
}

extension JournalTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    static let cellIdentifier = "journal_cell"
    
    // MARK: Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        let selectedJournal = journalLibrarian.getJournal(for: row)
        
        let journalID = selectedJournal.id
        UserDefaults.standard.set(journalID, forKey: JournalLibrarian.userDefaultKeyName)
        
        NotificationCenter.default.post(Notification(name: .journalChanged))
    }
    
    // MARK: Data Source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let journal = journalLibrarian.getJournal(for: row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: JournalTableViewController.cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = journal.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return journalLibrarian.numberOfJournals()
        }
        return 0
    }
    
}
