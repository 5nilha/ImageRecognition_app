//
//  ViewController.swift
//  ImageRecognition
//
//  Created by Fabio Quintanilha on 12/1/17.
//  Copyright © 2017 Fabio Quintanilha. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let apikey = "9da26cdb02b31c6cdebc77e5f85bc20233dcb516"
    let version = "2017-12-02"
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }


    
    //---------------- Image classification -------------------------
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognitionImage = VisualRecognition(apiKey: apikey, version: version)
            
            let imageCompressed = UIImageJPEGRepresentation(image, 0.01)  // Compress the image to 1% of the original size
            
            // gets an URL to the Document Directory
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            //creates a file URL to Changes the imageCompressed to an URL
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            //Writes the image to the file URL
            try? imageCompressed?.write(to: fileURL, options: [])
        
            visualRecognitionImage.classify(imageFile: fileURL, success: { (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    
                    self.classificationResults.append(classes[index].classification)
                    
                }
                print(self.classificationResults)
                
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
                
                if self.classificationResults.contains("pizza") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Pizza!"
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not Pizza"
                    }
                }
            })
        }
        else {
            print("Error occur picking the image")
        }
    }
    
    
    @IBAction func cameraBtnTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

