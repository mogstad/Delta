/// Generates item records in a given section
///
/// - parameter section: the section
/// - parameter oldSection: the index the section was originally located
/// - parameter from: the original data structure.
/// - parameter to: the new data structure.
/// - parameter preferReload: wheter it should generate a reload record, if 
///   either the `from` or `to` is empty. Reloading a section is required to 
///   avoid a crash if you’re displaying an empty state in the same “collection”
///   view using an actual cell. Defaults to `true`.
/// - returns: the required changes required to change the passed in `from`
///   array into the passed in `to` array.
public func generateItemRecords<Item: DeltaItem>(section: Int, oldSection: Int? = nil, from: [Item], to: [Item], preferReload: Bool = true) -> [CollectionRecord] where Item: Equatable {
  if from.count == 0 && to.count == 0 {
    return []
  } else if preferReload && (from.count == 0 || to.count == 0) {
    return [.reloadSection(section: section)]
  }

  return changes(from: from, to: to).map {
    $0.toCollectionItemRecord(section: section, oldSection: oldSection ?? section)
  }
}

/// Generate section records and item records for many sections.
///
/// - parameter from: the original data structure.
/// - parameter to: the new data structure.
/// - returns: the required changes to perform on the old nested data structure
///   to end up with the new data structure.
public func generateRecordsForSections<Section: DeltaSection>(from: [Section], to: [Section]) -> [CollectionRecord] where Section: Equatable {
  return generateItemRecords(from: from, to: to) + generateSectionRecords(from: from, to: to)
}

/// Generates CollectionRecords for sections
///
/// - parameter from: the original data structure.
/// - parameter to: the new data structure.
/// - returns: the required changes required to change the passed in `from` 
///   array into the passed in `to` array.
func generateSectionRecords<Section: DeltaSection>(from: [Section], to: [Section]) -> [CollectionRecord] where Section: Equatable {
  let records = changes(from: from, to: to)
  let recordsWithoutChange = records.filter { record in
    switch record {
    case .change(_, _):
      return false
    default:
      return true
    }
  }
  return recordsWithoutChange.map { $0.toCollectionSectionRecord() }
}

/// Generate all item records for many sections
///
/// - parameter from: the original data structure.
/// - parameter to: the new data structure.
/// - returns: all item records to transform the `from` data structure into the
///   `to` data structure.
func generateItemRecords<Section: DeltaSection>(from: [Section], to: [Section]) -> [CollectionRecord] where Section: Equatable {
  let cache = createItemCache(items: from)

  let itemRecords = to.enumerated().flatMap { (index, section) -> [CollectionRecord] in
    guard let cacheEntry = cache[section.deltaIdentifier] else { return [] }

    return generateItemRecords(
      section: index,
      oldSection: cacheEntry.index,
      from: cacheEntry.item.items,
      to: to[index].items)
  }
  return itemRecords
}
