//
//  ViewController.swift
//  AeroCheck
//
//  Created by Ayush Bhople on 30/08/23.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var faultClass: UILabel!
    @IBOutlet weak var firstView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            firstView.image = userPickedImage
            
            let imageData = userPickedImage.jpegData(compressionQuality: 1)
            let fileContent = imageData?.base64EncodedString()
            let postData = fileContent!.data(using: .utf8)
            
            var request = URLRequest(url: URL(string: "https://detect.roboflow.com/aircraft-defects-lm9e3/3?api_key=_&name=YOUR_IMAGE.jpg")!,timeoutInterval: Double.infinity)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData
            
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in

                // Parse Response to String
                guard let data = data else {
                    print(String(describing: error))
                    return
                }

                // Convert Response String to Dictionary
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let predictions = json["predictions"] as? [[String: Any]],
                       let firstPrediction = predictions.first,
                       let classValue = firstPrediction["class"] as? String {
                        
                        print("Class: \(classValue)")
                        DispatchQueue.main.async {
                            self.faultClass.text = classValue
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                // print(String(data: data, encoding: .utf8)!)
            }).resume()
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

