package GudangAPI::API::number::phrase::id;

use 5.010;
use strict;
use warnings;

use Lingua::ID::Nums2Words qw(nums2words);
use Lingua::ID::Words2Nums qw(words2nums);

our %SPEC;

$SPEC{convert_num_to_id_phrase} = {
    summary => 'Konversi angka menjadi frase bahasa Indonesia (terbilang)',
    description => <<'_',

Fungsi ini mengonversi angka menjadi frase dalam bahasa Indonesia, lazim disebut
'terbilang'.

* Hasil:

Angka. Jika frase tidak dapat diparsing, kode status 400 akan dikembalikan.

* Catatan:

Jika Anda memasukkan kata-kata yang tidak masuk akal (tidak sesuai kaidah bahasa
Indonesia), fungsi ini mungkin masih mengembalikan angka tapi yang tidak masuk
akal pula.

* Contoh:

  convert_num_to_id_phrase(num=>203) -> [200, "OK", "dua ratus tiga"]

* Lihat juga:

Fungsi convert_id_phrase_to_num() (alias dari_terbilang() untuk kebalikannya,
mengubah frase bahasa Indonesia menjadi terbilang).

_
    args => {
        num => ['float*' => {
            summary => 'Angka yang ingin diterjemahkan menjadi frase',
        }],
    },
    features => {pure=>1},
};
sub convert_num_to_id_phrase {
    my %args = @_;

    # XXX schema
    my $num = $args{num};
    defined($num) or return [400, "Please specify num"];

    my $phrase = nums2words($num);
    defined($phrase) ? [200, "OK", $phrase] :
        [400, "Invalid input, can't generate phrase"];
}

# alias ID
*terbilang       =     \&convert_num_to_id_phrase;
$SPEC{terbilang} = $SPEC{convert_num_to_id_phrase};

$SPEC{convert_id_phrase_to_num} = {
    summary => 'Konversi frase bahasa Indonesia (terbilang) menjadi angka',
    description => <<'_',

Fungsi ini adalah kebalikan fungsi 'terbilang', yaitu mengubah terbilang menjadi
angka. Salah satu aplikasi fungsi ini adalah untuk parsing bahasa atau untuk
melakukan ricek apakah sebuah ungkapan terbilang sama dengan angkanya.

* Hasil:

Angka. Jika frase tidak dapat diparsing, kode status 400 akan dikembalikan.

* Catatan:

Jika Anda memasukkan kata-kata yang tidak masuk akal (tidak sesuai kaidah bahasa
Indonesia), fungsi ini mungkin masih mengembalikan angka tapi yang tidak masuk
akal pula.

* Contoh:

  convert_id_phrase_to_num(phrase=>'seratus koma tiga') -> [200, "OK", 100.3]

* Lihat juga:

Fungsi convert_num_to_id_phrase() (alias terbilang()).

_
    args => {
        phrase => ['str*' => {
            summary => 'Frase yang ingin diterjemahkan menjadi angka',
        }],
    },
    features => {pure=>1},
};
sub convert_id_phrase_to_num {
    my %args = @_;

    # XXX schema
    my $phrase = $args{phrase} or return [400, "Please specify phrase"];

    my $num = words2nums($phrase);
    defined($num) ? [200, "OK", $num] :
        [400, "Invalid input, can't parse phrase"];
}

# alias ID
*dari_terbilang       =     \&convert_id_phrase_to_num;
$SPEC{dari_terbilang} = $SPEC{convert_id_phrase_to_num};

1;
