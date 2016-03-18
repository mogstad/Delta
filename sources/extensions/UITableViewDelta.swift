import UIKit

public extension UITableView {

  public typealias TableViewUpdateCallback = (NSIndexPath, NSIndexPath) -> Void

  public func performUpdates(records: [CollectionRecord], update: TableViewUpdateCallback? = nil) {
    self.beginUpdates()
    for record in records {
      switch record {
      case let .AddItem(section, index):
        let indexPath = NSIndexPath(forRow: index, inSection: section)
        self.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
      case let .RemoveItem(section, index):
        let indexPath = NSIndexPath(forRow: index, inSection: section)
        self.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
      case let .MoveItem(from, to):
        let indexPath = NSIndexPath(forRow: to.index, inSection: to.section)
        let fromIndexPath = NSIndexPath(forRow: from.index, inSection: from.section)
        self.moveRowAtIndexPath(fromIndexPath, toIndexPath: indexPath)
      case let .ChangeItem(section, index, from):
        let indexPath = NSIndexPath(forRow: index, inSection: section)
        let newIndexPath = NSIndexPath(forRow: from, inSection: section)
        if let updateCallback = update {
          updateCallback(indexPath, newIndexPath)
        } else {
          self.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
      case let .ReloadSection(section):
        self.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
      case let .MoveSection(section, from):
        self.moveSection(from, toSection: section)
      case let .AddSection(section):
        self.insertSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
      case let .RemoveSection(section):
        self.deleteSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
      }
    }
    self.endUpdates()
  }
  
}
