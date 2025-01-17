class Ldns < Formula
  desc "DNS library written in C"
  homepage "https://nlnetlabs.nl/projects/ldns/"
  url "https://nlnetlabs.nl/downloads/ldns/ldns-1.7.1.tar.gz"
  sha256 "8ac84c16bdca60e710eea75782356f3ac3b55680d40e1530d7cea474ac208229"

  bottle do
    cellar :any_skip_relocation
    sha256 "faa2291cda47e96003c8f9703f580252e9f794608019aa22a60bb71c1ea9dfbb" => :mojave
    sha256 "dbe318c3a0be2a59e3b71f48d2d13319ff6e8a47507f548aed6f73779f42ddb6" => :high_sierra
    sha256 "49f6436feb4baafbecf4db384f0bbd7d9a597511df8dcf1195739f18c7a02642" => :sierra
  end

  depends_on "swig" => :build
  depends_on "openssl"
  uses_from_macos "python@2"

  def install
    args = %W[
      --prefix=#{prefix}
      --with-drill
      --with-examples
      --with-ssl=#{Formula["openssl"].opt_prefix}
      --with-pyldns
      PYTHON_SITE_PKG=#{lib}/python2.7/site-packages
      --disable-dane-verify
    ]

    ENV["PYTHON"] = Formula["python@2"].opt_bin/"python2" unless OS.mac?
    system "./configure", *args

    if OS.mac?
      inreplace "Makefile" do |s|
        s.change_make_var! "PYTHON_LDFLAGS", "-undefined dynamic_lookup"
        s.gsub! /(\$\(PYTHON_LDFLAGS\).*) -no-undefined/, "\\1"
      end
    end

    system "make"
    system "make", "install"
    system "make", "install-pyldns"
    (lib/"pkgconfig").install "packaging/libldns.pc"
  end

  test do
    l1 = <<~EOS
      AwEAAbQOlJUPNWM8DQown5y/wFgDVt7jskfEQcd4pbLV/1osuBfBNDZX
      qnLI+iLb3OMLQTizjdscdHPoW98wk5931pJkyf2qMDRjRB4c5d81sfoZ
      Od6D7Rrx
    EOS
    l2 = <<~EOS
      AwEAAb/+pXOZWYQ8mv9WM5dFva8WU9jcIUdDuEjldbyfnkQ/xlrJC5zA
      EfhYhrea3SmIPmMTDimLqbh3/4SMTNPTUF+9+U1vpNfIRTFadqsmuU9F
      ddz3JqCcYwEpWbReg6DJOeyu+9oBoIQkPxFyLtIXEPGlQzrynKubn04C
      x83I6NfzDTraJT3jLHKeW5PVc1ifqKzHz5TXdHHTA7NkJAa0sPcZCoNE
      1LpnJI/wcUpRUiuQhoLFeT1E432GuPuZ7y+agElGj0NnBxEgnHrhrnZW
      UbULpRa/il+Cr5Taj988HqX9Xdm6FjcP4Lbuds/44U7U8du224Q8jTrZ
      57Yvj4VDQKc=
    EOS
    (testpath/"powerdns.com.dnskey").write <<~EOS
      powerdns.com.   10773 IN  DNSKEY  256 3 8  #{l1.tr!("\n", " ")}
      powerdns.com.   10773 IN  DNSKEY  257 3 8  #{l2.tr!("\n", " ")}
    EOS

    system "#{bin}/ldns-key2ds", "powerdns.com.dnskey"

    match = "d4c3d5552b8679faeebc317e5f048b614b2e5f607dc57f1553182d49ab2179f7"
    assert_match match, File.read("Kpowerdns.com.+008+44030.ds")
  end
end
