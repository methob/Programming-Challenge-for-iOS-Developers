//
//  MediaFilesTableViewCell.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit

class MediaFilesTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imageName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
