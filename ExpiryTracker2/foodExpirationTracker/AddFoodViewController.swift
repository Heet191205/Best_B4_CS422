//
//  AddFoodViewController.swift
//  foodExpirationTracker
//
//  Created by Mahir Patel on 8/8/25.
//

import UIKit
import CoreData
import UserNotifications

class AddFoodViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var categoryDisplayLabel: UILabel!
    @IBOutlet weak var productNameDisplayLabel: UILabel!
    
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var expirationDateTextField: UITextField!
    
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var productImageView: UIImageView! 

//MARK: - Core Data Managed Object Context
    private var managedContext: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError( "Could not load the AppDelegate." )
            
        }
        return appDelegate.persistentContainer.viewContext
    }
        
    let datePicker = UIDatePicker()
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    //  MARK: - Date Picker View Setup (NEW)
        func setupDatePicker() {
     
            datePicker.datePickerMode = .date
            
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            
            
            datePicker.minimumDate = Date()
            
           
            datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
            
            
            expirationDateTextField.inputView = datePicker
            
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
            toolbar.setItems([flexibleSpace, doneButton], animated: false)
            toolbar.isUserInteractionEnabled = true
            
           
            expirationDateTextField.inputAccessoryView = toolbar
            
            
            datePickerValueChanged()
        }
        
        
        @objc func doneDatePicker() {
            view.endEditing(true) // Dismiss the picker
        }
        
       
        @objc func datePickerValueChanged() {
            let dateFormatter = DateFormatter()
            // Set the desired date format for displaying in the text field
            dateFormatter.dateFormat = "dd/MM/yyyy" // Example: 09/08/2025
            expirationDateTextField.text = dateFormatter.string(from: datePicker.date)
        }

    let categories = ["Dairy", "Fruits", "Vegetables", "Meat & Poultry", "Seafood", "Grains & Bread", "Condiments", "Beverages", "Frozen Foods", "Other"]
    
    let categoryPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        foodNameTextField.addTarget(self, action: #selector(foodNameTextFieldDidChange), for: .editingChanged)
        setupCategoryPicker()
        setupDatePicker()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAndPickers))
                view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Update Display Labels (NEW)
        func updateDisplayLabels() {
            productNameDisplayLabel.text = foodNameTextField.text ?? "Food Item Name"
            categoryDisplayLabel.text = categoryTextField.text ?? "Category"
        }

        // MARK: - Actions for Text Field Changes (NEW)
        @objc func foodNameTextFieldDidChange(_ textField: UITextField) {
            updateDisplayLabels() // Update when food name changes
        }
    @objc func dismissKeyboardAndPickers() {
           view.endEditing(true)
       }
    func setupCategoryPicker() {
            categoryPickerView.delegate = self
            categoryPickerView.dataSource = self
            
            
            categoryTextField.inputView = categoryPickerView
            
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
            toolbar.setItems([doneButton], animated: false)
            toolbar.isUserInteractionEnabled = true
            
            categoryTextField.inputAccessoryView = toolbar
            
           
            if let initialCategory = categories.first {
                categoryTextField.text = initialCategory
                updateCategoryImage(for: initialCategory)
            }
        }
    @objc func donePicker() {
         view.endEditing(true)
     }
  
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func updateCategoryImage(for category: String) {
            let imageName = getImageName(for: category)
            productImageView.image = UIImage(named: imageName)
        }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return categories[row]
        }
        
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categories[row]
        updateDisplayLabels()
        updateCategoryImage(for: categories[row])
        }
    
    //MARK: - Save Food item Action
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let name = foodNameTextField.text, !name.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter the food name.")
                       return
        }
        
        guard let category = categoryTextField.text, !category.isEmpty else {
                    showAlert(title: "Missing Info", message: "Please select a category.")
                    return
                }
                guard let quantity = quantityTextField.text, !quantity.isEmpty else {
                    showAlert(title: "Missing Info", message: "Please enter the quantity.")
                    return
                }
                guard let expirationDateString = expirationDateTextField.text, !expirationDateString.isEmpty else {
                    showAlert(title: "Missing Info", message: "Please select an expiration date.")
                    return
                }
        
        let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                guard let expirationDate = dateFormatter.date(from: expirationDateString) else {
                    showAlert(title: "Invalid Date", message: "Please select a valid expiration date.")
                    return
                }
        
        
                guard let loggedInUserEmail = UserDefaults.standard.string(forKey: "loggedInUserEmail") else {
                    showAlert(title: "User Error", message: "No logged-in user found. Please re-login.")
                    return
                }
        let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "emailAddress == %@", loggedInUserEmail)
        
        do {
                    let users = try managedContext.fetch(userFetchRequest)
                    guard let currentUser = users.first else {
                        showAlert(title: "User Error", message: "Logged-in user not found in database. Please re-login.")
                        return
                    }
                    
                    //Creating a new food item object
                    let foodItem = FoodItem(context: managedContext)
                    foodItem.name = name
                    foodItem.category = category
                    foodItem.quantity = quantity
                    foodItem.expirationDate = expirationDate
                    foodItem.addedDate = Date() // Set the current date as the added date
                    
                        //setting an image name
                        if category == "Dairy" {
                            foodItem.imageName = "milk_icon"
                        } else if category == "Fruits" {
                            foodItem.imageName = "fruits_icon"
                        } else if category == "Vegetables" {
                            foodItem.imageName = "spinach_icon"
                        } else if category == "Meat & Poultry" {
                            foodItem.imageName = "meat_icon"
                        } else if category == "Seafood" {
                            foodItem.imageName = "seafood_icon"
                        } else if category == "Grains & Bread" {
                            foodItem.imageName = "bread_icon"
                        } else if category == "Condiments" {
                            foodItem.imageName = "condiments_icon"
                        } else if category == "Beverages" {
                            foodItem.imageName = "beverages_icon"
                        } else if category == "Frozen Foods" {
                            foodItem.imageName = "frozen_icon"
                        } else if category == "Other" {
                            foodItem.imageName = "other_icon"
                        } else {
                            foodItem.imageName = "default_food_icon"
                        }
                  
                    currentUser.addToFoodItems(foodItem)
                    
                   
                    try managedContext.save()
                    
                    print("Food item '\(name)' saved successfully for \(currentUser.fullName ?? currentUser.emailAddress ?? "user").")
            
                   
            scheduleNotification(for: foodItem)
                    
                   
                   
                    if let tabBarController = self.tabBarController {
                        tabBarController.selectedIndex = 0 // Switch to the Home tab
                    }
                   
                   
                    
                   
                    showAlert(title: "Success", message: "\(name) added successfully!")
                    
                } catch let error as NSError {
                    print("Could not save food item. \(error), \(error.userInfo)")
                    showAlert(title: "Save Error", message: "Could not save food item. Please try again.")
                }
    }
    
    private func showAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
    
    private func getImageName(for category: String) -> String {
            switch category {
            case "Dairy": return "milk_icon"
            case "Vegetables": return "spinach_icon"
            case "Fruits": return "fruits_icon"
            case "Meat & Poultry": return "meat_icon"
            case "Seafood": return "seafood_icon"
            case "Other": return "other_icon"
            case "Grains & Bread": return "bread_icon"
            case "Beverages": return "beverages_icon"
            case "Frozen Foods": return "frozen_icon"
            case "Condiments": return "condiments_icon"
                
            default: return "default_food_icon"
            }
        }
    
    func scheduleNotification(for foodItem: FoodItem){
        guard let expirationDate = foodItem.expirationDate, let foodName = foodItem.name else {
            print("Failed to schedule notification: Missing expiration date")
            return
        }
        
       
        let notificationDataComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: expirationDate)
        
        guard let dayBeforeExpiration = Calendar.current.date(from: notificationDataComponents) else {
            print("Failed to schedule notification: Failed to create date from components")
            return
        }
        
        var notificationComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        notificationComponents.hour = 9
        notificationComponents.minute = 0
        
        guard let finalNotificationDate = Calendar.current.date(from: notificationComponents) else {
            print("Failed to schedule notification: Failed to create date from components")
            return
        }
        if finalNotificationDate < Date() {
                    print("Notification date is in the past for \(foodName). Not scheduling.")
                    return
                }
        
       
        let content = UNMutableNotificationContent()
        content.title = "Food Expiring Soon! ⏰"
        content.body = "\(foodName) from \(foodItem.category ?? "your list")expires on \(expirationDate.formatted(date: .numeric, time: .omitted))." // Using new Date formatting
        content.sound = .default
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationComponents, repeats: false)
        
        let notificationIdentifier = "food_expiration_\(foodName)_\(expirationDate.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
                   if let error = error {
                       print("Error scheduling notification for \(foodName): \(error.localizedDescription)")
                   } else {
                       print("Notification scheduled for \(foodName) at \(finalNotificationDate). Identifier: \(notificationIdentifier)")
                   }
               }
    }
    
}
