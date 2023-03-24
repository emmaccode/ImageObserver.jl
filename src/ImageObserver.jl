module ImageObserver
using Toolips
using ToolipsSession
using ToolipsDefaults
using ToolipsBase64
using Images
using FileIO
# welcome to your new toolips project!
"""
home(c::Connection) -> _
--------------------
The home function is served as a route inside of your server by default. To
    change this, view the start method below.
"""
function home(c::Connection)
    #== just the body, we wiil compose our page by pushing things to
    this body ==#
    bod = body("mybody")
    #=
    now we need to allocate the file names into memory
    (so they can be known by index)
    =#
    firstimages = readdir("public/first")
    secondimages = readdir("public/second")
    # i set the `images` variable here so that we can change this whenever
    #   the option box values change.
    images = firstimages
    # load the first image
    firstimg = load("public/first/" * firstimages[1])
    # transfer it into a B64 (img) Component
    image::Component{:img} = base64img("imageelement", firstimg)
    imgdiv = div("imgdiv")
    push!(imgdiv, image)
    # the folder names
    folders = ["first", "second"]
    # create the folder selector
    options = Vector{Servable}([ToolipsDefaults.option(f, text = f) for f in folders])
    dropd = ToolipsDefaults.dropdown("maindrop", options, "index" => "1",
    value = "first")
    # spawn observer (every 2 seconds)
    script!(c, "imgobserve", time = 1000) do cm::ComponentModifier
        # CM rootc components' properties are always Strings -- we need
        #   numerical index, so we must parse it.
        selected::Int64 = parse(Int64, cm[dropd]["index"])
        # we increment by one
        selected += 1
        #= we need to check if this is greater than the length of images
        =#
        if selected > length(images)
            selected = 1
        end
        # update our selection
        cm[image] = "index" => "$selected"
        # check options for folder
        selected_folder = cm[dropd]["value"]
        # and then update it.
        if selected_folder == "first"
            images = firstimages
        else
            images = secondimages
        end
        # now read the file and update the base64
        fname = images[selected]
        fpath = "public/$selected_folder/$fname"
        newimg = load(fpath)
        update_base64!(cm, image, newimg)
    end
    # push components into body and write
    push!(bod, imgdiv, dropd)
    write!(c, DOCTYPE())
    write!(c, bod)
end


secondr = route("/sec") do c::Connection
    maintable = div("mytable")

end

fourofour = route("404") do c
    write!(c, p("404message", text = "404, not found!"))
end

routes = [route("/", home), fourofour]
extensions = Vector{ServerExtension}([Logger(), Files(), Session(), ])
"""
start(IP::String, PORT::Integer, ) -> ::ToolipsServer
--------------------
The start function starts the WebServer.
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000)
     ws = WebServer(IP, PORT, routes = routes, extensions = extensions)
     ws.start(); ws
end
end # - module
