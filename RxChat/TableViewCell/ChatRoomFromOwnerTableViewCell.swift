//
//  ChatRoomFromOwnerTableViewCell.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/15.
//

import UIKit

class ChatRoomFromOwnerTableViewCell: UITableViewCell {

    @IBOutlet weak var chatBubbleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chatBubbleBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatBubbleBackgroundView.backgroundColor = .systemGray6
        chatBubbleBackgroundView.setCornerRadius(value: 0.03)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
