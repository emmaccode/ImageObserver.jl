using Pkg; Pkg.activate(".")
using Toolips
using Revise
using ImageObserver

IP = "127.0.0.1"
PORT = 8000
ImageObserverServer = ImageObserver.start(IP, PORT)
