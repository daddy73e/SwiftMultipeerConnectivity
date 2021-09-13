//
//  RootTableViewCell.swift
//  GeuniVideoStream
//
//  Created by Yeongeun Song on 2021/09/13.
//

import UIKit

class RootTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    private var item:RootItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func config(item:RootItem) {
        labelTitle.text = item.name
    }

}
