//
//  ViewController.swift
//  ParkingMarker
//
//  Created by Jonathan Yee on 5/31/18.
//  Copyright © 2018 Jonathan Yee. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        loadTableViewData()
        view.backgroundColor = UIColor.lightGray
        tableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Variables
    let objectManager = ObjectManager()
    let locationManager = CLLocationManager()
    var hasLocation = false
    var editTrigger = false
    var editIP: IndexPath?
    var myCarsLocation: CLPlacemark?
    var locationMarker: CLLocationCoordinate2D?
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var locationArray: [Location] = []
    
    var titleTextField: UITextField?
    
    func titleTextField(textField: UITextField!) {
        titleTextField = textField
        titleTextField?.placeholder = "Location Title"
    }
    
    func okHandler(alert: UIAlertAction!){
        //Create the location with the passed data
        if editTrigger == false {
            //MARK: making a new object
            if hasLocation == true {
                getUserLocation()
                if locationMarker != nil {
                    objectManager.createLocation(marker: locationMarker!, title: (titleTextField?.text!)!)
                    loadTableViewData()
                }
            } else {
                print("Please wait while we find your location")
            }
        } else {
            //MARK: editing an existing object
            let objectToEdit = locationArray[editIP!.row]
            objectManager.editLocation(object: objectToEdit, title: (titleTextField?.text!)!)
            loadTableViewData()
        }
        editTrigger = false
    }
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addNewLocationButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Create New Location",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addTextField(configurationHandler: titleTextField)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: self.okHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    //Functions
    func getUserLocation() {
        print("## getUserLocation ##")
        let longitude: CLLocationDegrees = (locationManager.location?.coordinate.longitude)!
        let latitude: CLLocationDegrees = (locationManager.location?.coordinate.latitude)!
        let location = CLLocation(latitude: latitude, longitude: longitude)
        locationMarker = CLLocationCoordinate2DMake(latitude, longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("There was an error")
                return
            }
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0]
                self.myCarsLocation = pm
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! MapViewController
        controller.carLocation = sender as? Location
    }
    
    //CLLocation Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if hasLocation == false {
            hasLocation = true
            print("We has your location")
        }
    }
    
    //TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = 55
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
        cell.label.text = locationArray[indexPath.row].title
        return cell
    }
    
    func loadTableViewData(){
        print("## loadTableViewData ##")
        locationArray = objectManager.fetchAllLocation()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationToPass = locationArray[indexPath.row]
        performSegue(withIdentifier: "segueToMap", sender: locationToPass)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }

    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") {_,_,_ in
            print("## editAction ##")
            self.editTrigger = true
            self.editIP = indexPath
            let alertController = UIAlertController(title: "Input New Name",
                                                    message: nil,
                                                    preferredStyle: .alert)
            alertController.addTextField(configurationHandler: self.titleTextField)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: self.okHandler)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        }
        action.backgroundColor = UIColor.purple
        return action
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete"){_,_,_ in
            print("## deleteAction ##")
            let locationToDelete = self.locationArray[indexPath.row]
            self.objectManager.deleteLocation(location: locationToDelete)
            self.loadTableViewData()
        }
        action.backgroundColor = UIColor.red
        return action
    }
}//End Class

