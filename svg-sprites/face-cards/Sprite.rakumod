unit class Sprite;
use BasicData;
use JSON::Fast;

has $.path;
has @.bytes;
has $.width;
has $.height;
has $.depth;

constant %Types  = :basic => 'bas',  binary => 'bin', json => 'json', plain => 'txt', prog8 => 'p8';
constant @Sizes  = 8, 16, 32, 64;
constant @Depths = 4, 8;
constant @Colors = 16, 256;

method new($path, $width, $height, $depth) {
    self.bless(:$path, :$width, :$height, :$depth, :bytes([]));
}

submethod TWEAK(:$path, :$width, :$height, :$depth) {
    for $!width, $!height -> $dim is rw {
       if $dim (elem) @Sizes {
          ($dim,) = @Sizes.grep(* == $width, :k);
       }
       if $dim !~~ ^+@Sizes {
           die "Invalid sprite size: $dim";
       }
    }
    if $!depth (elem) @Depths {
        ($!depth,) = @Depths.grep(* == $!depth, :k);
    } elsif $!depth (elem) @Colors {
        ($!depth,) = @Colors.grep(* == $!depth, :k);
    }
    if $!depth !~~ ^+@Depths {
        die "Invalid sprite depth: $!depth";
    }
}

method add(*@bytes) {
    @!bytes.push(|@bytes);
}

method write($type, $filename=$!path) {
    given $type {
        when 'basic'  { self.write-basic($filename);     }
        when 'binary' { self.write-binary($filename);    }
        when 'json'   { self.write-json($filename);      }
        when 'plain'  { self.write-plain($filename);     }
        when 'prog8'  { self.write-prog8($filename);     }
        default       { die "Unknown file type '$type'"; }
    }
}

method write-all() {
    mkdir($!path);
    for %Types.kv -> $type, $suffix {
        self.write($type, "$!path/data.$suffix")
    }
}

method write-plain($filename=$!path) {
    my $f = open($filename, :w);
    $f.say($_) for @!bytes;
}

method write-binary($filename=$!path) {
    my $f = open($filename, :w, :b);
    $f.write(Buf(|@!bytes));
}

method write-json($filename=$!path) {
    my $f = open($filename, :w);
    $f.write(to-json @!bytes);
}

method write-basic($filename=$!path) {
    my $f = open($filename, :w);
    my $data = BasicData.new(:file($f));
    $data.add($!width, $!height, $!depth, |@!bytes);
    $data.flush;
}
