//
//  MessageTableMyViewCell.swift
//  GeuniVideoStream
//
//  Created by Yeongeun Song on 2021/09/14.
//

import UIKit

class MessageTableMyViewCell: UITableViewCell {

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
        labelId.text = msg.displayName
        labelMessage.text = msg.message
    }

}
