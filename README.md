# Instalator OpenWebRX+

**Zainstaluj OpenWebRX+ jedną komendą!**

Ten instalator został stworzony z myślą o maksymalnym uproszczeniu procesu. Niezależnie od Twojego doświadczenia z systemem Linux, z łatwością uruchomisz własny odbiornik websdr. Pożegnaj się ze skomplikowanymi konfiguracjami – **teraz to naprawdę proste!**

---

## Wymagania

* **Debian 12 Bookworm x86/64**

---

## Ważna Uwaga

Ten instalator **nie był testowany na architekturze ARM** (np. Raspberry Pi). Możesz spróbować go użyć na własną odpowiedzialność, jednak nie gwarantujemy poprawnego działania.

---

## Użycie

Aby rozpocząć instalację, wykonaj poniższe kroki:

1.  **Zaloguj się do swojego serwera Linux:**
    * **Poprzez SSH (dla serwerów zdalnych):** Otwórz terminal na swoim komputerze i użyj komendy:
        ```bash
        ssh Twoj_Uzytkownik@Adres_IP_Serwera
        ```
        Zastąp `Twoj_Uzytkownik` swoją nazwą użytkownika, a `Adres_IP_Serwera` adresem IP lub nazwą hosta serwera.
      
    * **Lokalnie (gdy używasz GUI):** Otwórz terminal (zazwyczaj znajdziesz go w menu aplikacji lub naciskając `Ctrl+Alt+T`).

2.  **Przejdź na użytkownika `root`:** Po zalogowaniu, użyj komendy:
    ```bash
    su -
    ```
    Zostaniesz poproszony o podanie hasła użytkownika `root`.



### Wybierz metodę instalacji:
### 1. Metoda curl (nie potrzeba git):

```bash
curl -O https://raw.githubusercontent.com/bigossi5/owrx_installator/main/owrx_installer.sh
chmod +x owrx_installer.sh
bash owrx_installer.sh
```

### 2. Metoda z git:

```bash
apt install git -y
git clone https://github.com/bigossi5/owrx_installator.git
cd owrx_installator
chmod +x owrx_installer.sh
bash owrx_installer.sh
```
---

## Informacje

* Instalator **automatycznie pobiera wszystkie potrzebne składniki** do instalacji.
* Podczas instalacji zostaniesz poproszony o podanie **podstawowych danych konfiguracyjnych** (np. znak krótkofalarski, lokalizacja, adres e-mail).
* Instalator ma wbudowaną **obsługę DMR oraz satelit pogodowych typu NOAA**, instalując niezbędne komponenty automatycznie (w tym `satdump` oraz `softbme`).
* Po instalacji nastąpi **automatyczny restart serwera**.
* Po restarcie, dostęp do swojej instancji OpenWebRX+ uzyskasz pod adresem: `http://<ip_serwera>:8073` (zastąp `<ip_serwera>` adresem IP Twojego serwera).
* Po zalogowaniu **niezbędne jest przejście do ustawień** w celu konfiguracji OWRX pod siebie.
