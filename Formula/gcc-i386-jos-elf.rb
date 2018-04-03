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

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "binutils-i386-jos-elf"

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  def version_suffix
    if build.head?
      "HEAD"
    else
      version.to_s.slice(/\d/)
    end
  end

  # Fix for libgccjit.so linkage on Darwin
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=64089
  # https://github.com/Homebrew/homebrew-core/issues/1872#issuecomment-225625332
  # https://github.com/Homebrew/homebrew-core/issues/1872#issuecomment-225626490
  # Now fixed on GCC trunk for GCC 8, may backported to other branches
  unless build.head?
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/e9e0ee09389a54cc4c8fe1c24ebca3cd765ed0ba/gcc/6.1.0-jit.patch"
      sha256 "863957f90a934ee8f89707980473769cff47ca0663c3906992da6afb242fb220"
    end
  end

  # Fix parallel build on APFS filesystem
  # Remove for 7.4.0 and later
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81797
  if MacOS.version >= :high_sierra
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/df0465c02a/gcc/apfs.patch"
      sha256 "f7772a6ba73f44a6b378e4fe3548e0284f48ae2d02c701df1be93780c1607074"
    end
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    osmajor = `uname -r`.chomp

    args = [
      "--prefix=#{prefix}",
      "--libdir=#{lib}/gcc/#{version_suffix}",
      # Make most executables versioned to avoid conflicts.
      "--program-suffix=-#{version_suffix}",
      "--build=x86_64-apple-darwin#{osmajor}",
      "--host=x86_64-apple-darwin#{osmajor}",
      "--target=i386-jos-elf",
      "--disable-werror",
      "--disable-libssp",
      "--disable-libmudflap",
      "--with-newlib",
      "--without-headers",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc"].opt_prefix}",
      "--enable-languages=c"
    ]

    # Ensure correct install names when linking against libgcc_s;
    # see discussion in https://github.com/Homebrew/homebrew/pull/34303
    inreplace "libgcc/config/t-slibgcc-darwin", "@shlib_slibdir@", "#{HOMEBREW_PREFIX}/lib/gcc/#{version_suffix}"

    mkdir "build" do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # "native-system-headers" will be appended
        #args << "--with-native-system-header-dir=/usr/include"
        #args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system "../configure", *args

      make_args = []
      # Use -headerpad_max_install_names in the build,
      # otherwise lto1 load commands cannot be edited on El Capitan
      if MacOS.version == :el_capitan
        make_args << "BOOT_LDFLAGS=-Wl,-headerpad_max_install_names"
      end

      system "make", "all-gcc", *make_args
      system "make", "install-gcc"
      system "make", "all-target-libgcc", *make_args
      system "make", "install-target-libgcc"

    end

    # Handle conflicts between GCC formulae and avoid interfering
    # with system compilers.
    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }
    # Even when we disable building info pages some are still installed.
    info.rmtree
  end

  def add_suffix(file, suffix)
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    File.rename file, "#{dir}/#{base}-#{suffix}#{ext}"
  end
end
