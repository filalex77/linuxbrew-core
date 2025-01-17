class Starship < Formula
  desc "The cross-shell prompt for astronauts"
  homepage "https://github.com/starship/starship"
  url "https://github.com/starship/starship/archive/v0.7.0.tar.gz"
  sha256 "7f769adae13cc0b0410c0835d78d1286af0192f6fd264de98f980ff31548f4fb"
  head "https://github.com/starship/starship.git"

  bottle do
    cellar :any
    sha256 "f329566033784f76d5a3a2f772d6131033a94d84b5e0c516a08cea531eff5dd6" => :mojave
    sha256 "cddd620a2fd958ef25329582ec924ac69ac5849fef87e8bde64bdd447c664144" => :high_sierra
    sha256 "41e26b0325de8b833e0b38b51836f6e1ed0196d31143c0d82644d6f3e40ebbbb" => :sierra
  end

  depends_on "rust" => :build
  depends_on "openssl"

  def install
    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    ENV["STARSHIP_CONFIG"] = ""
    assert_equal "[1;32m➜[0m ", shell_output("#{bin}/starship module char")
  end
end
