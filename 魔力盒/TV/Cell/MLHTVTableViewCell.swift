//
//  MLHTVTableViewCell.swift
//  魔力盒
//
//  Created by Haitang on 17/6/10.
//  Copyright © 2017年 Haitang. All rights reserved.
//

import UIKit

class MLHTVTableViewCell: UITableViewCell {

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func reloadDataWith(data:MLHFindMagicTVPosts){
        titleLabel.text = data.title
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
