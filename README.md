# Sundalang

**Bahasa pemrograman dengan kata kunci berbahasa Sunda, dikompilasi ke Python.**

![Tampilan installer Sundalang](https://i.ibb.co.com/C5Fjq3pd/Screenshot-20261023-062559.jpg)

> Wilujeng sumping! Sundalang membuat Anda bisa menulis program dengan kata-kata seperti `jieun`, `citak`, `lamun`, dan `pikeun`, lalu menjalankannya di Android (Termux), Windows, Linux, atau macOS.

```
jieun ngaran = tanya("Saha ngaran anjeun? ")
citak "Wilujeng sumping,", ngaran

pikeun i ti 1 nepi 3 {
    citak "Itungan ka-" + teks(i)
}
```

```text
Saha ngaran anjeun? Asep
Wilujeng sumping, Asep
Itungan ka-1
Itungan ka-2
Itungan ka-3
```

---

## Daftar Isi

1. [Tentang Sundalang](#1-tentang-sundalang)
2. [Isi Folder](#2-isi-folder)
3. [Persyaratan](#3-persyaratan)
4. [Instalasi](#4-instalasi)
5. [Perintah `sunda`](#5-perintah-sunda)
6. [Program Pertama](#6-program-pertama)
7. [Referensi Sintaks](#7-referensi-sintaks)
8. [Contoh Program](#8-contoh-program)
9. [Mode Interaktif (REPL)](#9-mode-interaktif-repl)
10. [Pesan Kesalahan](#10-pesan-kesalahan)
11. [Cara Kerja Compiler](#11-cara-kerja-compiler)
12. [Cara Kerja Installer (`run.sh`)](#12-cara-kerja-installer-runsh)
13. [Batasan](#13-batasan)
14. [Tanya Jawab dan Pemecahan Masalah](#14-tanya-jawab-dan-pemecahan-masalah)

---

## 1. Tentang Sundalang

Sundalang adalah bahasa pemrograman sederhana yang kata kuncinya memakai bahasa Sunda. Compiler-nya ditulis dengan **Python** dalam satu berkas (`sundalang.py`) dan hanya memakai library bawaan Python, jadi tidak ada yang perlu dipasang lewat `pip`.

Cara kerjanya singkat: kode Sundalang (berkas `.sd`) diterjemahkan menjadi kode Python, lalu langsung dijalankan.

**Fitur utama**

- Kata kunci dan pesan kesalahan berbahasa Sunda.
- Variabel, angka, teks, boolean, dan daftar.
- Percabangan (`lamun`, `atawa_lamun`, `lamun_henteu`).
- Perulangan (`salila` dan `pikeun`) dengan `eureun` dan `terus`.
- Fungsi buatan sendiri (`pagawean`), termasuk rekursi.
- 14 fungsi bawaan (input, matematika, daftar, huruf).
- Mode interaktif (REPL) untuk mencoba kode baris demi baris.
- Opsi `--py` untuk melihat kode Python hasil kompilasi.
- Opsi `-o` untuk membuat program mandiri.
- Pesan kesalahan yang menunjukkan nomor baris dan isi barisnya.
- Installer dengan menu interaktif untuk Android, Windows, Linux, dan macOS.

---

## 2. Isi Folder

| Berkas | Fungsi |
| --- | --- |
| `sundalang.py` | Compiler, runtime, dan mode interaktif (semuanya dalam satu berkas). |
| `run.sh` | Installer dengan menu interaktif. Memasang perintah `sunda` ke perangkat. |
| `testing.sd` | Contoh program Sundalang (faktorial, input, daftar, perulangan). |
| `README.md` | Dokumentasi ini. |

> **Penting:** `run.sh` dan `sundalang.py` harus berada di **folder yang sama**. Installer menyalin `sundalang.py` dari folder tempat `run.sh` berada.

---

## 3. Persyaratan

- **Python 3** (diuji pada Python 3.12).
- **Bash** untuk menjalankan installer `run.sh`:
  - Android: Termux (Bash sudah tersedia).
  - Linux dan macOS: sudah tersedia.
  - Windows: [Git Bash](https://git-scm.com/downloads) atau WSL.

Jika Python belum terpasang, installer akan mencoba memasangnya lewat package manager sistem (`pkg`, Homebrew, `winget`, `apt`, `dnf`, `pacman`, dan lainnya). Jika gagal, installer menampilkan petunjuk pemasangan manual.

---

## 4. Instalasi

### 4.1 Siapkan folder

Ekstrak `compiler_sunda.zip` ke sebuah folder, lalu masuk ke folder itu.

```bash
unzip compiler_sunda.zip -d compiler_sunda
cd compiler_sunda
```

<details>
<summary><b>Pengguna Termux: mengambil berkas dari penyimpanan HP</b></summary>

```bash
pkg install unzip
termux-setup-storage                 # izinkan akses penyimpanan (sekali saja)
cd ~/storage/downloads               # folder tempat zip berada
unzip compiler_sunda.zip -d compiler_sunda
cd compiler_sunda
```

</details>

### 4.2 Jalankan installer

```bash
bash run.sh
```

Tampilan installer akan seperti ini:

![Tampilan menu installer Sundalang](https://i.ibb.co.com/C5Fjq3pd/Screenshot-20261023-062559.jpg)

Gunakan menu berikut:

| Tombol | Fungsi |
| --- | --- |
| `↑` / `↓` (atau `k` / `j`) | Memindahkan pilihan |
| `Enter` | Menjalankan pilihan |
| `1` sampai `6` | Langsung memilih menu bernomor |
| `q` | Keluar |

| No. | Menu | Keterangan |
| --- | --- | --- |
| 1 | **Pasang Sundalang** | Memasang compiler dan perintah `sunda` |
| 2 | **Perbarui** | Memakai versi terbaru dari folder ini |
| 3 | **Cek status** | Melihat kondisi pemasangan |
| 4 | **Copot** | Menghapus Sundalang dari perangkat |
| 5 | **Cara pakai** | Menampilkan contoh perintah |
| 6 | **Keluar** | Menutup installer |

Pilih **Pasang Sundalang**. Installer menjalankan 6 langkah secara otomatis:

1. Mengenali sistem
2. Mencari Python
3. Menyalin berkas
4. Membuat perintah
5. Mengatur PATH (installer meminta izin Anda terlebih dahulu)
6. Memeriksa hasil (menjalankan program uji kecil)

Jika semuanya berhasil, Anda akan melihat tulisan **"Sundalang siap dipakai!"**.

> Setelah pemasangan, **buka terminal baru** (atau jalankan `source ~/.bashrc`, atau `~/.zshrc` jika memakai Zsh) agar perintah `sunda` dikenali. Di Termux langkah ini biasanya tidak diperlukan.

### 4.3 Perintah langsung tanpa menu

```bash
bash run.sh pasang      # pasang Sundalang
bash run.sh perbarui    # pakai versi di folder ini
bash run.sh status      # cek kondisi pemasangan
bash run.sh copot       # hapus Sundalang
bash run.sh cara        # ringkasan cara pakai
bash run.sh bantuan     # bantuan installer
```

Opsi tambahan:

| Opsi | Fungsi |
| --- | --- |
| `-y` atau `--yes` | Menjawab "ya" otomatis pada semua pertanyaan, contohnya `bash run.sh pasang -y` |
| `NO_COLOR=1` | Mematikan warna, contohnya `NO_COLOR=1 bash run.sh` |

> **Catatan:** pada teks bantuan installer tertulis `bash sundalang.sh`. Itu hanya nama lain untuk berkas yang sama. Pakai nama berkas yang ada di folder Anda (`run.sh`).

### 4.4 Catatan per platform

| Platform | Lokasi perintah `sunda` | Catatan |
| --- | --- | --- |
| Android (Termux) | `$PREFIX/bin` | Sudah ada di PATH. Python dipasang lewat `pkg install python`. |
| Linux dan WSL | `~/.local/bin` | PATH ditambahkan ke `~/.bashrc`, `~/.zshrc`, atau `config.fish` sesuai shell Anda. |
| macOS | `~/.local/bin` | Python dipasang lewat Homebrew bila belum ada. |
| Windows (Git Bash) | `~/.local/bin` | Dibuat juga `sunda.cmd` agar bisa dipakai di CMD dan PowerShell. PATH Windows ditambah lewat PowerShell. Tutup lalu buka lagi terminal setelah pemasangan. |

Lokasi bisa diubah dengan variabel lingkungan `SUNDA_BIN` (folder perintah) dan `SUNDA_DATA` (folder data), contohnya:

```bash
SUNDA_BIN=~/bin bash run.sh pasang
```

### 4.5 Memperbarui dan mencopot

- **Memperbarui:** setelah mengubah `sundalang.py`, jalankan `bash run.sh perbarui`. Installer membandingkan berkas di folder ini dengan yang terpasang, lalu menyalinnya bila berbeda.
- **Mencopot:** jalankan `bash run.sh copot`. Installer meminta konfirmasi, lalu menghapus perintah `sunda`, blok pengaturan PATH yang ia tambahkan, dan folder datanya.

### 4.6 Menjalankan tanpa memasang

Anda tidak wajib memasang apa pun. Compiler bisa dipakai langsung:

```bash
python3 sundalang.py testing.sd
```

Semua opsi pada bagian berikutnya bisa dipakai dengan cara ini, cukup ganti `sunda` dengan `python3 sundalang.py`.

---

## 5. Perintah `sunda`

| Perintah | Fungsi |
| --- | --- |
| `sunda berkas.sd` | Menjalankan program |
| `sunda berkas` | Sama seperti di atas; ekstensi `.sd` boleh dihilangkan |
| `sunda` | Membuka mode interaktif (REPL) |
| `sunda --baru halo` | Membuat berkas `halo.sd` berisi contoh program |
| `sunda berkas.sd --py` | Menampilkan kode Python hasil kompilasi (tanpa menjalankan) |
| `sunda berkas.sd -o hasil` | Membuat program mandiri bernama `hasil` |
| `sunda --versi` | Menampilkan versi |
| `sunda -h` atau `sunda --bantuan` | Menampilkan bantuan |

**Kode keluar (exit code):** `0` jika berhasil, `1` jika ada kesalahan (kompilasi, berkas tidak ditemukan, atau error saat berjalan).

**Program mandiri (`-o`).** Hasilnya adalah satu berkas Python berisi runtime lengkap dan kode program Anda. Berkas itu bisa dijalankan tanpa `sunda` dan tanpa `sundalang.py`, tetapi tetap memerlukan Python 3:

```bash
sunda testing.sd -o faktorial
./faktorial              # atau: python3 faktorial
```

**Menjalankan `.sd` langsung (Linux dan macOS).** Berkas yang dibuat dengan `--baru` otomatis dapat dieksekusi dan diawali baris `#!/usr/bin/env sunda`. Jika perintah `sunda` sudah ada di PATH, berkas itu bisa dijalankan langsung:

```bash
sunda --baru halo
./halo.sd
```

---

## 6. Program Pertama

**Langkah 1 — buat berkas contoh**

```bash
sunda --baru halo
```

```text
Berkas dijieun: halo.sd
Jalankeun nganggo: sunda halo.sd
```

**Langkah 2 — lihat isinya**

```
#!/usr/bin/env sunda
jieun ngaran = tanya("Saha ngaran anjeun? ")
citak "Wilujeng sumping,", ngaran

pikeun i ti 1 nepi 3 {
    citak "Itungan ka-" + teks(i)
}
```

**Langkah 3 — jalankan**

```bash
sunda halo
```

```text
Saha ngaran anjeun? Ujang
Wilujeng sumping, Ujang
Itungan ka-1
Itungan ka-2
Itungan ka-3
```

Penjelasan baris demi baris:

| Baris | Arti |
| --- | --- |
| `#!/usr/bin/env sunda` | Baris shebang. Karena diawali `#`, baris ini dianggap komentar. |
| `jieun ngaran = tanya(...)` | Membuat variabel `ngaran`, isinya jawaban dari pengguna. |
| `citak "Wilujeng sumping,", ngaran` | Mencetak teks dan isi variabel, dipisah spasi. |
| `pikeun i ti 1 nepi 3 { ... }` | Perulangan dengan `i` bernilai 1, 2, 3 (batas atas ikut dihitung). |
| `teks(i)` | Mengubah angka `i` menjadi teks. |

---

## 7. Referensi Sintaks

### 7.1 Komentar dan penulisan baris

```
# ini komentar sampai akhir baris
jieun a = 1        # komentar juga boleh di akhir baris
jieun b = 2; jieun c = 3     # titik koma memisahkan beberapa perintah
```

- Satu perintah ditulis per baris. Titik koma `;` bisa dipakai sebagai pemisah di baris yang sama.
- **Indentasi tidak berpengaruh.** Blok kode memakai kurung kurawal `{ }`, bukan spasi.
- Baris baru di dalam `( )` dan `[ ]` diabaikan, sehingga daftar atau pemanggilan fungsi panjang boleh dipecah ke beberapa baris.

### 7.2 Variabel (`jieun`)

```
jieun umur = 17
jieun nama = "Asep"
jieun kosongan          # tanpa nilai awal, isinya kosong
```

- Variabel **harus dibuat dengan `jieun`** sebelum diberi nilai baru dengan `=`. Jika tidak, muncul kesalahan:
  ```
  Kasalahan kompilasi di baris 3: variabel 'b' acan dijieun; paké 'jieun b = ...' heula
  ```
- Mengubah nilai variabel yang sudah ada:
  ```
  jieun skor = 10
  skor = 20          # ubah nilai
  skor += 5          # tambah 5
  ```
- Nama variabel terdiri dari huruf, angka, dan garis bawah `_`, serta tidak boleh diawali angka.
- Kata kunci (lihat [7.13](#713-daftar-kata-kunci)) tidak boleh dipakai sebagai nama variabel.
- Sebaiknya jangan memakai nama fungsi bawaan (misalnya `teks` atau `angka`) sebagai nama variabel.

### 7.3 Tipe data

| Tipe | Contoh | Keterangan |
| --- | --- | --- |
| Bilangan bulat | `10`, `0`, `42` | |
| Bilangan desimal | `3.5`, `0.25` | Memakai titik, harus diawali angka (`0.5`, bukan `.5`) |
| Teks | `"halo"` atau `'halo'` | Boleh kutip ganda atau tunggal |
| Boolean | `leres`, `lepat` | Benar dan salah |
| Kosong | `kosong` | Berarti "tidak ada nilai" |
| Daftar | `[1, "dua", leres]` | Boleh berisi tipe campuran dan daftar lain |

Karakter khusus di dalam teks:

| Tulisan | Hasil |
| --- | --- |
| `\n` | Baris baru |
| `\t` | Tab |
| `\"` atau `\'` | Tanda kutip |
| `\\` | Garis miring terbalik |

### 7.4 Operator

**Aritmetika**

| Operator | Fungsi | Contoh | Hasil |
| --- | --- | --- | --- |
| `+` | Tambah (atau gabung teks) | `2 + 3` | `5` |
| `-` | Kurang | `7 - 2` | `5` |
| `*` | Kali | `4 * 3` | `12` |
| `/` | Bagi | `7 / 2` | `3.5` |
| `%` | Sisa bagi | `7 % 3` | `1` |
| `**` | Pangkat | `2 ** 10` | `1024` |

Hal yang perlu diketahui:

- `/` menghasilkan bilangan bulat jika pembagiannya habis (`8 / 2` menghasilkan `4`), dan desimal jika tidak (`7 / 2` menghasilkan `3.5`).
- `/` dengan pembagi `0` menghasilkan kesalahan "teu tiasa dibagi ku nol".
- `+` otomatis menggabungkan teks bila salah satu sisinya teks, dan angka diubah menjadi teks. Jadi `"Umur " + 17` menghasilkan `Umur 17` (tidak perlu `teks()`).

**Perbandingan:** `==` (sama dengan), `!=` (tidak sama), `<`, `>`, `<=`, `>=`.

**Logika**

| Operator | Arti | Contoh |
| --- | --- | --- |
| `jeung` | dan | `a > 1 jeung a < 10` |
| `atawa` | atau | `a < 1 atawa a > 10` |
| `lain` | bukan | `lain leres` menghasilkan `lepat` |

**Penugasan:** `=`, `+=`, `-=`, `*=`, `/=`. (Tidak ada `%=` dan `**=`.)

**Urutan prioritas** (dari yang paling rendah ke paling tinggi):

| Tingkat | Operator |
| --- | --- |
| 1 | `atawa` |
| 2 | `jeung` |
| 3 | `lain` |
| 4 | `==` `!=` `<` `>` `<=` `>=` |
| 5 | `+` `-` |
| 6 | `*` `/` `%` |
| 7 | `-` (negatif, misalnya `-5`) |
| 8 | `**` |
| 9 | Pemanggilan `f()` dan indeks `d[0]` |

Gunakan tanda kurung `( )` jika ingin mengubah urutan.

### 7.5 Mencetak (`citak`)

```
citak "Halo"                      # Halo
citak "Jumlah:", 3 + 4            # Jumlah: 7
citak                             # cetak baris kosong
```

- Beberapa nilai dipisah koma, dan di layar dipisah satu spasi.
- Cara tampil nilai khusus: `leres`, `lepat`, dan `kosong` ditampilkan apa adanya dalam bahasa Sunda.
- Angka desimal yang bulat ditampilkan tanpa `.0` (misalnya `2.0` tampil `2`).
- Daftar ditampilkan dengan teks di dalam tanda kutip:

```
citak [1, "dua", [3, 4], leres, kosong]
```

```text
[1, "dua", [3, 4], leres, kosong]
```

### 7.6 Input (`tanya`)

```
jieun ngaran = tanya("Saha ngaran anjeun? ")
```

`tanya(...)` menampilkan pertanyaan lalu mengembalikan jawaban sebagai **teks**. Untuk memakainya sebagai angka, bungkus dengan `angka()`:

```
jieun umur = angka(tanya("Umur: "))
citak "Tahun payun:", umur + 1
```

### 7.7 Percabangan (`lamun`, `atawa_lamun`, `lamun_henteu`)

```
lamun nilai >= 90 {
    citak "A"
} atawa_lamun nilai >= 75 {
    citak "B"
} lamun_henteu {
    citak "C"
}
```

| Kata kunci | Padanan |
| --- | --- |
| `lamun` | `if` (jika) |
| `atawa_lamun` | `else if` (jika tidak, maka jika). Boleh dipakai berkali-kali. |
| `lamun_henteu` | `else` (jika semuanya tidak terpenuhi) |

- Kurung kurawal `{ }` **wajib**, meskipun isinya hanya satu perintah.
- Syarat boleh diberi tanda kurung: `lamun (a < b) { ... }`.
- `atawa_lamun` dan `lamun_henteu` boleh ditulis di baris baru, tidak harus setelah `}`.

### 7.8 Perulangan

**`salila` (selama kondisi benar)**

```
jieun n = 1
salila n <= 5 {
    citak n
    n += 1
}
```

**`pikeun ... ti ... nepi ...` (perulangan dengan rentang angka)**

```
pikeun i ti 1 nepi 5 {
    citak i
}
```

Batas awal dan akhir **sama-sama ikut dihitung** (`1 nepi 5` menghasilkan 1, 2, 3, 4, 5).

**Dengan `lengkah` (langkah)**

```
pikeun i ti 1 nepi 10 lengkah 3 {      # 1, 4, 7, 10
    citak i
}

pikeun i ti 10 nepi 1 lengkah -4 {     # 10, 6, 2 (menurun)
    citak i
}
```

`lengkah` tidak boleh `0`.

**`eureun` dan `terus`**

| Kata kunci | Padanan | Fungsi |
| --- | --- | --- |
| `eureun` | `break` | Keluar dari perulangan |
| `terus` | `continue` | Lompat ke putaran berikutnya |

```
pikeun i ti 1 nepi 10 {
    lamun i == 3 { terus }      # lewati angka 3
    lamun i == 6 { eureun }     # berhenti di angka 6
    citak "i =", i
}
```

```text
i = 1
i = 2
i = 4
i = 5
```

`eureun` dan `terus` hanya boleh dipakai di dalam `salila` atau `pikeun`.

### 7.9 Daftar

```
jieun buah = ["apel", "jeruk", "mangga"]

citak buah[0]               # apel (indeks dimulai dari 0)
buah[1] = "anggur"          # mengubah isi
tambihkeun(buah, "durian")  # menambah di akhir
citak panjang(buah)         # 4
citak buah                  # ["apel", "anggur", "mangga", "durian"]
```

- Indeks dimulai dari **0**. Indeks negatif (`buah[-1]`) mengambil dari belakang.
- Indeks di luar batas menghasilkan kesalahan "indeks daptar kaluar tina wates".
- Untuk menelusuri seluruh isi daftar, pakai `pikeun` dengan indeks:

```
pikeun i ti 0 nepi panjang(buah) - 1 {
    citak i, buah[i]
}
```

### 7.10 Fungsi (`pagawean`) dan `balik`

```
pagawean luas_persegi(sisi) {
    balik sisi * sisi
}

citak luas_persegi(5)       # 25
```

- `pagawean nama(parameter1, parameter2) { ... }` membuat fungsi.
- `balik nilai` mengembalikan nilai dan mengakhiri fungsi. `balik` tanpa nilai mengembalikan `kosong`.
- `balik` **hanya** boleh dipakai di dalam `pagawean`.
- Rekursi didukung:

```
pagawean fib(n) {
    lamun n < 2 { balik n }
    balik fib(n - 1) + fib(n - 2)
}
citak fib(10)       # 55
```

> **Penting:** di level paling atas program, definisikan `pagawean` **sebelum** memanggilnya. Memanggil fungsi yang baru didefinisikan di baris bawahnya menghasilkan kesalahan `'nama' acan dijieun` saat program berjalan.

### 7.11 Fungsi bawaan

| Fungsi | Fungsi | Contoh | Hasil |
| --- | --- | --- | --- |
| `panjang(x)` | Panjang daftar atau teks | `panjang("sunda")` | `5` |
| `angka(x)` | Mengubah teks menjadi angka | `angka("42") + 1` | `43` |
| `teks(x)` | Mengubah nilai menjadi teks | `teks(99) + "!"` | `99!` |
| `tanya(pesan)` | Meminta input pengguna | `tanya("Nama? ")` | teks jawaban |
| `acak(a, b)` | Bilangan bulat acak dari `a` sampai `b` (keduanya ikut) | `acak(1, 6)` | `1` sampai `6` |
| `akar(x)` | Akar kuadrat | `akar(81)` | `9` |
| `pangbadagna(...)` | Nilai terbesar | `pangbadagna([3, 9, 2])` | `9` |
| `pangleutikna(...)` | Nilai terkecil | `pangleutikna(3, 8, 1)` | `1` |
| `tambihkeun(daftar, x)` | Menambah `x` di akhir daftar | `tambihkeun(d, 5)` | (mengubah `d`) |
| `bunderkeun(x, n)` | Membulatkan ke `n` desimal (`n` boleh dikosongkan) | `bunderkeun(3.14159, 2)` | `3.14` |
| `mutlak(x)` | Nilai mutlak | `mutlak(-7)` | `7` |
| `urutkeun(daftar)` | Daftar baru yang sudah terurut naik | `urutkeun([5, 2, 9])` | `[2, 5, 9]` |
| `hurup_gede(teks)` | Huruf besar semua | `hurup_gede("sunda")` | `SUNDA` |
| `hurup_leutik(teks)` | Huruf kecil semua | `hurup_leutik("SUNDA")` | `sunda` |

Catatan:

- `bunderkeun(2.5)` menghasilkan `3` (setengah dibulatkan ke atas).
- `akar()` dari angka negatif menghasilkan kesalahan "akar tina angka négatif teu tiasa".
- `angka("abc")` menghasilkan kesalahan `'abc' lain angka`.
- `urutkeun()` tidak mengubah daftar aslinya, melainkan membuat daftar baru.

### 7.12 Cakupan variabel

- Variabel yang dibuat **di dalam fungsi** (`jieun`) hanya berlaku di fungsi itu. Parameter juga bersifat lokal.
- Variabel yang dibuat di luar fungsi dapat **dibaca dan diubah** dari dalam fungsi, cukup dengan `=` atau `+=` (tanpa `jieun`):

```
jieun hitung = 0

pagawean tambah() {
    hitung += 1
}

tambah()
tambah()
citak "hitung =", hitung       # hitung = 2
```

- Blok `lamun`, `salila`, dan `pikeun` **tidak** membuat cakupan baru. Variabel di dalamnya tetap milik fungsi atau program yang membungkusnya.

### 7.13 Daftar kata kunci

Ada 20 kata kunci. Semuanya tidak boleh dipakai sebagai nama variabel atau fungsi.

| Kata kunci | Padanan | Kegunaan |
| --- | --- | --- |
| `jieun` | buat | Membuat variabel |
| `citak` | cetak | Mencetak ke layar |
| `lamun` | jika | Percabangan |
| `atawa_lamun` | jika tidak, maka jika | Percabangan lanjutan |
| `lamun_henteu` | jika tidak | Percabangan terakhir |
| `salila` | selama | Perulangan berdasarkan kondisi |
| `pikeun` | untuk | Perulangan dengan rentang |
| `ti` | dari | Batas awal `pikeun` |
| `nepi` | sampai | Batas akhir `pikeun` |
| `lengkah` | langkah | Besar langkah `pikeun` |
| `pagawean` | pekerjaan | Membuat fungsi |
| `balik` | kembali | Mengembalikan nilai fungsi |
| `eureun` | berhenti | Keluar dari perulangan |
| `terus` | lanjut | Lanjut ke putaran berikutnya |
| `leres` | benar | Nilai boolean benar |
| `lepat` | salah | Nilai boolean salah |
| `kosong` | kosong | Nilai kosong |
| `jeung` | dan | Operator logika dan |
| `atawa` | atau | Operator logika atau |
| `lain` | bukan | Operator logika bukan |

---

## 8. Contoh Program

### 8.1 `testing.sd` (contoh bawaan)

```
#!/usr/bin/env sunda
pagawean faktorial(n) {
    lamun n <= 1 {
        balik 1
    }
    balik n * faktorial(n - 1)
}

jieun ngaran = tanya("Saha ngaran anjeun? ")
citak "Wilujeng sumping,", ngaran

pikeun i ti 1 nepi 5 {
    citak teks(i) + "! =", faktorial(i)
}

jieun buah = ["apel", "jeruk", "mangga"]
tambihkeun(buah, "durian")
citak "Aya", panjang(buah), "buah:", buah

jieun total = 0
jieun n = 1
salila n <= 10 {
    lamun n % 2 == 0 {
        total += n
    }
    n += 1
}
citak "Jumlah angka genap 1-10:", total
```

Jalankan:

```bash
sunda testing.sd
```

Hasil (dengan input `Asep`):

```text
Saha ngaran anjeun? Asep
Wilujeng sumping, Asep
1! = 1
2! = 2
3! = 6
4! = 24
5! = 120
Aya 4 buah: ["apel", "jeruk", "mangga", "durian"]
Jumlah angka genap 1-10: 30
```

Penjelasan bagian-bagiannya:

| Bagian | Penjelasan |
| --- | --- |
| `pagawean faktorial(n)` | Fungsi rekursif. Jika `n <= 1` mengembalikan `1`, selain itu mengembalikan `n * faktorial(n - 1)`. |
| `tanya(...)` dan `citak` | Meminta nama lalu menyapa pengguna. |
| `pikeun i ti 1 nepi 5` | Mencetak faktorial 1 sampai 5. `teks(i) + "! ="` menggabungkan angka dengan teks. |
| `jieun buah = [...]` | Membuat daftar, lalu `tambihkeun` menambah `"durian"`. |
| `panjang(buah)` | Menghitung isi daftar (sekarang 4). |
| `salila n <= 10` | Menjumlahkan angka genap (`n % 2 == 0`) dari 1 sampai 10: 2 + 4 + 6 + 8 + 10 = 30. |

### 8.2 FizzBuzz

```
pikeun i ti 1 nepi 15 {
    lamun i % 15 == 0 {
        citak "FizzBuzz"
    } atawa_lamun i % 3 == 0 {
        citak "Fizz"
    } atawa_lamun i % 5 == 0 {
        citak "Buzz"
    } lamun_henteu {
        citak i
    }
}
```

```text
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
```

### 8.3 Bilangan prima

```
pagawean prima(n) {
    lamun n < 2 {
        balik lepat
    }
    pikeun d ti 2 nepi n - 1 {
        lamun n % d == 0 {
            balik lepat
        }
    }
    balik leres
}

jieun hasil = []
pikeun n ti 1 nepi 30 {
    lamun prima(n) {
        tambihkeun(hasil, n)
    }
}
citak "Bilangan prima 1-30:", hasil
```

```text
Bilangan prima 1-30: [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
```

### 8.4 Tebak angka

```
jieun rusiah = acak(1, 10)
jieun nyobaan = 0
jieun nebak = 0

citak "Tebak angka 1 nepi 10!"
salila nebak != rusiah {
    nebak = angka(tanya("Tebakan anjeun: "))
    nyobaan += 1
    lamun nebak < rusiah {
        citak "Teuing leutik"
    } atawa_lamun nebak > rusiah {
        citak "Teuing gede"
    }
}
citak "Leres! Anjeun nebak dina", nyobaan, "kali."
```

Contoh sesi (angka rahasia 7):

```text
Tebak angka 1 nepi 10!
Tebakan anjeun: 3
Teuing leutik
Tebakan anjeun: 9
Teuing gede
Tebakan anjeun: 7
Leres! Anjeun nebak dina 3 kali.
```

---

## 9. Mode Interaktif (REPL)

Jalankan `sunda` tanpa nama berkas:

```bash
sunda
```

```text
Sundalang 1.1 - ketik 'kaluar' pikeun kaluar
sunda> 1 + 2
3
sunda> jieun a = 5
sunda> a * 3
15
sunda> pagawean kali2(n) {
  ...>   balik n * 2
  ...> }
sunda> kali2(21)
42
sunda> "halo"
"halo"
sunda> kaluar
```

Aturan mode interaktif:

- Jika sebuah baris hanya berisi **satu ekspresi**, hasilnya langsung ditampilkan (teks tampil dengan tanda kutip).
- Jika kurung `{`, `(`, atau `[` belum ditutup, prompt berubah menjadi `  ...>` dan Anda bisa melanjutkan menulis.
- Variabel dan fungsi **tetap tersimpan** selama sesi berlangsung.
- Keluar dengan mengetik `kaluar` (atau `exit` / `quit`), atau tekan `Ctrl+D`.
- `Ctrl+C` membatalkan baris yang sedang ditulis tanpa keluar dari REPL.
- Kesalahan hanya menampilkan pesan, sesi tidak berhenti.

---

## 10. Pesan Kesalahan

Ada dua jenis kesalahan, keduanya ditulis dalam bahasa Sunda dan memakai nomor baris dari **kode Sundalang Anda** (bukan dari kode Python hasil kompilasi).

### 10.1 Kesalahan kompilasi

Terjadi sebelum program berjalan. Pesan menampilkan nomor baris dan isi barisnya:

```text
Kasalahan kompilasi di baris 3: variabel 'b' acan dijieun; paké 'jieun b = ...' heula
  3 | b = 3
```

| Pesan | Artinya |
| --- | --- |
| `'x' teu kapendak (acan dijieun)` | Variabel atau fungsi `x` tidak ditemukan / belum dibuat |
| `variabel 'x' acan dijieun; paké 'jieun x = ...' heula` | Memberi nilai ke variabel yang belum dibuat dengan `jieun` |
| `teks acan ditutup (kurang tanda kutip)` | Teks tidak ditutup dengan tanda kutip |
| `blok acan ditutup, kedahna aya '}'` | Kurung kurawal penutup hilang |
| `kedahna aya '{' pikeun muka blok` | Kurung kurawal pembuka hilang |
| `kedahna aya 'nepi' (pikeun i ti 1 nepi 10)` | Format `pikeun` kurang lengkap |
| `saatos paréntah kedah baris anyar, tapi kapendak 'citak'` | Dua perintah berada di satu baris tanpa pemisah (pakai baris baru atau `;`) |
| `karakter '@' teu dikenal` | Ada karakter yang tidak dikenali bahasa ini |
| `saatos 'jieun' kedah aya ngaran variabel` | Nama variabel tidak ada atau memakai kata kunci |
| `'balik' ngan tiasa dipaké di jero 'pagawean'` | `balik` dipakai di luar fungsi |
| `'eureun' ngan tiasa dipaké di jero 'salila' atanapi 'pikeun'` | `eureun` / `terus` dipakai di luar perulangan |
| `sisi kénca '=' kedah variabel atanapi unsur daptar` | Sisi kiri `=` bukan variabel atau isi daftar |

### 10.2 Kesalahan saat program berjalan

Terjadi ketika program sedang berjalan:

```text
Kasalahan nalika ngajalankeun (baris 1): teu tiasa dibagi ku nol
```

| Pesan | Artinya |
| --- | --- |
| `teu tiasa dibagi ku nol` | Pembagian dengan nol |
| `indeks daptar kaluar tina wates` | Indeks daftar di luar jangkauan |
| `'abc' lain angka` | `angka()` gagal mengubah teks menjadi angka |
| `akar tina angka négatif teu tiasa` | `akar()` dipanggil dengan angka negatif |
| `jinis data teu cocog pikeun operasi ieu` | Tipe data tidak cocok (misalnya jumlah argumen fungsi salah, atau `"a" * "b"`) |
| `pagawean nelepon dirina teuing jero (rekursi teu aya tungtungna)` | Rekursi tanpa titik berhenti |
| `'x' acan dijieun` | Nama dipakai sebelum dibuat (misalnya fungsi dipanggil sebelum didefinisikan) |
| `lengkah teu tiasa nol` | `lengkah 0` pada `pikeun` |
| `dieureunkeun ku pamaké` | Program dihentikan dengan `Ctrl+C` |

Selain itu, `Berkas 'nama' teu kapendak` berarti berkas yang Anda sebutkan tidak ada di folder saat ini.

---

## 11. Cara Kerja Compiler

### 11.1 Alur kompilasi

```text
 berkas .sd
     │
     ▼
 ┌─────────┐   daftar token    ┌─────────┐   pohon sintaks (AST)   ┌───────────┐
 │  lex()  │ ───────────────▶  │ Parser  │ ──────────────────────▶ │ Generator │
 └─────────┘                   └─────────┘                         └───────────┘
 (pemecah teks)           (pemeriksa tata bahasa)               (penerjemah ke Python)
                                                                          │
                                                                          ▼
                                                                    kode Python
                                                                          │
                          ┌───────────────────────────┬──────────────────┤
                          ▼                           ▼                  ▼
                   jalankeun()                   --py (cetak)       -o (simpan sebagai
                (exec di memori)                                    program mandiri)
```

Tahapannya:

1. **Lexer (`lex`)** memecah teks program menjadi token: `NL` (baris baru), `ANGKA`, `TEKS`, `NAMA` (nama variabel/fungsi), `KONCI` (kata kunci), `OP` (operator), dan `EOF` (akhir berkas). Komentar dan spasi dibuang.
2. **Parser** memeriksa tata bahasa dan menyusun pohon sintaks (AST) dengan metode *recursive descent*. Setiap tingkat prioritas operator punya fungsinya sendiri (`atawa` → `jeung` → `lain` → `banding` → `tambah` → `kali` → `unari` → `pangkat` → `postfix` → `primary`).
3. **Generator** berjalan di pohon sintaks, memeriksa variabel dan cakupan, lalu menghasilkan kode Python.
4. **Runtime (`PREAMBLE`)** adalah kumpulan fungsi bantu Python yang ditempel di depan kode hasil, lalu seluruhnya dijalankan dengan `exec()`.

### 11.2 Contoh hasil kompilasi

Kode Sundalang:

```
jieun total = 0
pikeun i ti 1 nepi 3 {
    total += i
}
citak "Total:", total
```

Lihat hasil terjemahannya:

```bash
sunda contoh.sd --py
```

```python
total = 0
for i in _rentang(1, 3, 1):
    total = _tmb(total, i)
_citak('Total:', total)
```

`_rentang`, `_tmb`, dan `_citak` adalah fungsi runtime yang dijelaskan di bagian 11.4.

### 11.3 Isi `sundalang.py`

| Komponen | Jenis | Tugas |
| --- | --- | --- |
| `VERSI` | Konstanta | Nomor versi (`"1.1"`). Installer juga membaca nilai ini. |
| `KasalahanSunda` | Kelas | Kesalahan khusus Sundalang, membawa pesan dan nomor baris. |
| `KECAP_KONCI` | Himpunan | 20 kata kunci bahasa. |
| `OP_DUA`, `OP_SATU` | Konstanta | Operator dua karakter (`==`, `+=`, ...) dan satu karakter (`+`, `{`, ...). |
| `lex(src)` | Fungsi | Mengubah teks menjadi daftar token. Juga mendeteksi karakter asing dan teks yang tidak ditutup. |
| `N(...)` | Fungsi | Membuat satu simpul pohon sintaks. |
| `Parser` | Kelas | Menyusun pohon sintaks: `program`, `blok`, `stmt` (perintah), dan `expr` (ekspresi). |
| `BAWAAN` | Kamus | Pemetaan fungsi bawaan Sunda ke fungsi Python (misalnya `panjang` → `len`). |
| `pyname(n)` | Fungsi | Menambah akhiran `_s` pada nama yang bentrok dengan Python (misalnya `print` menjadi `print_s`) atau diawali `_`. |
| `Generator` | Kelas | Menerjemahkan pohon sintaks ke kode Python, mengelola cakupan variabel, dan menyisipkan `global` / `nonlocal` secara otomatis. |
| `PREAMBLE` | Teks | Kode runtime yang ditempel di depan program. |
| `CONTO` | Teks | Isi template untuk `--baru`. |
| `kompilasi(sumber)` | Fungsi | Menjalankan `lex` → `Parser` → `Generator`. |
| `rakit(kode, peta)` | Fungsi | Menggabungkan runtime, peta baris, dan kode program (dipakai oleh `-o` dan saat menjalankan). |
| `jalankeun(kode, peta)` | Fungsi | Menjalankan kode dengan `exec` dan melaporkan kesalahan dengan baris Sundalang. |
| `lapor(...)` | Fungsi | Mencetak kesalahan kompilasi beserta baris sumbernya. |
| `cari_berkas(nama)` | Fungsi | Mencari berkas, dan mencoba menambah `.sd` bila perlu. |
| `buat_baru(nama)` | Fungsi | Membuat berkas dari template (`--baru`) dan menjadikannya dapat dieksekusi. |
| `repl()` | Fungsi | Mode interaktif. |
| `main()` | Fungsi | Membaca argumen perintah (`argparse`) dan mengatur seluruh alur. |

**Beberapa detail penting dalam `Generator`:**

- **Pemeriksaan variabel.** Kompiler melacak variabel apa saja yang sudah dibuat di setiap cakupan, sehingga kesalahan seperti variabel belum dibuat terdeteksi sebelum program berjalan.
- **Fungsi "diangkat" (hoisting).** Nama fungsi dicatat lebih awal agar fungsi dapat saling memanggil. Namun, di level atas, fungsi tetap harus *dijalankan* setelah definisinya (lihat catatan di bagian 7.10).
- **`global` dan `nonlocal` otomatis.** Jika fungsi mengubah variabel luar, kompiler menambahkan pernyataan `global` atau `nonlocal` di kode Python sehingga Anda tidak perlu menulisnya.
- **Peta baris.** Setiap baris Python hasil terjemahan dicatat berasal dari baris berapa di berkas `.sd` (`peta`). Karena itulah kesalahan saat berjalan menunjuk nomor baris Sundalang, bukan nomor baris Python.

### 11.4 Fungsi runtime (`PREAMBLE`)

| Fungsi | Tugas |
| --- | --- |
| `_fmt` | Memformat nilai untuk ditampilkan: `leres` / `lepat` / `kosong`, desimal bulat tanpa `.0`, dan daftar dengan teks bertanda kutip. |
| `_citak` | Implementasi `citak`: mencetak nilai dipisah spasi. |
| `_tampil` | Mencetak hasil ekspresi pada mode interaktif. |
| `_tmb` | Implementasi `+`: menggabungkan teks jika salah satu sisi teks, selain itu menjumlahkan angka. |
| `_bgi` | Implementasi `/`: hasil bulat jika habis dibagi, desimal jika tidak, dan kesalahan jika dibagi nol. |
| `_teks`, `_angka` | Konversi ke teks dan ke angka. |
| `_tanya` | Implementasi `tanya` (mengembalikan teks kosong jika input berakhir). |
| `_acak`, `_akar`, `_bunderkeun` | Matematika: bilangan acak, akar kuadrat, pembulatan (setengah ke atas). |
| `_tambihkeun`, `_gede`, `_leutik` | Menambah ke daftar, huruf besar, huruf kecil. |
| `_rentang` | Rentang angka untuk `pikeun` (batas akhir ikut dihitung, mendukung langkah negatif). |
| `_pesen_galat`, `_lapor_galat`, `_hook` | Menerjemahkan kesalahan Python menjadi pesan Sunda beserta nomor baris Sundalang. |

Batas kedalaman rekursi diatur ke 3000, sehingga fungsi rekursif yang cukup dalam tetap bisa berjalan.

---

## 12. Cara Kerja Installer (`run.sh`)

`run.sh` adalah skrip Bash yang memasang Sundalang sebagai perintah `sunda`. Secara garis besar:

| Tahap | Yang dilakukan |
| --- | --- |
| **Deteksi sistem** | Mengenali macOS, Windows (Git Bash / MSYS / Cygwin), WSL, Android (Termux), atau Linux. |
| **Penentuan lokasi** | Menentukan folder perintah (`BIN_DIR`) dan folder data (`DATA_DIR`), serta berkas konfigurasi shell (`.bashrc`, `.zshrc`, `config.fish`, atau `.profile`). |
| **Pencarian Python** | Mencari `python3`, `python`, atau `py -3`. Jika tidak ada, mencoba memasangnya. |
| **Penyalinan berkas** | Menyalin `sundalang.py` ke `DATA_DIR` dan mencatat versinya. |
| **Pembuatan peluncur** | Membuat skrip kecil `sunda` yang memanggil Python dengan `sundalang.py`. Di Windows dibuat juga `sunda.cmd`. |
| **Pengaturan PATH** | Menambahkan folder perintah ke PATH setelah meminta izin, dengan blok bertanda `# >>> sundalang >>>` sampai `# <<< sundalang <<<` agar mudah dihapus kembali. |
| **Verifikasi** | Menjalankan `sunda --versi` dan program uji `citak "halo", 1 + 2` (harus menghasilkan `halo 3`). |

Hal lain yang dilakukan installer:

- **Tampilan menyesuaikan terminal.** Warna, lebar layar, dan simbol disesuaikan dengan kemampuan terminal. `NO_COLOR=1` mematikan warna.
- **Menangani berkas berakhiran baris Windows (CRLF).** Jika `run.sh` berasal dari Windows, installer otomatis membersihkannya saat dijalankan.
- **Aman terhadap berkas lain.** Jika sudah ada berkas bernama `sunda` yang bukan milik Sundalang, installer bertanya apakah ingin dicadangkan sebagai `sunda.bak`.
- **Pencopotan bersih.** `copot` menghapus perintah, blok PATH, dan data, tanpa menyentuh bagian lain di berkas konfigurasi shell Anda.

---

## 13. Batasan

Sundalang sengaja dibuat sederhana. Hal-hal berikut belum tersedia:

- Impor modul atau library.
- Kelas dan objek.
- Kamus (dictionary), tuple, dan himpunan. Struktur data yang ada hanya daftar.
- Membaca dan menulis berkas.
- Mengiris teks atau daftar (`teks[1:3]`).
- Perulangan langsung atas isi daftar (`pikeun` hanya untuk rentang angka; gunakan indeks seperti pada bagian 7.9).
- Blok tanpa kurung kurawal. Isi `lamun`, `salila`, `pikeun`, dan `pagawean` selalu memakai `{ }`.
- Komentar banyak baris. Gunakan `#` di setiap baris.
- Angka dengan notasi ilmiah (`1e5`).
- Fungsi harus didefinisikan sebelum dipanggil di level atas program.
- Program mandiri (`-o`) tetap memerlukan Python 3 di perangkat yang menjalankannya.

---

## 14. Tanya Jawab dan Pemecahan Masalah

**`sunda: command not found`**
Buka terminal baru, atau jalankan `source ~/.bashrc` (`~/.zshrc` untuk Zsh). Jalankan `bash run.sh status` dan lihat baris **PATH**. Di Windows, tutup lalu buka lagi terminal.

**Installer menampilkan "Berkas sundalang.py tidak ada di ..."**
`run.sh` dan `sundalang.py` harus berada di folder yang sama. Pindahkan keduanya ke satu folder, lalu jalankan ulang.

**"Python tidak ditemukan" atau "Python masih belum terdeteksi"**
Pasang Python 3 secara manual, lalu jalankan installer lagi:

| Platform | Perintah |
| --- | --- |
| Termux | `pkg install python` |
| macOS | `brew install python` |
| Windows | `winget install Python.Python.3.12` |
| Debian / Ubuntu | `sudo apt install python3` |

Di Windows, tutup dan buka lagi terminal setelah Python terpasang.

**`Berkas 'nama' teu kapendak`**
Berkas tidak ada di folder saat ini. Periksa nama dan lokasinya dengan `ls`, atau gunakan jalur lengkap.

**Apakah bisa menjalankan tanpa memasang?**
Bisa. Pakai `python3 sundalang.py berkas.sd` (lihat [4.6](#46-menjalankan-tanpa-memasang)).

**Apa beda `--py` dan `-o`?**
`--py` hanya **menampilkan** kode Python hasil terjemahan (tanpa runtime). `-o` **menyimpan** program mandiri lengkap dengan runtime, yang bisa dijalankan langsung dengan Python.

**Kenapa nama variabel saya berubah menjadi `print_s` di hasil `--py`?**
Nama yang bentrok dengan kata kunci atau fungsi bawaan Python (misalnya `print`, `list`, `math`) diberi akhiran `_s` supaya tidak merusak program. Perilaku program Anda tidak berubah.

**Teks Sunda atau karakter khusus tampil rusak di Windows**
Sundalang mengatur keluaran ke UTF-8. Gunakan terminal yang mendukung UTF-8, misalnya Git Bash atau Windows Terminal.

**Bagaimana cara melaporkan atau memperbaiki masalah?**
Jalankan program dengan `--py` untuk melihat kode Python hasil terjemahan, lalu periksa nomor baris pada pesan kesalahan. Isi `sundalang.py` dijelaskan di [bagian 11](#11-cara-kerja-compiler).

---

*Hatur nuhun sudah memakai Sundalang!*
