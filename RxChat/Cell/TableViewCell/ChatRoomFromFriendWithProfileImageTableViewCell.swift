//
//  ChatRoomFromFriendWithProfileImageTableViewCell.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/17.
//

import UIKit

class ChatRoomFromFriendWithProfileImageTableViewCell: UITableViewCell {

    @IBOutlet weak var chatBubbleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chatBubbleBackgroundView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatBubbleBackgroundView.backgroundColor = .systemGray4
        chatBubbleBackgroundView.setCornerRadius(value: 0.03)
        profileImage.setCornerRadius(value: 0.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
