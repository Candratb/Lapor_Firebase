import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_app/components/list_item.dart';
import 'package:lapor_app/models/akun.dart';
import 'package:lapor_app/models/laporan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lapor_app/pages/detail_page.dart'; // Import the DetailPage

class MyLaporan extends StatefulWidget {
  final Akun akun;
  const MyLaporan({super.key, required this.akun});

  @override
  State<MyLaporan> createState() => _MyLaporanState();
}

class _MyLaporanState extends State<MyLaporan> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Laporan> listLaporan = [];

  @override
  void initState() {
    super.initState();
    getLaporan();
  }

  void getLaporan() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('laporan')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .get();

      setState(() {
        listLaporan = querySnapshot.docs.map((doc) {
          final data = doc.data();
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
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: listLaporan.isEmpty
            ? const Center(
                child: Text('Belum ada laporan yang Anda unggah.'),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1 / 1.234,
                ),
                itemCount: listLaporan.length,
                itemBuilder: (context, index) {
                  // Wrap the ListItem widget in a GestureDetector or InkWell
                  return GestureDetector(
                    onTap: () {
                      // Navigate to DetailPage and pass the laporan and akun
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(),
                          settings: RouteSettings(
                            arguments: {
                              'laporan': listLaporan[index],
                              'akun': widget.akun,
                            },
                          ),
                        ),
                      );
                    },
                    child: ListItem(
                      laporan: listLaporan[index],
                      akun: widget.akun,
                      isLaporanku: true,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
