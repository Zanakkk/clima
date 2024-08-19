# clima

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Ketentuan
0 Dashboard
1 Reservation Page
2 Patient Page
3 Treatment Page
4 Medical Record Page
5 Receipt - advanced
6 Management Control


7 Staff List Page
8 Stocks Page
9 Peripheral Page
10 Report Page
11 Customer Support Page
12 Logout Page

Management
13 Management Doctor
14 Management Price List
15 Laporan Stok Obat
16 Sales page
17 Purchase Page
18 Payroll

AddOn
19 Cetak Invoice
20 Kirim Invoice WA
21 Ekspor Laporan Ke EXCEL

(pageVisibility[7]) ? const StocksPage() : Container(),
(pageVisibility[8]) ? const PeripheralsPage() : Container(),
(pageVisibility[9]) ? const ReportPage() : Container(),
(pageVisibility[10])
? const CustomerSupportPage()
: Container(),
(pageVisibility[11]) ? const LogOut() : Container(),