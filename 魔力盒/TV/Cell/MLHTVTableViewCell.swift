//
//  MLHTVTableViewCell.swift
//  MLH
//
//  Created by Haitang on 17/6/10.
//  Copyright © 2017年 Haitang. All rights reserved.
//

import UIKit
import YYKit
class MLHTVTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var shareNumberLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareNumberImage: UIImageView!
    @IBOutlet weak var commentNumberImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shareNumberImage.image = shareNumberImage.image?.getImage(tintColor: .white)
        commentNumberImage.image = commentNumberImage.image?.getImage(tintColor: .white)
    }
    func reloadDataWith(data:MLHFindMagicTVPosts){
        titleLabel.text = data.title
        commentNumberLabel.text = data.count_comment
        shareNumberLabel.text = data.count_share
        backImageView.setImageWith(URL(string: data.cover!), placeholder: nil)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
