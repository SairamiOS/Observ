//
//  ViewController.swift
//  DemoObservable
//
//  Created by GEIDC on 11/29/16.
//  Copyright © 2016 GEIDC. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources


extension String {
     public typealias Identity = String
    public var identity: Identity{ return self}

}

struct AnimatedSectionModel {
    let title: String
    var  data = [String]()
    
}

extension AnimatedSectionModel: AnimatableSectionModelType {
    
    typealias Item = String
    typealias Identity = String
    
    var identity: Identity{return title}
    var items: [Item]{return data}
    
    init(original: AnimatedSectionModel, items: [String]) {
        self = original
        data = items
    }
    
}


class ViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem?
    @IBOutlet weak var longPressGR: UILongPressGestureRecognizer?
    
    let disposeBag = DisposeBag()
    
    let datasource = RxCollectionViewSectionedAnimatedDataSource <AnimatedSectionModel>()
    let data = Variable([AnimatedSectionModel(title:"Section: 0",data:["0-0"])
        ])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        datasource.configureCell = {_, collectionView, indexPath,title in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Cell", for: indexPath)as!Cell
            cell.titelLable.text = title
            return cell
        }
        
        datasource.supplementaryViewFactory = {datasource,collectionView, kind,indexpath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexpath) as! HeaderCollectionReusableView
            header.titelLable.text = "Section: \(self.data.value.count)"
            return header
        }
        
        data.asDriver().drive((collectionView?.rx.items(dataSource:datasource))!).addDisposableTo(disposeBag)
        
//Add Cell -------
        addBarButtonItem?.rx.tap.asDriver().drive(onNext:{
            let section = self.data.value.count
            let items: [String] = {
               var itemsNw = [String]()
               let random = Int(arc4random_uniform(5))+1
               (0...random).forEach{
                    itemsNw.append(("\(section)-\($0)"))}
             return itemsNw
        }()
            
            self.data.value += [AnimatedSectionModel(title:"Section:\(section)",data:items)]
        }).addDisposableTo(disposeBag)
        
//GestureRecognizer-------
        longPressGR?.rx.event.asDriver().drive(onNext:{
            switch $0.state {
            case .began:
                guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: $0.location(in: self.collectionView)) else{ break }
                self.collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
            case .changed:
                self.collectionView?.updateInteractiveMovementTargetPosition($0.location(in: $0.view))
            case .ended:
                self.collectionView?.endInteractiveMovement()
            default:
                self.collectionView?.cancelInteractiveMovement()
            }
            
        }).addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

