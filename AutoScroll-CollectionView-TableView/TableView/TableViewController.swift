//
//  TableViewController.swift
//  AutoScroll-CollectionView-TableView
//
//  Created by kawaharadai on 2019/05/02.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var numbers = [Int]()
    private let cellCount = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numbers = (0 ..< cellCount).map { $0 }
        tableView.dataSource = self
        tableView.delegate = self
    }

}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TableViewCell.self), for: indexPath) as! TableViewCell
        cell.setText("\(numbers[indexPath.row])")
        if indexPath.row % 2 == 0 {
            cell.setBackgroundColor(.lightGray)
        }
        return cell
    }
}

extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height * 0.1
    }
}
