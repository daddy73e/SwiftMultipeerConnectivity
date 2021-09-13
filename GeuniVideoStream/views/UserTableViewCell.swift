//
//  UserTableViewCell.swift
//  GeuniVideoStream
//
//  Created by Yeongeun Song on 2021/09/13.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var labelUserName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func config(user:User) {
        labelUserName.text = user.name
    }
}
