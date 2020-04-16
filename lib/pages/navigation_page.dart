import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:teenfit/models/pengetahuan.dart';
import 'package:teenfit/models/healthcare.dart';
import 'package:teenfit/models/quiz.dart';
// import 'package:teenfit/models/user.dart';
import 'package:teenfit/models/rapor.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NavigationEnum {
  DASHBOARD,
  PROFILE,
  HEALTH_CARE,
  PENGETAHUAN,
  KUISIONER,
  LAPORAN,
  HEALTH_RESULT,
}
enum JawabanSalahBenar {
  SALAH,
  BENAR
}

enum JawabanSikap {
  SANGAT_SETUJU,
  SETUJU,
  RAGU_RAGU,
  TIDAK_SETUJU,
  SANGAT_TIDAK_SETUJU
}

class NavigationPage extends StatefulWidget {

  NavigationPage({Key key, this.userId}): super(key: key);

  final String userId;

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {

  // Variables and Constanta ----------------------------------------------- //
  NavigationEnum _menuIndex = NavigationEnum.DASHBOARD;
  List<JawabanSalahBenar> _jawabPengetahuan = new List(26);
  List<JawabanSikap> _jawabSikap = new List(15);
  List<JawabanSalahBenar> _jawabKepatuhan = new List(13);

  Map<dynamic, dynamic> _userMap;
  Map<dynamic, dynamic> _healthCareMap;
  Map<dynamic, dynamic> _laporanMap;
  final databaseReference = FirebaseDatabase.instance.reference();

  DateTime _selectedTime;
  int _selectedHari;
  List<DropdownMenuItem<int>> _hariList = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static const dotColor = Color(0xff999999);
  static const dotActiveColor = Color(0xffff3800);
  static const titleColor = Color(0xff1c1a1a);
  static const descriptionColor = Color(0xff707070);

  // HealthCare ------------------------------------ //
  int _beratBadan;
  int _tinggiBadan;
  double _lingkarLenganAtas;
  double _kadarHB;
  String _keluhan;
  String _tanggalDataDiri;
  bool _isLoading;
  final TextEditingController _tanggalMens = new TextEditingController();
  final _formKeyHealthCare = new GlobalKey<FormState>();

  // Laporan ------------------------------------ //
  int _nilaiPengetahuan = 0;
  int _nilaiSikap = 0;
  int _nilaiKepatuhan = 0;
  String _grade = "";
  String _tanggalQuiz = "";

  // Pengetahuan ------------------------------------ //
  final List<Pengetahuan> _pengetahuanList = [
    Pengetahuan(
      title: "Anemia itu apa sih ?",
      picture: "assets/images/pict01.png",
      description: "Anemia adalah kadar hemoglobin dalam tubuh yang nilainya kurang dari 12 g/dl pada remaja putri dan Wanita Usia Subur (WUS)."
    ),
    Pengetahuan(
      title: "Seperti ini nih kalo darah kita anemia",
      picture: "assets/images/pict02.png",
      description: "Anemia berbeda  dengan darah rendah. Anemia adalah kondisi kurangnya kadar Hb dalam darah, sedangkan darah rendah adalah kondisi di mana tekanan darah turun di bawah normal."
    ),
    Pengetahuan(
      title: "Yuk kenali tanda-tanda anemia",
      picture: "assets/images/pict03.png",
      description: "• 5L (lesu, letih, lemah, lelah, lalai)\n• Sakit kepala atau pusing\n• Mata berkunang–kunang\n• Mudah mengantuk\n• Cepat capai\n• Sulit konsentrasi\n• Pucat pada wajah, kelopak mata, bibir, kulit, kuku dan telapak tangan \n\nTeman-teman, anemia ada tanda dan gejalanya, biasanya kamu akan mengalami satu, dua bahkan ada yang mengalami semua tanda dan gejala tersebut."
    ),
    Pengetahuan(
      title: "Anemia disebabkan apa ya ?",
      picture: "assets/images/pict04.png",
      description: "Kekurangan zat besi dapat mengakibatkan anemia. Asupan zat besi sangat penting bagi tubuh kita, baik zat besi hewani maupun nabati serta asam folat dan vitamin B12 juga berperan penting dalam pembuatan hemoglogin.\nPerdarahan dapat menyebabkan anemia. Perdarahan dapat terjadi karena luka, menstruasi yang banyak dan lama juga perdarahan karena kecacingan.\nAnemia dapat terjadi karena proses hemolitik yaitu sel darah merah lebih cepat mati (usia sel darah merah normal 120 hari)."
    ),
    Pengetahuan(
      title: "Anemia bisa menyebabkan apa?",
      picture: "assets/images/pict05.png",
      description: "Bila kita terkena anemia akan berakibat saat ini dan nanti. Saat ini akan mengakibatkan daya tahan tubuh menurun atau gampang sakit, kebugaran menurun, jadi malas bergerak dan akan berakibat malas belajar sehingga prestasi menurunkan prestasi belajar dan produktivitas kerja."
    ),
    Pengetahuan(
      title: "Dampak akan datang",
      picture: "assets/images/pict06.png",
      description: "Bila remaja menderita anemia tidak diobati, lalu menikah dan hamil nantinya akan beresiko:\n1. Pada ibu hamil yang anemia akan terjadi perdarahan saat kehamilan, saat melahirkan dan setelah melahirkan.\n2. Pada bayi yang di kandung: akan terjadi resiko pertumbuhan janin terlambat (PJT), prematur, bayi lahir dengan berat rendah (BBLR)\n3. Setelah lahir, bayi akan beresiko gangguan tumbuh kembang anak yaitu stunting (Kerdil)\n4. Bayi yang dilahirkan dari ibu anemia akan beresiko anemia juga."
    ),
    Pengetahuan(
      title: "Bagaimana cara mencegah anemia?",
      picture: "assets/images/icon_search.png",
      description: "Langkah 1, makan makanan yang bergizi seimbang. langkah 2, minum tablet tambah darah (TTD) seminggu sekali. Makanan yang mengandung zat besi yaitu\n1. Zat besi heme (dari hewan) seperti: hati, daging, ayam, bebek, burung, dan ikan\n2. Zat besi non heme (dari non hewan) yaitu sayuran berwarna hijau tua (bayam, singkong, dan kankung, sawi, kacang panjang, daun kelor dll), kacang-kacangan seperti kacang hijau, tempe, tahu dan kacang merah. Minum tablet tambah darah (TTD) dengan kandungan zat besi setara 60 mg besi elemental dan 400 mcg asam folat."
    ),
    Pengetahuan(
      title: "Tablet tambah darah (TTD)",
      picture: "assets/images/pict08.png",
      description: "Sebaiknya  minum tablet tambah darah (TTD) menggunakan air putih atau air jeruk. Tidak boleh diminum menggunakan kopi, susu atau teh. Karena kopi, susu dan teh akan menurunkan dan menghambat penyerapan zat besi. Pada jeruk sebaliknya kandungan vitamin C-nya dapat meningkatkan penyerapan zat besi. Jangan lupa diminum teratur 1 kali/minggu "
    ),
    Pengetahuan(
      title: "Konsumsi TTD terus menerus",
      picture: "assets/images/pict09.png",
      description: "Boleh dan tidak membahayakan tubuh karena dalam tubuh ada zat autoregulasi zat besi, jadi aman. Namun ada yang mengalami efek samping setealah minum TTD. Seperti mual, muntah, nyeri ulu hati, tinja berwarna hitam, hal ini wajar dan tidak berbahaya. Sebaiknya TTD diminum setelah makan atau sebelum tidur."
    ),
    Pengetahuan(
      title: "Teman-teman tau gak apa itu Mina Aloe ?",
      picture: "assets/images/pict10.png",
      description: "Mia artinya ikan, Aloe artinya lidah buaya. Kita bisa mencegah anemia dengan mengkonsumsi ikan dan lidah buaya. Ini salah satu cara, dan masih banyak lagi makanan yang dapat meningkatkan kadar hemoglobin kita. Ikan lele mengandung protein (17,7%), lemak (4,8%), mineral (1,2%), dan air (76%). Sedangkan lidah buaya mengandung zat gizi yang diperlukan tubuh: vitamin A, B1, B2, B3, B12, C, E, choline, inositol, dan asam folat. Kandungan mineralnya: kalsium (Ca), magnesium (Mg), potasium (K), sodium (Na), besi (Fe), zinc (Zn), dan kromium (Cr)."
    )
  ];

// Quiz Pengetahuan ------------------------------------ //
  final List<Quiz> _pengetahuanQuiz = [
    Quiz(
      pertanyaan:"Anemia adalah tekanan darah rendah.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Kadar hemoglobin normal pada remaja adalah ≥ 10 gr/dl.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Sel darah merah berfungsi mengantarkan oksigen keseluruh tubuh.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Remaja mengalami anemia bila kadar hemoglobinnya kurang dari 12 g/dl.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Penyakit malaria dapat menyebabkan anemia.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Salah satu penyebab anemia ialah kurangnya mengkonsumsi zat besi.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Kecacingan pada remaja bukan merupakan penyebab anemia.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Menstruasi yang lama dan berlebihan tidak menyebabkan anemia.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Remaja putri yang melakukan diet vegetarian dapat mencegah anemia.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Remaja anemia akan tetap bugar dan sehat.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Tanda dan gejala anemia 5L (lesu, letih ,lemah, lelah dan lalai).",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Gejala fisik anemia: pucat di muka, kelompak mata, bibir, kuku dan telapak tangan.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Sering sakit kepala dan mata berkunang-kunang adalah gejala anemia.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Sayuran lebih banyak zat besinya dari pada daging, ikan dan telur.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Bayi yang lahir prematur salah satu penyebabnya adalah ibunya anemia.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Anemia remaja berakibat menurunkan prestasi belajar.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Remaja anemia tidak berdampak pada kehamilanya kelak.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Remaja anemia kelak akan melahirkan bayi yang sehat.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Sumber zat besi nabati adalah hati dan telur.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Minum TTD sebaiknya menggunakan air jeruk atau air putih.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Remaja sebaiknya minum TTD satu kali/bulan.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Minum TTD dapat menggunakan minuman teh, kopi atau susu.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Minum TTD secara terus-menerus berbahaya pada remaja.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Remaja minum TTD satu tablet, 1 kali/minggu.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Efek samping minum TTD, nyeri mual dan muntah berbahaya pada kesehatan.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Efek samping minum TTD adalah mual dan tinja berwarna hitam.",
      jawaban:1
    ),
  ];

// Quiz Sikap ------------------------------------ //
  final List<Quiz> _sikapQuiz = [
    Quiz(
      pertanyaan:"Remaja putri sebaiknya memiliki kadar hemoglobin ≥ 12 g/dl.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Remaja sehat sebaiknya diet vegetarian/sayuran.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Minum TTD lebih baik menggunakan minuman susu.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Anemia remaja segera diatasi karena berakibat pada kehamilannya kelak.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Keluhan sering pusing, pucat dan mudah lelah segera diperiksakan ke puskesmas/dokter.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Semua remaja putri minum TTD 1 kali/minggu.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Minum TTD dapat menimbulkan efek samping tinja/kotoran berwarna hitam.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"TTD diberikan pada remaja yng anemia atau yang sakit saja.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Saya tidak perlu minum TTD karena makanan saya sudah memenuhi nilai gizi.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Saya tidak suka dengan sayuran dan dapat digantikan dengan minum vitamin.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Saya akan Minum TTD 1 kali/minggu sesuai dengan petunjuk petugas kesehatan.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Saya tidak akan minum TTD bila tidak diijinkan oleh orang tua.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Jika lupa minum TTD saya akan segera minum saat ingat.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Setelah minum TTD bila mengalami mual muntah saya tidak akan kuatir karena tidak berbahaya.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Bila saya cepat lelah, mudah ngantuk dan sering pusing, saya akan periksa ke dokter/puskesmas.",
      jawaban:1
    ),
  ];

// Quiz Pengetahuan ------------------------------------ //
  final List<Quiz> _kepatuhanQuiz = [
    Quiz(
      pertanyaan:"Saya kadang-kadang lupa minum TTD 1 kali/minggu.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Dalam 1 bulan terakhir, ada jadwal yang terlewat/lupa minum TTD.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Dalam 1 bulan terakhir, tidak ada jadwal yang terlewat/lupa minum TTD.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Saya selalu ingat untuk minum TTD 1 kali/minggu.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Setiap kali saya ada acara atau berpergian biasanya terlewati tidak minum TTD.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Setiap kali saya ada acara atau berpergian saya selalu minum TTD.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Saya tidak pernah minum TTD setiap minggu.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Minggu lalu saya lupa minum TTD.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Saya tidak minum TTD karena merasa baik-baik saja/sehat.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Saya tidak suka minum TTD karena menimbulkan efek samping mual/muntah, nyeri uluhati dan BAB berwarna hitam.",
      jawaban:0
    ),
    Quiz(
      pertanyaan:"Saya tetap minum TTD walaupun menimbulkan efek samping mual/muntah, nyeri uluhati dan BAB berwarna hitam.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Saya minum TTD menggunakan air jeruk atau air putih.",
      jawaban:1
    ),
    Quiz(
      pertanyaan:"Saya minum TTD menggunakan minuman kopi, susu atau teh.",
      jawaban:0
    ),
  ];

// Init State ---------------------------------------------------------------------------- //
  @override
  void initState() {
    super.initState();

    _selectedHari = 0;
    loadHariList();
    _selectedTime = DateTime.now();
    _isLoading = false;

    getUserMap();
    getHealthResult();
    getRapor();

    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
      .initialize(
        initializationSettings, onSelectNotification: onSelectNotification
      )
      .then(
        (init)
        {
          setupNotification();
        }
      );
  }

// Push Notofication ---------------------------------------------------------------------//
  Future createNotificationNow() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'TTD', 'TeenFit weekly notification', 'Tablet tambah darah notification',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Ayo minum TTD',
      'Sudah waktunya minum Tablet Tambah Darah loh',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future createWeeklyNotification() async {
    var hari = Day.Monday;
    var time = Time(_selectedTime.hour, _selectedTime.minute, _selectedTime.second);
    // print(_selectedTime);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'TTD', 'TeenFit weekly notification', 'Tablet tambah darah notification',
      importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    String _toTwoDigitString(int value) {
      return value.toString().padLeft(2, '0');
    }

    switch(_selectedHari)
    {
      case 0:
        hari = Day.Monday;
      break;
      case 1:
        hari = Day.Thursday;
      break;
      case 2:
        hari = Day.Wednesday;
      break;
      case 3:
        hari = Day.Tuesday;
      break;
      case 4:
        hari = Day.Friday;
      break;
      case 5:
        hari = Day.Saturday;
      break;
      case 6:
        hari = Day.Sunday;
      break;
      default:
        hari = Day.Monday;
      break;
    }

    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      0,
      'Ayo minum TTD',
      'Waktunya minum tablet tambah darah ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
      hari,
      time,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("TeenFit", style: TextStyle(fontSize: 18.0, color: Colors.indigo)),
          // title: Text("${_userMap['name']}"),
          content: Text("Jangan Lupa Minum Tablet Tambah Darah ya", style: TextStyle(fontSize: 14.0, color: Colors.indigo),),
        );
      },
    );
  }

  Future<void> setupNotification() async {
    try {
      await createWeeklyNotification();
    } catch (e) {
      // print(e.toString());
    }
  }

  // Widget --------------------------------------------------------------- //
  Widget navigation() {
    switch (_menuIndex) {
      case NavigationEnum.DASHBOARD:
          return showDashboard();
        break;
      case NavigationEnum.PROFILE:
        setState(() {
          _isLoading = false;
        });
        getUserMap();
        return showProfile();
        break;
      case NavigationEnum.HEALTH_CARE:
        return showHealthCare();
      case NavigationEnum.HEALTH_CARE:
        getHealthResult();
        return showHealthResult();
        break;
      case NavigationEnum.KUISIONER:
        return showKuisioner();
        break;
      case NavigationEnum.PENGETAHUAN:
        return showPengetahuan();
        break;
      case NavigationEnum.LAPORAN:
        // createNotificationNow();
        // createWeeklyNotification();
        setupNotification();
        getRapor();
        return showLaporan();
        break;
      case NavigationEnum.HEALTH_RESULT:
        return showHealthResult();
        break;
      default:
        return showDashboard();
    }
  }

  // Dashboard ---------------------------------------------------- //
  Widget showDashboard()
  {
    return new Stack(
      children: <Widget>[
        Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Image.asset('assets/teenfit-icon.png'),
          )
        ),
        Container(
          margin: EdgeInsets.only(top: 130),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: GridView.count(
              crossAxisCount: 2,
              children: <Widget>[
                createGridItem(0),
                createGridItem(1),
                createGridItem(2),
                createGridItem(3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget createGridItem(int position) {
    var color = Colors.white;
    var icondata = Icons.add;
    var textMenu = "TeenFit";

    switch (position) {
      case 0:
        color = Colors.blue;
        icondata = Icons.local_hospital;
        textMenu = "Data Diri";
        break;
      case 1:
        color = Colors.red[800];
        icondata = Icons.format_list_bulleted;
        textMenu = "Kuisioner";
        break;
      case 2:
        color = Colors.amber[700];
        icondata = Icons.find_in_page;
        textMenu = "Pengetahuan";
        break;
      case 3:
        color = Colors.teal;
        icondata = Icons.library_books;
        textMenu = "Rapor";
        break;
    }

    return Builder(builder: (context) {
      return Padding(
        padding:
            const EdgeInsets.only(left: 10.0, right: 10, bottom: 5, top: 5),
        child: Card(
          elevation: 10,
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: Colors.white),
          ),
          child: InkWell(
            onTap: ()
            {
              switch (position) {
                case 0:
                  setState(() {
                    if(_healthCareMap == null)
                    {
                      _menuIndex = NavigationEnum.HEALTH_CARE;
                    }
                    else if(_healthCareMap.length > 0)
                    {
                      _menuIndex = NavigationEnum.HEALTH_RESULT;
                    }
                  });
                  // print('Menu index: $position');
                  break;
                case 1:
                  setState(() {
                    _menuIndex = NavigationEnum.KUISIONER;
                  });
                  // print('Menu index: $position');
                  break;
                case 2:
                  setState(() {
                    _menuIndex = NavigationEnum.PENGETAHUAN;
                  });
                  // print('Menu index: $position');
                  break;
                case 3:
                  setState(() {
                    _menuIndex = NavigationEnum.LAPORAN;
                  });
                  // print('Menu index: $position');
                  break;
              }
            },
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    icondata,
                    size: 40,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      textMenu,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

// Profile ---------------------------------------------------- //
  void getUserMap()
  {
    databaseReference.child("user").orderByChild("userId").equalTo(widget.userId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic>  values = snapshot.value;
      values.forEach((key,values) {
        // print(values);
        // print(values["name"]);
        _userMap = values;
        // print(_userMap);
      });
    });
  }

  Widget showProfile() {
    // print("lalalalala");
    return new Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(7.0),
                child:Text("Nama : ${_userMap['name']}",
                  style: TextStyle(fontSize: 14.0, color: Colors.black)),
              ),
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Text("Tanggal Lahir : ${_userMap['birthDate']}",
                  style: TextStyle(fontSize: 14.0, color: Colors.black)),
              ),
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Text("Pendidikan: ${textPendidikan(_userMap['pendidikan'])}",
                  style: TextStyle(fontSize: 14.0, color: Colors.black)),
              ),
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Text("Set Notifikasi TTD:",
                  style: TextStyle(fontSize: 14.0, color: Colors.black)),
              ),
              showHariInput(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  color: Color(0xffdef8ff),
                  child: setTime(),
                ),
              ),
              Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SizedBox(
                    height: 36.0,
                    child: new RaisedButton(
                      elevation: 5.0,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                      color: Colors.blue,
                      child: new Text('Submit',
                          style: new TextStyle(fontSize: 14.0, color: Colors.white)),
                      onPressed: (){
                        // print("Set Notifikasi---------");
                        // createWeeklyNotification();
                        // createNotificationNow();
                      },
                    ),
                  )
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  void loadHariList() {
    _hariList = [];
    _hariList.add(new DropdownMenuItem(
      child: new Text('Senin'),
      value: 0,
    ));
    _hariList.add(new DropdownMenuItem(
      child: new Text('Selasa'),
      value: 1,
    ));
    _hariList.add(new DropdownMenuItem(
      child: new Text('Rabu'),
      value: 2,
    ));
    _hariList.add(new DropdownMenuItem(
      child: new Text('Kamis'),
      value: 3,
    ));
    _hariList.add(new DropdownMenuItem(
      child: new Text('Jumat'),
      value: 4,
    ));
    _hariList.add(new DropdownMenuItem(
      child: new Text('Sabtu'),
      value: 5,
    ));
    _hariList.add(new DropdownMenuItem(
      child: new Text('Minggu'),
      value: 6,
    ));
  }

  Widget showHariInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: InputDecorator(
        decoration: InputDecoration(
          icon: const Icon(Icons.view_day),
        ),
        child: new DropdownButtonHideUnderline(
          child: new DropdownButton(
            isDense: true,
            autofocus: false,
            items: _hariList,
            value: _selectedHari,
            onChanged: (value) {
              setState(() {
                _selectedHari = value;
                // print(value);
              });
            },
            isExpanded: true,
          )
        )
      )
    );
  }

  Widget setTime() {
    return new TimePickerSpinner(
      is24HourMode: false,
      normalTextStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey
      ),
      highlightedTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.indigo
      ),
      spacing: 14,
      itemHeight: 36,
      isForce2Digits: true,
      onTimeChange: (time) {
        setState(() {
          _selectedTime = time;
          // print(_selectedTime);
        });
      },
    );
  }

  String textPendidikan(int pendidikan)
  {
    switch(pendidikan)
    {
      case 0:
        return "SLTP";
      break;
      case 0:
        return "SLTA";
      break;
      case 0:
        return "SMK";
      break;
    }
    return "";
  }

