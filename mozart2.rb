require 'formula'

class Mozart2 < Formula
  homepage 'https://github.com/mozart/mozart2'
  # head 'https://github.com/mozart/mozart2.git' # TODO
  head 'https://github.com/eregon/mozart2.git', :branch => 'osx'

  depends_on 'cmake' => :build
  depends_on 'boost' => 'c++11'
  depends_on 'emacs'
  depends_on 'llvm_for_mozart2'
  depends_on :x11 # Tcl/Tk

  def install
    cmake_args = std_cmake_args.dup

    # removes default -DCMAKE_BUILD_TYPE=None
    cmake_args.reject! { |arg| /^-DCMAKE_BUILD_TYPE=/ === arg }
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"

    emacs_prefix = Formula.factory('emacs').opt_prefix
    llvm_prefix = Formula.factory('llvm_for_mozart2').opt_prefix

    cmake_args << "-DEMACS=#{emacs_prefix}/bin/emacs"

    cmake_args << "-DCMAKE_C_COMPILER=clang"
    cmake_args << "-DCMAKE_CXX_COMPILER=clang++"

    cmake_args << "-DLLVM_SRC_DIR=#{llvm_prefix}"
    cmake_args << "-DLLVM_BUILD_DIR=#{llvm_prefix}"

    # Set flags to use libc++ and C++0x headers
    cpp_headers_dir = if MacOS.version >= :mavericks
      "/Library/Developer/CommandLineTools/usr/lib/c++/v1"
    elsif MacOS.version >= :lion
      "/usr/lib/c++/v1"
    else
      raise "No known C++0x headers in this OS X version: #{MacOS.version}"
    end
    cmake_args << "-DCMAKE_CXX_FLAGS=-stdlib=libc++ -I#{cpp_headers_dir}"

    p cmake_args # FIXME: remove

    mkdir 'build'
    cd 'build' do
      system "cmake", "..", *cmake_args
      system "make", "install"

      # copy vmtest for testing purposes
      test = prefix/"test"
      test.mkdir
      test.install "vm/vm/test/vmtest"
    end
  end

  test do
    puts `#{prefix}/test/vmtest`
  end
end
