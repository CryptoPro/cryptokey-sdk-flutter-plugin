import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import 'cert_bloc.dart';

class CertScreen extends StatelessWidget {
  const CertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CertsBloc>(
      create: (context) => getIt<CertsBloc>()..add(LoadCerts()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<CertsBloc>().add(CreateCert());
              },
              child: const Icon(Icons.add),
            ),
            body: BlocBuilder<CertsBloc, CertsState>(
              builder: (context, state) {
                if (state is CertsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CertsLoaded) {
                  if (state.certs.isEmpty) {
                    return const Center(child: Text('Сертификаты не найдены'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.certs.length,
                    itemBuilder: (context, index) {
                      final cert = state.certs[index];

                      final displayName =
                          cert.dn?["2.5.4.3"] ??
                          cert.friendlyName ??
                          "Name is empty";

                      String formatDate(int timestampInSeconds) {
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          timestampInSeconds * 1000,
                        );
                        final day = date.day.toString().padLeft(2, '0');
                        final month = date.month.toString().padLeft(2, '0');
                        final year = date.year;
                        return "$day.$month.$year";
                      }

                      String? dateString;

                      if (cert.notBefore == 0) {
                        dateString = "0";
                      } else {
                        dateString =
                            "${formatDate(cert.notBefore ?? 0)} - ${formatDate(cert.notAfter ?? 0)}";
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.insert_drive_file_outlined,
                                    color: Colors.black12,
                                    size: 36,
                                  ),
                                  title: Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text("тип: ${cert.type}"),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildParamRow(
                                        "Статус:",
                                        cert.state ?? "not found",
                                      ),
                                      const SizedBox(height: 8),
                                      _buildParamRow(
                                        "Срок действия:",
                                        dateString,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildParamRow(
                                        "Серийный номер:",
                                        cert.serialNumber ?? "not found",
                                      ),
                                      const SizedBox(height: 8),
                                      _buildParamRow(
                                        "ID сертификата (cid):",
                                        cert.cid ?? "—",
                                      ),
                                      const SizedBox(height: 8),
                                      _buildParamRow(
                                        "ID запроса (rid):",
                                        cert.rid ?? "—",
                                      ),
                                      const SizedBox(height: 8),
                                      _buildParamRow(
                                        "Хранилище:",
                                        cert.isClient == true
                                            ? "На устройстве"
                                            : "Облачное / Серверное",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Удалить сертификат/запрос',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text("Удаление сертификата"),
                                      content: const Text(
                                        "Вы уверены, что хотите удалить этот сертификат/запрос?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: const Text("Отмена"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                            context.read<CertsBloc>().add(
                                              DeleteCert(cert.rid, cert.cid),
                                            );
                                          },
                                          child: const Text(
                                            "Удалить",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: Text('Ошибка при загрузке сертификатов'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

Widget _buildParamRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 2,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    ],
  );
}
