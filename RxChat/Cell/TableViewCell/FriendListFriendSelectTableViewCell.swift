//
//  FriendListFriendEditTableViewCell.swift
//  RxChat
//
//  Created by MoNireu on 2022/01/07.
//

import UIKit

class FriendListFriendSelectTableViewCell: FriendListFriendTableViewCell {

    @IBOutlet weak var radioBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
