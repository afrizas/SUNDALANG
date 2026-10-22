#!/usr/bin/env bash
[ -z "${SUNDA_SUMBER:-}" ] && grep -q $'\r' "$0" 2>/dev/null && SUNDA_SUMBER="$(cd "$(dirname "$0")" && pwd)" exec bash <(tr -d '\r' <"$0") "$@"; _=

NAMA_APP="Sundalang"
PERINTAH="sunda"
BERKAS_PY="sundalang.py"
BERKAS_CONTO="conto.sd"
PENANDA_AWAL="# >>> sundalang >>>"
PENANDA_AKHIR="# <<< sundalang <<<"
SUMBER_DIR="${SUNDA_SUMBER:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

MENU_LABEL=("Pasang Sundalang" "Perbarui" "Cek status" "Copot" "Cara pakai" "Keluar")
MENU_AKSI=(pasang perbarui status copot cara keluar)
MENU_DESK=(
    "Pasang compiler dan perintah sunda"
    "Pakai versi terbaru dari folder ini"
    "Lihat kondisi pemasangan"
    "Hapus Sundalang dari perangkat"
    "Contoh perintah yang bisa dipakai"
    "Tutup pemasang"
)

FONT_S=".###/#.../.##./...#/###."
FONT_U="#..#/#..#/#..#/#..#/.##."
FONT_N="#..#/##.#/#.##/#..#/#..#"
FONT_D="###./#..#/#..#/#..#/###."
FONT_A=".##./#..#/####/#..#/#..#"
FONT_L="#.../#.../#.../#.../####"
FONT_G=".###/#.../#.##/#..#/.###"

MASKOT=(
    ".....gg....."
    "....gggg...."
    ".....s......"
    "...oooooo..."
    "..owbbbbbo.."
    ".obbbbbbbbo."
    ".obebbbbebo."
    ".obebbbbebo."
    ".ocbbmmbbco."
    ".obbbbbbbbo."
    "..obbbbbbo.."
    "...oooooo..."
)

PS_BUKA='$d=$env:SUNDA_DIR; $k=[Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Environment",$true); $p=$k.GetValue("Path","",[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames); $a=@($p -split ";" | Where-Object { $_ -ne "" -and $_ -ne $d });'
PS_TUTUP='$k.SetValue("Path",($a -join ";"),[Microsoft.Win32.RegistryValueKind]::ExpandString); $k.Close(); [Environment]::SetEnvironmentVariable("SUNDALANG_SIARAN","1","User"); [Environment]::SetEnvironmentVariable("SUNDALANG_SIARAN",$null,"User")'
PS_TAMBAH="$PS_BUKA"' $a += $d; '"$PS_TUTUP"
PS_HAPUS="$PS_BUKA $PS_TUTUP"

OTOMATIS=0
PERLU_MUAT_ULANG=0
PY_EXE=""
PY_VER=""
KEY=""
KEY_NUM=0


deteksi_os() {
    local s o
    s=$(uname -s 2>/dev/null)
    o=$(uname -o 2>/dev/null)
    case "$s" in
        Darwin)
            OS="macos"
            OS_LABEL="macOS"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS="windows"
            OS_LABEL="Windows (Git Bash)"
            ;;
        Linux)
            if [ "$o" = "Android" ] || [ -n "${TERMUX_VERSION:-}" ] || [ -d /data/data/com.termux ]; then
                OS="android"
                OS_LABEL="Android (Termux)"
            elif grep -qi microsoft /proc/version 2>/dev/null; then
                OS="wsl"
                OS_LABEL="Windows (WSL)"
            else
                OS="linux"
                OS_LABEL="Linux"
            fi
            ;;
        *)
            OS="linux"
            OS_LABEL="${s:-Tidak dikenal}"
            ;;
    esac
    if [ "$OS" = "android" ]; then
        PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
    fi
}

tentukan_lokasi() {
    case "$OS" in
        android)
            BIN_DIR="${SUNDA_BIN:-$PREFIX/bin}"
            DATA_DIR="${SUNDA_DATA:-$PREFIX/share/sundalang}"
            SHEBANG_SH="$PREFIX/bin/sh"
            if [ ! -x "$SHEBANG_SH" ]; then
                SHEBANG_SH="/bin/sh"
            fi
            ;;
        *)
            BIN_DIR="${SUNDA_BIN:-$HOME/.local/bin}"
            DATA_DIR="${SUNDA_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/sundalang}"
            SHEBANG_SH="/bin/sh"
            ;;
    esac
    case "$(basename "${SHELL:-sh}")" in
        zsh)
            RC_FILE="$HOME/.zshrc"
            RC_JENIS="posix"
            ;;
        fish)
            RC_FILE="$HOME/.config/fish/config.fish"
            RC_JENIS="fish"
            ;;
        bash)
            if [ "$OS" = "macos" ]; then
                RC_FILE="$HOME/.bash_profile"
            else
                RC_FILE="$HOME/.bashrc"
            fi
            RC_JENIS="posix"
            ;;
        *)
            RC_FILE="$HOME/.profile"
            RC_JENIS="posix"
            ;;
    esac
}


ukur_layar() {
    local kolom baris
    kolom=$(tput cols 2>/dev/null)
    baris=$(tput lines 2>/dev/null)
    case "$kolom" in
        ''|*[!0-9]*) kolom="${COLUMNS:-80}" ;;
    esac
    case "$baris" in
        ''|*[!0-9]*) baris="${LINES:-24}" ;;
    esac
    LEBAR=$kolom
    BARIS=$baris
    W=$((LEBAR - 4))
    if [ "$W" -gt 60 ]; then
        W=60
    fi
    if [ "$W" -lt 28 ]; then
        W=28
    fi
}

tentukan_mode_warna() {
    MODE_WARNA=0
    if [ "$INTERAKTIF" != 1 ] || [ -n "${NO_COLOR:-}" ]; then
        return 0
    fi
    case "${COLORTERM:-}" in
        *truecolor*|*24bit*)
            MODE_WARNA=24
            return 0
            ;;
    esac
    if [ "$OS" = "android" ]; then
        MODE_WARNA=24
        return 0
    fi
    case "${TERM:-}" in
        *256color*|*direct*) MODE_WARNA=256 ;;
        *) MODE_WARNA=8 ;;
    esac
}

