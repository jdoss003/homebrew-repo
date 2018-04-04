class GccI386JosElf < Formula

  # Modified version of Homebrew's gcc formula

  desc "GNU compiler collection"
  homepage "https://gcc.gnu.org/"
  revision 1
  head "svn://gcc.gnu.org/svn/gcc/trunk"

  stable do
    url "https://ftp.gnu.org/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.xz"
    mirror "https://ftpmirror.gnu.org/gcc/gcc-7.3.0/gcc-7.3.0.tar.xz"
    sha256 "832ca6ae04636adbb430e865a1451adf6979ab44ca1c8374f61fba65645ce15c"
  end

  depends_on "gmp" => :build
  depends_on "libmpc"
  depends_on "mpfr" => :build
  depends_on "binutils-i386-jos-elf"

  def install
    args = [
      "--prefix=#{prefix}",
      "--target=i386-jos-elf",
      "--disable-werror",
      "--disable-nls",
      "--disable-libssp",
      "--disable-libmudflap",
      "--disable-multilib",
      "--with-newlib",
      "--without-headers",
      "--without-isl",
      "--enable-languages=c"
    ]

    mkdir "build" do

      system "../configure", *args

      system "make", "all-gcc"
      system "make", "install-gcc"
      system "make", "all-target-libgcc"
      system "make", "install-target-libgcc"

      binutils = Formula["binutils-i386-jos-elf"].prefix
      FileUtils.ln_sf "#{binutils}/i386-jos-elf", "#{prefix}/i386-jos-elf"
    end
  end

  test do
    system "i386-jos-elf-gcc", "--version"
  end
end
