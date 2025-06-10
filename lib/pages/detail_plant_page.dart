import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DetailPlantPage extends StatefulWidget {
  final int plantId;
  final String token;

  const DetailPlantPage({
    super.key,
    required this.plantId,
    required this.token,
  });

  @override
  State<DetailPlantPage> createState() => _DetailPlantPageState();
}

class _DetailPlantPageState extends State<DetailPlantPage> {
  final String baseUrl =
      'https://plant-parent-helper-be-103949415038.us-central1.run.app';
  late Future<Map<String, dynamic>> _plantDetailsFuture;

  final Map<String, double> conversionRates = {
    'USD': 0.000061,
    'EUR': 0.000057,
    'JPY': 0.0095,
  };

  @override
  void initState() {
    super.initState();
    _plantDetailsFuture = fetchAllDetails();
  }

  Future<Map<String, dynamic>> fetchAllDetails() async {
    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/plants/${widget.plantId}'),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        ),
        http.get(
          Uri.parse('$baseUrl/plants/${widget.plantId}/costs'),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        ),
      ]);

      if (responses[0].statusCode != 200) {
        throw Exception(
            'Gagal memuat detail tanaman: ${jsonDecode(responses[0].body)['msg']}');
      }

      if (responses[1].statusCode != 200) {
        throw Exception(
            'Gagal memuat biaya tanaman: ${jsonDecode(responses[1].body)['msg']}');
      }

      final plantData = jsonDecode(responses[0].body);
      final costsData = jsonDecode(responses[1].body);

      return {
        'plant': plantData,
        'costs': costsData,
      };
    } catch (e) {
      throw Exception(
          'Terjadi kesalahan jaringan atau server: ${e.toString()}');
    }
  }

  String formatTimeInZones(DateTime time) {
    final wib = time.add(const Duration(hours: 7));
    final wita = time.add(const Duration(hours: 8));
    final wit = time.add(const Duration(hours: 9));
    final london =
        time.add(const Duration(hours: 1)); // Adjust for DST if needed

    final formatter = DateFormat('dd MMM yyyy, HH:mm:ss');

    return '''
WIB   : ${formatter.format(wib)} (GMT+7)
WITA  : ${formatter.format(wita)} (GMT+8)
WIT   : ${formatter.format(wit)} (GMT+9)
London: ${formatter.format(london)} (GMT+1)
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Detail Tanaman", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _plantDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }

          if (snapshot.hasData) {
            final plantData = snapshot.data!['plant'];
            final plantCosts = snapshot.data!['costs'] as List;

            final totalCost = plantCosts.fold<int>(
                0, (sum, item) => sum + (item['amount'] as int));

            final currencyFormatter = NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plantData['imageUrl'] != null &&
                      plantData['imageUrl'].isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        plantData['imageUrl'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported,
                                size: 100, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(plantData['name'] ?? 'Nama Tanaman',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InfoTile(
                      icon: Icons.location_on,
                      text: plantData['location'] ?? 'Lokasi tidak diatur'),
                  InfoTile(
                      icon: Icons.note,
                      text: plantData['note'] ?? 'Tidak ada catatan'),
                  InfoTile(
                      icon: Icons.person,
                      text:
                          'Pemilik: ${plantData['user']?['name'] ?? 'Tidak diketahui'}'),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text("Rekap Biaya Perawatan",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(currencyFormatter.format(totalCost),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.green)),
                  const SizedBox(height: 4),
                  buildConversionSection(totalCost),
                  const SizedBox(height: 20),
                  const Text("Riwayat Biaya",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (plantCosts.isEmpty)
                    const Text("Belum ada catatan biaya.")
                  else
                    ...plantCosts.map((cost) {
                      String timeString =
                          cost['createdAt'].toString().replaceAll('Z', '');
                      final createdAt = DateTime.parse(timeString);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            const Icon(Icons.attach_money, color: Colors.green),
                        title: Text(currencyFormatter.format(cost['amount'])),
                        subtitle: Text(formatTimeInZones(createdAt),
                            style: const TextStyle(fontSize: 12)),
                      );
                    }),
                ],
              ),
            );
          }

          return const Center(child: Text("Data tidak ditemukan."));
        },
      ),
    );
  }

  Widget buildConversionSection(int totalCost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: conversionRates.entries.map((entry) {
        final converted = (totalCost * entry.value).toStringAsFixed(2);
        return Text("≈ $converted ${entry.key}",
            style: const TextStyle(fontSize: 14, color: Colors.grey));
      }).toList(),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
