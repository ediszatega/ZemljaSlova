enum FilterFieldType {
  text,
  number,
  date,
  dropdown,
  checkbox,
}

class FilterField {
  final String key;
  final String label;
  final FilterFieldType type;
  final String? suffix;
  final List<FilterDropdownOption>? dropdownOptions;
  final dynamic initialValue;
  final String? placeholder;

  const FilterField({
    required this.key,
    required this.label,
    required this.type,
    this.suffix,
    this.dropdownOptions,
    this.initialValue,
    this.placeholder,
  });
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