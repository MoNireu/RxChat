//
//  FriendListTableViewCell.swift
//  RxChat
//
//  Created by MoNireu on 2021/08/03.
//

import UIKit

class FriendListMyTableViewCell: UITableViewCell {

    @IBOutlet weak var myProfileImageView: UIImageView!
    @IBOutlet weak var myProfileName: UILabel!
    @IBOutlet weak var myProfileStatMsg: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        myProfileImageView.clipsToBounds = true
        myProfileImageView.layer.cornerRadius = myProfileImageView.frame.size.width * 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