tentukan_glif() {
    local lokal="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
    UTF=0
    case "$lokal" in
        *[Uu][Tt][Ff]-8*|*[Uu][Tt][Ff]8*) UTF=1 ;;
    esac
    if [ "$OS" = "android" ]; then
        UTF=1
    fi
    if [ "$UTF" = 1 ]; then
        G_OK="✓" G_ERR="✗" G_WARN="!" G_INFO="•" G_PANAH="❯" G_BUNGA="✿"
        G_GARIS="─" G_BAR="━" G_BAR2="─" G_TITIK="●" G_KOSONG="○" G_SEP="·" G_HATI="♥"
        G_SPIN=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
        MENU_IKON=("✿" "↻" "◎" "✕" "✦" "◂")
        TEKS_HINT_PANJANG="↑↓ pilih  ·  Enter jalan  ·  1-6  ·  q keluar"
        TEKS_HINT_PENDEK="↑↓ pilih · Enter · q keluar"
    else
        G_OK="+" G_ERR="x" G_WARN="!" G_INFO="*" G_PANAH=">" G_BUNGA="*"
        G_GARIS="-" G_BAR="=" G_BAR2="-" G_TITIK="*" G_KOSONG="o" G_SEP="|" G_HATI="<3"
        G_SPIN=("|" "/" "-" "\\")
        MENU_IKON=("+" "^" "o" "x" "?" "<")
        TEKS_HINT_PANJANG="atas/bawah pilih | Enter jalan | 1-6 | q keluar"
        TEKS_HINT_PENDEK="atas/bawah | Enter | q keluar"
    fi
}

ke256() {
    IDX256=$((16 + 36 * (($1 * 5 + 127) / 255) + 6 * (($2 * 5 + 127) / 255) + (($3 * 5 + 127) / 255)))
}

esc_fg() {
    case "$MODE_WARNA" in
        24) ESC_FG=$'\033[38;2;'"$1;$2;${3}m" ;;
        256)
            ke256 "$1" "$2" "$3"
            ESC_FG=$'\033[38;5;'"${IDX256}m"
            ;;
        8) ESC_FG=$'\033[35m' ;;
        *) ESC_FG="" ;;
    esac
}

esc_bg() {
    case "$MODE_WARNA" in
        24) ESC_BG=$'\033[48;2;'"$1;$2;${3}m" ;;
        256)
            ke256 "$1" "$2" "$3"
            ESC_BG=$'\033[48;5;'"${IDX256}m"
            ;;
        8) ESC_BG=$'\033[45m' ;;
        *) ESC_BG="" ;;
    esac
}

buat_warna() {
    local nama=$1 r=$2 g=$3 b=$4 kode8=$5
    esc_fg "$r" "$g" "$b"
    if [ "$MODE_WARNA" = 8 ]; then
        ESC_FG=$'\033[3'"${kode8}m"
    fi
    printf -v "C_$nama" '%s' "$ESC_FG"
    esc_bg "$r" "$g" "$b"
    if [ "$MODE_WARNA" = 8 ]; then
        ESC_BG=$'\033[4'"${kode8}m"
    fi
    printf -v "B_$nama" '%s' "$ESC_BG"
}

buat_palet() {
    C_RESET="" C_BOLD="" C_DIM=""
    if [ "$MODE_WARNA" != 0 ]; then
        C_RESET=$'\033[0m'
        C_BOLD=$'\033[1m'
        C_DIM=$'\033[2m'
    fi
    buat_warna PINK 255 126 182 5
    buat_warna PURPLE 179 136 255 5
    buat_warna SKY 110 198 255 6
    buat_warna GREEN 126 224 129 2
    buat_warna YELLOW 255 209 102 3
    buat_warna RED 255 107 129 1
    buat_warna GRAY 150 150 175 7
    buat_warna INK 45 30 70 0
    buat_warna KODE 52 44 76 0
    PIL_AKTIF="$B_PINK$C_INK$C_BOLD"
    PIL_KODE="$B_KODE$C_PINK"
}

siapkan_tampilan() {
    INTERAKTIF=0
    if [ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ]; then
        INTERAKTIF=1
    fi
    ukur_layar
    tentukan_mode_warna
    tentukan_glif
    buat_palet
}


gradien() {
    local pos=$1 total=$2 t u
    if [ "$total" -le 1 ]; then
        t=0
    else
        t=$((pos * 100 / (total - 1)))
    fi
    if [ "$t" -lt 50 ]; then
        u=$((t * 2))
        GR_R=$((255 + (179 - 255) * u / 100))
        GR_G=$((126 + (136 - 126) * u / 100))
        GR_B=$((182 + (255 - 182) * u / 100))
    else
        u=$(((t - 50) * 2))
        GR_R=$((179 + (110 - 179) * u / 100))
        GR_G=$((136 + (198 - 136) * u / 100))
        GR_B=255
    fi
}

ulang() {
    local karakter=$1 jumlah=$2 hasil="" i=0
    while [ "$i" -lt "$jumlah" ]; do
        hasil="$hasil$karakter"
        i=$((i + 1))
    done
    printf '%s' "$hasil"
}

garis_gradien() {
    local lebar=$1 i=0 keluar=""
    while [ "$i" -lt "$lebar" ]; do
        gradien "$i" "$lebar"
        esc_fg "$GR_R" "$GR_G" "$GR_B"
        keluar="$keluar$ESC_FG$G_GARIS"
        i=$((i + 1))
    done
    printf '  %s%s\n' "$keluar" "$C_RESET"
}

teks_gradien() {
    local teks=$1 i=0 total=${#1}
    HASIL_GR=""
    while [ "$i" -lt "$total" ]; do
        gradien "$i" "$total"
        esc_fg "$GR_R" "$GR_G" "$GR_B"
        HASIL_GR="$HASIL_GR$ESC_FG${teks:$i:1}"
        i=$((i + 1))
    done
    HASIL_GR="$HASIL_GR$C_RESET"
}

data_huruf() {
    case "$1" in
        S) GLYPH=$FONT_S ;;
        U) GLYPH=$FONT_U ;;
        N) GLYPH=$FONT_N ;;
        D) GLYPH=$FONT_D ;;
        A) GLYPH=$FONT_A ;;
        L) GLYPH=$FONT_L ;;
        G) GLYPH=$FONT_G ;;
        *) GLYPH="...././.../.../..." ;;
    esac
}

