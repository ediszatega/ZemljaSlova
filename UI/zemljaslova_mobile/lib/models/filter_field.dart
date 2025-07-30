enum FilterFieldType {
  text,
  number,
  date,
  dropdown,
  checkbox,
}

class FilterDropdownOption {
  final String value;
  final String label;
  final dynamic data;

  const FilterDropdownOption({
    required this.value,
    required this.label,
    this.data,
  });
}

class FilterField {
  final String key;
  final String label;
  final FilterFieldType type;
  final String? suffix;
  final String? placeholder;
  final List<FilterDropdownOption>? dropdownOptions;

  const FilterField({
    required this.key,
    required this.label,
    required this.type,
    this.suffix,
    this.placeholder,
    this.dropdownOptions,
  });
} 