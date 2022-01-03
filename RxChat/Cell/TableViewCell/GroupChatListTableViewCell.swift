//
//  GroupChatListTableViewCell.swift
//  RxChat
//
//  Created by MoNireu on 2022/01/03.
//

import UIKit

class GroupChatListTableViewCell: UITableViewCell {
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


class GroupChatListOneMemberTableViewCell: GroupChatListTableViewCell {
    @IBOutlet var memberOneImageView: UIImageView!
}

class GroupChatListTwoMemberTableViewCell: GroupChatListTableViewCell {
    @IBOutlet var memberOneImageView: UIImageView!
    @IBOutlet var memberTwoImageView: UIImageView!
}

class GroupChatListThreeMemberTableViewCell: GroupChatListTableViewCell {
    @IBOutlet var memberOneImageView: UIImageView!
    @IBOutlet var memberTwoImageView: UIImageView!
    @IBOutlet var memberThreeImageView: UIImageView!
}

class GroupChatListFourMemberTableViewCell: GroupChatListTableViewCell {
    @IBOutlet var memberOneImageView: UIImageView!
    @IBOutlet var memberTwoImageView: UIImageView!
    @IBOutlet var memberThreeImageView: UIImageView!
    @IBOutlet var memberFourImageView: UIImageView!
}
