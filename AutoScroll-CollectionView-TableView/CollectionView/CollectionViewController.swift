//
//  CollectionViewController.swift
//  AutoScroll-CollectionView-TableView
//
//  Created by kawaharadai on 2019/05/02.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit

enum ScrollDirectionType {
    case upper, under, left, right
}

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var numbers = [Int]()
    private let cellCount = 20
    private var autoScrollTimer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        numbers = (0 ..< cellCount).map { $0 }
        collectionView.dataSource = self
        collectionView.delegate = self
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        collectionView.addGestureRecognizer(gesture)
    }

    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = false
        case .changed:
            let transition = sender.translation(in: view)
            let isScrollLeft = Int(transition.x) < -30
            let isScrollRight = Int(transition.x) > 30
            
            switch (autoScrollTimer.isValid, isScrollLeft, isScrollRight) {
            case (false, true, false):
                startAutoScroll(duration: 1.0, direction: .left)
            case (false, false, true):
                startAutoScroll(duration: 1.0, direction: .right)
            default: break
            }
        case .ended:
            stopAutoScrollIfNeeded()
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
        default: break
        }
    }

    private func startAutoScroll(duration: TimeInterval, direction: ScrollDirectionType) {
        var indexPath = collectionView.indexPathsForVisibleItems.sorted { $0.item < $1.item }.first ?? IndexPath(item: 0, section: 0)
        let firstItem = IndexPath(item: 0, section: 0)
        let lastItem = IndexPath(item: collectionView.numberOfItems(inSection: 0) - 1, section: 0)
        var shouldFinish = false
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            switch direction {
            case .left:
                indexPath = (indexPath.item + 2 >= self.collectionView.numberOfItems(inSection: 0)) ? lastItem : IndexPath(item: indexPath.item + 2, section: 0)
                shouldFinish = indexPath.item == lastItem.item
            case .right:
                indexPath = (indexPath.item - 2 <= 0) ? firstItem : IndexPath(item: indexPath.item - 2, section: 0)
                shouldFinish = indexPath.item == firstItem.item
            default: break
            }
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                if shouldFinish { self.stopAutoScrollIfNeeded() }
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

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionViewCell.self), for: indexPath) as! CollectionViewCell
        cell.setText("\(numbers[indexPath.item])")
        if indexPath.item % 2 == 0 {
            cell.setBackgroundColor(.lightGray)
        }
        return cell
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = collectionView.frame.size.height
        return CGSize(width: length, height: length)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
