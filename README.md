# XM CRM — iPhone / iPad ilovasi

Ilova ichida **https://xmcrm.uz** ochiladi. Serverga yangi versiya qo'yilsa, ilova ham darhol yangilanadi, qayta o'rnatish shart emas.

## .ipa qayerdan olinadi
Har safar `main`ga push qilinganda GitHub Actions (macOS) imzosiz `.ipa` yig'adi va uni **Releases** bo'limiga qo'yadi.
Qo'lda ishga tushirish: **Actions → iOS .ipa → Run workflow**.

## iPhone'ga o'rnatish (bepul, o'z Apple ID bilan)
- **Windows / macOS:** [Sideloadly](https://sideloadly.io). iPhone'ni kabel bilan ulang, `XM-CRM.ipa` ni tanlang, Apple ID kiriting, **Start** bosing.
- **Linux (Kali):** Impactor
  ```bash
  sudo apt install -y flatpak usbmuxd
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub dev.khcrysalis.PlumeImpactor
  flatpak run dev.khcrysalis.PlumeImpactor
  ```
  iPhone'ni kabel bilan ulang ("Bu kompyuterga ishonasizmi?" → **Ishonish**), Apple ID bilan kiring, `XM-CRM.ipa` ni tanlab o'rnating.
- iPhone'da: **Sozlamalar → Umumiy → VPN va qurilmalarni boshqarish** bo'limida Apple ID'ingizga **Ishonish** ni bosing.
- iOS 16+ da: **Sozlamalar → Maxfiylik va xavfsizlik → Dasturchi rejimi → Yoqish** (telefon qayta yuklanadi).
- Bepul Apple ID bilan ilova **7 kun** ishlaydi, keyin Sideloadly bilan qayta o'rnatiladi. Login va ma'lumotlar saqlanib qoladi.

## iOS'ga xos imkoniyatlar
- Excel/PDF yuklab olish iOS **Ulashish** oynasida ochiladi: Fayllarga saqlash, Telegram, AirDrop.
- Chek va Z-hisobot **AirPrint** orqali chop etiladi.
- Notch va pastki chiziq ostiga kontent kirib ketmaydi, internet uzilsa "ulanish yo'q" sahifasi chiqadi va internet qaytganda o'zi ochiladi.
