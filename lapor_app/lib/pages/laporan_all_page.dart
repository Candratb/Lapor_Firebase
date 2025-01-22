import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_app/components/list_item.dart';
import 'package:lapor_app/models/akun.dart';
import 'package:lapor_app/models/laporan.dart';
import 'package:lapor_app/pages/detail_page.dart';  

class AllLaporan extends StatefulWidget {
  final Akun akun;
  const AllLaporan({super.key, required this.akun});

  @override
  State<AllLaporan> createState() => _AllLaporanState();
}

class _AllLaporanState extends State<AllLaporan> {
  final _firestore = FirebaseFirestore.instance;

  List<Laporan> listLaporan = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('laporan').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Tidak ada laporan.'));
            }

            listLaporan = snapshot.data!.docs.map<Laporan>((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Laporan(
                uid: data['uid'] ?? '',
                docId: doc.id,
                judul: data['judul'] ?? '',
                instansi: data['instansi'] ?? '',
                deskripsi: data['deskripsi'],
                gambar: data['gambar'],
                nama: data['nama'] ?? '',
                status: data['status'] ?? '',
                tanggal: (data['tanggal'] as Timestamp).toDate(),
                maps: data['maps'] ?? '',
                komentar: (data['komentar'] as List<dynamic>?)?.map((komentar) {
                  return Komentar(
                    nama: komentar['nama'] ?? '',
                    isi: komentar['isi'] ?? '',
                  );
                }).toList(),
              );
            }).toList();

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1 / 1.234,
              ),
              itemCount: listLaporan.length,
              itemBuilder: (context, index) {
                final laporan = listLaporan[index];

                return GestureDetector(
                  onTap: () {
                    // Navigasi ke DetailPage dengan mengirimkan data laporan dan akun
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailPage(),
                        settings: RouteSettings(
                          arguments: {
                            'laporan': laporan,
                            'akun': widget.akun, 
                          },
                        ),
                      ),
                    );
                  },
                  child: ListItem(
                    laporan: laporan,
                    akun: widget.akun,
                    isLaporanku: false,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
