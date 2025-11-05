//
//  HomeScreenViewController.swift
//  foodExpirationTracker
//
//  Created by Mahir Patel on 8/7/25.
//

import UIKit
import CoreData
import UserNotifications
class HomeScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    // MARK: - IBOutlets for Summary Cards (UIViews)
    @IBOutlet weak var cardView3: UIView!
    @IBOutlet weak var cardView2: UIView!
    @IBOutlet weak var cardView1: UIView!
    
   
    @IBOutlet weak var totalItemsCountLabel: UILabel!
    @IBOutlet weak var expiredCountLabel: UILabel!
    @IBOutlet weak var expiringCountLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var quoteLabel: UILabel!
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    private let quotes: [String] = [
        "Wasting food is stealing from the hungry. – Pope Francis",
                "Destroying food is profound disregard for humanity.",
                "Don't waste food. Live simply, so others may live.",
                "Food waste: a waste of water, land, and energy.",
                "We are trashing our land to grow food no one eats. – Tristram Stuart",
                "Food waste's carbon footprint exceeds airlines'. – Sarah Kaplin",
                "If food waste were a country, it'd be third in emissions. – Inger Andersen",
                "40% of our food production goes to waste. – Anthony Bourdain",
                "Food waste is the most unsustainable thing. – Tristram Stuart",
                "Food waste: profit over people and planet. – Chef Dan Barber",
                "Many don't see food waste as a problem. – Jonathan Bloom",
                "Wasting food isn't taboo, it's a last environmental ill. – Jonathan Bloom",
                "Cut food waste: save money, feed the world, protect the planet. – Tristram Stuart",
                "Wasting food is like dropping a bag of groceries and leaving it. – Dana Gunders",
                "There's food for everyone, but not everyone eats. – Carlo Petrini",
                "Eat what you buy. Don’t waste. – Chef José Andrés",
                "It either goes in your mouth or in your trash. – Geneen Roth",
                "There is no such thing as ‘away’. – Annie Leonard",
                "Respect for food is respect for life. – Thomas Keller",
                "Starve once, think twice about wasting food. – Criss Jami"
     ]
     
     private var quoteTimer: Timer?
    var fetchedFoodItems: [FoodItem] = [] {
       
        didSet {
            updateSummaryCards() // Call this after food items are fetched or deleted
        }
    }
    
    private var managedContext: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get appDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        applyCardStyling(to: cardView1)
        applyCardStyling(to: cardView2)
        applyCardStyling(to: cardView3)
        
        updateGreeting()
        fetchFoodItems()
        requestNotificationPermission()
        
        displayRandomQuote()
        startQuoteTimer()
    }
   
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           fetchFoodItems()
        stopQuoteTimer()
       }
    
    // MARK: - Quote Management
        
        // Displays a random quote from the 'quotes' array in the quoteLabel
        private func displayRandomQuote() {
            guard !quotes.isEmpty else {
                quoteLabel.text = "No quotes available."
                return
            }
            let randomIndex = Int(arc4random_uniform(UInt32(quotes.count)))
            quoteLabel.text = quotes[randomIndex]
            quoteLabel.numberOfLines = 0
            quoteLabel.textAlignment = .center
            print("Displayed quote: \(quotes[randomIndex])")
        }
        
        
        private func startQuoteTimer() {
           
            stopQuoteTimer()
            
           
            quoteTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
                self?.displayRandomQuote()
            }
            print("Quote timer started.")
        }
        
        
        private func stopQuoteTimer() {
            quoteTimer?.invalidate()
            quoteTimer = nil
            print("Quote timer stopped.")
        }
    
    // MARK: - Profile Button Tapped
        @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) { // Ensure sender is UIBarButtonItem
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            
            let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
                self?.performLogout()
            }
            alertController.addAction(logoutAction)
            
           
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
        
        
        private func performLogout() {
          
            UserDefaults.standard.removeObject(forKey: "loggedInUserEmail")
            print("User data cleared from UserDefaults.")
            
            
            managedContext.reset()
            
           
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
                print("Error: Could not find key window for logout transition.")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? loginViewController else { // Ensure your LoginViewController has this Storyboard ID
                print("Error: Could not instantiate LoginViewController from storyboard.")
                return
            }
            
            
            window.rootViewController = loginViewController
            
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
            
            print("User logged out. Navigating to Login screen.")
        }

    
    //MARK: - Notification Permission Request
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notification permission granted.")
            }else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
            else {
                print("Notification permission denied.")
            }
        }
    }
    // MARK: - Update Greeting Method
    func updateGreeting() {
        guard let loggedInUserEmail = UserDefaults.standard.string(forKey: "loggedInUserEmail") else {
            greetingLabel.text = "Hello! 👋"
            print("No logged-in user email found in UserDefaults")
            return
        }
        let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "emailAddress == %@", loggedInUserEmail)

        do {
            let users = try managedContext.fetch(userFetchRequest)
            if let currentUser = users.first {
                let userName = currentUser.fullName ?? currentUser.emailAddress ?? "user"
                greetingLabel.text = "Hello, \(userName)! 👋"
                print("Greeting updated for user: \(userName)")
            } else {
                greetingLabel.text = "Hello, Guest! 👋"
                print("Logged-in user not found in Core Data for greeting.")
            }
        } catch let error as NSError {
            greetingLabel.text = "Hello! 👋"
            print("Error fetching user for greeting: \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Update Summary Cards Method
    func updateSummaryCards() {
        let today = Calendar.current.startOfDay(for: Date())
        
       
        let totalItems = fetchedFoodItems.count
        let expiredItems = fetchedFoodItems.filter { ($0.expirationDate ?? Date.distantFuture) < today }.count
        let expiringItems = fetchedFoodItems.filter {
            let expirationDay = Calendar.current.startOfDay(for: $0.expirationDate ?? Date.distantFuture)
            let daysUntilExpiration = Calendar.current.dateComponents([.day], from: today, to: expirationDay).day ?? 0
            return daysUntilExpiration >= 0 && daysUntilExpiration <= 3 // Including today and up to 3 days
        }.count
        
        
        totalItemsCountLabel.text = "\(totalItems)"
        expiredCountLabel.text = "\(expiredItems)"
        expiringCountLabel.text = "\(expiringItems)"
        
        print("Summary counts updated: Total=\(totalItems), Expired=\(expiredItems), Expiring=\(expiringItems)")
    }

    // MARK: - Data Fetching Method
    func fetchFoodItems() {
        guard let loggedInUserEmail = UserDefaults.standard.string(forKey: "loggedInUserEmail") else {
            print("No logged-in user email found in UserDefaults for food items.")
            fetchedFoodItems = []
            tableView.reloadData()
            return
        }
        
        let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "emailAddress == %@", loggedInUserEmail)
        
        do {
            let users = try managedContext.fetch(userFetchRequest)
            guard let currentUser = users.first else {
                print("Logged-in user not found in Core Data for food items: \(loggedInUserEmail)")
                fetchedFoodItems = [] // This will trigger didSet
                tableView.reloadData()
                return
            }

            if let userFoodItems = currentUser.foodItems as? Set<FoodItem> {
                fetchedFoodItems = userFoodItems.sorted { item1, item2 in
                    guard let date1 = item1.expirationDate else { return false }
                    guard let date2 = item2.expirationDate else { return true }
                    return date1 < date2
                }
                print("Fetched \(fetchedFoodItems.count) food items for user \(loggedInUserEmail)")
            } else {
                fetchedFoodItems = [] // This will trigger didSet
                print("No food items found for user \(loggedInUserEmail).")
            }
            
            tableView.reloadData()

        } catch let error as NSError {
            print("Error fetching user or food items: \(error), \(error.userInfo)")
            fetchedFoodItems = [] // This will trigger didSet
            tableView.reloadData()
        }
    }
    
   // helper function
    private func applyCardStyling(to cardView: UIView?) {
        if let cv = cardView {
            cv.layer.cornerRadius = 10
            cv.layer.shadowColor = UIColor.black.cgColor
            cv.layer.shadowOpacity = 0.2
            cv.layer.shadowOffset = CGSize(width: 0, height: 2)
            cv.layer.shadowRadius = 3
            cv.layer.masksToBounds = false
            cv.backgroundColor = .white
        }
    }

    // MARK: - UITableViewDataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedFoodItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemCellTableViewCell", for: indexPath) as? FoodItemCellTableViewCell else {
            fatalError("Failed to dequeue FoodItemCellTableViewCell. Check Identifier and Class in Storyboard.")
        }
        
        let foodItem = fetchedFoodItems[indexPath.row]
        
        cell.productName.text = foodItem.name
        cell.productCategory.text = foodItem.category
        cell.productQuantity.text = foodItem.quantity
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        cell.productExpirationDate.text = "Expires \(dateFormatter.string(from: foodItem.expirationDate ?? Date()))"

        let status = getExpirationStatus(for: foodItem.expirationDate ?? Date())
        cell.productExpirationStatus.text = status.text
        
        cell.productImage.image = UIImage(named: foodItem.imageName ?? "") ?? UIImage(systemName: "questionmark.circle.fill")

        cell.productExpirationStatus.backgroundColor = status.backgroundColor
        cell.productExpirationStatus.textColor = status.textColor
        cell.productExpirationStatus.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        return cell
    }

    private func getExpirationStatus(for date: Date) -> (text: String, backgroundColor: UIColor, textColor: UIColor) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expirationDay = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: today, to: expirationDay)
        let daysUntilExpiration = components.day ?? 0

        if daysUntilExpiration < 0 {
            let daysAgo = abs(daysUntilExpiration)
            return ("Expired \(daysAgo) day\(daysAgo == 1 ? "" : "s") ago", .systemRed, .white)
        } else if daysUntilExpiration == 0 {
            return ("Expires Today!", .systemOrange, .white)
        } else if daysUntilExpiration <= 3 {
            return ("Expiring in \(daysUntilExpiration) day\(daysUntilExpiration == 1 ? "" : "s")", .systemOrange, .white)
        } else {
            return ("Fresh", .systemGreen, .white)
        }
    }

    // MARK: - UITableViewDelegate (remains the same)

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped on food item: \(fetchedFoodItems[indexPath.row].name ?? "Unknown Item")")
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - Swipe to Delete Implementation
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = fetchedFoodItems[indexPath.row]
            let notificationIdentifier = "food_expiration_\(itemToDelete.name ?? "")_\(itemToDelete.expirationDate?.timeIntervalSince1970 ?? 0.0)"
            managedContext.delete(itemToDelete)
            
            do {
                try managedContext.save()
                print("Successfully deleted item from Core Data.")
                
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
                fetchedFoodItems.remove(at: indexPath.row)
                
             
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            } catch let error as NSError {
                print("Error deleting item from Core Data: \(error), \(error.userInfo)")
                let alert = UIAlertController(title: "Error", message: "Could not delete item. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                tableView.reloadData()
            }
        }
    }
}
