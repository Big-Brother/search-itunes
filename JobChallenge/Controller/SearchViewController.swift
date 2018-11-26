//
//  SearchViewController.swift
//  JobChallenge
//
//  Created by Big Brother on 25/11/2018.
//  Copyright © 2018 Big Brother. All rights reserved.
//

import UIKit
import Kingfisher

class resultTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    
}

class SearchViewController: UITableViewController  {

    @IBOutlet var sortButton: UIBarButtonItem!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var searching: Bool = false
    var search: [Search] = []
    var results: [Result] = []
    var sortPopoverViewController = PopOverViewController()
    
    var selectedResult: Int?
    let searchController = UISearchController(searchResultsController: nil)
    
    /**
     Presents a pop over view containing a menu of sort options.
     
     - Parameter sender: The sending object.
     */
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        self.sortPopoverViewController.modalPresentationStyle = .popover
        self.sortPopoverViewController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.sortPopoverViewController.popoverPresentationController?.permittedArrowDirections = .unknown
        self.sortPopoverViewController.popoverPresentationController?.delegate = self

        self.present(self.sortPopoverViewController, animated: true, completion: nil)
    }
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search iTunes"
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
        
        self.sortButton.isHidden = true

        searchController.searchBar.delegate = self
        searchController.isActive = true

        let sortArray = ["Duration: high > low", "Duration: low > high", "Genre: Asc", "Genre: Desc", "Price: high > low", "Price: low > high"]
        sortPopoverViewController.arrayListPopover = sortArray
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sortTableDidSelected), name: NSNotification.Name(rawValue: "click"), object: nil)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.editButtonItem
    }
    
    /**
     Sorts the search results.
     
     - Parameter scope: The option to sort boy.
     */
    func sortSearchContent(scope: Int) {
        switch scope {
        case 0:
            self.results = self.results.sorted(by: { $0.trackTimeMillis! > $1.trackTimeMillis! })
            break
        case 1:
            self.results = self.results.sorted(by: { $0.trackTimeMillis! < $1.trackTimeMillis! })
            break
        case 2:
            self.results = self.results.sorted(by: { $0.primaryGenreName! < $1.primaryGenreName! })
            break
        case 3:
            self.results = self.results.sorted(by: { $0.primaryGenreName! > $1.primaryGenreName! })
            break
        case 4:
            self.results = self.results.sorted(by: { $0.trackPrice! > $1.trackPrice! })
            break
        case 5:
            self.results = self.results.sorted(by: { $0.trackPrice! < $1.trackPrice! })
            break
        default:
            break
        }
        self.resultsTableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //print(search.resultCount)
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.results.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! resultTableViewCell
        if self.results.count > 0 {
            let resultItem = self.results[indexPath.row]
            //cell.textLabel!.text = resultItem.trackName! + " - By \(resultItem.artistName!)"
            
            cell.titleLabel?.text = resultItem.trackName!
            cell.artistLabel?.text = "By \(resultItem.artistName!)"
            
            // todo: create as helper
            let dateFormatter = DateFormatter()
            let tempLocale = dateFormatter.locale // save locale temporarily
            dateFormatter.locale = Locale(identifier: "en_EN_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            // release date string
            var releaseDateStr = ""
            if let releaseDate = resultItem.releaseDate {
                // todo: create as helper
                let date = dateFormatter.date(from: releaseDate)!
                dateFormatter.dateFormat = "MMM d, yyyy" ; //"dd-MM-yyyy HH:mm:ss"
                dateFormatter.locale = tempLocale // reset the locale --> but no need here
                releaseDateStr = "Released: \(dateFormatter.string(from: date))"
                //print("releaseDateStr: \(releaseDateStr)")
            }
            
            // genre string
            var genreStr = ""
            if let genre = resultItem.primaryGenreName {
                genreStr = " | genre: \(genre)"
            } else {
                genreStr = ""
            }
            
            cell.releaseLabel?.text = releaseDateStr + genreStr
            
            // album string
            if let album = resultItem.collectionName {
                cell.albumLabel?.text = album
            } else {
                cell.albumLabel?.text = ""
            }
            
            // price string
            var priceStr = ""
            if let trackPrice = resultItem.trackPrice {
                // todo: create currency enum
                priceStr = "Price: $\(trackPrice)"
            }
            
            // duration string
            var durationStr = ""
            if let trackTime = resultItem.trackTimeMillis {
                // todo create as helper
                let time = NSDate(timeIntervalSince1970: Double(trackTime) / 1000)
                let timeFormatter = DateFormatter()
                timeFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
                timeFormatter.dateFormat = "HH:mm:ss"
                
                durationStr = " | Duration: \(timeFormatter.string(from: time as Date))"
            }
            
            cell.priceLabel?.text = priceStr + durationStr
            
            // set thumbnail
            if let artURL = resultItem.artworkUrl100 {
                let photoUrl = URL(string: artURL)
                cell.thumbnail.kf.setImage(with: photoUrl, placeholder: UIImage(named: "placeholderImg"))
                
            }
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    // When user taps cell, play the local file, if it's downloaded
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedResult = indexPath.row //results[indexPath.row]
        //self.selectedResultIndex = indexPath.row
        performSegue(withIdentifier: "resultDetails", sender: cell)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ResultDetailsViewController
        {
            let vc = segue.destination as? ResultDetailsViewController
            //vc?.result = self.results[self.selectedResult!]
            vc?.results = self.results
            vc?.resultIndex = self.selectedResult!
        }
    }
    //MARK: UISearchbar delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searching = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searching = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.results = []
        self.sortButton.isHidden = true
        self.resultsTableView.reloadData()
        searching = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searching = false;
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.results = []
            self.sortButton.isHidden = true
            self.resultsTableView.reloadData()
        } else {
            self.sortButton.isHidden = false
        let term = searchText.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://itunes.apple.com/search?entity=song&limit=33&term=\(term)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            //Implement JSON decoding and parsing
            do {
                //Decode data with JSONDecoder
                var resultItems: [Result] = []
                let decoder = JSONDecoder()
                let searchData = try decoder.decode(Search.self, from: data)
                for item in searchData.results {
                    resultItems.append(item)
                }
                self.results = resultItems
                //Get back to the main queue
                DispatchQueue.main.async {
                    self.resultsTableView.reloadData()
                }
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
        }
    }

}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    // changed to popover
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // changed to popover
        print("searchBar.selectedScopeButtonIndex: \(searchBar.selectedScopeButtonIndex)")
    }
}

extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        _ = searchController.searchBar
       // let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        //sortSearchContent(scope: scope)
       //
    }
}
extension SearchViewController: UIPopoverPresentationControllerDelegate {
    // MARK: - UIPopoverPresentationController Delegate
    // MARK: - Sort Table
    /**
     Catches the selected option in the sort menu and triggers the sort function.
     
     - Parameter notification: Notification from the observer.
     */
    @objc func sortTableDidSelected(_ notification: Notification)
    {
        var indexpath: IndexPath? = (notification.object as? IndexPath)
        sortSearchContent(scope: (indexpath?.row)!)
        self.sortPopoverViewController.dismiss(animated: true, completion: nil)
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool
    {
        return true
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
}
public extension UIBarButtonItem {
    var isHidden: Bool {
        get {
            return tintColor == UIColor.clear
        }
        set(hide) {
            if hide {
                isEnabled = false
                tintColor = UIColor.clear
            } else {
                isEnabled = true
                tintColor = nil 
            }
        }
    }
}