baris_kata() {
    local kata=$1 tr=$2 total=$3 x=0 i=0 c atas bawah ch huruf
    ROW_OUT=""
    while [ "$i" -lt "${#kata}" ]; do
        huruf=${kata:$i:1}
        data_huruf "$huruf"
        c=0
        while [ "$c" -lt 5 ]; do
            atas="."
            bawah="."
            if [ "$c" -lt 4 ]; then
                atas=${GLYPH:$((tr * 10 + c)):1}
                if [ $((tr * 2 + 1)) -lt 5 ]; then
                    bawah=${GLYPH:$((tr * 10 + 5 + c)):1}
                fi
            fi
            if [ "$atas" = "#" ] && [ "$bawah" = "#" ]; then
                ch="█"
            elif [ "$atas" = "#" ]; then
                ch="▀"
            elif [ "$bawah" = "#" ]; then
                ch="▄"
            else
                ch=" "
            fi
            gradien "$x" "$total"
            esc_fg "$GR_R" "$GR_G" "$GR_B"
            ROW_OUT="$ROW_OUT$ESC_FG$ch"
            x=$((x + 1))
            c=$((c + 1))
        done
        i=$((i + 1))
    done
}

warna_piksel() {
    case "$1" in
        g) PX_R=126 PX_G=224 PX_B=129 ;;
        s) PX_R=79 PX_G=191 PX_B=103 ;;
        o) PX_R=255 PX_G=126 PX_B=182 ;;
        b) PX_R=255 PX_G=214 PX_B=234 ;;
        w) PX_R=255 PX_G=255 PX_B=255 ;;
        e) PX_R=59 PX_G=42 PX_B=80 ;;
        m) PX_R=59 PX_G=42 PX_B=80 ;;
        c) PX_R=255 PX_G=128 PX_B=170 ;;
        *) return 1 ;;
    esac
    return 0
}

baris_maskot() {
    local tr=$1 atas bawah c=0 ada_atas ada_bawah
    local baris_atas="${MASKOT[$((tr * 2))]}" baris_bawah="${MASKOT[$((tr * 2 + 1))]}"
    ROW_OUT=""
    while [ "$c" -lt 12 ]; do
        atas=${baris_atas:$c:1}
        bawah=${baris_bawah:$c:1}
        ada_atas=0
        ada_bawah=0
        if warna_piksel "$atas"; then
            ada_atas=1
            esc_fg "$PX_R" "$PX_G" "$PX_B"
            ESC_ATAS=$ESC_FG
        fi
        if warna_piksel "$bawah"; then
            ada_bawah=1
            esc_bg "$PX_R" "$PX_G" "$PX_B"
            esc_fg "$PX_R" "$PX_G" "$PX_B"
            ESC_BAWAH_BG=$ESC_BG
            ESC_BAWAH_FG=$ESC_FG
        fi
        if [ "$ada_atas" = 1 ] && [ "$ada_bawah" = 1 ]; then
            ROW_OUT="$ROW_OUT$ESC_ATAS$ESC_BAWAH_BG▀$C_RESET"
        elif [ "$ada_atas" = 1 ]; then
            ROW_OUT="$ROW_OUT$ESC_ATAS▀$C_RESET"
        elif [ "$ada_bawah" = 1 ]; then
            ROW_OUT="$ROW_OUT$ESC_BAWAH_FG▄$C_RESET"
        else
            ROW_OUT="$ROW_OUT "
        fi
        c=$((c + 1))
    done
}

banner_besar_ok() {
    [ "$INTERAKTIF" = 1 ] && [ "$UTF" = 1 ] && [ "$LEBAR" -ge 30 ] && [ "$BARIS" -ge 22 ]
}

maskot_ok() {
    { [ "$MODE_WARNA" = 24 ] || [ "$MODE_WARNA" = 256 ]; } && [ "$LEBAR" -ge 42 ]
}

tampil_tagline() {
    printf '\n  %sWilujeng sumping!%s  %sbasa program Sunda%s\n' "$C_PINK$C_BOLD" "$C_RESET" "$C_GRAY" "$C_RESET"
    printf '  %sv%s %s Android %s Windows %s Linux %s macOS%s\n' \
        "$C_GRAY" "${VERSI_SUMBER:-?}" "$G_SEP" "$G_SEP" "$G_SEP" "$G_SEP" "$C_RESET"
    garis_gradien "$W"
}

tampil_banner_kecil() {
    teks_gradien "S U N D A L A N G"
    printf '\n  %s%s%s %s %s%s%s  %s%s%s\n' \
        "$C_PINK" "$G_BUNGA" "$C_RESET" "$HASIL_GR" "$C_PINK" "$G_BUNGA" "$C_RESET" \
        "$C_GRAY" "v${VERSI_SUMBER:-?}" "$C_RESET"
}

tampil_banner() {
    local baris=0 kata tr lebar_kata pad kiri
    printf '\n'
    if ! banner_besar_ok; then
        tampil_banner_kecil
        tampil_tagline
        return 0
    fi
    while [ "$baris" -lt 6 ]; do
        if [ "$baris" -lt 3 ]; then
            kata="SUNDA"
            tr=$baris
            lebar_kata=25
            pad=""
        else
            kata="LANG"
            tr=$((baris - 3))
            lebar_kata=20
            pad="     "
        fi
        baris_kata "$kata" "$tr" "$lebar_kata"
        kiri=$ROW_OUT
        if maskot_ok; then
            baris_maskot "$baris"
            printf '  %s%s%s %s%s\n' "$kiri" "$C_RESET" "$pad" "$ROW_OUT" "$C_RESET"
        else
            printf '  %s%s\n' "$kiri" "$C_RESET"
        fi
        baris=$((baris + 1))
    done
    tampil_tagline
}


sembunyi_kursor() {
    if [ "$INTERAKTIF" = 1 ]; then
        printf '\033[?25l'
    fi
}

tampil_kursor() {
    if [ "$INTERAKTIF" = 1 ]; then
        printf '\033[?25h'
    fi
}

bersihkan_layar() {
    if [ "$INTERAKTIF" = 1 ]; then
        printf '\033[H\033[2J'
    fi
}

