//
//  MessageTableViewCell.swift
//  GeuniVideoStream
//
//  Created by Yeongeun Song on 2021/09/13.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelId: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func config(msg:Message) {
        labelId.text = msg.id
        labelMessage.text = msg.message
    }
}
