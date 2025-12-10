part of 'pages.dart';

class InternationalPage extends StatefulWidget {
  const InternationalPage({super.key});

  @override
  State<InternationalPage> createState() => _InternationalPageState();
}

class _InternationalPageState extends State<InternationalPage> {
  final weightController = TextEditingController();
  final searchController = TextEditingController();

  final List<String> courierOptions = ["pos", "tiki"];
  String selectedCourier = "pos";
  String? selectedCountryId;
  bool showSearchList = false;

  @override
  void dispose() {
    weightController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<InternationalViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Courier + Weight (same layout as Home)
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedCourier,
                                items: courierOptions
                                    .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c.toUpperCase()),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => selectedCourier = v ?? 'pos'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Berat (gr)',
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Destination (country search)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Destination (Country)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Cari Negara (e.g. Japan)",
                            suffixIcon: showSearchList
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        showSearchList = false;
                                        selectedCountryId = null;
                                        searchController.clear();
                                      });
                                    },
                                  )
                                : const Icon(Icons.search),
                          ),
                          onChanged: (val) {
                            if (val.trim().isEmpty) {
                              setState(() => showSearchList = false);
                              vm.searchCountry('');
                              return;
                            }
                            setState(() => showSearchList = true);
                            vm.searchCountry(val);
                          },
                        ),

                        if (showSearchList)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Builder(builder: (context) {
                              final list = vm.countryList.data ?? [];

                              if (vm.countryList.status == Status.loading) {
                                return const SizedBox(
                                  height: 80,
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              if (list.isEmpty) {
                                return Container(
                                  height: 80,
                                  alignment: Alignment.center,
                                  child: const Text('Negara tidak ditemukan'),
                                );
                              }

                              return Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (context, i) {
                                    final country = list[i];
                                    return ListTile(
                                      title: Text(country.countryName),
                                      onTap: () {
                                        setState(() {
                                          selectedCountryId = country.countryId;
                                          searchController.text = country.countryName;
                                          showSearchList = false;
                                        });
                                      },
                                    );
                                  },
                                ),
                              );
                            }),
                          ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedCountryId != null && weightController.text.isNotEmpty) {
                                vm.calculateInternationalCost(
                                  originCityId: "0",
                                  destinationCountryId: selectedCountryId!,
                                  weight: int.parse(weightController.text),
                                  courier: selectedCourier,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Lengkapi semua field!'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text(
                              'Hitung Ongkir',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  color: Colors.blue[50],
                  elevation: 2,
                  child: vm.costList.status == Status.loading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Builder(builder: (context) {
                          final results = vm.costList.data ?? [];

                          if (results.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: Text("Tidak ada data ongkir.")),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: results.length,
                            itemBuilder: (context, i) {
                              final c = results[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: ListTile(
                                  title: Text(
                                    "${c.name} (${c.code}): ${c.service}",
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Biaya: ${c.currency} ${c.cost}"),
                                      const SizedBox(height: 4),
                                      Text("Estimasi sampai: ${c.etd}"),
                                    ],
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[50],
                                    child: Icon(Icons.flight, color: Colors.blue[800]),
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (_) => Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  backgroundColor: Color(0xFFE3F2FD),
                                                  child: Icon(Icons.flight, color: Colors.blue),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    c.name,
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  icon: const Icon(Icons.close),
                                                ),
                                              ],
                                            ),
                                            const Divider(),
                                            _row("Nama Kurir", c.name),
                                            _row("Kode", c.code),
                                            _row("Layanan", c.service),
                                            _row("Deskripsi", c.description),
                                            _row("Biaya", "${c.currency} ${c.cost}"),
                                            _row("Estimasi Pengiriman", c.etd),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }),
                ),
              ],
            ),
          ),

          if (vm.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          const Text(' : '),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }
}
