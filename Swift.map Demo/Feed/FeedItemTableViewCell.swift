//  Swift.map Demo
//  Created by Maciej Matuszewski.

import UIKit

protocol FeedItemTableViewCellDelegate: class {
    func feedItemTableViewCell(_ feedItemTableViewCell: FeedItemTableViewCell, didDoubleTapWithGesture gestureRecognizer: UITapGestureRecognizer)
}

final class FeedItemTableViewCell: UITableViewCell {
    
    weak var delegate: FeedItemTableViewCellDelegate?

    let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let heartView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.0
        return imageView
    }()
    
    let smallHeartView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "heartSmall")
        imageView.isHidden = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addComponents()
        layoutComponents()
        addActions()
    }
    
    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.addTarget(self, action: #selector(onDoubleTap(_:)))
        return gestureRecognizer
    }()
    
    @available (*,unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        [photoView, heartView, smallHeartView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func addActions() {
        addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private func layoutComponents() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 300),
            
            photoView.topAnchor.constraint(equalTo: topAnchor),
            photoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            heartView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 60),
            heartView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            smallHeartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            smallHeartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
    
    override func prepareForReuse() {
        photoView.image = nil
    }
    
    @objc private func onDoubleTap(_ sender: UITapGestureRecognizer) {
        delegate?.feedItemTableViewCell(self, didDoubleTapWithGesture: sender)
    }
    
    func showHeartAnimation(markAsFavorite: Bool) {
        if markAsFavorite {
            heartView.image = UIImage(named: "heartLike")
            shake(view: heartView)
        } else {
            heartView.image = UIImage(named: "heartDislike")
        }
        show(view: heartView)
        smallHeartView.isHidden = !markAsFavorite
    }
    
    private func shake(view: UIView) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 10, -10, 10, -5, 5, -5, 0 ]
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
        animation.duration = 0.6
        animation.isAdditive = true
        view.layer.add(animation, forKey: "shake")
    }
    
    private func show(view: UIView) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "opacity"
        animation.values = [0, 1.0, 1.0, 0 ]
        animation.keyTimes = [0, 0.25, 0.75, 1]
        animation.duration = 0.6
        animation.isAdditive = true
        view.layer.add(animation, forKey: "show")
    }
}
