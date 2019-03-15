//  Swift.map Demo
//  Created by Maciej Matuszewski.

import UIKit

class FeedItemTableViewCell: UITableViewCell {

    let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addComponents()
        layoutComponents()
    }
    
    @available (*,unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [photoView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func layoutComponents() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 300),
            
            photoView.topAnchor.constraint(equalTo: topAnchor),
            photoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    override func prepareForReuse() {
        photoView.image = nil
    }
}
