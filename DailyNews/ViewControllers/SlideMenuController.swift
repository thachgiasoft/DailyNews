//
//  SwipeMenuController.swift
//  DailyNews
//
//  Created by Latif Atci on 3/31/20.
//  Copyright © 2020 Latif Atci. All rights reserved.
//

import UIKit

class SlideMenuController : UIViewController {
    
    var slideMenuTopView = UIView()
    var tableView : UITableView!
    let slideMenuCellId = "CellId"
    var sources : [ExpandedSources] = []
    var sourceCategories = ["General","Business","Entertainment","Health","Sports","Science"]
    
    var sourcesString = ""
    var sourceDelegate : SourcesViewControllerDelegate?
    let activityIndicatorView = UIActivityIndicatorView(color: .black)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTableView()
        configureTopView()
        view.addSubview(activityIndicatorView)
        activityIndicatorView.fillSuperview()
        fetchSources()
        
    }
    private func configureTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SlideMenuCell.self, forCellReuseIdentifier: slideMenuCellId)
        view.addSubview(tableView)
        
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: 150, left: 0, bottom: 0, right: 0))
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.rowHeight = 40
    }
    
    private func configureTopView() {
        view.addSubview(slideMenuTopView)
        slideMenuTopView.backgroundColor = .black
        
        slideMenuTopView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.leadingAnchor,size: .init(width: 0, height: 150))
    }
    
    
    
    
    
    func fetchSources() {
        let dispatchGroup = DispatchGroup()
        
        var generalGroup : [Sources] = []
        var businessGroup : [Sources] = []
        var entertainmentGroup : [Sources] = []
        var healthGroup : [Sources] = []
        var scienceGroup : [Sources] = []
        var sportsGroup : [Sources] = []
        activityIndicatorView.startAnimating()
        
        
        dispatchGroup.enter()
        FetchNews.shared.fetchSources(SRequest(category: .general, language: "en", country: nil)) { (result) in
            dispatchGroup.leave()
            switch result {
            case .success(let sourcesResponse):
                generalGroup.append(contentsOf: sourcesResponse.sources)
            case .failure(let err):
                print(err)
            }
            
        }
        dispatchGroup.enter()
        FetchNews.shared.fetchSources(SRequest(category: .business, language: "en", country: nil)) { (result) in
            dispatchGroup.leave()
            switch result {
            case .success(let sourcesResponse):
                businessGroup.append(contentsOf: sourcesResponse.sources)
            case .failure(let err):
                print(err)
            }
            
        }
        dispatchGroup.enter()
        FetchNews.shared.fetchSources(SRequest(category: .entertainment, language: "en", country: nil)) { (result) in
            dispatchGroup.leave()
            switch result {
            case .success(let sourcesResponse):
                entertainmentGroup.append(contentsOf: sourcesResponse.sources)
            case .failure(let err):
                print(err)
            }
            
        }
        dispatchGroup.enter()
        FetchNews.shared.fetchSources(SRequest(category: .health, language: "en", country: nil)) { (result) in
            dispatchGroup.leave()
            switch result {
            case .success(let sourcesResponse):
                healthGroup.append(contentsOf: sourcesResponse.sources)
            case .failure(let err):
                print(err)
            }
            
        }
        dispatchGroup.enter()
        FetchNews.shared.fetchSources(SRequest(category: .science, language: "en", country: nil)) { (result) in
            dispatchGroup.leave()
            switch result {
            case .success(let sourcesResponse):
                scienceGroup.append(contentsOf: sourcesResponse.sources)
            case .failure(let err):
                print(err)
            }
            
        }
        dispatchGroup.enter()
        FetchNews.shared.fetchSources(SRequest(category: .sports, language: "en", country: nil)) { (result) in
            dispatchGroup.leave()
            switch result {
            case .success(let sourcesResponse):
                sportsGroup.append(contentsOf: sourcesResponse.sources)
            case .failure(let err):
                print(err)
            }
            
        }
        
        dispatchGroup.notify(queue: .main) {
            self.activityIndicatorView.stopAnimating()
            self.sources.insert(ExpandedSources(isExpanded: false, sources: generalGroup), at: 0)
            self.sources.insert(ExpandedSources(isExpanded: false, sources: businessGroup), at: 1)
            self.sources.insert(ExpandedSources(isExpanded: false, sources: entertainmentGroup), at: 2)
            self.sources.insert(ExpandedSources(isExpanded: false, sources: healthGroup), at: 3)
            self.sources.insert(ExpandedSources(isExpanded: false, sources: sportsGroup), at: 4)
            self.sources.insert(ExpandedSources(isExpanded: false, sources: scienceGroup), at: 5)
            
            self.tableView.reloadData()
        }
        
        
    }
    
}

extension SlideMenuController : SlideMenuTableViewDelegate {
    
    func didSelectSlideMenuCell(cell: UITableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        let sourceId = sources[indexPath!.section].sources[indexPath!.row].id
        let sourceName = sources[indexPath!.section].sources[indexPath!.row].name
        sourcesString = sourceId
        let sourceVC = SourcesViewController()
        sourceVC.sourceId = sourceId
        sourceVC.sourceName = sourceName
        sourceDelegate?.pushToSourcesVC(source : sourceVC)
    }
}

extension SlideMenuController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !sources[section].isExpanded {
            return 0
        }
        
        return sources[section].sources.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sources.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: slideMenuCellId, for: indexPath) as! SlideMenuCell
        
        cell.sources = self.sources[indexPath.section].sources[indexPath.row]
        cell.selectionStyle = .none
        cell.slideDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleExpanding), for: .touchUpInside)
        button.tag = section
        
        let label = UILabel(text: sourceCategories[section], font: .boldSystemFont(ofSize: 16))
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        
        headerView.addSubview(stackView)
        stackView.anchor(top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, trailing: headerView.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 10))
        
        return headerView
    }
    
    @objc func handleExpanding(button : UIButton) {
        let section = button.tag
        
        var indexPaths = [IndexPath]()
        
        for row in sources[section].sources.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = sources[section].isExpanded
        sources[section].isExpanded = !isExpanded
        
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
            button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            
        }
        else {
            tableView.insertRows(at: indexPaths, with: .fade)
            button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            
        }
        
    }
}
