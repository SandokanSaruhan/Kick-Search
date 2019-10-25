//
//  MasterViewController.swift
//  KickSearch
//
//  Created by Saruhan Kole on 27.06.2019.
//  Copyright © 2019 Peartree Developers. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // MARK: - Properties
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
  
  var detailViewController: DetailViewController? = nil
  var constants = [Constant]()
  var filteredConstants = [Constant]()
  let searchController = UISearchController(searchResultsController: nil)
    
  var sortValue : Bool = false
  var filterValue : Bool = false
    
  @IBOutlet var imageView: UIImageView!
    
  // MARK: - View Setup
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //internet Check
    checkInternet()
    
    // Setup the Search Controller
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Projects"
    navigationItem.searchController = searchController
    definesPresentationContext = true
    
    // Setup the Scope Bar
    searchController.searchBar.scopeButtonTitles = ["All", "Sort", "Filter"]
    searchController.searchBar.delegate = self
    
    // Setup the search footer
    tableView.tableFooterView = searchFooter
    
    if let splitViewController = splitViewController {
      let controllers = splitViewController.viewControllers
      detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    //Check Internet
    checkInternet()
    
    // Setup the Data
    fetchResultsFromApi()
    
    //Set Up UI Image
    let image = UIImage(named: "Swipe=Down")
    imageView = UIImageView(image: image!)
    imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    imageView.center = view.center
    view.addSubview(imageView)
    
    if splitViewController!.isCollapsed {
      if let selectionIndexPath = tableView.indexPathForSelectedRow {
        tableView.deselectRow(at: selectionIndexPath, animated: animated)
      }
    }
    super.viewWillAppear(animated)
  }
    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
    
  // MARK: Internet Check
  func checkInternet() {
    let status = Reach().connectionStatus()
        
        switch status{
            case .unknown, .offline:
                print("Not connected")
                //Set Up Alert
                SharedClass.sharedInstance.alert(view: self, title: "No Connection", message: "Check your internet")
            case .online(.wwan):
                print("Connected via WWAN")
            case .online(.wiFi):
                print("Connected via WiFi")
        }
  }
    
  // MARK: Fetch Data From Web API
  func fetchResultsFromApi() {
    
    self.constants = []
        
    guard let url = URL(string: "http://starlord.hackerearth.com/kickstarter") else { return }
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    guard let dataResponse = data, error == nil else {
        print(error?.localizedDescription ?? "Response Error")
    return }
        
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
            //print(jsonResponse)
                
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                return
            }
            //print(jsonArray)
                
            /*
            for dic in jsonArray{
                guard let title = dic["title"] as? String else { return }
                print(title)
            }
            */
                
            for dic in jsonArray{
                self.constants.append(Constant(dic)) // adding now value in Model array
            }
            //print(self.constants[20].backers) //
            
        } catch let parsingError {
            print("Error", parsingError)
        }
    }
    print(self.constants)
    tableView.reloadData()
    task.resume()
  }
  
  // MARK: - Table View
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
      searchFooter.setIsFilteringToShow(filteredItemCount: filteredConstants.count, of: self.constants.count)
      return filteredConstants.count
    }
    
    searchFooter.setNotFiltering()
    return self.constants.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let constant: Constant
    if isFiltering() {
      constant = filteredConstants[indexPath.row]
    } else {
      constant = self.constants[indexPath.row]
    }
    cell.textLabel!.text = constant.backers
    cell.textLabel!.text = String(format: "%@%@", "Number of backers: ", constant.backers)
    cell.detailTextLabel!.text = constant.title
    return cell
  }
  
  // MARK: - Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let constant: Constant
        if isFiltering() {
          constant = filteredConstants[indexPath.row]
        } else {
          constant = self.constants[indexPath.row]
        }
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.detailConstant = constant
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
    
 
  
  // MARK: - Private instance methods
  func filterContentForSearchText(_ searchText: String, scope: String = "") {
    
    // MARK: - Sort methods
    if (scope == "Filter"){
        if (filterValue == true){
            filterValue = false
            filteredConstants = self.constants.sorted(by: { $0.backers > $1.backers })
            searchController.searchBar.placeholder = "For search, select All"
        }
        else{
            filterValue = true
            filteredConstants = self.constants.sorted(by: { $0.backers < $1.backers })
            searchController.searchBar.placeholder = "For search, select All"
        } 
    }else if (scope == "Sort"){
        if (sortValue == true){
            sortValue = false
            filteredConstants = self.constants.sorted(by: { $0.title < $1.title })
            searchController.searchBar.placeholder = "For search, select All"
        }
        else{
            sortValue = true
            filteredConstants = self.constants.sorted(by: { $0.title > $1.title })
            searchController.searchBar.placeholder = "For search, select All"
        }
    }else{
        searchController.searchBar.placeholder = "Search Projects"
        
        filteredConstants = self.constants.filter({( constant : Constant) -> Bool in
            let doesTitleMatch = (scope == "All") || (constant.title == scope)
            
            if searchBarIsEmpty() {
                return doesTitleMatch
            }else {
                return doesTitleMatch && constant.title.lowercased().contains(searchText.lowercased())
            }
        })
    }
    
    //print (filteredConstants)
    tableView.reloadData()
  }
    
  func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  func isFiltering() -> Bool {
    let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
    return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
  }
}

extension MasterViewController: UISearchBarDelegate {
  // MARK: - UISearchBar Delegate
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
  }
}

extension MasterViewController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    
    imageView .removeFromSuperview()
  }
}
