//
//  ScrollTableViewCell.swift
//  Jump
//
//  Created by nirvana on 2022/7/22.
//

import UIKit

class ScrollTableViewCell: UITableViewCell {

    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
