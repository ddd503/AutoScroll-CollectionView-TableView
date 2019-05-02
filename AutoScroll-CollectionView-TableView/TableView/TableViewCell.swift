//
//  TableViewCell.swift
//  AutoScroll-CollectionView-TableView
//
//  Created by kawaharadai on 2019/05/02.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak private var label: UILabel!

    override func prepareForReuse() {
        contentView.backgroundColor = .white
    }

    func setText(_ text: String?) {
        label.text = text
    }

    func setBackgroundColor(_ color: UIColor) {
        contentView.backgroundColor = color
    }

}
