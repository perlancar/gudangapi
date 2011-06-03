package GudangAPI::API::finance::currency::id::bca;

use 5.010;
use strict;
use warnings;

use File::Slurp;
use LWP::Simple;
use Log::Any '$log';

our %SPEC;

$SPEC{get_bca_exchange_rate} = {
    summary => 'Mengambil kurs mata uang dari BCA (klikbca.com)',
    description => <<'_',

Ini adalah versi permulaan, API masih mungkin akan berubah. Baru USD dan IDR
yang didukung. Update data setiap 15 menit sekali. Akan tersedia juga fungsi
get_id_exchange_rate() yang akan mengambil dari beberapa sumber di Indonesia
(seperti situs Dirjen Pajak dan BI).

* Hasil yang dikembalikan:

Sebuah array asosiatif (hash) yang berisi key-key berikut:

 sell                   Nilai kurs jual
 buy                    Nilai kurs beli
 spread                 Selisih kurs jual dan beli (sell-buy)
 average                Rata-rata kurs jual dan beli ((sell+buy)/2)
 mtime                  Waktu update data terakhir (dalam Unix time)
 mtime_str              Waktu update data terakhir (dalam format string)

* Contoh:

Untuk mengetahui berapa nilai $100 dalam rupiah saat ini:

 get_bca_exchange_rate_phrase(from=>'USD', to=>'IDR', amount=>100)

akan menghasilkan respon (dalam JSON):

 [200, "OK",
 {"sell": 867500,
  "buy": 842500,
  "average": 855000,
  "spread": 25000,
  "mtime": 1305867737}]

* Lihat juga:

_
    args => {
        from => ['str*' => {
            summary => 'Simbol mata uang sumber',
        }],
        to => ['str*' => {
            summary => 'Simbol mata uang tujuan',
        }],
        amount => ['float*' => {
            summary => 'Jumlah yang ingin dikonversi',
            default => 1,
        }],
    },
    features => {},
};
sub get_bca_exchange_rate {
    my %args = @_;

    # XXX schema
    my $from   = $args{from} or return [400, "Please specify from"];
    $from eq 'USD'
        or return [501, "Sorry, alpha version, only from USD supported"];
    my $to     = $args{to}   or return [400, "Please specify to"];
    $to eq 'IDR'
        or return [501, "Sorry, alpha version, only to IDR supported"];
    my $amount = $args{amount} // 1.0;

    # XXX cache

    my $data = {};
    my $page = get 'http://www.klikbca.com';
    $page or return [500, "Failed getting KlikBCA page"];
    $page =~ m!<td[^>]+"/images/kurs-tanggal.jpg">&nbsp;&nbsp;(\d\d?)-(\w{2,6})-(\d\d\d\d)\s*/\s*(\d\d?):(\d\d?) WIB(.+?)"/images/kurs-bawah.jpg"!s
        or return [500, "Failed parsing exchange rate [1]"];
    $data->{mtime_str} = "$1-$2-$3 $4:$5 WIB";
    my $rates = $6;
    $rates =~ m!>USD</td>\s*<td[^>]*>\s*(\d+\.\d+)</td>\s*<td[^>]*>\s*(\d+\.\d+)<!s
        or return [500, "Failed parsing USD rate [2]"];
    my ($usd_sell, $usd_buy) = ($1, $2);
    $log->tracef("usd_sell=%s, usd_buy=%s", $usd_sell, $usd_buy);
    #for ($usd_sell, $usd_buy)
    $data->{sell} = $usd_sell * $amount;
    $data->{buy}  = $usd_buy * $amount;
    $data->{average} = ($usd_sell+$usd_buy)/2 * $amount;
    $data->{spread} = ($usd_sell-$usd_buy) * $amount;
    [200, "OK", $data];
}

1;