ringkas_path() {
    local p=$1
    case "$p" in
        "$HOME") p="~" ;;
        "$HOME"/*) p="~/${p#"$HOME"/}" ;;
    esac
    if [ -n "${PREFIX:-}" ]; then
        case "$p" in
            "$PREFIX"/*) p='$PREFIX/'"${p#"$PREFIX"/}" ;;
        esac
    fi
    printf '%s' "$p"
}

bungkus() {
    if command -v fold >/dev/null 2>&1; then
        printf '%s\n' "$1" | fold -s -w "$2"
    else
        printf '%s\n' "$1"
    fi
}

pesan() {
    local ikon=$1 warna=$2 teks=$3 pertama=1 baris
    while IFS= read -r baris; do
        if [ "$pertama" = 1 ]; then
            printf '  %s%s%s %s\n' "$warna" "$ikon" "$C_RESET" "$baris"
            pertama=0
        else
            printf '    %s\n' "$baris"
        fi
    done <<<"$(bungkus "$teks" "$((W - 1))")"
}

info() {
    pesan "$G_INFO" "$C_SKY" "$*"
}

sukses() {
    pesan "$G_OK" "$C_GREEN" "$*"
}

peringatan() {
    pesan "$G_WARN" "$C_YELLOW" "$*"
}

galat() {
    pesan "$G_ERR" "$C_RED" "$*" >&2
}

baris_info() {
    local label=$1 nilai=$2 warna=${3:-} pertama=1 baris lebar_label=${LEBAR_LABEL:-9}
    while IFS= read -r baris; do
        if [ "$pertama" = 1 ]; then
            printf '  %s%-*s%s %s%s%s\n' "$C_GRAY" "$lebar_label" "$label" "$C_RESET" "$warna" "$baris" "$C_RESET"
            pertama=0
        else
            printf '  %*s %s%s%s\n' "$lebar_label" "" "$warna" "$baris" "$C_RESET"
        fi
    done <<<"$(bungkus "$nilai" "$((W - lebar_label - 2))")"
}

judul() {
    printf '\n  %s%s %s%s\n' "$C_PINK$C_BOLD" "$G_PANAH" "$1" "$C_RESET"
    garis_gradien "$W"
}

langkah() {
    local sekarang=$1 total=$2 teks=$3 i=0 bar=""
    while [ "$i" -lt "$total" ]; do
        if [ "$i" -lt "$sekarang" ]; then
            gradien "$i" "$total"
            esc_fg "$GR_R" "$GR_G" "$GR_B"
            bar="$bar$ESC_FG$G_BAR$G_BAR"
        else
            bar="$bar$C_GRAY$G_BAR2$G_BAR2"
        fi
        i=$((i + 1))
    done
    printf '\n  %s%s  %s%d/%d%s  %s%s%s\n' "$bar" "$C_RESET" "$C_GRAY" "$sekarang" "$total" "$C_RESET" "$C_BOLD" "$teks" "$C_RESET"
}

pil() {
    if [ "$MODE_WARNA" = 0 ]; then
        printf '[%s]' "$1"
    else
        printf '%s %s %s' "$PIL_KODE" "$1" "$C_RESET"
    fi
}

perintah_pil() {
    local cmd=$1 desk=$2
    if [ "$LEBAR" -ge 70 ]; then
        printf '  %s  %s%s%s\n' "$(pil "$cmd")" "$C_GRAY" "$desk" "$C_RESET"
    else
        printf '  %s\n' "$(pil "$cmd")"
        printf '    %s%s%s\n' "$C_GRAY" "$desk" "$C_RESET"
    fi
}

jalan_fg() {
    printf '    %s$ %s%s\n' "$C_GRAY" "$*" "$C_RESET"
    "$@"
}

dengan_spinner() {
    local pesan_teks=$1 log pid i=0 status warna
    local palet=("$C_PINK" "$C_PURPLE" "$C_SKY")
    shift
    log=$(mktemp "${TMPDIR:-/tmp}/sundalang.XXXXXX")
    if [ "$INTERAKTIF" != 1 ]; then
        info "$pesan_teks"
        "$@" >"$log" 2>&1
        status=$?
    else
        "$@" >"$log" 2>&1 &
        pid=$!
        sembunyi_kursor
        while kill -0 "$pid" 2>/dev/null; do
            warna=${palet[$((i % 3))]}
            printf '\r  %s%s%s %s' "$warna" "${G_SPIN[$((i % ${#G_SPIN[@]}))]}" "$C_RESET" "$pesan_teks"
            i=$((i + 1))
            sleep 0.1
        done
        wait "$pid"
        status=$?
        printf '\r\033[K'
        tampil_kursor
    fi
    if [ "$status" -eq 0 ]; then
        sukses "$pesan_teks"
    else
        galat "$pesan_teks"
        tail -n 8 "$log" | sed 's/^/      /' >&2
    fi
    rm -f "$log"
    return "$status"
}

tanya_ya() {
    local jawab bawaan=${2:-y} pil_ya pil_tidak
    if [ "$OTOMATIS" = 1 ]; then
        info "$1 ${C_GRAY}(otomatis: ya)${C_RESET}"
        return 0
    fi
    if [ ! -t 0 ]; then
        peringatan "$1 (dilewati; tambahkan -y untuk menjawab ya otomatis)"
        return 1
    fi
    pesan "?" "$C_YELLOW" "$1"
    if [ "$bawaan" = "y" ]; then
        pil_ya="$PIL_AKTIF Y ya $C_RESET"
        pil_tidak="${C_GRAY}n tidak$C_RESET"
    else
        pil_ya="${C_GRAY}y ya$C_RESET"
        pil_tidak="$PIL_AKTIF N tidak $C_RESET"
    fi
    printf '    %s   %s ' "$pil_ya" "$pil_tidak"
    IFS= read -rsn1 jawab
    printf '\r\033[K'
    case "$jawab" in
        y|Y)
            printf '    %s%s ya%s\n' "$C_GREEN" "$G_PANAH" "$C_RESET"
            return 0
            ;;
        n|N)
            printf '    %s%s tidak%s\n' "$C_GRAY" "$G_PANAH" "$C_RESET"
            return 1
            ;;
        *)
            if [ "$bawaan" = "y" ]; then
                printf '    %s%s ya%s\n' "$C_GREEN" "$G_PANAH" "$C_RESET"
                return 0
            fi
            printf '    %s%s tidak%s\n' "$C_GRAY" "$G_PANAH" "$C_RESET"
            return 1
            ;;
    esac
}

baca_tombol() {
    local k rest
    KEY="lain"
    KEY_NUM=0
    if ! IFS= read -rsn1 k; then
        KEY="eof"
        return
    fi
    case "$k" in
        $'\033')
            rest=""
            IFS= read -rsn2 -t 1 rest || true
            case "$rest" in
                "[A") KEY="atas" ;;
                "[B") KEY="bawah" ;;
                *) KEY="esc" ;;
            esac
            ;;
        "") KEY="enter" ;;
        [0-9])
            KEY="angka"
            KEY_NUM=$k
            ;;
        k|K) KEY="atas" ;;
        j|J) KEY="bawah" ;;
        q|Q) KEY="keluar" ;;
    esac
}

tunggu_tombol() {
    printf '\n  %s%s Tekan tombol apa saja untuk kembali%s' "$C_GRAY" "$G_PANAH" "$C_RESET"
    IFS= read -rsn1 _ || true
    printf '\n'
}


gambar_menu() {
    local pilih=$1 i=0 total=${#MENU_LABEL[@]}
    while [ "$i" -lt "$total" ]; do
        if [ "$i" -eq "$pilih" ]; then
            printf '  %s %s %s  %-*s%s\033[K\n' "$PIL_AKTIF" "$G_PANAH" "${MENU_IKON[$i]}" "$((W - 6))" "${MENU_LABEL[$i]}" "$C_RESET"
        else
            printf '     %s%s%s  %s\033[K\n' "$C_PINK" "${MENU_IKON[$i]}" "$C_RESET" "${MENU_LABEL[$i]}"
        fi
        i=$((i + 1))
    done
    printf '\033[K\n  %s%s%s\033[K\n' "$C_GRAY" "${MENU_DESK[$pilih]}" "$C_RESET"
}

menu_utama() {
    local pilih=0 total=${#MENU_LABEL[@]} aksi hint
    if [ "$W" -ge 44 ]; then
        hint=$TEKS_HINT_PANJANG
    else
        hint=$TEKS_HINT_PENDEK
    fi
    while true; do
        bersihkan_layar
        tampil_banner
        printf '\n  %s%s%s\n\n' "$C_GRAY" "$hint" "$C_RESET"
        sembunyi_kursor
        gambar_menu "$pilih"
        while true; do
            baca_tombol
            case "$KEY" in
                atas) pilih=$(((pilih + total - 1) % total)) ;;
                bawah) pilih=$(((pilih + 1) % total)) ;;
                enter) break ;;
                keluar | eof)
                    pilih=$((total - 1))
                    break
                    ;;
                angka)
                    if [ "$KEY_NUM" -ge 1 ] && [ "$KEY_NUM" -le "$total" ]; then
                        pilih=$((KEY_NUM - 1))
                        break
                    fi
                    ;;
            esac
            printf '\033[%dA' "$((total + 2))"
            gambar_menu "$pilih"
        done
        tampil_kursor
        aksi="${MENU_AKSI[$pilih]}"
        if [ "$aksi" = "keluar" ]; then
            bersihkan_layar
            tampil_banner_kecil
            printf '\n  %sSampai jumpa! Hatur nuhun %s%s\n\n' "$C_PINK" "$G_HATI" "$C_RESET"
            return 0
        fi
        bersihkan_layar
        tampil_banner_kecil
        jalankan_aksi "$aksi"
        tunggu_tombol
    done
}

jalankan_aksi() {
    case "$1" in
        pasang) aksi_pasang ;;
        perbarui) aksi_perbarui ;;
        status) aksi_status ;;
        copot) aksi_copot ;;
        cara) aksi_cara ;;
    esac
}


baca_versi() {
    sed -n 's/^VERSI *= *"\(.*\)".*/\1/p' "$1" 2>/dev/null | head -n 1
}

