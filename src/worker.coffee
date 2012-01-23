class GOLWTWorker
    constructor: ()->
        self.onmessage = (e) =>
            msg = e.data #JSON.parse(e.data)
            @work(msg["grid"], msg["index"], msg["step"])

    work: (grid, index, step)->
        changed = {}
        for x in [index...100] by step
            for y in [0...50]
                key = "#{x}_#{y}"

                nb_alive = 0
                for nbkey in grid[key]["neighbours"]
                    nb_alive += grid[nbkey]["value"]

                if grid[key]["value"]
                    if nb_alive < 2 or nb_alive > 3
                        changed[key] = 0
                else
                    if nb_alive == 3
                        changed[key] = 1

        postMessage(changed) #JSON.stringify(changed))


worker = new GOLWTWorker()