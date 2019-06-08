//
//  DetailViewController.swift
//  Kiedy leci?
//
//  Created by Krzysztof Wolarz on 14/05/2019.
//  Copyright © 2019 Krzysztof Wolarz. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct DetailMovie{
    var title: String
    var released: String
    var director: String
    var actors: String
    var plot: String
    var poster: UIImage
    var rating: String
    var type: String
}

struct NextEpisode{
    var season: String
    var number: String
    var airdate: String
    var airtime: String
}

class DetailViewController: UIViewController {
    
    //Podłączanie pól tekstowych z interfejsu oraz plakatu
    @IBOutlet var detailPosterImageView: UIImageView!
    @IBOutlet var detailTitleLabel: UILabel!
    @IBOutlet var detailReleasedLabel: UILabel!
    @IBOutlet var detailDirectorLabel: UILabel!
    @IBOutlet var detailRatingLabel: UILabel!
    @IBOutlet var detailPlotLabel: UILabel!
    @IBOutlet var detailActorsLabel: UILabel!
    @IBOutlet var detailTypeLabel: UILabel!
    
    @IBOutlet var nextEpisodeLabel: UILabel!
    @IBOutlet var nextEpisodeNumber: UILabel!
    @IBOutlet var nextEpisodeDate: UILabel!
    
    @IBOutlet var addMovieButton: UIBarButtonItem!
    
    //tworzenie zapisu do pliku
    let defaults = UserDefaults.standard
    
    //tworzenie animacji łdowania się interfejsu
    var indicator = UIActivityIndicatorView()
    var loadingView = UIView()
    
    //parametry filmu
    var isAdded = false
    var imdbID: String = ""
    var tvMazeID: String = ""
    
    private let tvMazeIDURL = "http://api.tvmaze.com/lookup/shows?imdb="
    var nextEpisode: NextEpisode = NextEpisode(season: "", number: "", airdate: "", airtime: "")
    var movie: DetailMovie = DetailMovie(title: "", released: "", director: "", actors: "", plot: "", poster: UIImage(named: "noImage")!, rating: "", type: "")
    private let movieURL = "https://www.omdbapi.com/?"
    private let apiKey = "1d16c6bb"

    override func viewDidLoad() {
        super.viewDidLoad()
        addLoadingView()
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
        setIcon()
        // Do any additional setup after loading the view.
        let params = ["i": imdbID, "apikey": apiKey, "plot": "full"]
        getMovie(url: movieURL, parameter: params)
        print(movie.type)
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 20, y: self.view.frame.height/2 - 200, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(indicator)
    }
    
    func addLoadingView(){
        loadingView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        loadingView.backgroundColor = UIColor.white    //give color to the view
        loadingView.center = self.view.center
        self.view.addSubview(loadingView)
    }
    
    
    @IBAction func addMovieButtonPressed(_ sender: UIBarButtonItem) {
        var saved = defaults.object(forKey: "Key") as! [String]
        if saved.contains(imdbID) == false{
            saved.append(imdbID)
        } else {
            if let index = saved.firstIndex(of: imdbID) {
                saved.remove(at: index)
            }
        }
        
        defaults.set(saved, forKey: "Key")
        setIcon()
        print(saved.count)
    }
    
    func getMovie(url: String, parameter: [String:String]){
        Alamofire.request(url, method: .get, parameters: parameter).responseJSON{ response in
            if response.result.isSuccess{
                let json = JSON(response.result.value!)
                self.updatePoster(json: json)
                self.updateLabels(json: json)
                self.setInterfaceElements()
            }
            else{
                print("ERROR \(String(describing: response.result.error))")
            }
        }
    }
    
    func updatePoster(json: JSON){
        let moviePosterURL = json["Poster"].stringValue
        let url = URL(string: moviePosterURL)
        var poster = UIImage(named: "noImage")
        if let data = try? Data(contentsOf: url!){
            poster = UIImage(data: data)
        }
        movie.poster = poster!
    }
    
    func updateLabels(json: JSON){
        movie.title = json["Title"].stringValue
        movie.released = json["Released"].stringValue
        movie.director = json["Director"].stringValue
        movie.actors = json["Actors"].stringValue
        movie.plot = json["Plot"].stringValue
        movie.rating = json["imdbRating"].stringValue
        movie.type = json["Type"].stringValue
        loadingView.isHidden = true
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
        if movie.type == "series"{
            getTVMazeID(url: tvMazeIDURL + imdbID)
        } else{
            nextEpisodeLabel.isHidden = true
            nextEpisodeNumber.isHidden = true
            nextEpisodeDate.isHidden = true
        }
    }
    
    func setInterfaceElements(){
        detailPosterImageView.image = movie.poster
        detailTitleLabel.text = movie.title
        detailReleasedLabel.text = movie.released
        detailDirectorLabel.text = movie.director
        detailRatingLabel.text = movie.rating
        detailPlotLabel.text = movie.plot
        detailActorsLabel.text = movie.actors
        detailTypeLabel.text = movie.type
    }
    
    func getTVMazeID(url: String){
        Alamofire.request(url, method: .get).responseJSON{ response in
            if response.result.isSuccess{
                let json = JSON(response.result.value!)
                self.tvMazeID = json["id"].stringValue
                self.getNextEpisode(url: "http://api.tvmaze.com/shows/\(self.tvMazeID)?embed=nextepisode")
            } else {
                print(response.result.error!)
            }
        }
    }
    
    func getNextEpisode(url: String){
        Alamofire.request(url, method: .get).responseJSON{ response in
            let json = JSON(response.result.value!)
            self.nextEpisode.season = json["_embedded"]["nextepisode"]["season"].stringValue
            self.nextEpisode.number = json["_embedded"]["nextepisode"]["number"].stringValue
            self.nextEpisode.airdate = json["_embedded"]["nextepisode"]["airdate"].stringValue
            self.nextEpisode.airtime = json["_embedded"]["nextepisode"]["airtime"].stringValue
            self.setNextEpisodeLabels()
        }
    }
    
    func setNextEpisodeLabels(){
        nextEpisodeNumber.text = "S0\(nextEpisode.season)E0\(nextEpisode.number)"
        nextEpisodeDate.text = "\(nextEpisode.airdate) o godz. \(nextEpisode.airtime) GMT-4"
    }
    
    func setIcon(){
        let saved = defaults.object(forKey: "Key") as! [String]
        if saved.contains(imdbID) == false{
            let buttonIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addMovieButtonPressed(_:)))
            self.navigationItem.rightBarButtonItem = buttonIcon
        } else {
            let buttonIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(addMovieButtonPressed(_:)))
            self.navigationItem.rightBarButtonItem = buttonIcon
        }
    }
}
