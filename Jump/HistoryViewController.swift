//
//  HistoryViewController.swift
//  Jump
//
//  Created by nirvana on 2022/7/22.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ScoreHelper.scoreHeplper.list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "record", for: indexPath) as! ScrollTableViewCell
        cell.updateUI(indexPath: indexPath)
        return cell
    }
    @IBOutlet var historyTableView: UITableView!
    
    var closure:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
    }
    
    @IBAction func clearRocord(_ sender: Any) {
        ScoreHelper.saveToFile(record: [])
        ScoreHelper.scoreHeplper.list = []
        self.historyTableView.reloadData()
        
        self.closure!()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
