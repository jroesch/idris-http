module Main

import Effects
import Effect.StdIO
import Lightyear.Core
import Lightyear.Combinators
import Lightyear.Strings
import IdrisNet.TCP.TCPClient
import Parser

data Method = GET

instance Eq Method where
    GET == GET = True

instance Show Method where
    show GET = "GET"

data URI = MkURI String

instance Show URI where
    show (MkURI p) = p

data RequestLine = MkRequestLine Method URI

data MessageBody = Body

data Request = MkRequest RequestLine {- header CRLF -} MessageBody

methodParser : Parser Method
methodParser = (const GET `map` string "GET")

requestParser : Parser Request
requestParser = do
    method <- methodParser
    let requestLine = MkRequestLine method (MkURI "/")
    return $ MkRequest requestLine Body

parseRequest : String -> Result String Request
parseRequest str = 
    case execParserT requestParser str of
        Id v => v

render : Request -> String
render (MkRequest rl body) =
    let MkRequestLine method uri = rl
        in (show method) ++ " " ++ (show uri) ++ " HTTP/1.1" ++ "\r\n"

getRequest : String -> Request
getRequest uri = MkRequest (MkRequestLine GET (MkURI uri)) Body

-- only for now
partial
body : { [TCPCLIENT (), STDIO] ==> [TCPCLIENT (), STDIO]} Eff IO () 
body = do
    connectResult <- tcpConnect (Hostname "www.google.com") 80
    case connectResult of
        OperationSuccess sock => do
            writeRes <- tcpSend (render ?request)               
            case writeRes of
                OperationSuccess _ =>
                    ?tcpRecv 
        RecoverableError _ => ?yum
        ConnectionClosed => ?feh
        FataError => ?bleh
           --putStrLn "sock" -- >>= \_ => tcpSend "a" >>= \_ => 
           -- dat <- tcpSend "bleh"
           -- putStrLn "meh"
           -- tcpClose
            -- tcpRecv (render $ getRequest "/")
        -- RecoverableError _ =>  -- putStrLn "err"
        -- ConnectionClosed => ?bah -- putStrLn "conn"
        -- FatalError _ => ?meh -- putStrLn "fatal"

main : IO ()
main = run body