// Health Care ---------------------------------------------------- //
  Widget showHealthCare() {
    return new Container(
      padding: EdgeInsets.all(25.0),
      child: new Form(
        key: _formKeyHealthCare,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            showBBInput(),
            showLLAInput(),
            showTBInput(),
            showHBInput(),
            showTanggalMensInput(),
            showKeluhanInput(),
            showSubmitHealthCare()
          ],
        ),
      )
    );
  }

  Widget showBBInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Berat Badan',
          icon: new Icon(
            Icons.local_hospital,
            color: Colors.grey,
          )
        ),
        validator: (value) => value.isEmpty ? 'Berat Badan harus diisi' : null,
        onSaved: (value) => _beratBadan = int.parse(value),
      ),
    );
  }

  Widget showLLAInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Lingkar Lengan Atas',
          icon: new Icon(
            Icons.local_hospital,
            color: Colors.grey,
          )
        ),
        validator: (value) => value.isEmpty ? 'Lingkar Lengan Atas harus diisi' : null,
        onSaved: (value) => _lingkarLenganAtas = double.parse(value),
      ),
    );
  }

  Widget showTBInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Tinggi Badan',
          icon: new Icon(
            Icons.local_hospital,
            color: Colors.grey,
          )
        ),
        validator: (value) => value.isEmpty ? 'Tinggi Badan harus diisi' : null,
        onSaved: (value) => _tinggiBadan = int.parse(value),
      ),
    );
  }

  Widget showHBInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Kadar Hemoglobin',
          icon: new Icon(
            Icons.local_hospital,
            color: Colors.grey,
          )
        ),
        validator: (value) => value.isEmpty ? 'Kadar Hemoglobin harus diisi' : null,
        onSaved: (value) => _kadarHB = double.parse(value),
      ),
    );
  }

  Widget showTanggalMensInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new Row(children: <Widget>[
        new Expanded(
          child: new TextFormField(
            decoration: new InputDecoration(
              icon: const Icon(Icons.local_hospital),
              hintText: 'mm/dd/yyyy',
              labelText: 'Tanggal Mens Terakhir',
            ),
            controller: _tanggalMens,
            keyboardType: TextInputType.datetime,
            autofocus: false,
            onSaved: (value) => _tanggalMens.text = value,
        )),
        new IconButton(
          icon: new Icon(Icons.event),
          tooltip: 'Pilih Tanggal',
          onPressed: (() {
            _chooseDate(context, _tanggalMens.text);
          }),
        )
      ]),
    );
  }

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now) ? initialDate : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now());

    if (result == null) return;

    setState(() {
      _tanggalMens.text = new DateFormat.yMd().format(result);
    });
  }

  DateTime convertToDate(String input) {
    try
    {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  Widget showKeluhanInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Keluhan',
          icon: new Icon(
            Icons.local_hospital,
            color: Colors.grey,
          )
        ),
        // validator: (value) => value.isEmpty ? 'Keluhan harus diisi' : null,
        onSaved: (value) => _keluhan = value,
      ),
    );
  }

  Widget showSubmitHealthCare() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(8.0)),
          color: Colors.blue,
          child: new Text('Simpan',
              style: new TextStyle(fontSize: 16.0, color: Colors.white)),
          onPressed: validateAndSubmitHealthCare,
        ),
      )
    );
  }

  Widget showSubmitHealthResult() {
    return new Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom:30),
        child: SizedBox(
        height: 35.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0)),
          color: Colors.blue,
          child: new Text('Tambah Data Diri',
              style: new TextStyle(fontSize: 14.0, color: Colors.white)),
          onPressed: (){
            setState(() {
              _menuIndex = NavigationEnum.HEALTH_CARE;
            });
            // print("hey---------");
          },
        ),
      )
      )
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  void validateAndSubmitHealthCare() async {
    if (validateAndSaveHealthCare()) {
      try {
        addNewHealthCare(widget.userId);
        setState(() {
          _isLoading = true;
        });
        getHealthResult();

        setState(() {
          // print("--------------------------------------------------");
          _menuIndex = NavigationEnum.HEALTH_RESULT;
        });
        resetFormHealthCare();
      } catch (e) {
        // print('Error: $e');
        setState(() {
          _formKeyHealthCare.currentState.reset();
        });
      }
    }
  }

  bool validateAndSaveHealthCare() {
    final form = _formKeyHealthCare.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    else{
      _isLoading = false;
    }
    return false;
  }

  addNewHealthCare(String userId) {
    _tanggalDataDiri = new DateFormat.yMd().format(DateTime.now()).toString();
    if (userId.length > 0) {
      HealthCare healthCare = new HealthCare(
        userId,
        _beratBadan,
        _tinggiBadan,
        _lingkarLenganAtas,
        _kadarHB,
        _tanggalMens.text,
        _keluhan,
        _tanggalDataDiri
      );

      databaseReference.child("healthCare").push().set(healthCare.toJson());
    }
  }

  void resetFormHealthCare() {
    _formKeyHealthCare.currentState.reset();
    _tanggalMens.clear();
  }

