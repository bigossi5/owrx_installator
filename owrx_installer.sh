#!/bin/bash
set -eux

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

echo "[1/6] Aktualizacja i instalacja niezbędnych pakietow"
apt update
apt install -y sudo curl gnupg ca-certificates git cmake build-essential pkgconf g++ wget dialog

echo "[2/6] Instalacja OpenWebRX+..."
curl -s https://luarvique.github.io/ppa/openwebrx-plus.gpg | sudo gpg --yes --dearmor -o /etc/apt/trusted.gpg.d/openwebrx-plus.gpg
sudo tee /etc/apt/sources.list.d/openwebrx-plus.list <<<"deb [signed-by=/etc/apt/trusted.gpg.d/openwebrx-plus.gpg] https://luarvique.github.io/ppa/bookworm ./"
sudo apt update
sudo apt install -y openwebrx

echo "[3/6] Instalacja drivera RTL-SDR"
apt install -y rtl-sdr librtlsdr0 librtlsdr-dev

echo "[4/6] Instalacja zależności i kompilacja SatDump (bez GUI)..."
apt install -y libfftw3-dev libpng-dev libtiff-dev libjemalloc-dev libcurl4-openssl-dev \
               libvolk2-dev libnng-dev libzstd-dev libhdf5-dev librtlsdr-dev libhackrf-dev \
               libairspy-dev libairspyhf-dev libad9361-dev libiio-dev libbladerf-dev \
               libomp-dev ocl-icd-opencl-dev intel-opencl-icd mesa-opencl-icd

cd /opt
git clone https://github.com/SatDump/SatDump.git
cd SatDump
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_GUI=OFF ..
make -j"$(nproc)"
make install

echo "[5/6] Konfiguracja i uruchomienie usługi OpenWebRX..."

get_input() {
    local title="$1"
    local prompt="$2"
    local varname="$3"
    local result

    result=$(dialog --ascii-lines --title "$title" --inputbox "$prompt" 10 60 3>&1 1>&2 2>&3 3>&-)
    eval "$varname=\"\$result\""
}
get_yesno() {
    local title="$1"
    local prompt="$2"
    local varname="$3"
    dialog --ascii-lines --title "$title" --yesno "$prompt" 7 60
    if [ $? -eq 0 ]; then
        eval "$varname=\"True\""
    else
        eval "$varname=\"False\""
    fi
}

get_input "Znak" "Podaj swój znak krótkofalarski (callsign):" CALLSIGN
get_input "Lokalizacja" "Podaj lokalizację odbiornika (np. Warszawa, Polska):" LOCATION
get_input "Email" "Podaj swój adres e-mail:" EMAIL

MAGIC_KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)

get_yesno "APRS iGate" "Czy chcesz włączyć APRS iGate?" APRS_ENABLED
get_yesno "PSKReporter" "Czy chcesz włączyć PSKReporter?" PSK_ENABLED
get_yesno "WSPRnet" "Czy chcesz włączyć WSPRnet?" WSPR_ENABLED

cat > /usr/lib/python3/dist-packages/owrx/config/defaults.py <<EOF
from owrx.property import PropertyLayer

