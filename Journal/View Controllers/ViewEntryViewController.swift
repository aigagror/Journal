//
//  ViewEntryViewController.swift
//  Journal
//
//  Created by Edward Huang on 1/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class ViewEntryViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var entryHistorian: EntryHistorian = EntryHistorian.historian
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let entry = entryHistorian.getEntry(for: index)
        navigationItem.title = entry.title
        
        let text = entry.text
        textView.text = text
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
        
        guard let navVC = segue.destination as? UINavigationController else {
            fatalError("Destination is not a UINavigationController")
        }
        
        guard let editEntryVC = navVC.childViewControllers.first as? EditEntryViewController else {
            fatalError("First child is not a ViewEntryViewController")
        }
        
        editEntryVC.editingANewEntry = false
        editEntryVC.indexToEdit = index
    }
 

    // MARK: IBActions
    @IBAction func donePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
