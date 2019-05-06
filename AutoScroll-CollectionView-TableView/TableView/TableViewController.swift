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
    private let cellCount = 20
    private var autoScrollTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numbers = (0 ..< cellCount).map { $0 }
        tableView.dataSource = self
        tableView.delegate = self
    }

    @IBAction func didTapUp(_ sender: UIButton) {
        startAutoScroll(duration: 0.1, direction: .upper)
    }

    @IBAction func didTapDown(_ sender: UIButton) {
        startAutoScroll(duration: 0.1, direction: .under)
    }

    @IBAction func didTapStop(_ sender: UIButton) {
        stopAutoScrollIfNeeded()
    }

    private func startAutoScroll(duration: TimeInterval, direction: ScrollDirectionType) {
        var currentOffsetY = tableView.contentOffset.y
        var shouldFinish = false
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            switch direction {
            case .upper:
                currentOffsetY = (currentOffsetY - 10 < 0) ? 0 : currentOffsetY - 10
                shouldFinish = currentOffsetY == 0
            case .under:
                let highLimit = self.tableView.contentSize.height - self.tableView.bounds.size.height
                currentOffsetY = (currentOffsetY + 10 > highLimit) ? highLimit : currentOffsetY + 10
                shouldFinish = currentOffsetY == highLimit
            default: break
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: duration * 2, animations: {
                    self.tableView.setContentOffset(CGPoint(x: 0, y: currentOffsetY), animated: false)
                }, completion: { _ in
                    if shouldFinish { self.stopAutoScrollIfNeeded() }
                })
            }
        })
    }

    private func stopAutoScrollIfNeeded() {
        if autoScrollTimer.isValid {
            view.layer.removeAllAnimations()
            autoScrollTimer.invalidate()
        }
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
