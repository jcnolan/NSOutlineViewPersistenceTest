//
//  ViewController.swift
//  NSOutlinePersistenceTest
//
//  Created by JC Nolan on 6/30/21.
//

// https://gist.github.com/floorish/4e13c7c28e211274b8d5a2dd32dcdc1a - original source

import Cocoa

class Item: NSObject {
    let name: String
    let children: [Item]
    
    init(name: String, children: [Item]) {
        self.name = name
        self.children = children
    }
    
}

class ViewController: NSViewController {

    lazy var outline: NSOutlineView = {
          let v = NSOutlineView()
          
          v.dataSource = self
          v.delegate = self

          let col = NSTableColumn()
          v.outlineTableColumn = col
          v.addTableColumn(col)
          
          v.headerView = nil
          
  //        v.autosaveExpandedItems = true
  //        v.autosaveName = "outline"
          
          v.selectionHighlightStyle = .sourceList
          v.backgroundColor = .clear
          v.rowSizeStyle = NSTableView.RowSizeStyle.default
          v.allowsMultipleSelection = true
          v.allowsEmptySelection = true
          
          return v

      }()
    
    let items: [Item] = [
          Item(name: "a", children: [
              Item(name: "aa", children: [
                  Item(name: "aaa", children: []),
                  Item(name: "aab", children: [
                      Item(name: "aaba", children: []),
                  ]),
              ]),
              Item(name: "ab", children: []),
              Item(name: "ac", children: []),
          ]),
          Item(name: "b", children: [
              Item(name: "ba", children: []),
          ]),
      ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(self.outline)
          self.outline.translatesAutoresizingMaskIntoConstraints = false
          self.outline.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
          self.outline.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
          self.outline.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
          self.outline.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
          
          self.outline.heightAnchor.constraint(equalToConstant: 400).isActive = true
          self.outline.widthAnchor.constraint(equalToConstant: 400).isActive = true

          self.outline.dataSource = self
          self.outline.delegate = self
          self.outline.reloadData()
          self.outline.sizeLastColumnToFit()
    }

}

extension ViewController: NSOutlineViewDataSource {
    
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item = item as? Item else { return items.count }
        
        return item.children.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? Item else { return items[index] }
        
        return item.children[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? Item else { return false }
        
        return !item.children.isEmpty
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item
    }
    

}

extension ViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        guard let item = item as? Item else { return false }
        print("should collapse", item.name)
        return !item.children.isEmpty
    }
    
    func outlineView(_ outlineView: NSOutlineView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, item: Any) {
        
        guard let item = item as? Item else { return }
        guard let cell = cell as? NSCell else { return }
        
        cell.title = item.name
        
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let i = item as? Item else { return nil }
        let v = NSView(frame: NSZeroRect)
        v.addSubview(NSTextField(labelWithString: i.name))
        return v
    }
    
    func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
        return item
    }
    
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        return object
    }
    
    func outlineViewItemDidCollapse(_ notification: Notification) {
        guard let item = notification.userInfo?["NSObject"] as? Item else {
            return
        }
        
        let isExpanded = self.outline.isItemExpanded(item)
        let isParentExpanded = self.outline.parent(forItem: item).map(self.outline.isItemExpanded)
        
        print("DELEGATE DID COLLAPSE", item.name, isExpanded, isParentExpanded)
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        guard let item = notification.userInfo?["NSObject"] as? Item else {
            return
        }
        
        let isExpanded = self.outline.isItemExpanded(item)
        let isParentExpanded = self.outline.parent(forItem: item).map(self.outline.isItemExpanded)

        print("DELEGATE DID EXPAND", item.name, isExpanded, isParentExpanded)
    }
    
   
}

