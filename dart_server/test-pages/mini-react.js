

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

  // Symbols react uses, without react. prefix
  const _symbols = (exports, require) => {
    exports.element = Symbol.for("element");
    exports.portal = Symbol.for("portal");
    exports.fragment = Symbol.for("fragment");
    exports.strict_mode = Symbol.for("strict_mode");
    exports.profiler = Symbol.for("profiler");
    exports.provider = Symbol.for("provider");
    exports.context = Symbol.for("context");
    exports.forward_ref = Symbol.for("forward_ref");
    exports.suspense = Symbol.for("suspense");
    exports.memo = Symbol.for("memo");
    exports.lazy = Symbol.for("lazy");
  };

  // -------- Elements module --------
  const _elements = (exports, require) => {
    const { element, fragment } = require("symbols");
    const elementSymbol = element;
    const createElement = (type, config = {}, ...children) => {
      // normalize the key and ref to null if not defined
      config = __nullCoalesce(config, {});
      let key = __nullCoalesce(config.key, null);
      let ref = __nullCoalesce(config.ref, null);
      const props = {};

      for (const prop in config) {
        if (prop !== "key" && prop !== "ref") {
          props[prop] = config[prop];
        }
      }

      if (typeof children !== "undefined") {
        props.children = children;
      }

      if (typeof props.children !== "object") {
        props.children = []
      }

      // assign null to ref.current if its available
      if (typeof ref === "object" && ref !== null) {
        ref.current = null;
      }

      const element = {
        $$typeof: elementSymbol,
        key,
        ref,
        props,
        type
      }

      return element;
    };

    exports.createElement = createElement;
    exports.Fragment = fragment;
    // since React.createFragment is an addon, we dont export it
  };

  const _miniReactReconciler = (exports, require) => {
    const WorkTag = {
      FunctionComponent: 0,
      ClassComponent: 1,
      HostRoot: 3,
      HostPortal: 4,
      HostComponent: 5,
      HostText: 6,
      Fragment: 7,
      Mode: 8,
      ContextConsumer: 9,
      ContextProvider: 10,
      ForwardRef: 11,
      Profiler: 12,
      SuspenseComponent: 13,
      MemoComponent: 14,
      SimpleMemoComponent: 15,
      LazyComponent: 16,
      IncompleteClassComponent: 17,
      DehydratedFragment: 18,
      SuspenseListComponent: 19,
      ScopeComponent: 21,
      OffscreenComponent: 22,
      LegacyHiddenComponent: 23,
      CacheComponent: 24,
      TracingMarkerComponent: 25,
      HostHoistable: 26,
      HostSingleton: 27,
      IncompleteFunctionComponent: 28,
      Throw: 29,
      ViewTransitionComponent: 30,
      ActivityComponent: 31,
    };

    

    function beginWork(){}

    /**
     * Reconciles children,
     * do note that this is a minimal implementation so it may break
     */
    function reconcileChildren(root){

    }

    exports.WorkTag = WorkTag;

  }

  const _miniReactDom = (exports, require) => {
    // TODO: implement after mini-react-fiber
  }

  // -------- Index module --------
  const _index = (exports, require) => {
    Object.assign(exports, require("react-mini-element"));
  };

  // -------- Setup --------
  const mmap = {
    index: _index,
    "react-mini-element": _elements,
    symbols: _symbols
  };

  const require = __createRequire(mmap);

  globalThis.React = require("index"); // mimic react UMD global
  globalThis.globalRequire = require;
})()