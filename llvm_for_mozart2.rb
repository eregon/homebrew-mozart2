require 'formula'

# Mozart 2 needs a specific LLVM build since it needs to be linked to libc++
# and the headers to access the parser.

class LlvmForMozart2 < Formula
  homepage 'http://llvm.org/'
  url 'http://llvm.org/releases/3.3/llvm-3.3.src.tar.gz'
  sha1 'c6c22d5593419e3cb47cbcf16d967640e5cce133'

  resource 'clang' do
    url 'http://llvm.org/releases/3.3/cfe-3.3.src.tar.gz'
    sha1 'ccd6dbf2cdb1189a028b70bcb8a22509c25c74c8'
  end

  depends_on 'cmake' => :build

  keg_only :provided_by_osx

  def install
    (buildpath/"tools/clang").install resource("clang")

    cmake_args = std_cmake_args.dup

    # removes default -DCMAKE_BUILD_TYPE=None
    cmake_args.reject! { |arg| /^-DCMAKE_BUILD_TYPE=/ === arg }
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"

    # Set flags to use libc++ and C++0x headers
    cmake_args << "-DCMAKE_CXX_FLAGS=-stdlib=libc++"

    cmake_args << "-DLLVM_TARGETS_TO_BUILD=X86" # try to speed up compilation

    mkdir 'build'
    cd 'build' do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/clang", "--version"
  end
end
