{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_aulahaskell (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/stephano/projects/bd-haskell-yesod/.stack-work/install/x86_64-linux-tinfo6/b8aa1a1cc0034c39c27449350bb87f501db377f0c34b8e3a5a877a13fa5b9d93/8.8.4/bin"
libdir     = "/home/stephano/projects/bd-haskell-yesod/.stack-work/install/x86_64-linux-tinfo6/b8aa1a1cc0034c39c27449350bb87f501db377f0c34b8e3a5a877a13fa5b9d93/8.8.4/lib/x86_64-linux-ghc-8.8.4/aulahaskell-0.0.0-AsgJl5bkAqyFSrf5CVLZ84"
dynlibdir  = "/home/stephano/projects/bd-haskell-yesod/.stack-work/install/x86_64-linux-tinfo6/b8aa1a1cc0034c39c27449350bb87f501db377f0c34b8e3a5a877a13fa5b9d93/8.8.4/lib/x86_64-linux-ghc-8.8.4"
datadir    = "/home/stephano/projects/bd-haskell-yesod/.stack-work/install/x86_64-linux-tinfo6/b8aa1a1cc0034c39c27449350bb87f501db377f0c34b8e3a5a877a13fa5b9d93/8.8.4/share/x86_64-linux-ghc-8.8.4/aulahaskell-0.0.0"
libexecdir = "/home/stephano/projects/bd-haskell-yesod/.stack-work/install/x86_64-linux-tinfo6/b8aa1a1cc0034c39c27449350bb87f501db377f0c34b8e3a5a877a13fa5b9d93/8.8.4/libexec/x86_64-linux-ghc-8.8.4/aulahaskell-0.0.0"
sysconfdir = "/home/stephano/projects/bd-haskell-yesod/.stack-work/install/x86_64-linux-tinfo6/b8aa1a1cc0034c39c27449350bb87f501db377f0c34b8e3a5a877a13fa5b9d93/8.8.4/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "aulahaskell_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "aulahaskell_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "aulahaskell_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "aulahaskell_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "aulahaskell_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "aulahaskell_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