defaultConfig = PropertyLayer(
    version=8,
    max_clients=50,
    receiver_name="$CALLSIGN",
    receiver_location="$LOCATION",
    receiver_asl=70,
    receiver_admin="$EMAIL",
    receiver_gps=PropertyLayer(lat=51.6, lon=19.796),
    photo_title="",
    photo_desc="",
    fft_fps=9,
    fft_size=4096,
    fft_voverlap_factor=0.3,
    audio_compression="adpcm",
    fft_compression="adpcm",
    wfm_deemphasis_tau=50e-6,
    wfm_rds_rbds=False,
    digimodes_fft_size=2048,
    digital_voice_dmr_id_lookup=True,
    digital_voice_nxdn_id_lookup=True,
    sdrs=PropertyLayer(
        rtlsdr=PropertyLayer(
            name="RTL-SDR",
            type="rtl_sdr",
            rf_gain=49,
            direct_sampling=0,
            profiles=PropertyLayer(
                **{
                    "70cm": PropertyLayer(
                        name="70cm",
                        center_freq=443500000,
                        samp_rate=2048000,
                        start_freq=444000000,
                        start_mod="nfm",
                        tuning_step="5000",
                    ),
                    "125cm": PropertyLayer(
                        name="1.25m",
                        center_freq=223500000,
                        samp_rate=2048000,
                        start_freq=224000000,
                        start_mod="nfm",
                        tuning_step="5000",
                    ),
                    "2m": PropertyLayer(
                        name="2m",
                        center_freq=146000000,
                        samp_rate=2048000,
                        start_freq=147000000,
                        start_mod="nfm",
                        tuning_step="5000",
                    ),
                    "6m": PropertyLayer(
                        name="6m",
                        center_freq=52000000,
                        samp_rate=2048000,
                        start_freq=53000000,
                        start_mod="usb",
                        tuning_step="500",
                    ),
                    "10m": PropertyLayer(
                        name="10m",
                        center_freq=28850000,
                        samp_rate=2048000,
                        start_freq=29000000,
                        start_mod="usb",
                        tuning_step="500",
                    ),
                    "cb": PropertyLayer(
                        name="11m CB",
                        center_freq=27000000,
                        samp_rate=2048000,
                        start_freq=26965000,
                        start_mod="am",
                        tuning_step="5000",
                    ),
                    "12m": PropertyLayer(
                        name="12m",
                        center_freq=24940000,
                        samp_rate=2048000,
                        start_freq=24950000,
                        start_mod="usb",
                        tuning_step="500",
                    ),
                    "15m": PropertyLayer(
                        name="15m",
                        center_freq=21225000,
                        samp_rate=2048000,
                        start_freq=21220000,
                        start_mod="usb",
                        tuning_step="500",
                    ),
                    "17m": PropertyLayer(
                        name="17m",
                        center_freq=18118000,
                        samp_rate=2048000,
                        start_freq=18110000,
                        start_mod="usb",
                        tuning_step="500",
                    ),
                    "20m": PropertyLayer(
                        name="20m",
                        center_freq=14175000,
                        samp_rate=2048000,
                        start_freq=14070000,
                        start_mod="usb",
                        tuning_step="500",
                    ),
                    "30m": PropertyLayer(
                        name="30m",
                        center_freq=10125000,
                        samp_rate=2048000,
                        start_freq=10142000,
                        start_mod="usb",
                        tuning_step="500",
                    ),
                    "40m": PropertyLayer(
                        name="40m",
                        center_freq=7150000,
                        samp_rate=2048000,
                        start_freq=7070000,
                        start_mod="lsb",
                        tuning_step="500",
                    ),
                    "60m": PropertyLayer(
                        name="60m",
                        center_freq=5350000,
                        samp_rate=2048000,
                        start_freq=5357000,
                        start_mod="usb",
                        tuning_step="500",
                    ),
                    "80m": PropertyLayer(
                        name="80m",
                        center_freq=3750000,
                        samp_rate=2048000,
                        start_freq=3570000,
                        start_mod="lsb",
                        tuning_step="500",
                    ),
                    "160m": PropertyLayer(
                        name="160m",
                        center_freq=1900000,
                        samp_rate=2048000,
                        start_freq=1910000,
                        start_mod="lsb",
                        tuning_step="500",
                    ),
                    "am": PropertyLayer(
                        name="AM Broadcast",
                        center_freq=1100000,
                        samp_rate=2048000,
                        start_freq=1300000,
                        start_mod="am",
                        tuning_step="5000",
                    ),
                    "49m": PropertyLayer(
                        name="49m Broadcast",
                        center_freq=6050000,
                        samp_rate=2048000,
                        start_freq=6070000,
                        start_mod="am",
                        tuning_step="5000",
                    ),
                    "41m": PropertyLayer(
                        name="41m Broadcast",
                        center_freq=7325000,
                        samp_rate=2048000,
                        start_freq=7320000,
                        start_mod="am",
                        tuning_step="5000",
                    ),
                    "31m": PropertyLayer(
                        name="31m Broadcast",
                        center_freq=9650000,
                        samp_rate=2048000,
                        start_freq=9700000,
                        start_mod="am",
                        tuning_step="5000",
                    ),
                    "25m": PropertyLayer(
                        name="25m Broadcast",
                        center_freq=11850000,
                        samp_rate=2048000,
                        start_freq=12000000,
                        start_mod="am",
                        tuning_step="5000",
                    ),
                    "22m": PropertyLayer(
                        name="22m Broadcast",
                        center_freq=13720000,
                        samp_rate=2048000,
                        start_freq=13800000,
                        start_mod="am",
                        tuning_step="5000",
                    ),
                    "ism433": PropertyLayer(
                        name="433MHz ISM",
                        center_freq=433000000,
                        samp_rate=2048000,
                        start_freq=433000000,
                        start_mod="nfm",
                        tuning_step="25000",
                    ),
                    "adsb1090": PropertyLayer(
                        name="1090MHz ADSB",
                        center_freq=1090000000,
                        samp_rate=2048000,
                        start_freq=1090000000,
                        start_mod="nfm",
                        tuning_step="25000",
                    ),
                }
            ),
        ),
    ),
    waterfall_scheme="ZoranWaterfall",
    waterfall_levels=PropertyLayer(min=-88, max=-20),
    waterfall_auto_levels=PropertyLayer(min=3, max=10),
    waterfall_auto_level_default_mode=False,
    waterfall_auto_min_range=50,
    key_locked=False,
    magic_key="$MAGIC_KEY",
    allow_center_freq_changes=False,
    allow_audio_recording=True,
    allow_chat=True,
    tuning_precision=2,
    squelch_auto_margin=10,
    google_maps_api_key="",
    openweathermap_api_key="",
    map_type="leaflet",
    map_position_retention_time=2 * 60 * 60,
    map_call_retention_time=5 * 60,
    map_max_calls=5,
    map_prefer_recent_reports=True,
    map_ignore_indirect_reports=False,
    callsign_url="https://www.qrz.com/db/{}",
    vessel_url="https://www.vesselfinder.com/vessels/details/{}",
    flight_url="https://www.flightradar24.com/{}",
    modes_url="https://flightaware.com/live/modes/{}/redirect",
    usage_policy_url="policy",
    session_timeout=0,
    keep_files=100,
    decoding_queue_workers=2,
    decoding_queue_length=10,
    wsjt_decoding_depth=3,
    wsjt_decoding_depths=PropertyLayer(jt65=1),
    fst4_enabled_intervals=[15, 30],
    fst4w_enabled_intervals=[120, 300],
    q65_enabled_combinations=["A30", "E120", "C60"],
    js8_enabled_profiles=["normal", "slow"],
    js8_decoding_depth=3,
    services_enabled=False,
    services_decoders=["ft8", "ft4", "wspr", "packet"],
    aprs_callsign="$CALLSIGN",
    aprs_igate_enabled=$APRS_ENABLED,
    aprs_igate_server="euro.aprs2.net",
    aprs_igate_password="",
    aprs_igate_beacon=False,
    aprs_igate_symbol="R&",
    aprs_igate_comment="OpenWebRX APRS gateway",
    pskreporter_enabled=$PSK_ENABLED,
    pskreporter_callsign="$CALLSIGN",
    wsprnet_enabled=$WSPR_ENABLED,
    wsprnet_callsign="$CALLSIGN",
    mqtt_enabled=False,
    mqtt_host="localhost",
    mqtt_use_ssl=False,
    paging_filter=True,
    paging_charset="US",
    eibi_bookmarks_range=200,
    repeater_range=200,
    adsb_ttl=900,
    vdl2_ttl=1800,
    hfdl_ttl=1800,
    acars_ttl=1800,
    fax_lpm=120,
    fax_min_length=200,
    fax_max_length=1500,
    fax_postprocess=True,
    fax_color=False,
    fax_am=False,
    image_compress=True,
    image_compress_level="7",
    image_compress_filter="5",
    image_quantize=False,
    image_quantize_colors="256",
    cw_showcw=False,
    dsc_show_errors=True,
    gps_updates=False,
    bandplan_region=0,
    rig_enabled=False,
    rig_model=2,
    rig_device="127.0.0.1:4533",
    rig_address=0,
    rec_squelch=-150,
    ssb_agc_profile="Fast",
    dab_output_rate=48000
).readonly()
EOF

