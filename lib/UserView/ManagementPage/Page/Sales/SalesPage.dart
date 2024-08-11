// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'FetchData.dart';
import 'Model.dart';
import 'SalesTable.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late Future<Map<String, Treatment>> treatmentsFuture;
  late Future<Map<String, Patient>> patientsFuture;

  @override
  void initState() {
    super.initState();
    treatmentsFuture = fetchTreatments();
    patientsFuture = fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Page'),
      ),
      body: FutureBuilder(
        future: Future.wait([treatmentsFuture, patientsFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final treatments = snapshot.data![0] as Map<String, Treatment>;
            final patients = snapshot.data![1] as Map<String, Patient>;

            return ListView.builder(
              itemCount: treatments.length,
              itemBuilder: (context, index) {
                final treatmentKey = treatments.keys.elementAt(index);
                final treatment = treatments[treatmentKey]!;
                final patient = patients[treatment.idpasien]!;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SalesTablePage()));
                            },
                            child: const Text('tabel')),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(patient.imageUrl),
                              radius: 30,
                            ),
                            const SizedBox(width: 16.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(patient.fullName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text('Doctor: ${treatment.doctor}'),
                                Text('Timestamp: ${treatment.timestamp}'),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: treatment.procedures.length,
                          itemBuilder: (context, procedureIndex) {
                            final procedure =
                                treatment.procedures[procedureIndex];
                            return ListTile(
                              title: Text(procedure.procedure),
                              subtitle: procedure.explanation != null
                                  ? Text(procedure.explanation!)
                                  : null,
                              trailing: Text('Rp ${procedure.price}'),
                            );
                          },
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Total: Rp ${treatment.procedures.fold<int>(0, (sum, item) => sum + item.price)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
