//  Swift.map Demo
//  Created by Maciej Matuszewski.

import UIKit

class FeedViewController: UIViewController {
    
    enum CellReuseIdentifier: String {
        case imageCell
    }
    
    private let apiClient: APIClient
    private let imageDownloader = ImageDownloader()
    
    private var currentPage = 0
    private var isFetching = false
    private var items: [FeedItem] = [] {
        didSet {
            update(tableView: tableView, oldItems: oldValue, newItems: items)
        }
    }
    
    private var favoriteItemsIndexPaths: [IndexPath] = [] {
        didSet {
            statsLabel.text = "❤️ \(favoriteItemsIndexPaths.count)"
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = nil
        tableView.register(FeedItemTableViewCell.self, forCellReuseIdentifier: CellReuseIdentifier.imageCell.rawValue)
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .clear
        return tableView
    }()
    
    private let statsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️ 0"
        return label
    }()
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        super.init(nibName: nil, bundle: nil)
    }
    
    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addComponents()
        layoutComponents()
        fetch()
    }
    
    private func addComponents() {
        [tableView, statsView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [statsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            statsView.addSubview($0)
        }
    }

    private func layoutComponents() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            statsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            statsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            statsLabel.topAnchor.constraint(equalTo: statsView.topAnchor, constant: 4),
            statsLabel.leadingAnchor.constraint(equalTo: statsView.leadingAnchor, constant: 4),
            statsLabel.trailingAnchor.constraint(equalTo: statsView.trailingAnchor, constant: -4),
            statsLabel.bottomAnchor.constraint(equalTo: statsView.bottomAnchor, constant: -4),
        ])
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[0]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier.imageCell.rawValue, for: indexPath) as! FeedItemTableViewCell
        cell.smallHeartView.isHidden = !favoriteItemsIndexPaths.contains(indexPath)
        cell.delegate = self
        imageDownloader.image(from: item.imageURL) { [weak cell] image in cell?.photoView.image = image }
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == items.count {
            fetch()
        }
    }
}

private extension FeedViewController {
    
    @objc func refresh() {
        favoriteItemsIndexPaths = []
        items = []
        currentPage = 0
        fetch()
    }
    
    func fetch() {
        guard !isFetching else { return }
        isFetching = true
        let nextPage = currentPage + 1
        apiClient.send(request: FeedRequest(page: nextPage)) { [weak self] (items: [FeedItem]?) in
            guard let self = self, let items = items else { return }
            self.items.append(contentsOf: items)
            self.currentPage = nextPage
            self.isFetching = false
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

private extension FeedViewController {
    private func update(tableView: UITableView, oldItems: [FeedItem], newItems: [FeedItem], sectionIndex: Int = 0) {
        
        var deletes = [Int]()
        var inserts = [Int]()
        var reloads = [Int]()
        
        oldItems.enumerated().forEach { offset, element in if !newItems.contains(element) { deletes.append(offset) } }
        newItems.enumerated().forEach { offset, element in
            if !oldItems.contains(element) { if deletes.contains(offset) { reloads.append(offset) } else { inserts.append(offset) } }
        }
        deletes = deletes.compactMap { if reloads.contains($0) { return nil } else { return $0 } }
        
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.deleteRows(at: deletes.map({ return IndexPath(row: $0, section: sectionIndex) }), with: .none)
            tableView.insertRows(at: inserts.map({ return IndexPath(row: $0, section: sectionIndex) }), with: .none)
            tableView.reloadRows(at: reloads.map({ return IndexPath(row: $0, section: sectionIndex) }), with: .none)
            tableView.endUpdates()
        }
    }
}

extension FeedViewController: FeedItemTableViewCellDelegate {
    func feedItemTableViewCell(_ feedItemTableViewCell: FeedItemTableViewCell, didDoubleTapWithGesture gestureRecognizer: UITapGestureRecognizer) {
        guard let indexPath = tableView.indexPath(for: feedItemTableViewCell) else { return }
        if favoriteItemsIndexPaths.contains(indexPath) {
            //Dislike
            favoriteItemsIndexPaths.removeAll { $0 == indexPath }
            feedItemTableViewCell.showHeartAnimation(markAsFavorite: false)
        } else {
            //Like
            favoriteItemsIndexPaths.append(indexPath)
            feedItemTableViewCell.showHeartAnimation(markAsFavorite: false)
        }
    }
}
