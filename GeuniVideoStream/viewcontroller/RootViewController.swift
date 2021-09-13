//
//  RootViewController.swift
//  GeuniVideoStream
//
//  Created by Yeongeun Song on 2021/09/13.
//

import UIKit

class RootViewController: UITableViewController {

    private var rootItems = [RootItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTable()
    }
    
    private func configTable() {
        rootItems.append(RootItem(name: RootTypes.chat.rawValue))
        rootItems.append(RootItem(name: RootTypes.video.rawValue))
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rootItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RootTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RootTableViewCell", for: indexPath) as! RootTableViewCell

        let item = self.rootItems[indexPath.row]
        cell.config(item: item)
        cell.selectionStyle = .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectItem:RootItem = self.rootItems[indexPath.row]
        switch selectItem.name {
        case RootTypes.chat.rawValue:
            self.performSegue(withIdentifier: "showChat", sender: selectItem)
        case RootTypes.video.rawValue:
            self.performSegue(withIdentifier: "showVideo", sender: selectItem)
        default:
            return
        }
    }

}