path_berisi() {
    case ":$PATH:" in
        *":$1:"*) return 0 ;;
    esac
    return 1
}

sudah_terpasang() {
    [ -f "$BIN_DIR/$PERINTAH" ] && grep -q '^SUNDALANG_LAUNCHER=1' "$BIN_DIR/$PERINTAH" 2>/dev/null
}

cari_python() {
    local kandidat hasil ok exe ver
    PY_EXE=""
    PY_VER=""
    for kandidat in python3 python "py -3"; do
        command -v "${kandidat%% *}" >/dev/null 2>&1 || continue
        if [ "$OS" = "macos" ] && [ "$(command -v "${kandidat%% *}")" = "/usr/bin/python3" ]; then
            xcode-select -p >/dev/null 2>&1 || continue
        fi
        hasil=$($kandidat -c 'import sys;print(int(sys.version_info>=(3,8)));print(sys.executable);print("%d.%d.%d"%sys.version_info[:3])' 2>/dev/null | tr -d '\r')
        ok=$(printf '%s\n' "$hasil" | sed -n 1p)
        exe=$(printf '%s\n' "$hasil" | sed -n 2p)
        ver=$(printf '%s\n' "$hasil" | sed -n 3p)
        if [ "$ok" = "1" ] && [ -n "$exe" ]; then
            PY_EXE="$exe"
            PY_VER="$ver"
            return 0
        fi
    done
    return 1
}

petunjuk_python() {
    peringatan "Pasang Python 3.8 atau lebih baru secara manual:"
    case "$OS" in
        android) perintah_pil "pkg install python" "di Termux" ;;
        macos) perintah_pil "brew install python" "atau unduh dari python.org" ;;
        windows) perintah_pil "winget install Python.Python.3.12" "atau unduh dari python.org" ;;
        *) perintah_pil "sudo apt install python3" "atau pakai package manager distro Anda" ;;
    esac
}

pasang_python() {
    local sudo=""
    if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        sudo="sudo"
    fi
    case "$OS" in
        android)
            dengan_spinner "Memasang Python lewat pkg" pkg install -y python
            ;;
        macos)
            if command -v brew >/dev/null 2>&1; then
                dengan_spinner "Memasang Python lewat Homebrew" brew install python
            else
                petunjuk_python
                return 1
            fi
            ;;
        windows)
            if command -v winget.exe >/dev/null 2>&1; then
                jalan_fg winget.exe install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
            else
                petunjuk_python
                return 1
            fi
            ;;
        *)
            if [ "$(id -u)" -ne 0 ] && [ -z "$sudo" ]; then
                petunjuk_python
                return 1
            fi
            if command -v apt-get >/dev/null 2>&1; then
                jalan_fg $sudo apt-get update && jalan_fg $sudo apt-get install -y python3
            elif command -v dnf >/dev/null 2>&1; then
                jalan_fg $sudo dnf install -y python3
            elif command -v yum >/dev/null 2>&1; then
                jalan_fg $sudo yum install -y python3
            elif command -v pacman >/dev/null 2>&1; then
                jalan_fg $sudo pacman -S --noconfirm python
            elif command -v zypper >/dev/null 2>&1; then
                jalan_fg $sudo zypper install -y python3
            elif command -v apk >/dev/null 2>&1; then
                jalan_fg $sudo apk add python3
            elif command -v xbps-install >/dev/null 2>&1; then
                jalan_fg $sudo xbps-install -y python3
            else
                petunjuk_python
                return 1
            fi
            ;;
    esac
}

