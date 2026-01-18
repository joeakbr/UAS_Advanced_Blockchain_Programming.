# UAS_Advanced_Blockchain_Programming

Repository ini berisi kode sumber untuk tugas akhir mata kuliah Advanced Blockchain Programming, Aplikasi ini adalah DApp (Decentralized Application) sederhana untuk layanan transportasi ojek online yang berjalan di jaringan Ethereum (Sepolia Testnet).


## Fitur Utama
1.  Registrasi Driver: Pengemudi dapat mendaftar dengan data lengkap (Nama, Plat, Tipe Kendaraan, Tarif).
2.  Ride Request: Penumpang dapat membuat pesanan perjalanan.
3.  Sistem Escrow* Pembayaran penumpang ditahan di Smart Contract dan baru cair ke pengemudi setelah konfirmasi selesai.
4.  Transparansi Status: Melacak status order dari Requested -> Accepted -> Funded -> Started -> Completed -> Finalized.

## Teknologi yang Digunakan
Solidity: Bahasa pemrograman Smart Contract.
Web3.js: Library untuk menghubungkan website dengan Blockchain.
HTML/CSS/JS: Antarmuka pengguna (Frontend).
Sepolia Testnet: Jaringan blockchain untuk pengujian.

## Cara Menjalankan Aplikasi
Karena aplikasi ini menggunakan Web3.js dan file lokal, browser mungkin memblokir koneksi jika dibuka langsung. ikutin langkkah ini dulu :

1.  Clone atau Download repository ini.
2.  Buka folder proyek menggunakan VSCODE
3.  Install Extension "Live Server" di VS Code.
4.  Klik kanan pada file "index.html" dan Pilih "Open with Live Server".
5.  Pastikan memiliki MetaMask yang terinstall di browser.
6.  Pastikan MetaMask terhubung ke jaringan Sepolia.
7.  Klik tombol Connect di aplikasi.

## Alamat Smart Contract
Smart contract sudah dideploy di jaringan Sepolia pada alamat:
"0xCB15e7a0556c017554b908f1A853679ECda27ebf"

