//
//  searchMoviesTableViewController.swift
//  Kiedy leci?
//
//  Created by Krzysztof Wolarz on 14/05/2019.
//  Copyright © 2019 Krzysztof Wolarz. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

struct Movie{
    var title: String
    var year: String
    var poster: UIImage
    var movieIndex: String
}

class searchMoviesTableViewCell: UITableViewCell {
    @IBOutlet var cellMoviePoster: UIImageView!
    @IBOutlet var cellMovieTitle: UILabel!
    @IBOutlet var cellMovieYear: UILabel!
    
}

class searchMoviesTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    @IBOutlet var searchBar: UISearchBar!
    
    var movies = [Movie]()
    private let movieURL = "https://www.omdbapi.com/?"
    private let apiKey = "1d16c6bb"
    var index = 0
    var page = 1
    var type = String()
    
    var timer = Timer()
    
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        searchBar.scopeButtonTitles = ["Wszystko", "Filmy", "Seriale"]
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        
        activityIndicator()
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Anuluj"
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 20, y: self.view.frame.height/2 - 200, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.gray
        //indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //indicator.stopAnimating()
        //indicator.hidesWhenStopped = true
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print(" ")
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("Wybrany kafelek: \(selectedScope)")
        if selectedScope == 1{
            type = "movie"
        } else if selectedScope == 2{
            type = "series"
        } else if selectedScope == 0{
            type = ""
        }
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(output), userInfo: searchBar.text, repeats: false)
        
        if searchBar.text != ""{
            searchBar.resignFirstResponder()
            //indicator.stopAnimating()
            //indicator.hidesWhenStopped = true
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(output), userInfo: searchText, repeats: false)
        
    }
    
    @objc func output(){
        
        index = 0
        if timer.userInfo != nil{
            indicator.startAnimating()
            indicator.backgroundColor = .white
            let searchMov = timer.userInfo as! String
            let finalSearchMov = searchMov.replacingOccurrences(of: " ", with: "+")
            let params = ["s": finalSearchMov, "apikey": apiKey, "p": String(page), "type": type]
            getMovies(url: movieURL, parameter: params)
            movies.removeAll()
            tableView.reloadData()

        }
        if timer.userInfo as! String == ""{
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
        }
        timer.invalidate()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 141
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Movie", for: indexPath) as! searchMoviesTableViewCell
        
        cell.cellMovieTitle.text = movies[indexPath.row].title
        cell.cellMovieYear.text = movies[indexPath.row].year
        cell.cellMoviePoster.image = movies[indexPath.row].poster
        
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController{
            detailVC.imdbID = movies[indexPath.row].movieIndex
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func getMovies(url: String, parameter: [String:String]){
        Alamofire.request(url, method: .get, parameters: parameter).responseJSON{ response in
            if(response.result.isSuccess){
                let movieJSON: JSON = JSON(response.result.value!)
                self.updateMovies(json: movieJSON)
            }
            else{
                print("ERROR \(String(describing: response.result.error))")
            }
            self.tableView.reloadData()
        }
    }
    
    func updateMovies(json: JSON){
        for _ in json["Search"]{
            
            var movPoster = UIImage(named: "noImage")
            
            let movTitle = ("\(json["Search"][index]["Title"].stringValue)")
            let movYear = ("\(json["Search"][index]["Year"].stringValue)")
            let movIndex = ("\(json["Search"][index]["imdbID"].stringValue)")
            
            //let moviePosterUrl = json["Search"][index]["Poster"].stringValue
            let moviePosterUrl2 = "http://img.omdbapi.com/?&apikey=1d16c6bb&i=\(movIndex)"
            
            if let url = URL(string: moviePosterUrl2){
                do{
                    let data = try Data(contentsOf: url)
                    movPoster = UIImage(data: data)
                } catch{
                    movPoster = UIImage(named: "noImage")
                }
            }
            let mov: Movie = Movie(title: movTitle, year: movYear, poster: movPoster!, movieIndex: movIndex)
            movies.append(mov)
            
            if index <= 8{
                index += 1
            }
        }
    }
}
