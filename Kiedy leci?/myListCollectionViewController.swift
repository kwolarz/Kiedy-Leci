//
//  myListCollectionViewController.swift
//  Kiedy leci?
//
//  Created by Krzysztof Wolarz on 13/05/2019.
//  Copyright © 2019 Krzysztof Wolarz. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SDWebImage

class myListCollectionViewController: UICollectionViewController {
    //MARK: ustawianie zapisanych indexów z IMDB
     var savedMov = [String]()
    
    //MARK: Dane API
    private let movieURL = "https://www.omdbapi.com/?"
    private let apiKey = "1d16c6bb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: (self.collectionView.frame.size.width - 36)/3, height: (self.collectionView.frame.size.height + 60)/4.42)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController{
            detailVC.imdbID = savedMov[indexPath.item]
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savedMov = UserDefaults.standard.object(forKey: "Key") as? [String] ?? [String]()
        collectionView.reloadData()
    }
    
    //MARK: Obsługa Collection View
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedMov.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieOnMyList", for: indexPath) as! myListCollectionViewCell
//        let params = ["i": savedMov[indexPath.item], "apikey": apiKey]
//        Alamofire.request(movieURL, method: .get, parameters: params).responseJSON{ response in
//            let json = JSON(response.result.value!)
//            let moviePosterURL = json["Poster"].stringValue
//            let url = URL(string: moviePosterURL)3657
//
//            if let data = try? Data(contentsOf: url!){
//                cell.posterOnMyListImageView.image = UIImage(data: data)
//            } else{
//                cell.posterOnMyListImageView.image = UIImage(named: "noImage")
//            }
//        }
        
//        let moviePosterUrl = "http://img.omdbapi.com/?&apikey=1d16c6bb&i=\(savedMov[indexPath.item])"
//        let url = URL(string: moviePosterUrl)
//        if let data = try? Data(contentsOf: url!){
//            cell.posterOnMyListImageView.image = UIImage(data: data)
//        } else{
//            cell.posterOnMyListImageView.image = UIImage(named: "noImage")
//        }
        
        cell.posterOnMyListImageView.sd_setImage(with: URL(string: "http://img.omdbapi.com/?&apikey=1d16c6bb&i=\(savedMov[indexPath.item])"), placeholderImage: UIImage(named: "noImage"), options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
            return
        })
        
        
        //cell.layer.borderColor = UIColor.gray.cgColor
        //cell.layer.borderWidth = 0.5
    
        return cell
    }
}