dialog --ascii-lines --msgbox "Konfiguracja została zapisana" 10 60

clear

systemctl enable openwebrx
systemctl start openwebrx

echo "[6/6] Kompilacja i instalacja SoftMbe + codecserver-softmbe..."
BUILD_PACKAGES="git build-essential debhelper cmake libprotobuf-dev protobuf-compiler"
apt -y install --no-install-recommends $BUILD_PACKAGES libcodecserver-dev

pushd /tmp
git clone https://github.com/szechyjs/mbelib.git
cd mbelib
dpkg-buildpackage
cd ..
dpkg -i libmbe1_1.3.0_*.deb libmbe-dev_1.3.0_*.deb
rm -rf mbelib

git clone https://github.com/knatterfunker/codecserver-softmbe.git
cd codecserver-softmbe
sed -i 's/dh \$@/dh \$@ --dpkg-shlibdeps-params=--ignore-missing-info/' debian/rules
dpkg-buildpackage
cd ..
dpkg -i codecserver-driver-softmbe_0.0.1_*.deb
rm -rf codecserver-softmbe

apt remove -y --purge --autoremove $BUILD_PACKAGES

# Konfiguracja codecserver
mkdir -p /etc/codecserver
cat >> /etc/codecserver/codecserver.conf << _EOF_

# add softmbe
[device:softmbe]
driver=softmbe
_EOF_

popd

echo
echo "Instalacja zakończona pomyślnie"
sudo reboot
