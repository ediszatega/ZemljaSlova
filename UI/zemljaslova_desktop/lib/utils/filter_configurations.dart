import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/filter_field.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';

class FilterConfigurations {
  static List<FilterField> getBookFilters(BuildContext context) {
    return [
      // Price range - Min
      const FilterField(
        key: 'minPrice',
        label: 'Minimalna cijena',
        type: FilterFieldType.number,
        suffix: 'KM',
      ),
      // Price range - Max
      const FilterField(
        key: 'maxPrice',
        label: 'Maksimalna cijena',
        type: FilterFieldType.number,
        suffix: 'KM',
      ),
      // Author filter
      FilterField(
        key: 'authorId',
        label: 'Autor',
        type: FilterFieldType.dropdown,
        dropdownOptions: _getAuthorDropdownOptions(context),
      ),
      // Availability filter
      const FilterField(
        key: 'isAvailable',
        label: 'Dostupnost',
        type: FilterFieldType.dropdown,
        dropdownOptions: [
          FilterDropdownOption(value: '', label: 'Sve knjige', data: null),
          FilterDropdownOption(value: 'true', label: 'Dostupne', data: true),
          FilterDropdownOption(value: 'false', label: 'Nedostupne', data: false),
        ],
      ),
    ];
  }

  static List<FilterField> getEventFilters(BuildContext context) {
    return [
      // Price range - Min
      const FilterField(
        key: 'minPrice',
        label: 'Minimalna cijena',
        type: FilterFieldType.number,
        suffix: 'KM',
      ),
      // Price range - Max
      const FilterField(
        key: 'maxPrice',
        label: 'Maksimalna cijena',
        type: FilterFieldType.number,
        suffix: 'KM',
      ),
      // Date range - From
      const FilterField(
        key: 'startDateFrom',
        label: 'Od datuma',
        type: FilterFieldType.date,
      ),
      // Date range - To
      const FilterField(
        key: 'startDateTo',
        label: 'Do datuma',
        type: FilterFieldType.date,
      ),
    ];
  }

  static List<FilterDropdownOption> _getAuthorDropdownOptions(BuildContext context) {
    try {
      final authorProvider = Provider.of<AuthorProvider>(context, listen: false);
      final authors = authorProvider.authors;
      
      return [
        const FilterDropdownOption(value: '', label: 'Svi autori', data: null),
        ...authors.map((author) => FilterDropdownOption(
          value: author.id.toString(),
          label: '${author.firstName} ${author.lastName}',
          data: author.id,
        )),
      ];
    } catch (e) {
      return [
        const FilterDropdownOption(value: '', label: 'Svi autori', data: null),
      ];
    }
  }
} 