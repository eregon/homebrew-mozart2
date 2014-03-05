require 'formula'

# Mozart 2 needs a specific LLVM build since it needs to be linked to libc++
# and the headers to access the parser.

class ClangForMozart2 < Formula
  homepage  'http://llvm.org/'
  url       'http://llvm.org/releases/3.2/clang-3.2.src.tar.gz'
  sha1      'b0515298c4088aa294edc08806bd671f8819f870'
end

class LlvmForMozart2 < Formula
  homepage 'http://llvm.org/'
  url 'http://llvm.org/releases/3.2/llvm-3.2.src.tar.gz'
  sha1 '42d139ab4c9f0c539c60f5ac07486e9d30fc1280'

  depends_on 'cmake' => :build

  keg_only :provided_by_osx

  def install
    ClangForMozart2.new("clang_for_mozart2").brew do
      (buildpath/'tools/clang').install Dir['*']
    end

    cmake_args = std_cmake_args.dup

    # removes default -DCMAKE_BUILD_TYPE=None
    cmake_args.reject! { |arg| /^-DCMAKE_BUILD_TYPE=/ === arg }
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"

    # Set flags to use libc++ and C++0x headers
    cpp_headers_dir = if MacOS.version >= :mavericks
      "/Library/Developer/CommandLineTools/usr/lib/c++/v1"
    elsif MacOS.version >= :lion
      "/usr/lib/c++/v1"
    else
      raise "No known C++0x headers in this OS X version: #{MacOS.version}"
    end
    cmake_args << "-DCMAKE_CXX_FLAGS=-stdlib=libc++ -I#{cpp_headers_dir}"

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
