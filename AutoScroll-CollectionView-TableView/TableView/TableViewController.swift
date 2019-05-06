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
    private var autoScrollTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numbers = (0 ..< cellCount).map { $0 }
        tableView.dataSource = self
        tableView.delegate = self
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        tableView.addGestureRecognizer(gesture)
    }

    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            tableView.isScrollEnabled = false
            tableView.isUserInteractionEnabled = false
        case .changed:
            let transition = sender.translation(in: view)
            let isScrollUpper = Int(transition.y) > 30
            let isScrollLower = Int(transition.y) < -30

            switch (autoScrollTimer.isValid, isScrollUpper, isScrollLower) {
            case (false, true, false):
                startAutoScroll(duration: 0.1, direction: .upper)
            case (false, false, true):
                startAutoScroll(duration: 0.1, direction: .under)
            default: break
            }
        case .ended:
            stopAutoScrollIfNeeded()
            tableView.isScrollEnabled = true
            tableView.isUserInteractionEnabled = true
        default: break
        }
    }

    private func startAutoScroll(duration: TimeInterval, direction: ScrollDirectionType) {
        var currentOffsetY = tableView.contentOffset.y
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            switch direction {
            case .upper:
                currentOffsetY = (currentOffsetY - 10 < 0) ? 0 : currentOffsetY - 10
                if currentOffsetY == 0 { self.stopAutoScrollIfNeeded() }
            case .under:
                let highLimit = self.tableView.contentSize.height - self.tableView.bounds.size.height
                currentOffsetY = (currentOffsetY + 10 > highLimit) ? highLimit : currentOffsetY + 10
                if currentOffsetY == highLimit { self.stopAutoScrollIfNeeded() }
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: duration * 2, animations: {
                    self.tableView.setContentOffset(CGPoint(x: 0, y: currentOffsetY), animated: false)
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
