import 'package:flutter/material.dart';

import 'currency.dart';
import 'currency_service.dart';

class CurrencyListView extends StatefulWidget {
  /// Called when a currency is select.
  ///
  /// The currency picker passes the new value to the callback.
  final ValueChanged<Currency> onSelect;

  /// Can be used to uses filter the Currency list (optional).
  ///
  /// It takes a list of Currency code.
  final List<String> currencyFilter;

  /// Shows flag for each currency (optional).
  ///
  /// Defaults true.
  final bool showFlag;

  const CurrencyListView({
    Key key,
    this.onSelect,
    this.currencyFilter,
    this.showFlag = true,
  }) : super(key: key);

  @override
  _CurrencyListViewState createState() => _CurrencyListViewState();
}

class _CurrencyListViewState extends State<CurrencyListView> {
  final CurrencyService _currencyService = CurrencyService();

  List<Currency> _filteredList;
  List<Currency> _currencyList;

  TextEditingController _searchController;

  static String countryCodeToEmoji(String countryCode) {
    // 0x41 is Letter A
    // 0x1F1E6 is Regional Indicator Symbol Letter A
    // Example :
    // firstLetter U => 20 + 0x1F1E6
    // secondLetter S => 18 + 0x1F1E6
    // See: https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  @override
  void initState() {
    _searchController = TextEditingController();

    _currencyList = _currencyService.getAll();

    _filteredList = <Currency>[];

    if (widget.currencyFilter != null) {
      final List<String> currencyFilter =
          widget.currencyFilter.map((code) => code.toUpperCase()).toList();

      _currencyList
          .removeWhere((element) => !currencyFilter.contains(element.code));
    }

    _filteredList.addAll(_currencyList);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Search",
              hintText: "Search",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFF8C98A8).withOpacity(0.2),
                ),
              ),
            ),
            onChanged: _filterSearchResults,
          ),
        ),
        Expanded(
          child: ListView(
            children: _filteredList
                .map<Widget>((currency) => _listRow(currency))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _listRow(Currency currency) {
    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onSelect(currency);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 15),
                    if (widget.showFlag) ...[
                      Text(
                        countryCodeToEmoji(currency.flag),
                        style: const TextStyle(fontSize: 25),
                      ),
                      const SizedBox(width: 15),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency.code,
                            style: const TextStyle(fontSize: 17),
                          ),
                          Text(
                            currency.name,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  currency.symbol,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _filterSearchResults(String query) {
    List<Currency> _searchResult = <Currency>[];

    if (query.isEmpty) {
      _searchResult.addAll(_currencyList);
    } else {
      _searchResult = _currencyList
          .where((c) =>
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.code.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() => _filteredList = _searchResult);
  }
}
