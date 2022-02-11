//
//  GroupChatCollectionViewCell.swift
//  RxChat
//
//  Created by MoNireu on 2022/02/08.
//

import UIKit

class ChatSummaryGroupChatMemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var groupChatNameLabel: UILabel!
}

class ChatSummaryGroupChatOneMemberCollectionViewCell: ChatSummaryGroupChatMemberCollectionViewCell {
    @IBOutlet weak var groupChatImageView1: UIImageView!
}

class ChatSummaryGroupChatTwoMemberCollectionViewCell: ChatSummaryGroupChatMemberCollectionViewCell {
    @IBOutlet weak var groupChatImageView1: UIImageView!
    @IBOutlet weak var groupChatImageView2: UIImageView!
}

class ChatSummaryGroupChatThreeMemberCollectionViewCell: ChatSummaryGroupChatMemberCollectionViewCell {
    @IBOutlet weak var groupChatImageView1: UIImageView!
    @IBOutlet weak var groupChatImageView2: UIImageView!
    @IBOutlet weak var groupChatImageView3: UIImageView!
}

class ChatSummaryGroupChatFourMemberCollectionViewCell: ChatSummaryGroupChatMemberCollectionViewCell {
    @IBOutlet weak var groupChatImageView1: UIImageView!
    @IBOutlet weak var groupChatImageView2: UIImageView!
    @IBOutlet weak var groupChatImageView3: UIImageView!
    @IBOutlet weak var groupChatImageView4: UIImageView!
}
