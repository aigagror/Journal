//
//  EntryTableViewController.swift
//  Journal
//
//  Created by Edward Huang on 1/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class EntryTableViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var timeFrameSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var entryHistorian: EntryHistorian = EntryHistorian.historian
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // SegmentControl
        timeFrameSegmentControl.addTarget(self, action: #selector(segmentControlValueDidChange), for: .valueChanged)
        let selectedIndex = timeFrameSegmentControl.selectedSegmentIndex
        guard let timeFrame = TimeFrame(rawValue: selectedIndex) else {
            fatalError("Could not get time frame")
        }
        entryHistorian.timeFrame = timeFrame
        
        // Watch for any changes to the entries
        NotificationCenter.default.addObserver(self, selector: #selector(receivedJournalChangeNotification), name: .NSManagedObjectContextDidSave, object: nil)
        
        // Watch for any changes to the journals
        NotificationCenter.default.addObserver(self, selector: #selector(receivedJournalChangeNotification), name: Notification.Name.journalChanged, object: nil)
        entryHistorian.update()
        
        // Set title to current journal
        let currentJournal = JournalLibrarian.librarian.getCurrentJournal()
        navigationItem.title = currentJournal.name
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
        
        guard let row = tableView.indexPathForSelectedRow?.row else {
            fatalError("An entry was not selected")
        }
        
        guard let navVC = segue.destination as? UINavigationController else {
            fatalError("Destination is not a UINavigationController")
        }
        
        guard let viewEntryVC = navVC.childViewControllers.first as? ViewEntryViewController else {
            fatalError("First child is not a ViewEntryViewController")
        }
        viewEntryVC.index = row
    }
 
    
    // MARK: Private functions
    @objc
    private func receivedJournalChangeNotification() {
        entryHistorian.update()
        
        // Update title
        let currentJournal = JournalLibrarian.librarian.getCurrentJournal()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.navigationItem.title = currentJournal.name
        }
    }
    
    @objc
    private func receivedContextChangeNotification() {
        entryHistorian.update()
        tableView.reloadData()
    }
    
    // MARK: Segment Control
    @objc
    private func segmentControlValueDidChange() {
        let rawValue = timeFrameSegmentControl.selectedSegmentIndex
        guard let newTimeFrame = TimeFrame(rawValue: rawValue) else {
            fatalError("Could not get time frame")
        }
        
        entryHistorian.timeFrame = newTimeFrame
        
        tableView.reloadData()
    }
}

extension EntryTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    private static let cellIdentifier = "entry_cell"
    
    // MARK: Delegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            let row = indexPath.row
            entryHistorian.deleteEntry(atIndex: row)
            tableView.endUpdates()
        }
    }
    
    
    // MARK: Data Source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        let entry = entryHistorian.getEntry(forIndex: row)
        let date = entry.date
        let title = entry.title
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EntryTableViewController.cellIdentifier, for: indexPath)
        
        // Format cell
        cell.textLabel?.text = title
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/yy")
        let dateString = dateFormatter.string(from: date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return entryHistorian.numberOfEntries()
        }
        return 0
    }
    
}
