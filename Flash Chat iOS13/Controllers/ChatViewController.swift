

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }
    func loadMessages(){
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { QuerySnapshot, error in
            self.messages = []
            if let e = error {
                print("There was an issue with retrieving data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = QuerySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        //print(data)
                        if let messageSender = data["sender"] as? String , let messageBody =  data["body"] as? String {//, let messageHeartRate =  data["heartRate"] as? Int, let messageBloodOxygenPercentage =  data["bloodOxygenPercentage"] as? Int, let messageHappinessIndex = data["happinessIndex"] as? Double {
                            
                            let newMessage = Message(sender: messageSender,
                                                     body: messageBody,
                                                     time: Date.init(),
                                                     heartRate: 0, //messageHeartRate,
                                                     bloodOxygenPercentage: 0,
                                                     happinessIndex: 0)
                            
                            //print("Here are the new message: \(newMessage)")
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data:
            [K.FStore.senderField : messageSender,
             K.FStore.bodyField : messageBody,
             K.FStore.dateField : Date().timeIntervalSince1970,
             K.FStore.bopField: Int.random(in: 94 ... 100),
             K.FStore.bpmField: Int.random(in: 50 ... 110),
             K.FStore.happinessIndex: ""
            ]) { (error) in
                if let e = error{
                    print("there's an error \(e)")
                } else {
                    print("sucessfully saved")
                    self.messageTextfield.text = ""
                }
                
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
    do {
        try firebaseAuth.signOut()
        navigationController?.popToRootViewController(animated: true)
    } catch let signOutError as NSError {
      print("Error signing out: %@", signOutError)
    }
        }
    
}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func numberToColor(number: Double) -> UIColor{
        var red = 0.0
        var green = 0.0
        let number = number * 100
        if (number >= 50) {
            red = 255
            green = (100 - number) * 2
        } else {
            red = number * 2
            green = 255 }
        let blue = 0
        return UIColor(red: CGFloat(green/225), green: CGFloat(red/225), blue: CGFloat(0), alpha: 1)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell

        let message = messages[indexPath.row]
        //let hapIndex = (message.happinessIndex)
//        print(numberToColor(number: hapIndex))
        cell.label.text = message.body;
        if (message.sender == Auth.auth().currentUser?.email) {
            cell.leftImageView.isHidden = true;
            cell.rightImageView.isHidden = false;
            cell.messageBubble.backgroundColor = UIColor(named: "BrandBlue")
            cell.label.textColor = UIColor.white;   
//            cell.rightResultBar.backgroundColor = numberToColor(number: hapIndex)
//            cell.leftResultBar.isHidden = true;
            return cell;
        } else {
            //let happinessIndex =
//            cell.leftResultBar.backgroundColor = numberToColor(number: hapIndex)
//            cell.rightResultBar.isHidden = true;
            cell.messageBubble.backgroundColor = UIColor.lightGray;
            cell.label.textColor = UIColor.black;
            cell.rightImageView.isHidden = true;
            cell.leftImageView.isHidden = false;
            return cell;
        }
    }
    
    
}
