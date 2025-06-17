// since the .jsx is for react, and... my mini-react thing is not working right now...

const root = document.getElementById("root");

function clicker(){
  const btn = document.createElement("button");

  // create the "state" object, in react, this is just a useState()[0]

  const state = {
    _count: 0,
    get count () {
      return this._count;
    },
    set count (val){
      btn.innerText = "Count:" + val;
      this._count = val;
    }
  }

  btn.addEventListener("click", function(){
    // update
    state.count += 1; // syntactic sugar/shorthand for state.count = state.count + 1
  })

  // set initial
  state.count = 0;

  return btn;
}

function reloader(){
  const btn = document.createElement("button");
  btn.addEventListener("click", function(){
    window.location.reload();
  })

  btn.innerText = "Reload";
  btn.style.marginLeft = "3px"; // shift 3px to the left
  btn.style.marginBottom = "3px";
  return btn;
}

root.appendChild(clicker());
root.appendChild(reloader());