// Health Result ---------------------------------------------------- //
  Future getHealthResult () async
  {
    await databaseReference.child("healthCare").orderByChild("userId").equalTo(widget.userId).once().then((DataSnapshot snapshot) async {
      if(snapshot.value != null)
      {
        _healthCareMap = snapshot.value;
        // print(snapshot.value);
        // print(_healthCareMap);
      }
    });
  }

  double imt (int _bb, int _tb)
  {
    return (_bb / (_tb / 100));
  }

  String statusIMT (double _imt)
  {
    String _statusIMT = "";
    if(_imt <= 18.4) {
      _statusIMT = "Berat badan kurang";
    }
    else if (_imt > 18.4 && _imt <= 24.9) {
      _statusIMT = "Berat badan ideal";
    }
    else if (_imt > 24.9 && _imt <= 29.9) {
      _statusIMT = "Berat badan berlebih";
    }
    else if (_imt > 29.9 && _imt <= 39.9) {
      _statusIMT = "Gemuk";
    }
    else {
      _statusIMT = "Sangat gemuk";
    }

    return _statusIMT;
  }

  String statusAnemia (var _kadarHB)
  {
    String _statusAnemia;
    if(_kadarHB <= 8.0) {
      _statusAnemia = "Anemia berat";
    }
    else if (_kadarHB > 8.0 && _kadarHB <= 10.9) {
      _statusAnemia = "Anemia sedang";
    }
    else if (_kadarHB > 11.0 && _kadarHB <= 11.9) {
      _statusAnemia = "Anemia ringan";
    }
    else {
      _statusAnemia = "Non anemia";
    }

    return _statusAnemia;
  }

  String statusGizi(var lla)
  {
    return (lla < 23.5 ? "Kekurangan gizi" : "Gizi cukup");
  }

  String nextHaid (String _tanggalMens)
  {
    return DateFormat.yMd().format(convertToDate(_tanggalMens).add(new Duration(days: 28))).toString();
  }

  Widget showHealthResult() {
    setState(() {
      // print("--------------------------------------------------");
      _isLoading = false;
    });
    return new Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top:11.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text("DATA DIRI", style: TextStyle(fontSize: 16.0, color: Colors.black))
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 75.0),
          child: ListView(
            children: _buildListHealtCare(context),
          ),
        ),
        showSubmitHealthResult()
      ]
    );
  }

  List<Widget> _buildListHealtCare(BuildContext context) {
    List<Widget> widgets = [];
    if(_healthCareMap != null){
      _healthCareMap.forEach((key,values) {
        widgets.add(
          Card(
            color: Color(0xffdef8ff),
            child: Padding (
              padding: const EdgeInsets.all(10.0),
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child:Text("Tanggal Input: ${_healthCareMap[key]['tanggalDataDiri']}\n----------------------------------------------------------------------",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child:Text("Berat badan: ${_healthCareMap[key]['beratBadan']}\nBerat badan: ${_healthCareMap[key]['tinggiBadan']}\nIndex Masa Tubuh (IMT): ${imt(_healthCareMap[key]['beratBadan'], _healthCareMap[key]['tinggiBadan']).round()}\nStatus IMT: ${statusIMT(imt(_healthCareMap[key]['beratBadan'], _healthCareMap[key]['tinggiBadan']))}",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text("Lingkar lengan atas: ${_healthCareMap[key]['lingkarLenganAtas']}\nStatus gizi: ${statusGizi(_healthCareMap[key]['lingkarLenganAtas'])}",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text("Kadar Hemoglobin: ${_healthCareMap[key]['kadarHB']}\nStatus anemia: ${statusAnemia(_healthCareMap[key]['kadarHB'])}",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text("Tanggal haid: ${_healthCareMap[key]['tanggalMens']}\nPerkiraan haid berikutnya: ${nextHaid(_healthCareMap[key]['tanggalMens'])}",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
    else
    {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text("Data kosong silahkan klik Tambah Data Diri",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.0, color: Colors.black)),
        ),
      );
    }
    return widgets;
  }

// Laporan ---------------------------------------------------- //
  Future getRapor () async
  {
    await databaseReference.child("rapor").orderByChild("userId").equalTo(widget.userId).once().then((DataSnapshot snapshot) async {
      if(snapshot.value != null)
      {
        _laporanMap = snapshot.value;
        // print(snapshot.value);
        // print(_laporanMap);
      }
    });
  }

  Widget showLaporan() {
    setState(() {
      // print("--------------------------------------------------");
      _isLoading = false;
    });
    return new Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top:11.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text("Hasil Kuisioner", style: TextStyle(fontSize: 16.0, color: Colors.black))
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 75.0),
          child: ListView(
            children: _buildListLaporan(context),
          ),
        ),
        showSubmitLaporan()
      ]
    );
  }

  List<Widget> _buildListLaporan(BuildContext context) {
    List<Widget> widgets = [];
    if(_laporanMap != null){
      _laporanMap.forEach((key,values) {
        widgets.add(
          Card(
            color: Color(0xffdef8ff),
            child: Padding (
              padding: const EdgeInsets.all(10.0),
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child:Text("Tanggal Input: ${_laporanMap[key]['tanggalQuiz']}\n----------------------------------------------------------------------",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child:Text("Nilai Pengetahuan: ${_laporanMap[key]['nilaiPengetahuan']}",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text("Nilai Sikap: ${_laporanMap[key]['nilaiSikap']}",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text("Nilai Kepatuhan: ${_laporanMap[key]['nilaiKepatuhan']}",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text("Grade: ${_laporanMap[key]['grade']}",
                      style: TextStyle(fontSize: 12.0, color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
    else
    {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text("Data kosong silahkan klik Isi Kuisioner",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.0, color: Colors.black)),
        ),
      );
    }
    return widgets;
  }

    Widget showSubmitLaporan() {
    return new Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom:30),
        child: SizedBox(
        height: 35.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0)),
          color: Colors.blue,
          child: new Text('Isi Kuisioner',
              style: new TextStyle(fontSize: 14.0, color: Colors.white)),
          onPressed: (){
            resetKuisioner();
            setState(() {
              _menuIndex = NavigationEnum.KUISIONER;
            });
            // print("Isi Kuisioner---------");
          },
        ),
      )
      )
    );
  }

// Pengetahuan ---------------------------------------------------- //
  Widget showPengetahuan() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: new Swiper.children(
        index: 0,
        autoplay: false,
        loop: false,
        pagination: new SwiperPagination(
          margin: EdgeInsets.only(bottom: 20.0),
          builder: DotSwiperPaginationBuilder(
            color: dotColor,
            activeColor: dotActiveColor,
            size: 5.0,
            activeSize: 7.0,
          ),
        ),
        control: new SwiperControl(
          iconNext: null,
          iconPrevious: null
        ),
        children: _buildPage(context),
      ),
    );
  }

  List<Widget> _buildPage(BuildContext context) {
    List<Widget> widgets = [];
    for(int i=0; i<_pengetahuanList.length; i++) {
      Pengetahuan _pengetahuan = _pengetahuanList[i];
      widgets.add(
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height/25.0,
          ),
          child: ListView(
            children:
            <Widget>[
              Image.asset(
                _pengetahuan.picture,
                height: MediaQuery.of(context).size.height/5,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height/25.0,
                ),
              ),
              Center(
                child: Text(
                  _pengetahuan.title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height/50.0,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height/20.0,
                ),
                child: Text(
                  _pengetahuan.description,
                  style: TextStyle(
                    color: descriptionColor,
                    fontSize: 11.0,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

// Quiz Pengetahuan ------------------------------------------------------- //
  Widget showKuisioner() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: new Swiper.children(
        // index: 0,
        autoplay: false,
        loop: false,
        pagination: new SwiperPagination(
          margin: EdgeInsets.only(bottom: 20.0),
          builder: FractionPaginationBuilder(
            color: dotColor,
            activeColor: dotActiveColor,
            fontSize: 12,
            activeFontSize: 12
          ),
        ),
        control: new SwiperControl(
          iconNext: null,
          iconPrevious: null
        ),
        children: _buildKuisioner(context),
      ),
    );
  }

  List<Widget> _buildKuisioner(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(showPengetahuanQuizIntro());
    for(int i=0; i<_pengetahuanQuiz.length; i++) {
      widgets.add(
        ListView(
          children:
          <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, MediaQuery.of(context).size.width/8.0, 25.0, 25.0),
                      child: Text(
                      "Soal Pengetahuan",
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                      child: Text(
                      "No: ${i+1}",
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                      child: Text(
                      "${_pengetahuanQuiz[i].pertanyaan}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/5.0),
                    child: ListTile(
                      title: const Text('Benar',
                          style: TextStyle(
                          color: titleColor,
                          fontSize: 14.0,
                        ),
                      ),
                      leading: Radio(
                        value: JawabanSalahBenar.BENAR,
                        groupValue: _jawabPengetahuan[i],
                        onChanged: (JawabanSalahBenar value) {
                          setState(() {
                            _jawabPengetahuan[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/5.0),
                    child: ListTile(
                      title: const Text('Salah',
                          style: TextStyle(
                          color: titleColor,
                          fontSize: 14.0,
                        ),
                      ),
                      leading: Radio(
                        value: JawabanSalahBenar.SALAH,
                        groupValue: _jawabPengetahuan[i],
                        onChanged: (JawabanSalahBenar value) {
                          setState(() {
                            _jawabPengetahuan[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

// Quiz Sikap ------------------------------------------------------- //
    widgets.add(showNextQuizSikap());
    for(int i=0; i<_sikapQuiz.length; i++) {
      widgets.add(
        ListView(
          children:
          <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, MediaQuery.of(context).size.width/15.0, 25.0, 10.0),
                      child: Text(
                      "Soal Sikap",
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                      child: Text(
                      "No: ${i+1}",
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 8.0),
                      child: Text(
                      "${_sikapQuiz[i].pertanyaan}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/8.0),
                    child: ListTile(
                      title: const Text('Sangat Setuju',
                          style: TextStyle(
                          color: titleColor,
                          fontSize: 14.0,
                        ),
                      ),
                      leading: Radio(
                        value: JawabanSikap.SANGAT_SETUJU,
                        groupValue: _jawabSikap[i],
                        onChanged: (JawabanSikap value) {
                          setState(() {
                            _jawabSikap[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/8.0),
                    child: ListTile(
                      title: const Text('Setuju',
                          style: TextStyle(
                          color: titleColor,
                          fontSize: 14.0,
                        ),
                      ),
                      leading: Radio(
                        value: JawabanSikap.SETUJU,
                        groupValue: _jawabSikap[i],
                        onChanged: (JawabanSikap value) {
                          setState(() {
                            _jawabSikap[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/8.0),
                    child: ListTile(
                      title: const Text('Ragu-Ragu',
                          style: TextStyle(
                          color: titleColor,
                          fontSize: 14.0,
                        ),
                      ),
                      leading: Radio(
                        value: JawabanSikap.RAGU_RAGU,
                        groupValue: _jawabSikap[i],
                        onChanged: (JawabanSikap value) {
                          setState(() {
                            _jawabSikap[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/8.0),
                    child: ListTile(
                      title: const Text('Tidak Setuju',
                          style: TextStyle(
                          color: titleColor,
                          fontSize: 14.0,
                        ),
                      ),
                      leading: Radio(
                        value: JawabanSikap.TIDAK_SETUJU,
                        groupValue: _jawabSikap[i],
                        onChanged: (JawabanSikap value) {
                          setState(() {
                            _jawabSikap[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/8.0),
                    child: ListTile(
                      title: const Text('Sangat Tidak Setuju',
                          style: TextStyle(
                          color: titleColor,
                          fontSize: 14.0,
                        ),
                      ),
                      leading: Radio(
                        value: JawabanSikap.SANGAT_TIDAK_SETUJU,
                        groupValue: _jawabSikap[i],
                        onChanged: (JawabanSikap value) {
                          setState(() {
                            _jawabSikap[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
// Quiz Kepatuhan ------------------------------------------------------- //
    widgets.add(showNextQuizKepatuhan());
    for(int i=0; i<_kepatuhanQuiz.length; i++) {
      widgets.add(
        ListView(
          children:
          <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, MediaQuery.of(context).size.width/8.0, 25.0, 25.0),
                      child: Text(
                      "Soal Kepatuhan",
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                      child: Text(
                      "No: ${i+1}",
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25.0),
                      child: Text(
                      "${_kepatuhanQuiz[i].pertanyaan}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/5.0),
                    child: ListTile(
                      title: const Text('Ya',
                          style: TextStyle(
                          color: titleColor,
                          fontSize: 14.0,
                        ),
                      ),
                      leading: Radio(
                        value: JawabanSalahBenar.BENAR,
                        groupValue: _jawabKepatuhan[i],
                        onChanged: (JawabanSalahBenar value) {
                          setState(() {
                            _jawabKepatuhan[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/5.0),
                    child: ListTile(
                      title: const Text('Tidak',
                          style: TextStyle(
                          color: titleColor,
                          fontSize: 14.0,
                        ),
                      ),
                      leading: Radio(
                        value: JawabanSalahBenar.SALAH,
                        groupValue: _jawabKepatuhan[i],
                        onChanged: (JawabanSalahBenar value) {
                          setState(() {
                            _jawabKepatuhan[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    widgets.add(showFinishQuiz());
    return widgets;
  }

  void resetKuisioner()
  {
    _nilaiPengetahuan = 0;
    _nilaiSikap = 0;
    _nilaiKepatuhan = 0;
    _jawabPengetahuan = new List(26);
    _jawabSikap = new List(15);
    _jawabKepatuhan = new List(13);
  }

  Widget showPengetahuanQuizIntro()
  {
    return ListView(
      children:
      <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(25.0, MediaQuery.of(context).size.width/8.0, 25.0, 25.0),
                  child: Text(
                  "Kuisioner Pengetahuan Anemia Pada Remaja",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.0),
                  child: Text(
                  "Petunjuk pengisian kuesioner I\n\nPilihlah jawaban Benar atau Salah yang kamu anggap tepat pada tiap pertanyaan yang tersedia.",
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showNextQuizSikap() {
    return ListView(
      children:
      <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(25.0, MediaQuery.of(context).size.width/10.0, 25.0, 10.0),
                  child: Text(
                  "Kuisioner Sikap Anemia Pada Remaja",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.0),
                  child: Text(
                  "Petunjuk pengisian kuesioner II\n\n• Sangat Setuju\n• Setuju\n• Ragu-ragu\n• Tidak Setuju\n• Sangat tidak setuju\n\nPilihlah jawaban yang kamu anggap paling sesuai dengan pendapat kamu, dan menggambarkan diri kamu sebenarnya.",
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showNextQuizKepatuhan() {
    return ListView(
      children:
      <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(25.0, MediaQuery.of(context).size.width/10.0, 25.0, 10.0),
                  child: Text(
                  "Kuisioner Kepatuhan Anemia Pada Remaja",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.0),
                  child: Text(
                  "Petunjuk pengisian kuesioner III\n\nPililah jawaban Benar atau salah yang kamu anggap tepat berdasarkan pada tiap pertanyaan yang tersedia.",
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showFinishQuiz() {
    return ListView(
      children:
      <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(25.0, MediaQuery.of(context).size.width/10.0, 25.0, 10.0),
                  child: Text(
                  "Kuisioner Finish",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.0),
                  child: Text(
                  "Terimakasih telah mengisi seluruh kuisioner yang ada. Silahkan klik tombol Finish Kuisioner untuk menyimpan hasil dan melihat rapor kuisioner.",
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 12.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 36.0,
                  child: new RaisedButton(
                    elevation: 5.0,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0)),
                    color: Colors.blue,
                    child: new Text('Finish Kuisioner',
                        style: new TextStyle(fontSize: 14.0, color: Colors.white)),
                    onPressed: (){
                      hitungNilaiRapor();
                      // print(_jawabPengetahuan);
                      // print(_jawabSikap);
                      // print(_jawabKepatuhan);
                      addNewRapor(widget.userId);
                      setState(() {
                        _menuIndex = NavigationEnum.LAPORAN;
                      });
                      // print("Finish---------");
                    },
                  ),
                )
              )
            ],
          ),
        ),
      ],
    );
  }

  addNewRapor(String userId) {
    _tanggalQuiz = new DateFormat.yMd().format(DateTime.now()).toString();
    if (userId.length > 0) {
      Rapor rapor = new Rapor(
        userId,
        _nilaiPengetahuan,
        _nilaiSikap,
        _nilaiKepatuhan,
        _grade,
        _tanggalQuiz
      );

      databaseReference.child("rapor").push().set(rapor.toJson());
    }
  }

  int convertSalahBenar(JawabanSalahBenar jawaban)
  {
    if(jawaban == JawabanSalahBenar.BENAR) {
      return 1;
    }
    else {
      return 0;
    }
  }

  int convertJawabSikap(JawabanSikap sikap, int upDown)
  {
    if(sikap == JawabanSikap.SANGAT_SETUJU) {
      if(upDown == 0) {
        return 1;
      }
      else {
        return 5;
      }
    }
    else if(sikap == JawabanSikap.SETUJU) {
      if(upDown == 0) {
        return 2;
      }
      else {
        return 4;
      }
    }
    else if(sikap == JawabanSikap.RAGU_RAGU) {
      return 3;
    }
    else if(sikap == JawabanSikap.TIDAK_SETUJU) {
      if(upDown == 0) {
        return 4;
      }
      else {
        return 2;
      }
    }
    else if(sikap == JawabanSikap.SANGAT_TIDAK_SETUJU) {
      if(upDown == 0) {
        return 5;
      }
      else {
        return 1;
      }
    }
    else{
      return 0;
    }
  }

  String hitungGrade(int totalNilai)
  {
    if(totalNilai >= 85) {
      return "A";
    }
    else if(totalNilai >= 75 && totalNilai < 85){
      return "B";
    }
    else if(totalNilai >= 65 && totalNilai < 75){
      return "C";
    }
    else if(totalNilai >= 55 && totalNilai < 65){
      return "D";
    }
    else {
      return "E";
    }
  }

  void hitungNilaiRapor()
  {
    int i = 0;
    for(i = 0; i < _jawabPengetahuan.length; i++)
    {
      if(_jawabPengetahuan[i] == null)
      {
        _nilaiPengetahuan += 0;
      }
      else if(convertSalahBenar(_jawabPengetahuan[i]) == _pengetahuanQuiz[i].jawaban)
      {
        _nilaiPengetahuan += 100;
      }
    }
    for(i = 0; i < _jawabSikap.length; i++)
    {
      // print(_jawabSikap[i].toString());
      if(_jawabSikap[i] == null)
      {
        _nilaiSikap += 0;
      }
      else
      {
        _nilaiSikap += convertJawabSikap(_jawabSikap[i], _sikapQuiz[i].jawaban);
      }
    }
    for(i = 0; i< _jawabKepatuhan.length; i++)
    {
      if(_jawabKepatuhan[i] == null)
      {
        _nilaiKepatuhan += 0;
      }
      else if(convertSalahBenar(_jawabKepatuhan[i]) == _kepatuhanQuiz[i].jawaban)
      {
        _nilaiKepatuhan += 100;
      }
    }

    _nilaiPengetahuan = (_nilaiPengetahuan/26).round();
    _nilaiSikap = ((_nilaiSikap/75)*100).round();
    _nilaiKepatuhan = (_nilaiKepatuhan/13).round();
    int totalNilai = ((_nilaiPengetahuan + _nilaiSikap + _nilaiKepatuhan)/3).round();
    _grade = hitungGrade(totalNilai);

    // print("Nilai Pengetahuan: $_nilaiPengetahuan");
    // print("Nilai Sikap: $_nilaiSikap");
    // print("Nilai Kepatuhan: $_nilaiKepatuhan");
  }

// Context ---------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<NavigationPageProvider>(context);
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          navigation(),
          _showCircularProgress(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.currentIndex,
        onTap: (index) {
          if(index == 0) {
            setState(() {
              resetKuisioner();
              _menuIndex = NavigationEnum.DASHBOARD;
            });
          }
          else
          {
            setState(() {
              _isLoading = true;
              resetKuisioner();
              _menuIndex = NavigationEnum.PROFILE;
            });
          }
          // print('Menu index: $_menuIndex');
          provider.currentIndex = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.person),
            title: new Text('Profile'),
          )
        ],
      ),
    );
  }
}

class NavigationPageProvider with ChangeNotifier {
  int _currentIndex = 0;

  get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
