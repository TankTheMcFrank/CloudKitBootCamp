//
//  CloudKitCrudBootcamp.swift
//  CloudKitBootCamp
//
//  Created by Frank Herring on 10/6/23.
//

import CloudKit
import SwiftUI

struct FruitModel: Hashable {
    let name: String
    let imageURL: URL?
    let record: CKRecord
}

class CloudKitCrudBootcampViewModel: ObservableObject {
    
    @Published var text: String = ""
    @Published var fruits: [FruitModel] = []
    
    init() {
        fetchItems()
    }
    
    func addButtonPressed() {
        guard !text.isEmpty else { return } /* do nothing if text is empty */
        addItem(name: text)
    }
    
    private func addItem(name: String) {
        let newFruit = CKRecord(recordType: "Fruits")
        newFruit["name"] = name
        
        guard 
            let image = UIImage(named: "apple"),
            let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("apple.jpg"),
            let data = image.jpegData(compressionQuality: 1.0)
        else { return }
        
        do {
            try data.write(to: url)
            let asset = CKAsset(fileURL: url)
            newFruit["image"] = asset
            saveItem(record: newFruit)
        } catch let error {
            print(error)
        }
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) { [weak self] returnedRecord, returnedError in
            print("Record: \(String(describing: returnedRecord))")
            print("Error: \(String(describing: returnedError))")
            
            DispatchQueue.main.async {
                self?.text = ""
                /* using the following line is okay in apps with small data sets,
                    but in apps with large data sets, it's probably better to just update
                    the item in the local array after saving the data -> this ensures that
                    you're not having to re-download a whole lot of data every time
                    you update a record */
                self?.fetchItems()
            }
        }
    }
    
    func fetchItems() {
        let predicate = NSPredicate(value: true)
//        let predicate = NSPredicate(format: "name = %@", argumentArray: ["Coconut"])
        let query = CKQuery(recordType: "Fruits", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        
        /* could implement the following line of code to limit number of returned items
            apparently, if left to default, you get the 'maximum' number of results
            also apparently, this isn't necessary 'all' the results in the database... it's only 100
            that's where the returned cursor comes into play below */
//        queryOperation.resultsLimit = 2
        
        var returnedItems: [FruitModel] = []
        
        if #available(iOS 15.0, *) {
            queryOperation.recordMatchedBlock = { returnedRecordID, returnedResult in
                switch returnedResult {
                case .success(let record):
                    guard let name = record["name"] as? String else { return }
                    let imageAsset = record["image"] as? CKAsset
                    let imageURL = imageAsset?.fileURL
                    print(record)
                    returnedItems.append(FruitModel(name: name, imageURL: imageURL, record: record))
                    break
                case .failure(let error):
                    print("Error recordMatchedBlock: \(error)")
                    break
                }
            }
        } else {
            queryOperation.recordFetchedBlock = { returnedRecord in
                guard let name = returnedRecord["name"] as? String else { return }
                let imageAsset = returnedRecord["image"] as? CKAsset
                let imageURL = imageAsset?.fileURL
                returnedItems.append(FruitModel(name: name, imageURL: imageURL, record: returnedRecord))
            }
        }
        
        /* these are our completion blocks */
        if #available(iOS 15.0, *) {
            queryOperation.queryResultBlock = { [weak self] returnedResult in
                print("RETURNED queryResultBlock: \(returnedResult)")
                DispatchQueue.main.async {
                    self?.fruits = returnedItems
                }
            }
        } else {
            queryOperation.queryCompletionBlock = { [weak self] returnedCursor, returnedError in
                print("RETURNED queryCompletionBlock")
                DispatchQueue.main.async {
                    self?.fruits = returnedItems
                }
            }
        }
        
        /* name is counterintuitive... 'adding' the operation is what executes the operation*/
        addOperation(operation: queryOperation)
    }
    
    func addOperation(operation: CKDatabaseOperation) {
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func updateItem(fruit: FruitModel) {
        let record = fruit.record
        record["name"] = "NEW NAME"
        saveItem(record: record)
    }
    
    func deleteItem(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let fruit = fruits[index]
        let record = fruit.record
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { [weak self] returnedRecordID, returnedError in
            /* by using this completion handler and deleting the item from the fruits array,
                we're avoiding having to reload data from the database since we're confident that
                the deletion happened in the cloud */
            DispatchQueue.main.async {
                self?.fruits.remove(at: index)
            }
        }
    }
    
}

struct CloudKitCrudBootcamp: View {
    
    @StateObject private var vm = CloudKitCrudBootcampViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                header
                textField
                addButton
                
                List {
                    ForEach(vm.fruits, id: \.self) { fruit in
                        HStack {
                            Text(fruit.name)
                            
                            if let url = fruit.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                        }
                        .onTapGesture {
                            vm.updateItem(fruit: fruit)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        vm.deleteItem(indexSet: indexSet)
                    })
                }
                .listStyle(.plain)
            }
            .padding()
            .toolbar(.hidden)
        }
    }
}

//#Preview {
//    CloudKitCrudBootcamp()
//}

extension CloudKitCrudBootcamp {
    private var header: some View {
        Text("CloudKit CRUD ☁️☁️☁️")
            .font(.headline)
            .underline()
    }
    
    private var textField: some View {
        TextField("Add something here...", text: $vm.text)
            .frame(height: 55)
            .padding(.leading)
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
    }
    
    private var addButton: some View {
        Button {
            vm.addButtonPressed()
        } label: {
            Text("Add")
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.pink)
                .cornerRadius(10)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}