pastikan_python() {
    if cari_python; then
        sukses "Python $PY_VER siap dipakai"
        return 0
    fi
    peringatan "Python 3.8 atau lebih baru belum ditemukan"
    if ! tanya_ya "Pasang Python sekarang?"; then
        petunjuk_python
        return 1
    fi
    if ! pasang_python; then
        galat "Gagal memasang Python"
        return 1
    fi
    if cari_python; then
        sukses "Python $PY_VER siap dipakai"
        return 0
    fi
    if [ "$OS" = "windows" ]; then
        peringatan "Python baru terpasang. Tutup lalu buka lagi terminal, kemudian jalankan ulang: bash sundalang.sh"
    else
        galat "Python masih belum terdeteksi setelah pemasangan"
    fi
    return 1
}

salin_berkas() {
    local sumber="$SUMBER_DIR/$BERKAS_PY"
    if [ ! -f "$sumber" ]; then
        galat "Berkas $BERKAS_PY tidak ada di $(ringkas_path "$SUMBER_DIR")"
        return 1
    fi
    if ! mkdir -p "$DATA_DIR/contoh" "$BIN_DIR"; then
        galat "Tidak bisa membuat folder $(ringkas_path "$DATA_DIR") atau $(ringkas_path "$BIN_DIR")"
        return 1
    fi
    if ! cp "$sumber" "$DATA_DIR/$BERKAS_PY"; then
        galat "Gagal menyalin $BERKAS_PY"
        return 1
    fi
    chmod 644 "$DATA_DIR/$BERKAS_PY"
    if [ -f "$SUMBER_DIR/$BERKAS_CONTO" ]; then
        cp "$SUMBER_DIR/$BERKAS_CONTO" "$DATA_DIR/contoh/$BERKAS_CONTO"
    fi
    printf '%s\n' "$VERSI_SUMBER" >"$DATA_DIR/versi"
    sukses "Berkas disalin ke $(ringkas_path "$DATA_DIR")"
}

