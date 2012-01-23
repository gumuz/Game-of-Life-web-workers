class GOLWT
    ###
    Game of Life
    ###
    constructor: (element_id)->
        # create canvas element and add it to the container
        element = document.getElementById(element_id)
        canvas = document.createElement("canvas")
        canvas.setAttribute("width", "250px")
        canvas.setAttribute("height", "250px")
        element.appendChild(canvas)
        @ctx = canvas.getContext("2d")

        # set up workers
        @timestamp = new Date().getTime()
        @jobs_running = 0
        @nr_of_workers = 1
        @workers = []

        for i in [0...@nr_of_workers]
            worker = new Worker('/src/js/worker.js')
            worker.onmessage = (e) =>
                @receive_message(e.data)
            @workers.push(worker)

        # set up grid
        @grid = {}
        for x in [0...50]
            for y in [0...50]
                key = "#{x}_#{y}"
                # randomize screen
                value = parseInt(Math.random()*10)%2

                @grid[key] = {
                    "value": value,
                    "age": 0,
                    "neighbours": []
                }

                # pre-calculate neighbour keys in toroidal fashion
                for nx in [-1..1]
                    for ny in [-1..1]
                        if ny==0 and nx == 0
                            continue

                        # edge wrapping
                        nbx = x + nx
                        if nbx == -1
                            nbx = 49
                        if nbx == 50
                            nbx = 0

                        nby = y + ny
                        if nby == -1
                            nby = 49
                        if nby == 50
                            nby = 0

                        @grid[key]["neighbours"].push("#{nbx}_#{nby}")
        @tmp_grid = @copy_grid(@grid)

    copy_grid: (grid)->
        # copies a grid
        result = {}
        for key, cell of grid
            result[key] = {
                "value": cell["value"],
                "age": cell["age"],
                "neighbours": cell["neighbours"]
            }
        return result


    send_message: (worker_id, message_data)->
        # stringify since some browser only support string passing
        message_data = JSON.stringify(message_data)
        @workers[worker_id].postMessage(message_data)

    receive_message: (data)->
        # parse json into object
        msg = JSON.parse(data)

        # set changed values in temporary grid
        for key, value of msg
            @tmp_grid[key]["value"] = value

        @jobs_running--

    run: () ->
        # main loop
        if @jobs_running == 0
            # collect & calculate framerate data
            now = new Date().getTime()
            fps = parseInt(1000/(now-@timestamp))
            @timestamp = now

            # draw canvas when all jobs have finished
            @ctx.clearRect(0, 0, 250, 250)

            # draw grid
            @ctx.fillStyle = "rgb(0,0,0)"
            @grid = @copy_grid(@tmp_grid)
            for key, cell of @grid
                if cell["value"]
                    [x,y] = key.split("_")
                    @ctx.fillRect(x*5, y*5, 5, 5)

            # draw fps
            @ctx.fillStyle = "rgb(0,0,0)"
            @ctx.fillRect(10, 10, 40, 25)
            @ctx.fillStyle = "rgb(200,200,200)"
            @ctx.fillRect(13, 13, 34, 19)
            @ctx.strokeStyle =  "rgb(0,0,0)"
            @ctx.strokeText(fps+" fps", 15, 25)


            # wakeup workers for another round of calculating
            @jobs_running = @nr_of_workers

            for worker_id in [0...@nr_of_workers]
                @send_message(worker_id, {
                    "index": worker_id,
                    "step": @nr_of_workers,
                    "grid": @grid
                })

        # schedule next run when browser is free
        window.webkitRequestAnimationFrame(=>
            @run()
        )

# export class to global
window.GOLWT = GOLWT