package GudangAPI::API::tax::id::npwp;

use 5.010;
use strict;
use warnings;

use Business::ID::NPWP ();

our %SPEC;

$SPEC{validate_npwp} = {
    summary => 'Validasi NPWP (nomor pokok wajib pajak)',
    description => <<'_',

Fungsi ini mengecek apakah sintaks/format nomor kode wajib pajak (NPWP) adalah
valid. Catatan: fungsi ini hanya mengecek sintaks dan tidak benar-benar
memeriksa ke database kantor pajak apakah sebuah NPWP dipakai/tidak.

* Hasil yang dikembalikan:

Jika valid, fungsi akan mengembalikan kode 200. Jika tidak valid, kode 400 akan
dikembalikan dan pesan kesalahan akan berisi detil mengapa NPWP tidak valid.

* Contoh:

  validate_npwp(npwp=>'00.000.001.8-000') -> [200, "OK"]
  validate_npwp(npwp=>'00.000.000.8-000') -> [400, "Invalid NPWP: zero serial"]

* Lihat juga: parse_npwp() untuk memparsing NPWP ke dalam elemen-elemennya.

_
    args => {
        npwp => ['str*' => {
            summary => 'Nomor yang ingin dicek',
        }],
    },
    features => {pure=>1},
};
sub validate_npwp {
    my %args = @_;

    # XXX schema
    my $npwp = $args{npwp} or return [400, "Please specify npwp"];

    my $obj  = Business::ID::NPWP->new($npwp);
    return [400, "Invalid NPWP: ".$obj->errstr] unless $obj->validate;
    [200, "OK"];
}

$SPEC{parse_npwp} = {
    summary => 'Parsing NPWP (nomor pokok wajib pajak)',
    description => <<'_',

Fungsi ini memparsing nomor pokok wajib pajak ke dalam elemen-elemennya.

* Hasil yang dikembalikan: array asosiatif berisi key-key berikut:

 Nama                       Penjelasan
 ----                       ----------
 normalized                 Nomor dalam format baku
 pretty                     Nomor dalam format cantik

 taxpayer_code              Kode WP (wajib pajak) 2 digit
 serial                     Kode seri 6 digit
 check_digit                Kode cek 1 digit
 local_tax_office_code      Kode KPP (kantor wajib pajak) 3 digit
 branch_code                Kode cabang WP

* Contoh:

 parse_npwp(npwp=>'02.183.241.5-400.001')

hasilnya adalah (dalam JSON):

 [
  200,
  "OK",
  {"normalized":"02.183.241.5-400.001",
   "pretty":"02.183.241.5-400.001",
   "taxpayer_code":"02",
   "serial":"183241",
   "check_digit":"5",
   "local_tax_office_code":"400",
   "branch_code":"001"}
 ]

* Lihat juga: validate_npwp()

_
    args => {
        npwp => ['str*' => {
            summary => 'Nomor yang ingin dicek',
        }],
    },
    features => {pure=>1},
};
sub parse_npwp {
    my %args = @_;

    # XXX schema
    my $npwp = $args{npwp} or return [400, "Please specify npwp"];

    my $obj  = Business::ID::NPWP->new($npwp);
    return [400, "Invalid NPWP: ".$obj->errstr] unless $obj->validate;
    [200, "OK", {
        normalized    => $obj->normalize,
        pretty        => $obj->pretty,
        taxpayer_code => $obj->taxpayer_code,
        serial        => $obj->serial,
        check_digit   => $obj->check_digit,
        local_tax_office_code => $obj->local_tax_office_code,
        branch_code   => $obj->branch_code,
    }];
}

1;