kutip() {
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

buat_peluncur() {
    local target="$BIN_DIR/$PERINTAH" py="$PY_EXE" skrip="$DATA_DIR/$BERKAS_PY"
    if [ "$OS" = "windows" ]; then
        py=$(cygpath -m "$PY_EXE")
        skrip=$(cygpath -m "$skrip")
    fi
    if [ -e "$target" ] && ! sudah_terpasang; then
        peringatan "Sudah ada berkas lain bernama $(ringkas_path "$target")"
        if tanya_ya "Cadangkan sebagai $PERINTAH.bak lalu timpa?"; then
            mv "$target" "$target.bak"
        else
            return 1
        fi
    fi
    {
        printf '#!%s\n' "$SHEBANG_SH"
        printf 'SUNDALANG_LAUNCHER=1\n'
        if [ "$OS" = "windows" ]; then
            printf 'export PYTHONUTF8=1 PYTHONUNBUFFERED=1\n'
        fi
        printf 'PY=%s\n' "$(kutip "$py")"
        printf 'SKRIP=%s\n' "$(kutip "$skrip")"
        cat <<'ISI'
[ -x "$PY" ] || PY=$(command -v python3 || command -v python)
[ -n "$PY" ] || { echo "Python tidak ditemukan" >&2; exit 127; }
exec "$PY" "$SKRIP" "$@"
ISI
    } >"$target"
    chmod 755 "$target"
    if [ "$OS" = "windows" ]; then
        printf '@echo off\r\nset PYTHONUTF8=1\r\n"%s" "%s" %%*\r\n' \
            "$(cygpath -w "$PY_EXE")" "$(cygpath -w "$DATA_DIR/$BERKAS_PY")" >"$BIN_DIR/$PERINTAH.cmd"
        sukses "Perintah $PERINTAH dibuat (juga $PERINTAH.cmd untuk CMD dan PowerShell)"
    else
        sukses "Perintah $PERINTAH dibuat di $(ringkas_path "$BIN_DIR")"
    fi
}

catat_jejak() {
    mkdir -p "$DATA_DIR"
    if ! grep -qxF "$1" "$DATA_DIR/jejak" 2>/dev/null; then
        printf '%s\n' "$1" >>"$DATA_DIR/jejak"
    fi
}

ekspresi_bin() {
    if [ "${BIN_DIR#"$HOME"/}" != "$BIN_DIR" ]; then
        printf '$HOME/%s' "${BIN_DIR#"$HOME"/}"
    else
        printf '%s' "$BIN_DIR"
    fi
}

atur_path_shell() {
    local ekspresi
    ekspresi=$(ekspresi_bin)
    if grep -qF "$PENANDA_AWAL" "$RC_FILE" 2>/dev/null; then
        sukses "PATH sudah diatur di $(ringkas_path "$RC_FILE")"
        return 0
    fi
    if ! tanya_ya "Tambahkan $(ringkas_path "$BIN_DIR") ke PATH lewat $(ringkas_path "$RC_FILE")?"; then
        peringatan "Dilewati. Tambahkan sendiri baris ini ke $(ringkas_path "$RC_FILE"):"
        perintah_pil "export PATH=\"$ekspresi:\$PATH\"" "salin ke berkas di atas"
        return 0
    fi
    mkdir -p "$(dirname "$RC_FILE")"
    {
        printf '\n%s\n' "$PENANDA_AWAL"
        if [ "$RC_JENIS" = "fish" ]; then
            printf 'fish_add_path -g "%s"\n' "$ekspresi"
        else
            printf 'export PATH="%s:$PATH"\n' "$ekspresi"
        fi
        printf '%s\n' "$PENANDA_AKHIR"
    } >>"$RC_FILE"
    catat_jejak "rc=$RC_FILE"
    sukses "PATH ditambahkan ke $(ringkas_path "$RC_FILE")"
}

jalan_powershell() {
    SUNDA_DIR="$(cygpath -w "$BIN_DIR")" powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$1" >/dev/null 2>&1
}

atur_path_windows() {
    if ! command -v powershell.exe >/dev/null 2>&1; then
        peringatan "PowerShell tidak ditemukan. Tambahkan $(cygpath -w "$BIN_DIR") ke PATH Windows secara manual"
        return 0
    fi
    if ! tanya_ya "Tambahkan $(cygpath -w "$BIN_DIR") ke PATH pengguna Windows?"; then
        peringatan "Dilewati. Tambahkan folder itu ke PATH lewat Environment Variables"
        return 0
    fi
    if jalan_powershell "$PS_TAMBAH"; then
        catat_jejak "winpath=1"
        sukses "PATH Windows diperbarui"
    else
        peringatan "Gagal mengubah PATH Windows. Tambahkan $(cygpath -w "$BIN_DIR") secara manual"
    fi
}

atur_path() {
    if [ "$OS" = "android" ]; then
        sukses "Tidak perlu, PATH Termux sudah siap"
        return 0
    fi
    if path_berisi "$BIN_DIR"; then
        sukses "$(ringkas_path "$BIN_DIR") sudah ada di PATH"
        return 0
    fi
    PERLU_MUAT_ULANG=1
    if [ "$OS" = "windows" ]; then
        atur_path_windows
    else
        atur_path_shell
    fi
}

verifikasi() {
    local tmp keluaran versi
    versi=$("$BIN_DIR/$PERINTAH" --versi 2>/dev/null | tr -d '\r')
    if [ -z "$versi" ]; then
        galat "Perintah $PERINTAH tidak bisa dijalankan"
        return 1
    fi
    sukses "$versi"
    tmp=$(mktemp "${TMPDIR:-/tmp}/sundalang.XXXXXX")
    printf 'citak "halo", 1 + 2\n' >"$tmp.sd"
    keluaran=$("$BIN_DIR/$PERINTAH" "$tmp.sd" 2>&1 | tr -d '\r')
    rm -f "$tmp" "$tmp.sd"
    if [ "$keluaran" = "halo 3" ]; then
        sukses "Program uji berjalan dengan benar"
        return 0
    fi
    galat "Program uji menghasilkan keluaran tak terduga: $keluaran"
    return 1
}

ringkasan_pasang() {
    local muat
    if [ "$PERLU_MUAT_ULANG" = 1 ]; then
        if [ "$OS" = "windows" ]; then
            muat="Tutup lalu buka lagi terminal Anda agar perintah $PERINTAH dikenali"
        else
            muat="Buka terminal baru, atau jalankan source $(ringkas_path "$RC_FILE") agar perintah $PERINTAH dikenali"
        fi
        printf '\n'
        peringatan "$muat"
    fi
    teks_gradien "Sundalang siap dipakai!"
    printf '\n  %s%s%s %s %s%s%s\n\n' "$C_PINK" "$G_BUNGA" "$C_RESET" "$HASIL_GR" "$C_PINK" "$G_BUNGA" "$C_RESET"
    printf '  %sCoba sekarang:%s\n\n' "$C_BOLD" "$C_RESET"
    perintah_pil "$PERINTAH --baru halo" "buat program pertama"
    perintah_pil "$PERINTAH halo" "jalankan programnya"
    perintah_pil "$PERINTAH" "mode interaktif"
    printf '\n'
}

aksi_pasang() {
    local total=6 pembaruan=0
    PERLU_MUAT_ULANG=0
    if sudah_terpasang; then
        pembaruan=1
    fi
    if [ "$pembaruan" = 1 ]; then
        judul "Perbarui $NAMA_APP"
    else
        judul "Pasang $NAMA_APP"
    fi
    langkah 1 "$total" "Mengenali sistem"
    baris_info "Sistem" "$OS_LABEL $G_SEP $(uname -m 2>/dev/null)"
    baris_info "Perintah" "$(ringkas_path "$BIN_DIR")"
    baris_info "Data" "$(ringkas_path "$DATA_DIR")"
    langkah 2 "$total" "Mencari Python"
    pastikan_python || return 1
    langkah 3 "$total" "Menyalin berkas"
    salin_berkas || return 1
    langkah 4 "$total" "Membuat perintah"
    buat_peluncur || return 1
    langkah 5 "$total" "Mengatur PATH"
    atur_path
    langkah 6 "$total" "Memeriksa hasil"
    verifikasi || return 1
    printf '\n'
    garis_gradien "$W"
    printf '\n'
    ringkasan_pasang
}

aksi_perbarui() {
    local terpasang
    judul "Perbarui $NAMA_APP"
    if ! sudah_terpasang; then
        printf '\n'
        peringatan "$NAMA_APP belum terpasang"
        if tanya_ya "Pasang sekarang?"; then
            aksi_pasang
        fi
        return 0
    fi
    terpasang=$(cat "$DATA_DIR/versi" 2>/dev/null)
    printf '\n'
    baris_info "Terpasang" "v${terpasang:-?}"
    baris_info "Folder ini" "v${VERSI_SUMBER:-?}"
    printf '\n'
    if cmp -s "$SUMBER_DIR/$BERKAS_PY" "$DATA_DIR/$BERKAS_PY"; then
        sukses "Sudah yang terbaru, tidak ada yang perlu diperbarui"
        return 0
    fi
    aksi_pasang
}

aksi_status() {
    local terpasang versi_folder="tidak ada"
    judul "Status $NAMA_APP"
    printf '\n'
    terpasang=$(cat "$DATA_DIR/versi" 2>/dev/null)
    baris_info "Sistem" "$OS_LABEL $G_SEP $(uname -m 2>/dev/null)"
    if cari_python; then
        baris_info "Python" "$PY_VER" "$C_GREEN"
    else
        baris_info "Python" "belum ditemukan" "$C_YELLOW"
    fi
    if sudah_terpasang; then
        baris_info "Sunda" "$G_TITIK terpasang v${terpasang:-?}" "$C_GREEN"
        baris_info "Lokasi" "$(ringkas_path "$BIN_DIR/$PERINTAH")"
    else
        baris_info "Sunda" "$G_KOSONG belum terpasang" "$C_YELLOW"
    fi
    if [ -f "$SUMBER_DIR/$BERKAS_PY" ]; then
        versi_folder="v${VERSI_SUMBER:-?}"
    fi
    baris_info "Folder" "$versi_folder"
    if path_berisi "$BIN_DIR" || [ "$OS" = "android" ]; then
        baris_info "PATH" "$G_TITIK siap" "$C_GREEN"
    else
        baris_info "PATH" "$G_KOSONG belum ada di sesi ini" "$C_YELLOW"
    fi
    if ! sudah_terpasang; then
        printf '\n  %sPilih "Pasang Sundalang" di menu untuk memulai%s\n' "$C_GRAY" "$C_RESET"
    fi
}

hapus_blok_rc() {
    local berkas=$1 tmp
    grep -qF "$PENANDA_AWAL" "$berkas" 2>/dev/null || return 1
    tmp=$(mktemp "${TMPDIR:-/tmp}/sundalang.XXXXXX")
    awk -v a="$PENANDA_AWAL" -v z="$PENANDA_AKHIR" '
        $0 == a { s = 1; pend = 0; next }
        $0 == z { s = 0; next }
        s { next }
        $0 == "" { if (pend) print ""; pend = 1; next }
        { if (pend) print ""; pend = 0; print }
        END { if (pend) print "" }
    ' "$berkas" >"$tmp" && cat "$tmp" >"$berkas"
    rm -f "$tmp"
    return 0
}

aksi_copot() {
    local ada=0 berkas
    judul "Copot $NAMA_APP"
    printf '\n'
    if sudah_terpasang || [ -f "$DATA_DIR/$BERKAS_PY" ]; then
        ada=1
    fi
    if [ "$ada" = 0 ]; then
        info "Tidak ada $NAMA_APP yang terpasang"
        return 0
    fi
    if ! tanya_ya "Hapus $NAMA_APP dari perangkat ini?" n; then
        info "Dibatalkan, tidak ada yang dihapus"
        return 0
    fi
    printf '\n'
    if sudah_terpasang; then
        rm -f "$BIN_DIR/$PERINTAH" "$BIN_DIR/$PERINTAH.cmd"
        sukses "Perintah $PERINTAH dihapus"
    fi
    for berkas in "$RC_FILE" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.config/fish/config.fish"; do
        if hapus_blok_rc "$berkas"; then
            sukses "Pengaturan PATH dihapus dari $(ringkas_path "$berkas")"
        fi
    done
    if [ "$OS" = "windows" ] && grep -qx 'winpath=1' "$DATA_DIR/jejak" 2>/dev/null; then
        if command -v powershell.exe >/dev/null 2>&1 && jalan_powershell "$PS_HAPUS"; then
            sukses "PATH Windows dibersihkan"
        else
            peringatan "Hapus $(cygpath -w "$BIN_DIR") dari PATH Windows secara manual"
        fi
    fi
    rm -f "$DATA_DIR/$BERKAS_PY" "$DATA_DIR/versi" "$DATA_DIR/jejak" "$DATA_DIR/contoh/$BERKAS_CONTO"
    rmdir "$DATA_DIR/contoh" "$DATA_DIR" 2>/dev/null
    sukses "Berkas data dihapus"
    printf '\n  %s%s Sundalang sudah dicopot. Sampai jumpa!%s\n' "$C_PINK" "$G_HATI" "$C_RESET"
}

aksi_cara() {
    judul "Cara pakai $NAMA_APP"
    printf '\n'
    perintah_pil "$PERINTAH halo.sd" "jalankan program"
    perintah_pil "$PERINTAH halo" "sama, .sd boleh dihilangkan"
    perintah_pil "$PERINTAH" "mode interaktif"
    perintah_pil "$PERINTAH --baru halo" "buat halo.sd berisi contoh"
    perintah_pil "$PERINTAH halo.sd --py" "lihat kode Python hasilnya"
    perintah_pil "$PERINTAH halo.sd -o halo" "buat program mandiri"
    perintah_pil "$PERINTAH --versi" "lihat versi"
    perintah_pil "$PERINTAH -h" "bantuan lengkap"
    printf '\n  %sPanduan lengkap ada di README.md%s\n' "$C_GRAY" "$C_RESET"
}

tampil_bantuan_skrip() {
    local LEBAR_LABEL=18
    judul "Pemasang $NAMA_APP"
    printf '\n  Pakai:  bash sundalang.sh [perintah]\n\n'
    baris_info "(kosong)" "buka menu interaktif"
    baris_info "pasang" "pasang Sundalang"
    baris_info "perbarui" "pakai versi di folder ini"
    baris_info "status" "cek kondisi pemasangan"
    baris_info "copot" "hapus Sundalang"
    baris_info "cara" "ringkasan cara pakai"
    baris_info "bantuan" "tampilkan bantuan ini"
    printf '\n'
    baris_info "-y, --yes" "jawab ya otomatis"
    baris_info "NO_COLOR=1" "matikan warna"
    printf '\n'
}

bersihkan() {
    tampil_kursor
    if [ -n "${C_RESET:-}" ]; then
        printf '%s' "$C_RESET"
    fi
}

main() {
    local perintah="" arg
    for arg in "$@"; do
        case "$arg" in
            -y|--yes) OTOMATIS=1 ;;
            -h|--help|--bantuan|bantuan|help) perintah="bantuan" ;;
            pasang|install) perintah="pasang" ;;
            perbarui|update|upgrade) perintah="perbarui" ;;
            status) perintah="status" ;;
            copot|uninstall|hapus) perintah="copot" ;;
            cara) perintah="cara" ;;
            *)
                printf 'Perintah tidak dikenal: %s\n' "$arg" >&2
                printf 'Jalankan: bash sundalang.sh bantuan\n' >&2
                return 2
                ;;
        esac
    done

    deteksi_os
    tentukan_lokasi
    siapkan_tampilan
    VERSI_SUMBER=$(baca_versi "$SUMBER_DIR/$BERKAS_PY")
    trap bersihkan EXIT
    trap 'exit 130' INT TERM

    case "$perintah" in
        "")
            if [ -t 0 ] && [ "$INTERAKTIF" = 1 ]; then
                menu_utama
            else
                tampil_banner
                tampil_bantuan_skrip
            fi
            ;;
        bantuan)
            tampil_banner_kecil
            tampil_bantuan_skrip
            ;;
        *)
            tampil_banner
            jalankan_aksi "$perintah"
            ;;
    esac
}

main "$@"
exit $?
