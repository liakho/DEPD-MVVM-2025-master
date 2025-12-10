part of 'pages.dart';

class InternationalPage extends StatefulWidget {
  const InternationalPage({super.key});

  @override
  State<InternationalPage> createState() => _InternationalPageState();
}

class _InternationalPageState extends State<InternationalPage> {
  final TextEditingController weightCtrl = TextEditingController();
  final TextEditingController countryCtrl = TextEditingController();

  final List<String> couriersAvailable = ['pos', 'tiki'];
  String courierSelected = 'tiki';
  String? chosenCountryId;
  bool showCountryResults = false;

  @override
  void dispose() {
    weightCtrl.dispose();
    countryCtrl.dispose();
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
                _buildInputCard(vm),
                const SizedBox(height: 16),
                _buildOutputCard(vm),
              ],
            ),
          ),

          if (vm.isLoading) _loadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildInputCard(InternationalViewModel vm) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _courierDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _weightField()),
              ],
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Destination (Country)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            _countrySearchField(vm),

            if (showCountryResults) const SizedBox(height: 8),
            if (showCountryResults) _countryResultsBox(vm),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onCalculatePressed(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Hitung Ongkir', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courierDropdown() {
    return DropdownButton<String>(
      isExpanded: true,
      value: courierSelected,
      items: couriersAvailable
          .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
          .toList(),
      onChanged: (v) => setState(() => courierSelected = v ?? couriersAvailable.first),
    );
  }

  Widget _weightField() {
    return TextField(
      controller: weightCtrl,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: 'Berat (gr)'),
    );
  }

  Widget _countrySearchField(InternationalViewModel vm) {
    return TextField(
      controller: countryCtrl,
      decoration: InputDecoration(
        hintText: 'Cari Negara (e.g. Singapore)',
        suffixIcon: showCountryResults
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    showCountryResults = false;
                    chosenCountryId = null;
                    countryCtrl.clear();
                    vm.searchCountry('');
                  });
                },
              )
            : const Icon(Icons.search),
      ),
      onChanged: (text) {
        final value = text.trim();
        if (value.isEmpty) {
          setState(() => showCountryResults = false);
          vm.searchCountry('');
          return;
        }
        setState(() => showCountryResults = true);
        vm.searchCountry(value);
      },
    );
  }

  Widget _countryResultsBox(InternationalViewModel vm) {
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
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          final country = list[i];
          final name = country.countryName ?? '';
          final id = country.countryId ?? '';

          return ListTile(
            title: Text(name),
            onTap: () {
              setState(() {
                chosenCountryId = id;
                countryCtrl.text = name;
                showCountryResults = false;
              });
            },
          );
        },
      ),
    );
  }

  void _onCalculatePressed(InternationalViewModel vm) {
    if (chosenCountryId != null && weightCtrl.text.isNotEmpty) {
      final w = int.tryParse(weightCtrl.text) ?? 0;
      vm.calculateInternationalCost(
        originCityId: '0',
        destinationCountryId: chosenCountryId!,
        weight: w,
        courier: courierSelected,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field!'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildOutputCard(InternationalViewModel vm) {
    return Card(
      color: Colors.blue[50],
      elevation: 2,
      child: vm.costList.status == Status.loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : _outputList(vm),
    );
  }

  Widget _outputList(InternationalViewModel vm) {
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
        final item = results[i];
        return _costTile(item);
      },
    );
  }

  Widget _costTile(dynamic item) {
    final name = (item.name ?? '');
    final code = (item.code ?? '');
    final service = (item.service ?? '');
    final description = (item.description ?? '');
    final currency = (item.currency ?? '');
    final cost = item.cost?.toString() ?? '';
    final etd = (item.etd ?? '');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          '$name ($code): $service',
          style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w700),
        ),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Biaya: $currency $cost'),
          const SizedBox(height: 4),
          Text('Estimasi sampai: $etd'),
        ]),
        leading: CircleAvatar(backgroundColor: Colors.blue[50], child: Icon(Icons.flight, color: Colors.blue[800])),
        onTap: () => _showCostDetail(item),
      ),
    );
  }

  void _showCostDetail(dynamic item) {
    final name = item.name ?? '';
    final code = item.code ?? '';
    final service = item.service ?? '';
    final description = item.description ?? '';
    final currency = item.currency ?? '';
    final cost = item.cost?.toString() ?? '';
    final etd = item.etd ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.flight, color: Colors.blue)),
            const SizedBox(width: 10),
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const Divider(),
          _detailRow('Nama Kurir', name),
          _detailRow('Kode', code),
          _detailRow('Layanan', service),
          _detailRow('Deskripsi', description),
          _detailRow('Biaya', '$currency $cost'),
          _detailRow('Estimasi Pengiriman', etd),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [SizedBox(width: 120, child: Text(label)), const Text(' : '), Expanded(child: Text(value.isEmpty ? '-' : value))]),
    );
  }

  Widget _loadingOverlay() {
    return Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.white)));
  }
}
