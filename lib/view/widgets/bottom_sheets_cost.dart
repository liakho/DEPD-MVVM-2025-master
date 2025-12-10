part of 'widgets.dart';

class BottomSheetCostDetail extends StatelessWidget {
  final Costs cost;
  const BottomSheetCostDetail({super.key, required this.cost});

  String rupiahMoneyFormatter(int? value) {
    if (value == null) return "Rp0,00";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.local_shipping, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cost.name ?? '',
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
          _row("Nama Kurir", cost.name),
          _row("Kode", cost.code),
          _row("Layanan", cost.service),
          _row("Deskripsi", cost.description),
          _row("Biaya", rupiahMoneyFormatter(cost.cost)),
          _row("Estimasi Pengiriman", "${cost.etd} hari"),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label)),
          const Text(" : "),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }
}
