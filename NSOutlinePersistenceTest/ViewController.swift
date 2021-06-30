//
//  ViewController.swift
//  NSOutlinePersistenceTest
//
//  Created by JC Nolan on 6/30/21.
//

import Cocoa

class Item: NSObject, Codable {
    
    let name: String
    let children: [Item]
    var isExpanded: Bool
    
    init(name: String, children: [Item], isExpanded: Bool = false) {
        self.name = name
        self.children = children
        self.isExpanded = isExpanded
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
        
        if true {
            v.autosaveExpandedItems = true
            v.autosaveName = "outline"
        }
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
    
    func expandOutline()
    {
        var itemsToExpand:[Item] = []
        
        for x in 0 ..< outline.numberOfRows {
            
            let item: Item = outline.item(atRow: x) as! Item
            
            if item.isExpanded {} else {}
            itemsToExpand.append(item)
//            outline.expandItem(item)
        }
        
        for item in itemsToExpand {
            outline.expandItem(item)
        }
    }
    
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
        
        //
        
        expandOutline()
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
        
        let itemItem:Item = item as! Item
        
        let codedJson = try? JSONEncoder().encode(itemItem)
        let loginPrefsDefaultJsonStr:String = String(data:codedJson!, encoding: String.Encoding.utf8) ?? ""
        Swift.print("DefaultLoginPrefs: \(loginPrefsDefaultJsonStr)")
        return loginPrefsDefaultJsonStr
        
   //     return item
    }
    
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        
         let jsonDecoder = JSONDecoder()
         let loginPrefsSaved = object as? String ?? ""
         let dataToDecode = loginPrefsSaved.data(using: String.Encoding.utf8)
         
         var myLoginPrefs: Item? = nil
         
         do {
             myLoginPrefs = try jsonDecoder.decode(Item.self, from: dataToDecode!)
         } catch let error {
             print(error)
         //    myLoginPrefs = LoginPrefs()
         }
         
//        return object
        return myLoginPrefs
    }
    
    func outlineViewItemDidCollapse(_ notification: Notification) {
        guard let item = notification.userInfo?["NSObject"] as? Item else {
            return
        }
        
        item.isExpanded = false
        
        let isExpanded = self.outline.isItemExpanded(item)
        let isParentExpanded = self.outline.parent(forItem: item).map(self.outline.isItemExpanded)
        
        print("DELEGATE DID COLLAPSE", item.name, isExpanded, isParentExpanded)
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        guard let item = notification.userInfo?["NSObject"] as? Item else {
            return
        }
        
        item.isExpanded = true
        
        let isExpanded = self.outline.isItemExpanded(item)
        let isParentExpanded = self.outline.parent(forItem: item).map(self.outline.isItemExpanded)
        
        print("DELEGATE DID EXPAND", item.name, isExpanded, isParentExpanded)
    }
    
    
}

