import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_app/components/status_dialog.dart';
import 'package:lapor_app/components/styles.dart';
import 'package:lapor_app/models/akun.dart';
import 'package:lapor_app/models/laporan.dart';
import 'package:url_launcher/url_launcher.dart';

  class DetailPage extends StatefulWidget {
    const DetailPage({super.key});
    @override
    State<StatefulWidget> createState() => _DetailPageState();
  }

  class _DetailPageState extends State<DetailPage> {
    final bool _isLoading = false;

    String? status;

    Future launch(String uri) async {
      if (uri == '') return;
      if (!await launchUrl(Uri.parse(uri))) {
        throw Exception('Tidak dapat memanggil : $uri');
      }
    }

    void statusDialog(Laporan laporan) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatusDialog(
            laporan: laporan,
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      Laporan laporan = arguments['laporan'];
      Akun akun = arguments['akun'];

      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title:
              Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          laporan.judul,
                          style: headerStyle(level:3),
                        ),
                        SizedBox(height: 15),
                        laporan.gambar != ''
                            ? Image.network(laporan.gambar!)
                            : Image.asset('assets/istock-default.jpg'),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            laporan.status == 'Posted'
                                ? textStatus(
                                    'Posted', Colors.yellow, Colors.black)
                                : laporan.status == 'Process'
                                    ? textStatus(
                                        'Process', Colors.green, Colors.white)
                                    : textStatus(
                                        'Done', Colors.blue, Colors.white),
                            textStatus(
                                laporan.instansi, Colors.white, Colors.black),
                                if (akun.role == 'admin')
                                SizedBox(
                                  width: 250,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        status = laporan.status;
                                      });
                                      statusDialog(laporan);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text('Ubah Status'),
                                  ),
                                ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: const Center(child: Text('Nama Pengirim')),
                          subtitle: Center(
                            child: Text(laporan.nama),
                          ),
                          trailing: SizedBox(width: 45),
                        ),
                        ListTile(
                          leading: Icon(Icons.date_range),
                          title: Center(child: Text('Tanggal Laporan')),
                          subtitle: Center(
                              child: Text(DateFormat('dd MMMM yyyy')
                                  .format(laporan.tanggal))),
                          trailing: IconButton(
                            icon: Icon(Icons.location_on),
                            onPressed: () {
                              launch(laporan.maps);
                            },
                          ),
                        ),
                        SizedBox(height: 50),
                        Text(
                          'Deskripsi Laporan',
                          style: headerStyle(level:3),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(laporan.deskripsi ?? ''),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      );
    }

    Container textStatus(String text, var bgcolor, var textcolor) {
      return Container(
        width: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: bgcolor,
            border: Border.all(width: 1, color: primaryColor),
            borderRadius: BorderRadius.circular(25)),
        child: Text(
          text,
          style: TextStyle(color: textcolor),
        ),
      );
    }
  }