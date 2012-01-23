class GOLWTWorker
    constructor: ()->
        # bind messaging
        self.onmessage = (e) =>
            msg = JSON.parse(e.data)
            @work(msg["grid"], msg["index"], msg["step"])

    work: (grid, index, step)->
        # step through the assigned columns for this worker
        changed = {}
        for x in [index...50] by step
            for y in [0...50]
                key = "#{x}_#{y}"

                # count neighbours
                nb_alive = 0
                for nbkey in grid[key]["neighbours"]
                    nb_alive += grid[nbkey]["value"]

                # the famous GOL rules at work
                if grid[key]["value"]
                    if nb_alive < 2 or nb_alive > 3
                        changed[key] = 0
                else
                    if nb_alive == 3
                        changed[key] = 1

        # return only the changed cells
        postMessage(JSON.stringify(changed))

# instanciate!
worker = new GOLWTWorker()