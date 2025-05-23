# Instalator OWRX+
Openwebrx Plus instalator, umożliwia zainstalowanie Openwebrx+ za pomocą jednej komendy.

Użycie: 
1. Metoda curl (nie potrzeba git):
curl -O https://raw.githubusercontent.com/bigossi5/owrx_installator/main/owrx_installer.sh
chmod +x owrx_installer.sh
bash owrx_installer.sh

2. Metoda z git:
git clone https://github.com/bigossi5/owrx_installator.git
cd owrx_installator
chmod +x owrx_installer.sh
bash owrx_installer.sh

Podczas instalacji użytkownik jest pytany o podstawowe dane do konfiguracji (znak krótkofalarski, lokalizacja,email itd).
Instalator ma wbudowane dodanie obsługi DMR oraz satelit pogodowych typu NOAA - instaluje niezbędne rzeczy automatycznie.
Po instalacji następuje reboot serwera.
Po reboocie dostajemy się na serwer za pomocą url: http://ip_serwera:8073
Po zalogowaniu niezbędne jest przejście do ustawień w celu konfiguracji OWRX pod siebie.
