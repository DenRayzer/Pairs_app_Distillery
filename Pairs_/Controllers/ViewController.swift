//
//  ViewController.swift
//  Pairs_
//
//  Created by Елизавета on 17.04.2020.
//  Copyright © 2020 Elizaveta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var isItemSelected = false
    private var savedIndexPath = IndexPath()
    private var collectionView: UICollectionView!
    private var shiftedColors: [[String]] = [[String]]()
    private var sections = Bundle.main.decode([ColorSection].self, from: "model.json")
    private let colors = ["My1",
                          "My2",
                          "My3",
                          "My4",
                          "My5",
                          "My6",
                          "My7"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setData()
    }
    
    // MARK: setup collectionView
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            return self.createSection()
        }
        return layout
    }
    
    private func createSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 8)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(180),
                                                     heightDimension: .estimated(150))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .continuous
        layoutSection.contentInsets = NSDirectionalEdgeInsets.init(top: 12, leading: 12, bottom: 0, trailing: 12)
        
        let header = createSectionHeader()
        layoutSection.boundarySupplementaryItems = [header]
        
        return layoutSection
    }
    
    private func setData() {
        for i in 0..<sections.count {
            let randomNum = Int.random(in: 0..<colors.count)
            shiftedColors.append(colors.shifted(by: randomNum))
            
            for j in 0..<sections[i].items.count {
                sections[i].items[j].number = i*10 + j + 1
                
                if j < colors.count {
                    sections[i].items[j].color = shiftedColors[i][j]
                } else {
                    sections[i].items[j].color = shiftedColors[i][j - colors.count]
                }
            }
        }
    }
    
}

private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
    let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                         heightDimension: .estimated(1))
    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize,
                                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                                    alignment: .top)
    return sectionHeader
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath) as! ColorCell
        cell.number.text = String(sections[indexPath.section].items[indexPath.item].number)
        cell.backgroundColor = UIColor(named: sections[indexPath.section].items[indexPath.item].color)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as! SectionHeader
            sectionHeader.title.text = sections[indexPath.section].title
            return sectionHeader
        default:  fatalError("Unexpected element kind")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isItemSelected {
            isItemSelected = true
            savedIndexPath = indexPath
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderColor = UIColor.yellow.cgColor
            cell?.layer.borderWidth = 5
        } else {
            let selectedCell = collectionView.cellForItem(at: savedIndexPath)
            selectedCell?.layer.borderWidth = 0
            isItemSelected = false
            let savedItem = savedIndexPath.item
            let currentItem = indexPath.item
            
            if indexPath.section == savedIndexPath.section && indexPath.item != savedIndexPath.item {
                sections[indexPath.section].items.swapAt(savedItem, currentItem)
                collectionView.reloadItems(at: [indexPath, savedIndexPath])
                deleteRepetitionItems(section: indexPath.section)
            }
        }
    }
    
    private func deleteRepetitionItems(section: Int) {
        let lenght = sections[section].items.count - 1
        for i in 0..<lenght{
            if sections[section].items[i].color == sections[section].items[i + 1].color {
                sections[section].items.remove(at: i + 1)
                sections[section].items.remove(at: i)
                collectionView.deleteItems(at: [IndexPath(item: i + 1, section: section),IndexPath(item: i, section: section)])
                deleteRepetitionItems(section: section)
                break
            }
        }
    }
    
}

// MARK: to shift an array

extension Array {
    
    func shifted(by shiftAmount: Int) -> Array<Element> {
        guard self.count > 0, (shiftAmount % self.count) != 0 else { return self }
        
        let moduloShiftAmount = shiftAmount % self.count
        
        let negativeShift = shiftAmount < 0
        
        let effectiveShiftAmount = negativeShift ? moduloShiftAmount + self.count : moduloShiftAmount
        
        let shift: (Int) -> Int = {
            return $0 + effectiveShiftAmount >= self.count ? $0 + effectiveShiftAmount - self.count : $0 + effectiveShiftAmount
        }
        return self.enumerated().sorted(by: { shift($0.offset) < shift($1.offset) }).map { $0.element }
    }
    
}
