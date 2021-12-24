//
//  PrivateChatListTableViewCell.swift
//  RxChat
//
//  Created by MoNireu on 2021/12/24.
//

import UIKit

class PrivateChatListTableViewCell: UITableViewCell {

    @IBOutlet var roomImageView: UIImageView!
    @IBOutlet var roomTitleLbl: UILabel!
    @IBOutlet var roomLastChatLbl: UILabel!
    @IBOutlet var roomLastChatTimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
