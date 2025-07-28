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
      // Show past events checkbox
      const FilterField(
        key: 'showPastEvents',
        label: 'Prikaži prošle događaje',
        type: FilterFieldType.checkbox,
      ),
    ];
  }

  static List<FilterField> getAuthorFilters(BuildContext context) {
    return [
      // Birth year range - From
      const FilterField(
        key: 'birthYearFrom',
        label: 'Godina rođenja od',
        type: FilterFieldType.number,
        placeholder: 'npr. 1950',
      ),
      // Birth year range - To
      const FilterField(
        key: 'birthYearTo',
        label: 'Godina rođenja do',
        type: FilterFieldType.number,
        placeholder: 'npr. 2000',
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

  static List<FilterField> getMemberFilters(BuildContext context) {
    return [
      // Gender filter
      const FilterField(
        key: 'gender',
        label: 'Pol',
        type: FilterFieldType.dropdown,
        dropdownOptions: [
          FilterDropdownOption(value: '', label: 'Svi polovi', data: null),
          FilterDropdownOption(value: 'male', label: 'Muško', data: 'male'),
          FilterDropdownOption(value: 'female', label: 'Žensko', data: 'female'),
        ],
      ),
      // Birth year range - From
      const FilterField(
        key: 'birthYearFrom',
        label: 'Godina rođenja od',
        type: FilterFieldType.number,
        placeholder: 'npr. 1950',
      ),
      // Birth year range - To
      const FilterField(
        key: 'birthYearTo',
        label: 'Godina rođenja do',
        type: FilterFieldType.number,
        placeholder: 'npr. 2000',
      ),
      // Joined year range - From
      const FilterField(
        key: 'joinedYearFrom',
        label: 'Godina učlanjenja od',
        type: FilterFieldType.number,
        placeholder: 'npr. 2020',
      ),
      // Joined year range - To
      const FilterField(
        key: 'joinedYearTo',
        label: 'Godina učlanjenja do',
        type: FilterFieldType.number,
        placeholder: 'npr. 2024',
      ),
      // Show inactive members checkbox
      const FilterField(
        key: 'showInactiveMembers',
        label: 'Prikaži neaktivne članove',
        type: FilterFieldType.checkbox,
      ),
    ];
  }

  static List<FilterField> getEmployeeFilters(BuildContext context) {
    return [
      // Gender filter
      const FilterField(
        key: 'gender',
        label: 'Pol',
        type: FilterFieldType.dropdown,
        dropdownOptions: [
          FilterDropdownOption(value: '', label: 'Svi polovi', data: null),
          FilterDropdownOption(value: 'male', label: 'Muško', data: 'male'),
          FilterDropdownOption(value: 'female', label: 'Žensko', data: 'female'),
        ],
      ),
      // Access level filter
      const FilterField(
        key: 'accessLevel',
        label: 'Nivo pristupa',
        type: FilterFieldType.dropdown,
        dropdownOptions: [
          FilterDropdownOption(value: '', label: 'Svi nivoi', data: null),
          FilterDropdownOption(value: 'admin', label: 'Admin', data: 'admin'),
          FilterDropdownOption(value: 'employee', label: 'Uposlenik', data: 'employee'),
        ],
      ),
    ];
  }

  static List<FilterField> getVoucherFilters(BuildContext context) {
    return [
      // Value range - Min
      const FilterField(
        key: 'minValue',
        label: 'Minimalna vrijednost',
        type: FilterFieldType.number,
        suffix: 'KM',
        placeholder: 'npr. 10',
      ),
      // Value range - Max
      const FilterField(
        key: 'maxValue',
        label: 'Maksimalna vrijednost',
        type: FilterFieldType.number,
        suffix: 'KM',
        placeholder: 'npr. 100',
      ),
      // Voucher type filter
      const FilterField(
        key: 'voucherType',
        label: 'Tip vaučera',
        type: FilterFieldType.dropdown,
        dropdownOptions: [
          FilterDropdownOption(value: '', label: 'Svi tipovi', data: null),
          FilterDropdownOption(value: 'promotional', label: 'Promocijski', data: 'promotional'),
          FilterDropdownOption(value: 'purchased', label: 'Kupljeni', data: 'purchased'),
        ],
      ),
      // Usage status filter
      const FilterField(
        key: 'isUsed',
        label: 'Status korištenja',
        type: FilterFieldType.dropdown,
        dropdownOptions: [
          FilterDropdownOption(value: '', label: 'Svi statusi', data: null),
          FilterDropdownOption(value: 'false', label: 'Aktivni', data: false),
          FilterDropdownOption(value: 'true', label: 'Iskorišteni', data: true),
        ],
      ),
      // Expiration date range - From
      const FilterField(
        key: 'expirationDateFrom',
        label: 'Datum isteka od',
        type: FilterFieldType.date,
      ),
      // Expiration date range - To
      const FilterField(
        key: 'expirationDateTo',
        label: 'Datum isteka do',
        type: FilterFieldType.date,
      ),
    ];
  }
} 