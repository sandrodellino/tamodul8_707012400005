class Sensor {
  final String id;
  final String jenis;
  final String nama;
  final String lokasiPos;
  final String satuan;

  const Sensor({
    required this.id,
    required this.jenis,
    required this.nama,
    required this.lokasiPos,
    required this.satuan,
  });
}

const daftarSensor = [
  Sensor(
    id: 's1',
    jenis: 'ketinggian_air',
    nama: 'Ketinggian Air Sungai',
    lokasiPos: 'Pos Sungai Citarum - Dayeuhkolot',
    satuan: 'cm',
  ),
  Sensor(
    id: 's2',
    jenis: 'ketinggian_air',
    nama: 'Ketinggian Air Sungai',
    lokasiPos: 'Pos Sungai Cikapundung - Braga',
    satuan: 'cm',
  ),
  Sensor(
    id: 's3',
    jenis: 'pergeseran_tanah',
    nama: 'Pergeseran Tanah',
    lokasiPos: 'Pos Lereng Cimenyan',
    satuan: 'mm',
  ),
  Sensor(
    id: 's4',
    jenis: 'curah_hujan',
    nama: 'Curah Hujan',
    lokasiPos: 'Pos Bojongsoang',
    satuan: 'mm/jam',
  ),
];
