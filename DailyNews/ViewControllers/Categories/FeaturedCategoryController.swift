//
//  FeedViewController.swift
//  DailyNews
//
//  Created by Latif Atci on 3/3/20.
//  Copyright © 2020 Latif Atci. All rights reserved.
//

import UIKit
import SafariServices

class FeaturedCategoryController : UIViewController{
    
    
    let layout = UICollectionViewFlowLayout()
    var news : [THArticle] = []
    var headerNews : [THArticle] = []
    var collectionView : UICollectionView!
    let feedCellId = "feedCellId"
    let headerCellId = "headerCellId"
    var page = 2
    var hasMoreNews = true
    let activityIndicatorView = UIActivityIndicatorView(color: .black)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        view.addSubview(activityIndicatorView)
        activityIndicatorView.fillSuperview()
        fetchNews(page: page)
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGray5
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(SectionsCell.self, forCellWithReuseIdentifier: feedCellId)
        collectionView.register(SectionsPageHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellId)
        
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    func fetchNews(page : Int) {
        let dispatchGroup = DispatchGroup()
        var headerGroup : [THArticle] = []
        var group : [THArticle] = []
        activityIndicatorView.startAnimating()
        dispatchGroup.enter()
        
        FetchNews.shared.fetchData(THRequest(country: "us", category: .general, q: nil, pageSize: 10, page: page)) { (result) in
            dispatchGroup.leave()
            switch result {
            case .success(let news):
                if news.articles.count < 10 {
                    self.hasMoreNews = false
                }
                group.append(contentsOf: news.articles)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        
        dispatchGroup.enter()
        FetchNews.shared.fetchData(THRequest(country: "us", category: .general, q: nil, pageSize: 5, page: 1)) { (result) in
            dispatchGroup.leave()
            switch result {
            case .success(let news):
                headerGroup = news.articles
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.activityIndicatorView.stopAnimating()
            self.headerNews = headerGroup
            self.news.append(contentsOf: group)
            self.collectionView.reloadData()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMoreNews else {
                return
            }
            page += 1
            fetchNews(page : page)
        }
    }
    
}

extension FeaturedCategoryController : UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return .init(width: view.frame.width, height: view.frame.width / 1.2 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sf = SFSafariViewController(url: URL(string: news[indexPath.item].url)!)

        present(sf , animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellId, for: indexPath) as! SectionsPageHeader
        header.feedHeaderController.news = self.headerNews
        header.feedHeaderController.collectionView.reloadData()
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: view.frame.width / 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellId, for: indexPath) as! SectionsCell
        let article = news[indexPath.item]
        cell.news = article
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return news.count
    }
    
    
}
