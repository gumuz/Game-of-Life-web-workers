class GOLWT
    constructor: (element_id)->
        # create canvas element and add it to the container
        element = document.getElementById(element_id)
        canvas = document.createElement("canvas")
        canvas.setAttribute("width", "500px")
        canvas.setAttribute("height", "250px")
        element.appendChild(canvas)
        @ctx = canvas.getContext("2d")

        # set up workers
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
        for x in [0...100]
            for y in [0...50]
                key = "#{x}_#{y}"
#                value = 0
                value = parseInt(Math.random()*10)%2 # randomize screen

                @grid[key] = {
                    "value": value,
                    "age": 0,
                    "neighbours": []
                }

                # pre-calculate neighbour keys
                for nx in [-1..1]
                    for ny in [-1..1]
                        if ny==0 and nx == 0
                            continue

                        # calculate neighbours, in toroidal fashion
                        nbx = x + nx
                        if nbx == -1
                            nbx = 99
                        if nbx == 100
                            nbx = 0

                        nby = y + ny
                        if nby == -1
                            nby = 49
                        if nby == 50
                            nby = 0

                        @grid[key]["neighbours"].push("#{nbx}_#{nby}")
        @tmp_grid = @copy_grid(@grid)


    copy_grid: (grid)->
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
#        message_data = JSON.stringify(message_data)
        @workers[worker_id].postMessage(message_data)

    receive_message: (data)->
        msg = data #JSON.parse(data)

        for key, value of msg
            @tmp_grid[key]["value"] = value

        @jobs_running--

    run: () ->
        if @jobs_running == 0
            # draw
            @ctx.clearRect(0, 0, 500, 250)

            @grid = @copy_grid(@tmp_grid)
            for key, cell of @grid
                if cell["value"]
                    [x,y] = key.split("_")
                    @ctx.fillRect(x*5, y*5, 5, 5)


            # wakeup workers
            @jobs_running = @nr_of_workers

            for worker_id in [0...@nr_of_workers]
                @send_message(worker_id, {
                    "index": worker_id,
                    "step": @nr_of_workers,
                    "grid": @grid
                })

        window.webkitRequestAnimationFrame(=>
            @run()
        )

# export class
window.GOLWT = GOLWT