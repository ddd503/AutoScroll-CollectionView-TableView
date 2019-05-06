//
//  CollectionViewController.swift
//  AutoScroll-CollectionView-TableView
//
//  Created by kawaharadai on 2019/05/02.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit

enum ScrollDirectionType {
    case upper, under
}

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var numbers = [Int]()
    private let cellCount = 100
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
        case .changed:
            // 指の移動位置を見てstart or stop
            let transition = sender.translation(in: view)
            let isScrollUpper = Int(transition.y) > 30
            let isScrollLower = Int(transition.y) < -30

            switch (autoScrollTimer.isValid,
                    isScrollUpper,
                    isScrollLower) {
            case (false, true, false):
                startAutoScroll(duration: 0.1, direction: .upper)
            case (false, false, true):
                startAutoScroll(duration: 0.1, direction: .under)
            default: break
            }
        case .ended:
            stopAutoScrollIfNeeded()
        default: break
        }
    }

    private func startAutoScroll(duration: TimeInterval, direction: ScrollDirectionType) {
        var currentOffsetY = collectionView.contentOffset.y
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            switch direction {
            case .upper:
                currentOffsetY = (currentOffsetY - 10 < 0) ? 0 : currentOffsetY - 10
                if currentOffsetY == 0 { self.stopAutoScrollIfNeeded() }
            case .under:
                let highLimit = self.collectionView.contentSize.height - self.collectionView.bounds.size.height
                currentOffsetY = (currentOffsetY + 10 > highLimit) ? highLimit : currentOffsetY + 10
                if currentOffsetY == highLimit { self.stopAutoScrollIfNeeded() }
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: duration * 2, animations: {
                    self.collectionView.setContentOffset(CGPoint(x: 0, y: currentOffsetY), animated: false)
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
        let length = collectionView.frame.size.width / 3
        return CGSize(width: length, height: length)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
