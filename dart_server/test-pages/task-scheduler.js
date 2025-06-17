// A mini task scheduler for javascript



(() => {
    const _create = Object.create;
    const _assign = Object.assign;

    const __importDefault = mod => mod.default ? mod.default : mod;
    const __nullCoalesce = (l, r) => (l === null || l === undefined) ? r : l;

    // -------- Minimal require() system --------
    const __createRequire = mmap => {
        const __require = mod => {
            if (__require.cache[mod]) {
                return __require.cache[mod];
            }

            const _exports = {};
            mmap[mod](_exports, __require);
            __require.cache[mod] = _exports;
            return _exports;
        };

        __require.cache = {};
        return __require;
    };

    // -------- Custom Error Class --------
    class InvocationError extends Error {
        constructor(message) {
            super(message);
            this.name = this.constructor.name;
        }
    }

    const _index = (exports, require) => {
        // a Work
        // Work([...], argv) iterating through Work continues the work
        // note that after the final step, the output is directly returned
        async function* Work(steps, input) {
            let result = input;
            for (let i = 0; i < steps.length; i++) {
                let step = steps[i];
                result = await step(result);
                yield true;
            }

            return result;
        }

        class WorkScheduler {
            // public tasks;
            // private working;
            constructor() {
                this.tasks = [];
                this.working = false;
            }

            begin(pollingInterval, strategy, qt) {
                const worker = async () => {
                    const key = strategy.toLowerCase() === "fifo" ? "shift" : "pop";
                    this.working = true;

                    while (this.working) {
                        const task = this.tasks[key]();

                        if (typeof task === "undefined") {
                            await new Promise(r => setTimeout(r, pollingInterval));
                            continue;
                        }

                        const startTime = performance.now();
                        while (this.working && !(await task.next()).done) {
                            const now = performance.now();
                            if (now - startTime > qt) {
                                this.tasks.push(task); // requeue
                                break;
                            }
                        }

                        await new Promise(r => setTimeout(r, 0));
                    }
                };

                worker(); // start the worker directly
            }


            end() {
                this.working = false;
            }
            addWork(work) {
                return this.tasks.push(work);
            }
        }

        exports.Work = Work;
        exports.WorkScheduler = WorkScheduler;
    }

    const modules = {
        index: _index
    };
    const require = __createRequire(modules);

    // inject module namespace into globalThis
    globalThis.TaskScheduler = require("index");
})()