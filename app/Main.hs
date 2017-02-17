{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TemplateHaskell   #-}
module Main where
import           Data.Monoid                        ((<>))
import           Network.Wai.Auth.Executable
import           Network.Wai.Handler.Warp           (run)
import           Network.Wai.Middleware.Auth
import           Network.Wai.Middleware.Auth.Github
import           Network.Wai.Middleware.Auth.OAuth2
import           Options.Applicative.Simple


data BasicOptions = BasicOptions
    { configFile :: FilePath
    }
    deriving Show

basicSettingsParser :: Parser BasicOptions
basicSettingsParser =
  BasicOptions <$>
  strOption
    (long "config-file" <>
     short 'c' <>
     metavar "CONFIG" <>
     help "File with configuration for the Auth application.")


main :: IO ()
main = do
  (BasicOptions {..}, ()) <-
    simpleOptions
      $(simpleVersion waiMiddlewareAuthVersion)
      "wai-auth - Authentication server"
      "Run a protected file server or reverse proxy."
      basicSettingsParser
      empty
  authConfig <- readAuthConfig configFile
  let run' port app = do
        putStrLn $ "Listening on port " ++ show port
        run port app
  mkMain authConfig [oAuth2Parser, githubParser] run'

