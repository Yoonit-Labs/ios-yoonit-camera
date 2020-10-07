//
//  ViewController.swift
//  YoonitCameraDemo
//
//  Created on 07/10/2020.
//  Márcio Habigzang Brufatto © CyberLabs AI 2020.
//

import UIKit
import YoonitCamera


extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}

class PhotoListViewController: UITableViewController {

    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadImages()
    }
    
    private func loadImages(){

        let fileManager = FileManager.default
        let tempDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let items = try? fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        self.pictures = items?.map { item in
            let attrs = try? fileManager.attributesOfItem(atPath: item.path)
            if let size = attrs?[FileAttributeKey.size] {
                let f = ByteCountFormatter().string(fromByteCount: size as! Int64)
                print("\(item.lastPathComponent) \(f)")
            }
            return item.lastPathComponent
        }.sorted() ?? []
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadImages()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailsViewController {
            // 2: success! Set its selectedImage property
            vc.selectedImage = pictures[indexPath.row]
            // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

