//
//  homeViewController.swift
//  khyma
//
//  Created by aly hassan on 11/09/2021.
//

import UIKit

class homeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let tempDB = ["name", "name2", "name3", "name", "name2", "name3"]
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tempDB.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCV.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! homeCollectionViewCell
        cell.image.image = UIImage(named: "khymaIcon.jpg")
        cell.name.text = tempDB[indexPath.row]
        return cell
    }
    

    @IBOutlet weak var myCV: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myCV.delegate = self
        myCV.dataSource = self
        // aly =====> make estimate size in collection view in storyboard = none instead of automatic
        let numberOfCellsPerRow: CGFloat = 5
        let flowLayout = myCV.collectionViewLayout as! UICollectionViewFlowLayout
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1)*horizontalSpacing)/numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
