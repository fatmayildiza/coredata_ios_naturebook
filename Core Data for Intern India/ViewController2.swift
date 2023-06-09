//
//  ViewController2.swift
//  Core Data for Intern India
//
//  Created by fyildiza on 6.06.2023.
//

import UIKit
import CoreData

class ViewController2: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
   
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    
    var targetName = ""
    var targetId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetName != "" {
            //core data verileri buraya gelir.
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Galeri")
            //filtreleme
            let idString = targetId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject]{
                    
                    if let name = result.value(forKey: "name") as? String{
                        nameTextField.text = name
                    }
                    if let place = result.value(forKey: "place")  as? String{
                        placeTextField.text = place
                    }
                    if let year = result.value(forKey: "year") as? Int {
                        yearTextField.text = String(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data{
                        let image = UIImage(data: imageData)
                        imageView.image = image
                    }
                    
                }
            }catch {
                print("error")
                
            }
        }

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    
    @objc func imageTap() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func saveClickedButton(_ sender: Any) {
        //veri kaydetme işlemi
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName:"Galeri", into: context)
        
        saveData.setValue(nameTextField.text!, forKey: "name")
        saveData.setValue(placeTextField.text!, forKey: "place")
        if let year = Int(yearTextField.text!){
            saveData.setValue(year, forKey: "year")
        }
        let imagePress = imageView.image?.jpegData(compressionQuality: 0.5)
        saveData.setValue(imagePress, forKey: "image")
        saveData.setValue(UUID(), forKey: "id")
        do{
            try context.save()
            print("Success")
        } catch {
            print("Error")
        }
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "fatmasflowers"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
